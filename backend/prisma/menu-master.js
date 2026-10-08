/**
 * Parabdi PDF master inventory — SINGLE transcription source.
 *
 * Transcribed bullet-by-bullet from menu_document/Parabdi_Final_Organized_Menu.pdf
 * (exact PDF names and sections; nothing invented, no Jain yet). Required by both
 * seed-parabdi-menu.js (writes it to the DB) and reconcile-menu.js (checks
 * the DB against it). The DATABASE remains the one canonical backend menu
 * source at runtime — admin + customer app both read it via the API.
 *
 * Tuple: [name, category, subcategory, mealTags, extra?]
 * extra = { fasting: true } marks farari (fasting) foods.
 *
 * The PDF specifies NO prices and NO descriptions, so this file carries
 * NEITHER. The seed never writes a business price: existing rows keep their
 * database price untouched, and genuinely-new rows are created price-pending
 * (technical price 0 + isActive=false + isAvailable=false + 'price-pending'
 * tag + NULL description) so no invented price is ever customer-visible.
 * Real prices are set exclusively via Admin Food Edit (which rejects price
 * <= 0). New rows get NULL description — the PDF provides none.
 *
 * Transcription notes (PDF ambiguities, resolved once here):
 * - "Valor Papdi / Valor Dal" (§2) = two distinct preparations -> two items.
 * - "Bafvada" appears in BOTH §3 Visarati and §5 Snacks -> ONE canonical
 *   item, homed in Snacks & Beverages.
 * - "Rajagra / Singora Siro" (§3) = one siro preparation -> one exact-name item.
 * - "Tandarja ni Bhaji ane Keri nu Shaak" (§2) = one bullet -> one exact-name item.
 * - "Besan ni Sabji - Gisyo (...)" (§2) keeps canonical name "Besan ni Sabji";
 *   the Gisyo varieties are its 4-option variant group (see VARIANT_GROUPS).
 * - "Aathanu (All Type)" (§3) gets NO variant split — the PDF names no types.
 */
'use strict';

const CATEGORIES = [
  { name: 'Breakfast', icon: '🥞', displayOrder: 1, description: 'Breakfast & morning favourites' },
  { name: 'Shaak & Gujarati Main Dishes', icon: '🍲', displayOrder: 2, description: 'Vegetable / Shaak · Dal / Kadhi / Main preparations' },
  { name: 'Rice & Khichdi', icon: '🍚', displayOrder: 3, description: 'Rice & Khichdi' },
  { name: 'Rotli, Bhakhri & Puri', icon: '🫓', displayOrder: 4, description: 'Rotli / Bhakhri / Puri' },
  { name: 'Visarati Vangio', icon: '🥘', displayOrder: 5, description: 'Traditional / lesser-seen dishes' },
  { name: 'Sweets & Traditional Desserts', icon: '🍮', displayOrder: 6, description: 'Sweets & traditional desserts' },
  { name: 'Snacks & Beverages', icon: '🥤', displayOrder: 7, description: 'Snacks & beverages' },
];

