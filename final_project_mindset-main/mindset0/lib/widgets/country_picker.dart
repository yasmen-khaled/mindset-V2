import 'package:flutter/material.dart';
import '../services/country_service.dart';

class CountryPicker extends StatefulWidget {
  final Country? selectedCountry;
  final ValueChanged<Country> onCountrySelected;
  final String? hintText;

  const CountryPicker({
    super.key,
    this.selectedCountry,
    required this.onCountrySelected,
    this.hintText,
  });

  @override
  State<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCountryPicker(context),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.flag, color: Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: widget.selectedCountry != null
                    ? Text(
                        '${widget.selectedCountry!.flag} ${widget.selectedCountry!.name} (${widget.selectedCountry!.phoneCode})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        widget.hintText ?? 'Select Country',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 16,
                        ),
                      ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountryPickerModal(
        selectedCountry: widget.selectedCountry,
        onCountrySelected: widget.onCountrySelected,
      ),
    );
  }
}

class CountryPickerModal extends StatefulWidget {
  final Country? selectedCountry;
  final ValueChanged<Country> onCountrySelected;

  const CountryPickerModal({
    super.key,
    this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  State<CountryPickerModal> createState() => _CountryPickerModalState();
}

class _CountryPickerModalState extends State<CountryPickerModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Country> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = CountryService.getAllCountries();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredCountries = CountryService.searchCountries(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Select Country',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Search field
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search countries...',
                    hintStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Countries list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected = widget.selectedCountry?.code == country.code;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF7CB8FF).withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF7CB8FF)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      country.name,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF7CB8FF) : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${country.phoneCode} • ${country.example}',
                      style: TextStyle(
                        color: isSelected 
                            ? const Color(0xFF7CB8FF).withOpacity(0.8)
                            : Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF7CB8FF),
                          )
                        : null,
                    onTap: () {
                      widget.onCountrySelected(country);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          
          // Bottom safe area
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Phone input field with country picker
class CountryPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final Country? selectedCountry;
  final ValueChanged<Country> onCountrySelected;
  final String? hintText;
  final bool enabled;

  const CountryPhoneField({
    super.key,
    required this.controller,
    this.selectedCountry,
    required this.onCountrySelected,
    this.hintText,
    this.enabled = true,
  });

  @override
  State<CountryPhoneField> createState() => _CountryPhoneFieldState();
}

class _CountryPhoneFieldState extends State<CountryPhoneField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Country picker
        CountryPicker(
          selectedCountry: widget.selectedCountry,
          onCountrySelected: widget.onCountrySelected,
          hintText: 'Select Country',
        ),
        
        const SizedBox(height: 16),
        
        // Phone number field
        TextField(
          controller: widget.controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.phone,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.selectedCountry != null 
                ? 'Enter phone number (${widget.selectedCountry!.example.substring(widget.selectedCountry!.phoneCode.length)})'
                : 'Enter phone number',
            hintStyle: const TextStyle(color: Colors.white60),
            prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white70),
            prefixText: widget.selectedCountry?.phoneCode != null 
                ? '${widget.selectedCountry!.phoneCode} '
                : '',
            prefixStyle: const TextStyle(
              color: Color(0xFF7CB8FF),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            filled: true,
            fillColor: widget.enabled 
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
          ),
        ),
      ],
    );
  }
} 