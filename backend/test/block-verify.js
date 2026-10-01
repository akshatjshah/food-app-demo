// Verifies blocked users are rejected server-side, then removes all traces.
const BASE = 'http://localhost:3000/api/v1';
const PHONE = '+919000000002';
async function api(method, path, body, token) {
  const res = await fetch(BASE + path, {
    method,
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  const json = await res.json().catch(() => ({}));
  return { status: res.status, json };
}
(async () => {
  const admin = await api('POST', '/auth/admin-login', { email: 'admin@parabdi.com', password: 'admin123' });
  const atok = admin.json.data.access_token;
  const otpRes = await api('POST', '/auth/send-otp', { phoneNumber: PHONE });
  const code = otpRes.json.data.otp;
  if (!code) throw new Error('no dev OTP returned');
  const ver = await api('POST', '/auth/verify-otp', { phoneNumber: PHONE, otp: code });
  const ctok = ver.json.data.accessToken || ver.json.data.access_token;
  const uid = ver.json.data.user.id;
  const me1 = await api('GET', '/auth/me', null, ctok);
  console.log('unblocked /auth/me ->', me1.status);
  await api('PATCH', `/admin/customers/${uid}/block`, { isBlocked: true }, atok);
  const me2 = await api('GET', '/auth/me', null, ctok);
  console.log('blocked /auth/me ->', me2.status, JSON.stringify(me2.json).slice(0, 100));
  await api('PATCH', `/admin/customers/${uid}/block`, { isBlocked: false }, atok);
  const me3 = await api('GET', '/auth/me', null, ctok);
  console.log('unblocked /auth/me ->', me3.status);
  // cleanup: remove test user + otp leftovers
  const { PrismaClient } = require('@prisma/client');
  const p = new PrismaClient();
  await p.user.delete({ where: { id: uid } }).catch(() => {});
  await p.setting.deleteMany({ where: { key: { in: [`otp:${PHONE}`, `otp_rate:${PHONE}`] } } }).catch(() => {});
  await p.$disconnect();
  const ok = me1.status === 200 && me2.status === 401 && me3.status === 200;
  console.log(ok ? 'BLOCK ENFORCEMENT: PASS' : 'BLOCK ENFORCEMENT: FAIL');
  process.exit(ok ? 0 : 1);
})().catch((e) => { console.error(e); process.exit(2); });