// [name, category, subcategory, mealTags] — NO prices, NO descriptions (PDF has none).
const FOODS = [
  // ── BREAKFAST ──
  ['White Dhokla', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Khatta Dhokla', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Handvo', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Muthiya', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Patra', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Khichu', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Thepla', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Methi Thepla', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Bajra Rotla', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Makai no Chevdo', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Nylon Poha Chevdo', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Sev Mamra', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Besan Chilla', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Vegetable Sandwich', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Aloo Sandwiches', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Idli', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Uttapam', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Chakri', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Mamra', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Sabudana Bataka', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Tikhi Puri', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Farsi Puri', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Lilva Kachori', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],
  ['Aloo Paratha', 'Breakfast', 'Breakfast & Morning Favourites', ['breakfast']],

  // ── SHAAK & MAIN ──
  ['Ringana Bateta', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Ooro', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Sev Tameta', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Dudhi Chana Dal', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Dudhi Muthiya', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Kora nu Shak', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Tarelu Rataru', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Tindora Fry', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Turiya Patra', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Kobi Vatana', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Bhinda nu Shak', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Flowers Vatana', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Choli Bateta', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Tuver Lilva', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Valor Papdi', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Valor Dal', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', ['lunch', 'dinner']],
  ['Va nu Shak', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Rasavala Bateta', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Guvar Bateta', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Methi Alu', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Guju Dal', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', ['lunch', 'dinner']],
  ['Mung Dal', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', ['lunch', 'dinner']],
  ['Rajasthani Daal', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', ['lunch', 'dinner']],
  ['Besan ni Sabji', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Drum Stick Sabji', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Dal Dhokli', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', ['lunch', 'dinner']],

  // ── RICE & KHICHDI ──
  ['Steam Rice', 'Rice & Khichdi', 'Rice & Khichdi', ['lunch', 'dinner']],
  ['Jeera Rice', 'Rice & Khichdi', 'Rice & Khichdi', ['lunch', 'dinner']],
  ['Khichdi', 'Rice & Khichdi', 'Rice & Khichdi', ['lunch', 'dinner']],
  ['Vaghareli Khichdi', 'Rice & Khichdi', 'Rice & Khichdi', ['lunch', 'dinner']],
  ['Fada Khichdi', 'Rice & Khichdi', 'Rice & Khichdi', ['lunch', 'dinner']],

  // ── ROTLI / BHAKHRI / PURI ──
  ['Phulka Roti', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', ['lunch', 'dinner']],
  ['Tawa Roti', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', ['lunch', 'dinner']],
  ['Bajra Roti', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', ['lunch', 'dinner']],
  ['Makai Rotla', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', ['lunch', 'dinner']],
  ['Jowar Bhakhri', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', ['lunch', 'dinner']],
  ['Wheat Bhakhri', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', ['lunch', 'dinner']],
  ['Puri', 'Rotli, Bhakhri & Puri', 'Rotli / Bhakhri / Puri', ['lunch', 'dinner']],

  // ── SHAAK & MAIN, PDF bullets not in the earlier partial seed ──
  ['All Kathol Sabji (Single Sabji)', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Muli Baju', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Palak Mag ni Dal', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', ['lunch', 'dinner']],
  ['Palak Sabji', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Aloo Palak', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Bharela Rigna Batata', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Bhaji Pav Vadi', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Muda ni Bhaji', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Sweet Potato Sabji', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Tandarja ni Bhaji ane Keri nu Shaak', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Kankoda nu Shaak', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Chole Channa', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', ['lunch', 'dinner']],
  ['Somasa Punjabi', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', ['lunch', 'dinner']],
  ['Dal Fry', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', ['lunch', 'dinner']],
  ['Bhindani Curry', 'Shaak & Gujarati Main Dishes', 'Vegetable / Shaak', ['lunch', 'dinner']],
  ['Shilpa Special Khadi', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', ['lunch', 'dinner']],
  ['Ringan Lila Marcha ni Kadi', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', ['lunch', 'dinner']],
  ['Rajasthani Khadi', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', ['lunch', 'dinner']],
  ['Mag ni daal ni Pandoli', 'Shaak & Gujarati Main Dishes', 'Dal / Kadhi / Main Preparations', ['lunch', 'dinner']],

  // ── VISARATI VANGIO (§3 — 37 bullets; Bafvada homed in Snacks, see note) ──
  ['Panchkutiyu Shaak', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Khataa Mag', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Chorafali Shaak', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Lilva Tuvar', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Ghau ni Sev', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Vaghaero Rotlo', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Roti nu Chaas ma Shaak', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Ringna Methi', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Vagheri Rotli', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Bharela Marcha', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Desi Brown Channa nu Shaak', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Aadaj ni Daal', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Lasan ni Chatni', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Lila Channa nu Salad', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Ragda Peti', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Sevsar', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Vadapav', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Aambli ni Chatni', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Lili Chatni', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Vagerela Marcha', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Laal Marcha ni Chatni', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Aathanu (All Type)', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Katki Keri nu Kachumbar', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Murambo', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Chundo', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Farari Kadi', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner'], { fasting: true }],
  ['Tadeli Katri', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Tadeli Sing', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Sabudana ni Khicdi', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner'], { fasting: true }],
  ['Samo', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner'], { fasting: true }],
  ['Moraelo', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner'], { fasting: true }],
  ['Rajagra / Singora Siro', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner'], { fasting: true }],
  ['Suki Bhaji', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],
  ['Rajagrani Bhakri', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner'], { fasting: true }],
  ['Agiyaras nu Farar', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner'], { fasting: true }],
  ['Bajri nu Kuler', 'Visarati Vangio', 'Traditional / Lesser-seen Dishes', ['lunch', 'dinner']],

  // ── SWEETS & TRADITIONAL DESSERTS (§4 — 17 items, Chaas per PDF placement) ──
  ['Shrikhand', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Aam Ras', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Dudh Paak', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Lapsi', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Sukhdi', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Mohnthal', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Adadiya Paak (Seasonal)', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Taal ni Chki', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Sing Chiki', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Puran Poli', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Gajar no Halvo', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Khandvi', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Ladva', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Rotli nu Churmu', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Shiro', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Khir', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],
  ['Chaas', 'Sweets & Traditional Desserts', 'Sweets & Traditional Desserts', ['lunch', 'dinner']],

  // ── SNACKS & BEVERAGES (§5 — 6 items incl. canonical Bafvada) ──
  ['Lassi', 'Snacks & Beverages', 'Snacks & Beverages', ['snacks']],
  ['Daal Vada', 'Snacks & Beverages', 'Snacks & Beverages', ['snacks']],
  ['Bhajiya', 'Snacks & Beverages', 'Snacks & Beverages', ['snacks']],
  ['Bafvada', 'Snacks & Beverages', 'Snacks & Beverages', ['snacks']],
  ['Gotaa', 'Snacks & Beverages', 'Snacks & Beverages', ['snacks']],
  ['Cutless', 'Snacks & Beverages', 'Snacks & Beverages', ['snacks']],
];

// [foodName, groupName, min, max, [[option, neutralAdditionalPrice]]]
// Option deltas are ALWAYS 0 here (neutral schema default). The PDF defines
// variant SETS only — never price deltas. The seed creates missing options at
// 0 and NEVER overwrites an existing option's additionalPrice; real deltas are
// admin-managed via Food Edit / Customizations.
const VARIANT_GROUPS = [
  ['Nylon Poha Chevdo', 'Choose your type', 1, 1, [['Diet', 0], ['Regular', 0]]],
  ['Besan Chilla', 'Choose your style', 1, 1, [['Normal', 0], ['Fully Veg Loaded', 0]]],
  ['Vegetable Sandwich', 'Choose your toast', 1, 1, [['Without Toast', 0], ['Hand Toasted', 0]]],
  ['Steam Rice', 'Choose your rice', 1, 1, [['Chutta', 0], ['Chadela', 0]]],
  ['Besan ni Sabji', 'Choose your variety', 1, 1, [['Plain', 0], ['Onion', 0], ['Methi', 0], ['Ringan Vado', 0]]],
  ['Drum Stick Sabji', 'Choose your type', 1, 1, [['Type 1', 0], ['Type 2', 0]]],
  ['Dal Dhokli', 'Choose your type', 1, 1, [['Type 1', 0], ['Type 2', 0], ['Type 3', 0]]],
  ['Puri', 'Choose your puri', 1, 1, [['Yellow', 0], ['White', 0]]],
];

// Old generic/demo seed names — NOT Parabdi menu. Soft-delete only.
const DEMO_FOOD_NAMES = [
  'Gujarati Thali',
  'Punjabi Thali',
  'Rajasthani Thali',
  'Chicken Biryani',
  'Paneer Biryani',
  'Butter Naan',
  'Garlic Naan',
  'Tandoori Roti',
  'Samosa (2 pcs)',
  'Pav Bhaji',
  'Masala Dosa',
  'Idli Sambar (4 pcs)',
  'Buddha Bowl',
  'Grilled Chicken Salad',
  'Gulab Jamun (4 pcs)',
  'Rasmalai (2 pcs)',
  'Mango Lassi',
  'Masala Chai',
  'Buttermilk',
  'buttermilk',
];

const DEMO_CATEGORY_NAMES = [
  'Thali',
  'Rice & Biryani',
  'Breads',
  'bread',
  'Snacks',
  'South Indian',
  'Healthy Bowls',
  'Desserts',
  'Beverages',
];

module.exports = { CATEGORIES, FOODS, VARIANT_GROUPS, DEMO_FOOD_NAMES, DEMO_CATEGORY_NAMES };
