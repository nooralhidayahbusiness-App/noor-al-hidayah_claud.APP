/// عملات عالمية مع أسمائها بالعربية والإنجليزية.
/// مصدر الأسعار: open.er-api.com (يوفّر ~160 عملة).
class Currency {
  final String code;
  final String symbol;
  final String nameAr;
  final String nameEn;

  const Currency({
    required this.code,
    required this.symbol,
    required this.nameAr,
    required this.nameEn,
  });
}

const List<Currency> kCurrencies = [
  // ===== الخليج =====
  Currency(code: 'AED', symbol: 'د.إ', nameAr: 'درهم إماراتي', nameEn: 'UAE Dirham'),
  Currency(code: 'SAR', symbol: 'ر.س', nameAr: 'ريال سعودي', nameEn: 'Saudi Riyal'),
  Currency(code: 'QAR', symbol: 'ر.ق', nameAr: 'ريال قطري', nameEn: 'Qatari Riyal'),
  Currency(code: 'KWD', symbol: 'د.ك', nameAr: 'دينار كويتي', nameEn: 'Kuwaiti Dinar'),
  Currency(code: 'BHD', symbol: '.د.ب', nameAr: 'دينار بحريني', nameEn: 'Bahraini Dinar'),
  Currency(code: 'OMR', symbol: 'ر.ع', nameAr: 'ريال عماني', nameEn: 'Omani Rial'),
  Currency(code: 'YER', symbol: 'ر.ي', nameAr: 'ريال يمني', nameEn: 'Yemeni Rial'),
  Currency(code: 'IQD', symbol: 'ع.د', nameAr: 'دينار عراقي', nameEn: 'Iraqi Dinar'),

  // ===== الشام ومصر =====
  Currency(code: 'EGP', symbol: 'ج.م', nameAr: 'جنيه مصري', nameEn: 'Egyptian Pound'),
  Currency(code: 'JOD', symbol: 'د.أ', nameAr: 'دينار أردني', nameEn: 'Jordanian Dinar'),
  Currency(code: 'LBP', symbol: 'ل.ل', nameAr: 'ليرة لبنانية', nameEn: 'Lebanese Pound'),
  Currency(code: 'SYP', symbol: 'ل.س', nameAr: 'ليرة سورية', nameEn: 'Syrian Pound'),
  Currency(code: 'ILS', symbol: '₪', nameAr: 'شيكل', nameEn: 'Israeli Shekel'),

  // ===== شمال إفريقيا =====
  Currency(code: 'MAD', symbol: 'د.م', nameAr: 'درهم مغربي', nameEn: 'Moroccan Dirham'),
  Currency(code: 'DZD', symbol: 'د.ج', nameAr: 'دينار جزائري', nameEn: 'Algerian Dinar'),
  Currency(code: 'TND', symbol: 'د.ت', nameAr: 'دينار تونسي', nameEn: 'Tunisian Dinar'),
  Currency(code: 'LYD', symbol: 'د.ل', nameAr: 'دينار ليبي', nameEn: 'Libyan Dinar'),
  Currency(code: 'SDG', symbol: 'ج.س', nameAr: 'جنيه سوداني', nameEn: 'Sudanese Pound'),
  Currency(code: 'MRU', symbol: 'أ.م', nameAr: 'أوقية موريتانية', nameEn: 'Mauritanian Ouguiya'),

  // ===== أفريقيا =====
  Currency(code: 'NGN', symbol: '₦', nameAr: 'نايرا نيجيري', nameEn: 'Nigerian Naira'),
  Currency(code: 'KES', symbol: 'KSh', nameAr: 'شلن كيني', nameEn: 'Kenyan Shilling'),
  Currency(code: 'ZAR', symbol: 'R', nameAr: 'راند جنوب أفريقي', nameEn: 'South African Rand'),
  Currency(code: 'ETB', symbol: 'Br', nameAr: 'بير إثيوبي', nameEn: 'Ethiopian Birr'),
  Currency(code: 'GHS', symbol: '₵', nameAr: 'سيدي غاني', nameEn: 'Ghanaian Cedi'),
  Currency(code: 'TZS', symbol: 'TSh', nameAr: 'شلن تنزاني', nameEn: 'Tanzanian Shilling'),
  Currency(code: 'UGX', symbol: 'USh', nameAr: 'شلن أوغندي', nameEn: 'Ugandan Shilling'),
  Currency(code: 'XOF', symbol: 'CFA', nameAr: 'فرنك غرب أفريقي', nameEn: 'West African CFA'),
  Currency(code: 'XAF', symbol: 'FCFA', nameAr: 'فرنك وسط أفريقي', nameEn: 'Central African CFA'),

  // ===== أوروبا =====
  Currency(code: 'EUR', symbol: '€', nameAr: 'يورو', nameEn: 'Euro'),
  Currency(code: 'GBP', symbol: '£', nameAr: 'جنيه إسترليني', nameEn: 'British Pound'),
  Currency(code: 'CHF', symbol: 'CHF', nameAr: 'فرنك سويسري', nameEn: 'Swiss Franc'),
  Currency(code: 'SEK', symbol: 'kr', nameAr: 'كرونة سويدية', nameEn: 'Swedish Krona'),
  Currency(code: 'NOK', symbol: 'kr', nameAr: 'كرونة نرويجية', nameEn: 'Norwegian Krone'),
  Currency(code: 'DKK', symbol: 'kr', nameAr: 'كرونة دنماركية', nameEn: 'Danish Krone'),
  Currency(code: 'PLN', symbol: 'zł', nameAr: 'زلوتي بولندي', nameEn: 'Polish Zloty'),
  Currency(code: 'CZK', symbol: 'Kč', nameAr: 'كرونة تشيكية', nameEn: 'Czech Koruna'),
  Currency(code: 'HUF', symbol: 'Ft', nameAr: 'فورنت هنغاري', nameEn: 'Hungarian Forint'),
  Currency(code: 'RON', symbol: 'lei', nameAr: 'ليو روماني', nameEn: 'Romanian Leu'),
  Currency(code: 'BGN', symbol: 'лв', nameAr: 'ليف بلغاري', nameEn: 'Bulgarian Lev'),
  Currency(code: 'HRK', symbol: 'kn', nameAr: 'كونا كرواتية', nameEn: 'Croatian Kuna'),
  Currency(code: 'RSD', symbol: 'дин', nameAr: 'دينار صربي', nameEn: 'Serbian Dinar'),
  Currency(code: 'TRY', symbol: '₺', nameAr: 'ليرة تركية', nameEn: 'Turkish Lira'),
  Currency(code: 'RUB', symbol: '₽', nameAr: 'روبل روسي', nameEn: 'Russian Ruble'),
  Currency(code: 'UAH', symbol: '₴', nameAr: 'هريفنيا أوكراني', nameEn: 'Ukrainian Hryvnia'),
  Currency(code: 'ISK', symbol: 'kr', nameAr: 'كرونة آيسلندية', nameEn: 'Icelandic Krona'),

  // ===== آسيا =====
  Currency(code: 'USD', symbol: '\$', nameAr: 'دولار أمريكي', nameEn: 'US Dollar'),
  Currency(code: 'CAD', symbol: 'C\$', nameAr: 'دولار كندي', nameEn: 'Canadian Dollar'),
  Currency(code: 'MXN', symbol: 'Mex\$', nameAr: 'بيزو مكسيكي', nameEn: 'Mexican Peso'),
  Currency(code: 'BRL', symbol: 'R\$', nameAr: 'ريال برازيلي', nameEn: 'Brazilian Real'),
  Currency(code: 'ARS', symbol: '\$', nameAr: 'بيزو أرجنتيني', nameEn: 'Argentine Peso'),
  Currency(code: 'CLP', symbol: '\$', nameAr: 'بيزو تشيلي', nameEn: 'Chilean Peso'),
  Currency(code: 'COP', symbol: '\$', nameAr: 'بيزو كولومبي', nameEn: 'Colombian Peso'),
  Currency(code: 'PEN', symbol: 'S/', nameAr: 'سول بيروفي', nameEn: 'Peruvian Sol'),

  // ===== جنوب وشرق آسيا =====
  Currency(code: 'PKR', symbol: '₨', nameAr: 'روبية باكستانية', nameEn: 'Pakistani Rupee'),
  Currency(code: 'INR', symbol: '₹', nameAr: 'روبية هندية', nameEn: 'Indian Rupee'),
  Currency(code: 'BDT', symbol: '৳', nameAr: 'تاكا بنغلاديشية', nameEn: 'Bangladeshi Taka'),
  Currency(code: 'LKR', symbol: 'Rs', nameAr: 'روبية سريلانكية', nameEn: 'Sri Lankan Rupee'),
  Currency(code: 'NPR', symbol: '₨', nameAr: 'روبية نيبالية', nameEn: 'Nepalese Rupee'),
  Currency(code: 'AFN', symbol: '؋', nameAr: 'أفغاني', nameEn: 'Afghan Afghani'),
  Currency(code: 'IRR', symbol: '﷼', nameAr: 'ريال إيراني', nameEn: 'Iranian Rial'),
  Currency(code: 'MYR', symbol: 'RM', nameAr: 'رينغيت ماليزي', nameEn: 'Malaysian Ringgit'),
  Currency(code: 'SGD', symbol: 'S\$', nameAr: 'دولار سنغافوري', nameEn: 'Singapore Dollar'),
  Currency(code: 'IDR', symbol: 'Rp', nameAr: 'روبية إندونيسية', nameEn: 'Indonesian Rupiah'),
  Currency(code: 'THB', symbol: '฿', nameAr: 'بات تايلندي', nameEn: 'Thai Baht'),
  Currency(code: 'PHP', symbol: '₱', nameAr: 'بيزو فلبيني', nameEn: 'Philippine Peso'),
  Currency(code: 'VND', symbol: '₫', nameAr: 'دونغ فيتنامي', nameEn: 'Vietnamese Dong'),
  Currency(code: 'KRW', symbol: '₩', nameAr: 'وون كوري', nameEn: 'Korean Won'),
  Currency(code: 'JPY', symbol: '¥', nameAr: 'ين ياباني', nameEn: 'Japanese Yen'),
  Currency(code: 'CNY', symbol: '¥', nameAr: 'يوان صيني', nameEn: 'Chinese Yuan'),
  Currency(code: 'HKD', symbol: 'HK\$', nameAr: 'دولار هونغ كونغ', nameEn: 'Hong Kong Dollar'),
  Currency(code: 'TWD', symbol: 'NT\$', nameAr: 'دولار تايواني', nameEn: 'Taiwan Dollar'),
  Currency(code: 'MOP', symbol: 'MOP\$', nameAr: 'باتاكا ماكاوية', nameEn: 'Macanese Pataca'),

  // ===== أوقيانوسيا =====
  Currency(code: 'AUD', symbol: 'A\$', nameAr: 'دولار أسترالي', nameEn: 'Australian Dollar'),
  Currency(code: 'NZD', symbol: 'NZ\$', nameAr: 'دولار نيوزيلندي', nameEn: 'NZ Dollar'),
  Currency(code: 'FJD', symbol: 'FJ\$', nameAr: 'دولار فيجي', nameEn: 'Fijian Dollar'),

  // ===== أوروبا الشرقية وآسيا الوسطى =====
  Currency(code: 'KZT', symbol: '₸', nameAr: 'تينغي كازاخي', nameEn: 'Kazakhstani Tenge'),
  Currency(code: 'UZS', symbol: 'so\'m', nameAr: 'سوم أوزبكي', nameEn: 'Uzbekistani Som'),
  Currency(code: 'AZN', symbol: '₼', nameAr: 'مانات أذربيجاني', nameEn: 'Azerbaijani Manat'),
  Currency(code: 'GEL', symbol: '₾', nameAr: 'لاري جورجي', nameEn: 'Georgian Lari'),
  Currency(code: 'AMD', symbol: '֏', nameAr: 'درام أرميني', nameEn: 'Armenian Dram'),
  Currency(code: 'BYN', symbol: 'Br', nameAr: 'روبل بيلاروسي', nameEn: 'Belarusian Ruble'),
  Currency(code: 'MDL', symbol: 'L', nameAr: 'ليو مولدوفي', nameEn: 'Moldovan Leu'),
  Currency(code: 'MKD', symbol: 'ден', nameAr: 'دينار مقدوني', nameEn: 'Macedonian Denar'),
  Currency(code: 'ALL', symbol: 'L', nameAr: 'ليك ألباني', nameEn: 'Albanian Lek'),
  Currency(code: 'BAM', symbol: 'KM', nameAr: 'مارك بوسني', nameEn: 'Bosnian Mark'),

  // ===== أخرى =====
  Currency(code: 'BHD', symbol: '.د.ب', nameAr: 'دينار بحريني', nameEn: 'Bahraini Dinar'),
  Currency(code: 'MUR', symbol: '₨', nameAr: 'روبية موريشيوسية', nameEn: 'Mauritian Rupee'),
  Currency(code: 'MVR', symbol: 'Rf', nameAr: 'روفيا مالديفية', nameEn: 'Maldivian Rufiyaa'),
  Currency(code: 'SCR', symbol: '₨', nameAr: 'روبية سيشيلية', nameEn: 'Seychellois Rupee'),
  Currency(code: 'BND', symbol: 'B\$', nameAr: 'دولار بروناي', nameEn: 'Brunei Dollar'),
  Currency(code: 'KHR', symbol: '៛', nameAr: 'رييل كمبودي', nameEn: 'Cambodian Riel'),
  Currency(code: 'LAK', symbol: '₭', nameAr: 'كيب لاوسي', nameEn: 'Lao Kip'),
  Currency(code: 'MMK', symbol: 'K', nameAr: 'كيات ميانماري', nameEn: 'Myanmar Kyat'),
  Currency(code: 'MNT', symbol: '₮', nameAr: 'توغروغ منغولي', nameEn: 'Mongolian Tugrik'),
];

