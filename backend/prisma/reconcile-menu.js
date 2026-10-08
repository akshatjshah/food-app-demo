/**
 * Parabdi menu reconciliation — READ-ONLY check.
 *
 * Compares the PDF master inventory (prisma/menu-master.js) against the
 * backend menu and reports:
 *
 *   1. Missing items (master names with no non-deleted DB row)
 *   2. Unexpected/demo items (non-deleted DB rows outside master)
 *   3. Duplicate items (same normalized name twice among non-deleted rows)
 *   4. Wrong category mappings
 *   5. Wrong variant mappings (group name / option set mismatch)
 *   6. Price-pending items (tags ['price-pending'] or technical price 0 —
 *      rows the seed created without a PDF/admin price; must be 0 and all
 *      such rows must be inactive+unavailable)
 *   7. Generic-content rows (seed-template descriptions — price unverified,
 *      non-PDF text; clear via Admin Food Edit with a real price+description)
 *
 * Checks 1–5 run on NON-DELETED rows (the admin-visible inventory), so a
 * price-pending (inactive) row still counts as present. The public customer
 * listing additionally filters isActive — reported as info.
 *
 * Exit code 0 = all seven are 0. Exit code 1 = anything to fix.
 * Safe to run any number of times; never writes to the DB.
 *
 * Run: node prisma/reconcile-menu.js
 */
'use strict';

const { PrismaClient } = require('@prisma/client');
const { FOODS, VARIANT_GROUPS, DEMO_FOOD_NAMES } = require('./menu-master');

const prisma = new PrismaClient();
const norm = (s) => String(s || '').trim().toLowerCase();

