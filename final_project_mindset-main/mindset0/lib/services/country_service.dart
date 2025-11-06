class Country {
  final String name;
  final String code;
  final String flag;
  final String phoneCode;
  final String example;

  Country({
    required this.name,
    required this.code,
    required this.flag,
    required this.phoneCode,
    required this.example,
  });

  @override
  String toString() => '$flag $name ($phoneCode)';
}

class CountryService {
  static final List<Country> _countries = [
    // Libya first for prominence
    Country(
      name: 'Libya',
      code: 'LY',
      flag: '🇱🇾',
      phoneCode: '+218',
      example: '+218912345678',
    ),
    
    // Popular Arab countries
    Country(
      name: 'Egypt',
      code: 'EG',
      flag: '🇪🇬',
      phoneCode: '+20',
      example: '+201234567890',
    ),
    Country(
      name: 'Saudi Arabia',
      code: 'SA',
      flag: '🇸🇦',
      phoneCode: '+966',
      example: '+966512345678',
    ),
    Country(
      name: 'UAE',
      code: 'AE',
      flag: '🇦🇪',
      phoneCode: '+971',
      example: '+971501234567',
    ),
    Country(
      name: 'Algeria',
      code: 'DZ',
      flag: '🇩🇿',
      phoneCode: '+213',
      example: '+213551234567',
    ),
    Country(
      name: 'Tunisia',
      code: 'TN',
      flag: '🇹🇳',
      phoneCode: '+216',
      example: '+21612345678',
    ),
    Country(
      name: 'Morocco',
      code: 'MA',
      flag: '🇲🇦',
      phoneCode: '+212',
      example: '+212612345678',
    ),
    Country(
      name: 'Jordan',
      code: 'JO',
      flag: '🇯🇴',
      phoneCode: '+962',
      example: '+962791234567',
    ),
    Country(
      name: 'Lebanon',
      code: 'LB',
      flag: '🇱🇧',
      phoneCode: '+961',
      example: '+9613123456',
    ),
    Country(
      name: 'Kuwait',
      code: 'KW',
      flag: '🇰🇼',
      phoneCode: '+965',
      example: '+96512345678',
    ),
    Country(
      name: 'Qatar',
      code: 'QA',
      flag: '🇶🇦',
      phoneCode: '+974',
      example: '+97412345678',
    ),
    Country(
      name: 'Bahrain',
      code: 'BH',
      flag: '🇧🇭',
      phoneCode: '+973',
      example: '+97312345678',
    ),
    Country(
      name: 'Oman',
      code: 'OM',
      flag: '🇴🇲',
      phoneCode: '+968',
      example: '+96812345678',
    ),
    
    // Major international countries
    Country(
      name: 'United States',
      code: 'US',
      flag: '🇺🇸',
      phoneCode: '+1',
      example: '+1234567890',
    ),
    Country(
      name: 'Canada',
      code: 'CA',
      flag: '🇨🇦',
      phoneCode: '+1',
      example: '+1234567890',
    ),
    Country(
      name: 'United Kingdom',
      code: 'GB',
      flag: '🇬🇧',
      phoneCode: '+44',
      example: '+441234567890',
    ),
    Country(
      name: 'Germany',
      code: 'DE',
      flag: '🇩🇪',
      phoneCode: '+49',
      example: '+491234567890',
    ),
    Country(
      name: 'France',
      code: 'FR',
      flag: '🇫🇷',
      phoneCode: '+33',
      example: '+33123456789',
    ),
    Country(
      name: 'Italy',
      code: 'IT',
      flag: '🇮🇹',
      phoneCode: '+39',
      example: '+39123456789',
    ),
    Country(
      name: 'Spain',
      code: 'ES',
      flag: '🇪🇸',
      phoneCode: '+34',
      example: '+34123456789',
    ),
    Country(
      name: 'Turkey',
      code: 'TR',
      flag: '🇹🇷',
      phoneCode: '+90',
      example: '+901234567890',
    ),
    Country(
      name: 'India',
      code: 'IN',
      flag: '🇮🇳',
      phoneCode: '+91',
      example: '+911234567890',
    ),
    Country(
      name: 'China',
      code: 'CN',
      flag: '🇨🇳',
      phoneCode: '+86',
      example: '+8613000000000',
    ),
    Country(
      name: 'Japan',
      code: 'JP',
      flag: '🇯🇵',
      phoneCode: '+81',
      example: '+819012345678',
    ),
    Country(
      name: 'South Korea',
      code: 'KR',
      flag: '🇰🇷',
      phoneCode: '+82',
      example: '+821012345678',
    ),
    Country(
      name: 'Australia',
      code: 'AU',
      flag: '🇦🇺',
      phoneCode: '+61',
      example: '+61412345678',
    ),
    Country(
      name: 'Brazil',
      code: 'BR',
      flag: '🇧🇷',
      phoneCode: '+55',
      example: '+5511123456789',
    ),
    Country(
      name: 'Russia',
      code: 'RU',
      flag: '🇷🇺',
      phoneCode: '+7',
      example: '+79123456789',
    ),
    Country(
      name: 'South Africa',
      code: 'ZA',
      flag: '🇿🇦',
      phoneCode: '+27',
      example: '+27123456789',
    ),
  ];

  // Get all countries
  static List<Country> getAllCountries() {
    return List.from(_countries);
  }

  // Search countries by name, code, or phone code
  static List<Country> searchCountries(String query) {
    if (query.isEmpty) return getAllCountries();
    
    final lowercaseQuery = query.toLowerCase();
    return _countries.where((country) {
      return country.name.toLowerCase().contains(lowercaseQuery) ||
             country.code.toLowerCase().contains(lowercaseQuery) ||
             country.phoneCode.contains(query) ||
             country.flag.contains(query);
    }).toList();
  }

  // Get country by phone code
  static Country? getCountryByPhoneCode(String phoneCode) {
    try {
      return _countries.firstWhere(
        (country) => country.phoneCode == phoneCode,
      );
    } catch (e) {
      return null;
    }
  }

  // Get country by code
  static Country? getCountryByCode(String code) {
    try {
      return _countries.firstWhere(
        (country) => country.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get Libya as default
  static Country getLibya() {
    return _countries.first; // Libya is first in the list
  }

  // Format phone number for country
  static String formatPhoneNumber(String phone, Country country) {
    // Remove any non-digit characters except +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Remove existing country code if present
    if (cleaned.startsWith(country.phoneCode)) {
      cleaned = cleaned.substring(country.phoneCode.length);
    } else if (cleaned.startsWith('+')) {
      // Remove any other country code
      cleaned = cleaned.replaceFirst(RegExp(r'^\+\d{1,4}'), '');
    }
    
    // Add the selected country code
    return '${country.phoneCode}$cleaned';
  }

  // Validate phone number for country
  static bool isValidPhoneNumber(String phone, Country country) {
    if (!phone.startsWith(country.phoneCode)) return false;
    
    // Remove country code and check remaining digits
    String nationalNumber = phone.substring(country.phoneCode.length);
    
    // Libya: 9 digits (9xxxxxxxx)
    if (country.code == 'LY') {
      return nationalNumber.length == 9 && nationalNumber.startsWith('9');
    }
    
    // General validation: 7-14 digits
    return nationalNumber.length >= 7 && nationalNumber.length <= 14;
  }
} 