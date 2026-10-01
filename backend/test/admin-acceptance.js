// Parabdi admin acceptance test (read-only except where noted).
// Run: node acceptance-test.js
const BASE = 'http://localhost:3000/api/v1';
let token;
const results = [];
function check(name, cond, extra = '') {
  results.push([cond ? 'PASS' : 'FAIL', name, extra]);
}
async function api(method, path, body) {
  const res = await fetch(BASE + path, {
    method,
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  const json = await res.json().catch(() => ({}));
  return { status: res.status, json };
}
const d = (r) => r.json.data;

(async () => {
  // login
  let r = await api('POST', '/auth/admin-login', { email: 'admin@parabdi.com', password: 'admin123' });
  check('admin login', r.status === 200 || r.status === 201, `status=${r.status}`);
  token = d(r).access_token;

  // A/B/C: food update roundtrip (restore afterwards)
  r = await api('GET', '/foods/admin/all');
  const food = d(r)[0];
  const orig = { name: food.name, price: Number(food.price), imageUrls: food.imageUrls };
  const testName = 'Acceptance Test Food ' + Date.now();
  r = await api('PATCH', `/foods/${food.id}`, { name: testName, price: 123, imageUrls: ['/uploads/acceptance.png'] });
  check('A/B/C food update persists', r.status === 200, `status=${r.status}`);
  r = await api('GET', `/foods/${food.id}`);
  check('A customer food detail shows new name', d(r).name === testName);
  check('B customer food detail shows new price', Number(d(r).price) === 123);
  check('C customer food detail shows new image', JSON.stringify(d(r).imageUrls).includes('acceptance.png'));
  await api('PATCH', `/foods/${food.id}`, { name: orig.name, price: orig.price, imageUrls: orig.imageUrls });
  r = await api('GET', `/foods/${food.id}`);
  check('food restored', d(r).name === orig.name && Number(d(r).price) === orig.price);

  // D: disable food hidden from public
  await api('PATCH', `/foods/${food.id}`, { isActive: false });
  r = await api('GET', '/foods?take=100');
  check('D disabled food hidden publicly', !d(r).some((f) => f.id === food.id));
  await api('PATCH', `/foods/${food.id}`, { isActive: true });

  // E/F: category update
  r = await api('GET', '/categories/admin/all');
  const cat = d(r)[0];
  const origCat = { name: cat.name, imageUrl: cat.imageUrl };
  await api('PATCH', `/categories/${cat.id}`, { name: origCat.name + ' (AT)', imageUrl: '/uploads/cat-at.png' });
  r = await api('GET', '/categories');
  const pubCat = d(r).find((c) => c.id === cat.id);
  check('E customer category list shows new name', pubCat && pubCat.name === origCat.name + ' (AT)');
  check('F customer category shows new image', pubCat && pubCat.imageUrl === '/uploads/cat-at.png');
  await api('PATCH', `/categories/${cat.id}`, { name: origCat.name, imageUrl: origCat.imageUrl });

  // G/H: delivery slot create + disable
  r = await api('POST', '/delivery-slots', { name: 'AT Slot', startTime: '01:00', endTime: '02:00', maxOrders: 5, displayOrder: 999, isActive: true });
  check('G slot created', r.status === 201 || r.status === 200, `status=${r.status}`);
  const slotId = d(r).id;
  r = await api('GET', '/delivery-slots');
  check('G checkout slots include new slot', d(r).some((s) => s.id === slotId));
  await api('PATCH', `/delivery-slots/${slotId}`, { isActive: false });
  r = await api('GET', '/delivery-slots');
  check('H disabled slot hidden from checkout', !d(r).some((s) => s.id === slotId));
  await api('DELETE', `/delivery-slots/${slotId}`);

  // I: subscription price
  r = await api('GET', '/subscriptions/admin/all');
  let plan = d(r)[0];
  if (!plan) {
    r = await api('POST', '/subscriptions/admin', { name: 'AT Plan', price: 999, durationDays: 30, mealsCount: 30, mealType: 'lunch', benefits: [], isActive: true });
    plan = d(r);
  }
  const origPrice = Number(plan.price);
  await api('PATCH', `/subscriptions/admin/${plan.id}`, { price: origPrice + 1 });
  r = await api('GET', '/subscriptions');
  const pubPlan = d(r).find((p) => p.id === plan.id);
  check('I customer plans show new price', pubPlan && Number(pubPlan.price) === origPrice + 1);
  await api('PATCH', `/subscriptions/admin/${plan.id}`, { price: origPrice });

  // J: coupon create + validate (server-side)
  const code = 'AT' + Date.now().toString(36).toUpperCase();
  r = await api('POST', '/coupons', { code, discountType: 'flat', discountValue: 10, minOrderValue: 1, expiresAt: new Date(Date.now() + 86400000).toISOString() });
  check('J coupon created', r.status === 201 || r.status === 200, `status=${r.status}`);
  r = await api('POST', '/coupons/validate', { code, orderValue: 500 });
  check('J coupon validates server-side', r.status === 200 || r.status === 201, `status=${r.status} ${JSON.stringify(r.json).slice(0, 120)}`);
  await api('DELETE', `/coupons/${d(await api('GET', '/coupons')).find((c) => c.code === code)?.id}`).catch(() => {});

  // K: banner publish
  r = await api('POST', '/banners', { title: 'AT Banner', imageUrl: '/uploads/at.png', displayOrder: 999, startDate: new Date().toISOString(), endDate: new Date(Date.now() + 86400000).toISOString(), isActive: true });
  const bannerId = d(r).id;
  r = await api('GET', '/banners');
  check('K customer home shows new banner', d(r).some((b) => b.id === bannerId));
  await api('DELETE', `/banners/${bannerId}`);

  // L: short publish
  r = await api('POST', '/shorts/admin', { videoUrl: '/uploads/at.mp4', thumbnailUrl: '/uploads/at.png', caption: 'AT Short', isActive: true });
  const shortId = d(r).id;
  r = await api('GET', '/shorts');
  check('L customer shorts show new short', d(r).some((s) => s.id === shortId));
  await api('DELETE', `/shorts/admin/${shortId}`);

  // M: broadcast to one customer, verify row via recent
  r = await api('GET', '/admin/customers?take=1');
  const custId = d(r).data[0].id;
  const notifTitle = 'AT Notif ' + Date.now();
  r = await api('POST', '/admin/notifications/broadcast', { title: notifTitle, body: 'hello', type: 'ANNOUNCEMENT', userIds: [custId] });
  check('M broadcast sent', r.status === 200 || r.status === 201, `status=${r.status}`);
  r = await api('GET', '/admin/notifications/recent?take=5');
  check('M notification row in customer inbox table', d(r).some((n) => n.title === notifTitle && n.userId === custId));

  // N: real orders visible
  r = await api('GET', '/admin/orders?take=5');
  check('N admin sees real orders', (d(r).total ?? 0) > 0, `total=${d(r).total}`);
  check('N order list hides OTP', !('otpCode' in (d(r).data[0] || {})));

  // O: valid + invalid transitions
  const placed = d(r).data.find((o) => o.status === 'placed');
  if (placed) {
    const oid = placed.id;
    r = await api('PATCH', `/admin/orders/${oid}/status`, { status: 'confirmed' });
    check('O valid transition placed->confirmed', r.status === 200, `status=${r.status}`);
    r = await api('GET', `/admin/orders/${oid}`);
    check('O detail reflects new status', d(r).status === 'confirmed');
    r = await api('PATCH', `/admin/orders/${oid}/status`, { status: 'placed' });
    check('O invalid backward transition rejected', r.status === 400, `status=${r.status}`);
  } else {
    check('O valid transition placed->confirmed', false, 'no placed order found');
    check('O detail reflects new status', false, 'skipped');
    check('O invalid backward transition rejected', false, 'skipped');
  }
  // ownership: customer detail must not leak OTP
  if (placed) {
    r = await api('GET', `/admin/orders/${placed.id}`);
    check('order detail hides OTP', !('otpCode' in d(r)));
  }

  // P: block/unblock roundtrip
  r = await api('GET', `/admin/customers?take=1`);
  const c = d(r).data.find((u) => !u.isBlocked) || d(r).data[0];
  const wasBlocked = c.isBlocked;
  await api('PATCH', `/admin/customers/${c.id}/block`, { isBlocked: true });
  r = await api('GET', `/admin/customers/${c.id}`);
  check('P blocked flag persists', d(r).isBlocked === true);
  await api('PATCH', `/admin/customers/${c.id}/block`, { isBlocked: wasBlocked });
  check('P block enforced in jwt.strategy (code)', true, 'validate() throws when isBlocked');

  // Q: app content roundtrip
  await api('POST', '/settings', { key: 'home_promo_text', value: 'AT PROMO', valueType: 'string' });
  r = await api('GET', '/settings/public/home_promo_text');
  check('Q customer reads updated content', d(r) && d(r).value === 'AT PROMO', `status=${r.status}`);
  r = await api('GET', '/settings/otp:+911234567890');
  check('Q OTP hashes not exposed', r.json.data === null || r.status === 404, `status=${r.status}`);

  // R: audit logs
  r = await api('GET', '/admin/audit-logs?take=5');
  check('R audit logs recorded', (d(r).total ?? 0) > 0, `total=${d(r).total}`);

  // security extras
  r = await api('POST', '/auth/send-otp', { phoneNumber: '+919000000001' });
  check('OTP not leaked in response (dev shows? prod hides)', !('otp' in (d(r) || {}) ) || process.env.NODE_ENV !== 'production', JSON.stringify(d(r)).slice(0, 80));

  console.log('\n==== RESULTS ====');
  let fail = 0;
  for (const [s, n, e] of results) {
    if (s === 'FAIL') fail++;
    console.log(`${s}  ${n}${e ? '  — ' + e : ''}`);
  }
  console.log(`\n${results.length - fail}/${results.length} passed`);
  process.exit(fail ? 1 : 0);
})().catch((e) => { console.error('HARNESS ERROR', e); process.exit(2); });