async function main() {
  const masterByName = new Map();
  for (const [name, cat, sub] of FOODS) masterByName.set(norm(name), { name, category: cat, subcategory: sub });

  const activeFoods = await prisma.foodItem.findMany({
    where: { deletedAt: null },
    select: {
      id: true,
      name: true,
      price: true,
      description: true,
      tags: true,
      isActive: true,
      isAvailable: true,
      isJainAvailable: true,
      subcategory: true,
      category: { select: { name: true } },
      customizationGroups: {
        where: { isActive: true },
        select: { name: true, items: { where: { isActive: true }, select: { name: true } } },
      },
    },
  });
  const activePublicCount = activeFoods.filter((f) => f.isActive).length;

  // 1. Missing items (in master, no non-deleted row in DB)
  const presentNames = new Set(activeFoods.map((f) => norm(f.name)));
  const missing = FOODS.filter(([name]) => !presentNames.has(norm(name))).map(([n]) => n);

  // 2. Unexpected/demo items (non-deleted in DB, not in master)
  const demoSet = new Set(DEMO_FOOD_NAMES.map(norm));
  const unexpected = activeFoods
    .filter((f) => !masterByName.has(norm(f.name)))
    .map((f) => `${f.name} [${f.category?.name || '?'}]${demoSet.has(norm(f.name)) ? ' (known demo)' : ''}`);

  // 3. Duplicate items (same normalized name twice among non-deleted rows)
  const allRows = await prisma.foodItem.findMany({
    where: { deletedAt: null },
    select: { name: true },
  });
  const counts = new Map();
  for (const r of allRows) counts.set(norm(r.name), (counts.get(norm(r.name)) || 0) + 1);
  const duplicates = [...counts.entries()].filter(([, c]) => c > 1).map(([n, c]) => `${n} x${c}`);

  // 4. Wrong category mappings
  const wrongCategory = activeFoods
    .filter((f) => {
      const m = masterByName.get(norm(f.name));
      return m && norm(f.category?.name) !== norm(m.category);
    })
    .map((f) => `${f.name}: backend=[${f.category?.name}] master=[${masterByName.get(norm(f.name)).category}]`);

  // 5. Wrong variant mappings (group name or option set mismatch, order-insensitive)
  const wrongVariants = [];
  for (const [foodName, groupName, , , opts] of VARIANT_GROUPS) {
    const food = activeFoods.find((f) => norm(f.name) === norm(foodName));
    if (!food) continue; // already counted under missing
    const group = food.customizationGroups.find((g) => norm(g.name) === norm(groupName));
    if (!group) {
      wrongVariants.push(`${foodName}: missing group [${groupName}]`);
      continue;
    }
    const want = new Set(opts.map(([o]) => norm(o)));
    const got = new Set(group.items.map((i) => norm(i.name)));
    const missingOpts = [...want].filter((o) => !got.has(o));
    const extraOpts = [...got].filter((o) => !want.has(o));
    if (missingOpts.length || extraOpts.length) {
      wrongVariants.push(`${foodName} :: ${groupName}: missing=[${missingOpts.join(', ')}] extra=[${extraOpts.join(', ')}]`);
    }
  }
  // Variant groups on master foods that are NOT in the spec (except none expected)
  const specGroups = new Set(VARIANT_GROUPS.map(([f, g]) => `${norm(f)}||${norm(g)}`));
  for (const f of activeFoods) {
    if (!masterByName.has(norm(f.name))) continue;
    for (const g of f.customizationGroups) {
      if (!specGroups.has(`${norm(f.name)}||${norm(g.name)}`)) {
        wrongVariants.push(`${f.name} :: ${g.name}: unexpected group`);
      }
    }
  }

  // 6. Price-pending items: seed-created without a PDF/admin price.
  // Must be 0 rows, and any such row must be inactive+unavailable (never
  // customer-visible). The seed no longer invents prices, so any row here is
  // either newly created (awaiting admin pricing) or legacy to fix.
  const pricePending = activeFoods.filter((f) => {
    const tags = Array.isArray(f.tags) ? f.tags.map((t) => norm(t)) : [];
    return tags.includes('price-pending') || Number(f.price) === 0;
  });
  const pricePendingExposed = pricePending.filter((f) => f.isActive || f.isAvailable);
  const pricePendingNames = pricePending.map(
    (f) => `${f.name} (price=${Number(f.price)}, active=${f.isActive}, available=${f.isAvailable})`,
  );

  // 7. Generic-content rows: seed-template descriptions ("X - authentic
  // Parabdi preparation" / "X — authentic Parabdi preparation"). The PDF
  // provides NO descriptions, so these are non-PDF text and their prices are
  // unverified seed values. Clear via Admin Food Edit (real price +
  // real description). Informational list capped at 15 names in output.
  const genericRows = activeFoods.filter((f) =>
    /authentic Parabdi preparation/.test(String(f.description || '')),
  );

  // Info only: Jain flags on master foods (master defines no Jain variants).
  const jainOnMaster = activeFoods.filter(
    (f) => masterByName.has(norm(f.name)) && f.isJainAvailable,
  ).map((f) => f.name);

  console.log('--- Parabdi menu reconciliation ---');
  console.log(`Master (PDF-transcribed) items : ${FOODS.length}`);
  console.log(`Backend items (non-deleted)    : ${activeFoods.length}`);
  console.log(`Backend items (public/active)  : ${activePublicCount}`);
  console.log(`Missing items                  : ${missing.length}${missing.length ? ' -> ' + missing.join(', ') : ''}`);
  console.log(`Unexpected/demo items          : ${unexpected.length}${unexpected.length ? ' -> ' + unexpected.join(', ') : ''}`);
  console.log(`Duplicate items                : ${duplicates.length}${duplicates.length ? ' -> ' + duplicates.join(', ') : ''}`);
  console.log(`Wrong category mappings        : ${wrongCategory.length}${wrongCategory.length ? ' -> ' + wrongCategory.join('; ') : ''}`);
  console.log(`Wrong variant mappings         : ${wrongVariants.length}${wrongVariants.length ? ' -> ' + wrongVariants.join('; ') : ''}`);
  console.log(`Price-pending items            : ${pricePending.length}${pricePending.length ? ' -> ' + pricePendingNames.join('; ') : ''}`);
  console.log(`Price-pending exposed to menu  : ${pricePendingExposed.length}`);
  console.log(`Generic-content rows           : ${genericRows.length}${genericRows.length ? ' (e.g. ' + genericRows.slice(0, 15).map((f) => f.name).join(', ') + (genericRows.length > 15 ? ` … +${genericRows.length - 15} more` : '') + ')' : ''}`);
  console.log(`Jain flag on master foods      : ${jainOnMaster.length}${jainOnMaster.length ? ' -> ' + jainOnMaster.join(', ') : ''}`);

  const pass =
    missing.length === 0 &&
    unexpected.length === 0 &&
    duplicates.length === 0 &&
    wrongCategory.length === 0 &&
    wrongVariants.length === 0 &&
    pricePending.length === 0 &&
    genericRows.length === 0;
  console.log(
    pass
      ? 'RESULT: PASS (0/0/0/0/0/0/0)'
      : 'RESULT: FAIL — ' +
        [
          missing.length ? `${missing.length} missing` : null,
          unexpected.length ? `${unexpected.length} unexpected` : null,
          duplicates.length ? `${duplicates.length} duplicate` : null,
          wrongCategory.length ? `${wrongCategory.length} wrong-category` : null,
          wrongVariants.length ? `${wrongVariants.length} wrong-variants` : null,
          pricePending.length ? `${pricePending.length} price-pending` : null,
          genericRows.length ? `${genericRows.length} generic-content (price unverified)` : null,
        ]
          .filter(Boolean)
          .join(', '),
  );

  await prisma.$disconnect();
  if (!pass) process.exitCode = 1;
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