Currency? currencyByCode(String code) {
  for (final c in kCurrencies) {
    if (c.code == code) return c;
  }
  return null;
}

/// خريطة بسيطة: كلمة مفتاحية في اسم الموقع → رمز العملة.
/// تُستخدم لكشف العملة تلقائياً من موقع المستخدم.
const Map<String, String> kLocationKeywordToCurrency = {
  // الخليج
  'emirates': 'AED', 'dubai': 'AED', 'abu dhabi': 'AED', 'uae': 'AED',
  'الإمارات': 'AED', 'دبي': 'AED', 'أبو ظبي': 'AED',
  'saudi': 'SAR', 'riyadh': 'SAR', 'jeddah': 'SAR', 'makkah': 'SAR',
  'السعودية': 'SAR', 'الرياض': 'SAR', 'جدة': 'SAR', 'مكة': 'SAR',
  'qatar': 'QAR', 'doha': 'QAR', 'قطر': 'QAR', 'الدوحة': 'QAR',
  'kuwait': 'KWD', 'الكويت': 'KWD',
  'bahrain': 'BHD', 'manama': 'BHD', 'البحرين': 'BHD',
  'yemen': 'YER', 'sanaa': 'YER', 'اليمن': 'YER',
  'iraq': 'IQD', 'baghdad': 'IQD', 'العراق': 'IQD',

  // الشام ومصر
  'egypt': 'EGP', 'cairo': 'EGP', 'alexandria': 'EGP', 'مصر': 'EGP', 'القاهرة': 'EGP',
  'jordan': 'JOD', 'amman': 'JOD', 'الأردن': 'JOD',
  'lebanon': 'LBP', 'beirut': 'LBP', 'لبنان': 'LBP',
  'syria': 'SYP', 'damascus': 'SYP', 'سوريا': 'SYP',
  'palestine': 'ILS', 'gaza': 'ILS', 'فلسطين': 'ILS',
  'israel': 'ILS',

  // إفريقيا
  'morocco': 'MAD', 'rabat': 'MAD', 'casablanca': 'MAD', 'المغرب': 'MAD',
  'algeria': 'DZD', 'algiers': 'DZD', 'الجزائر': 'DZD',
  'tunisia': 'TND', 'tunis': 'TND', 'تونس': 'TND',
  'libya': 'LYD', 'tripoli': 'LYD', 'ليبيا': 'LYD',
  'sudan': 'SDG', 'khartoum': 'SDG', 'السودان': 'SDG',

  // أوروبا
  'united kingdom': 'GBP', 'london': 'GBP', 'england': 'GBP', 'britain': 'GBP',
  'france': 'EUR', 'paris': 'EUR', 'france': 'EUR', 'ألمانيا': 'EUR',
  'germany': 'EUR', 'berlin': 'EUR', 'italy': 'EUR', 'rome': 'EUR',
  'spain': 'EUR', 'madrid': 'EUR', 'netherlands': 'EUR', 'amsterdam': 'EUR',
  'switzerland': 'CHF', 'zurich': 'CHF', 'geneva': 'CHF',
  'sweden': 'SEK', 'stockholm': 'SEK',
  'norway': 'NOK', 'oslo': 'NOK',
  'denmark': 'DKK', 'copenhagen': 'DKK',
  'poland': 'PLN', 'warsaw': 'PLN',
  'turkey': 'TRY', 'istanbul': 'TRY', 'تركيا': 'TRY', 'إسطنبول': 'TRY',
  'russia': 'RUB', 'moscow': 'RUB', 'روسيا': 'RUB',

  // أمريكا
  'united states': 'USD', 'usa': 'USD', 'new york': 'USD', 'california': 'USD',
  'canada': 'CAD', 'toronto': 'CAD', 'ontario': 'CAD',
  'mexico': 'MXN', 'brazil': 'BRL',

  // آسيا
  'pakistan': 'PKR', 'karachi': 'PKR', 'lahore': 'PKR', 'باكستان': 'PKR',
  'india': 'INR', 'delhi': 'INR', 'mumbai': 'INR', 'الهند': 'INR',
  'bangladesh': 'BDT', 'dhaka': 'BDT', 'بنغلاديش': 'BDT',
  'indonesia': 'IDR', 'jakarta': 'IDR', 'إندونيسيا': 'IDR',
  'malaysia': 'MYR', 'kuala lumpur': 'MYR', 'ماليزيا': 'MYR',
  'china': 'CNY', 'beijing': 'CNY', 'shanghai': 'CNY',
  'japan': 'JPY', 'tokyo': 'JPY',
  'korea': 'KRW', 'seoul': 'KRW',
  'thailand': 'THB', 'bangkok': 'THB',
  'vietnam': 'VND',
  'philippines': 'PHP', 'manila': 'PHP',
  'singapore': 'SGD',
  'afghanistan': 'AFN', 'kabul': 'AFN', 'أفغانستان': 'AFN',
  'iran': 'IRR', 'tehran': 'IRR', 'إيران': 'IRR',

  // أوقيانوسيا
  'australia': 'AUD', 'sydney': 'AUD', 'melbourne': 'AUD',
  'new zealand': 'NZD',
};

/// استخراج رمز العملة من نص الموقع.
String? detectCurrencyFromLocation(String location) {
  final lower = location.toLowerCase();
  for (final entry in kLocationKeywordToCurrency.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return null;
}
