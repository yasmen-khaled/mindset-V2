import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/country_service.dart';
import '../widgets/country_picker.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _obscureNewText = true;
  bool _isLoading = false;
  bool _codeSent = false;
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    // Default to Libya for user convenience
    _selectedCountry = CountryService.getLibya();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendSMS() async {
    if (_selectedCountry == null || _phoneController.text.isEmpty) {
      _showSnackBar('Please select country and enter phone number', Colors.red);
      return;
    }

    // Format phone number with selected country
    String formattedPhone = CountryService.formatPhoneNumber(_phoneController.text.trim(), _selectedCountry!);
    
    // Validate phone number for the selected country
    if (!CountryService.isValidPhoneNumber(formattedPhone, _selectedCountry!)) {
      _showSnackBar('Please enter a valid phone number for ${_selectedCountry!.name}\nExample: ${_selectedCountry!.example}', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.sendSMSReset(formattedPhone);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        setState(() {
          _codeSent = true;
        });
        _showSnackBar('SMS sent to ${_selectedCountry!.flag} ${formattedPhone} (${result['expires_in_minutes']} minutes)', Colors.green);
      } else {
        _showSnackBar(result['message'], Colors.red);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Failed to send SMS: $e', Colors.red);
    }
  }

  Future<void> _handleVerifyAndReset() async {
    if (_codeController.text.isEmpty || _newPasswordController.text.isEmpty) {
      _showSnackBar('Please fill all fields', Colors.red);
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', Colors.red);
      return;
    }

    String formattedPhone = CountryService.formatPhoneNumber(_phoneController.text.trim(), _selectedCountry!);

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.verifySMSReset(
        formattedPhone,
        _codeController.text.trim(),
        _newPasswordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        _showSnackBar('${result['message']} - Password reset successful for ${_selectedCountry!.flag}!', Colors.green);
        // Navigate back to login after successful reset
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      } else {
        _showSnackBar(result['message'], Colors.red);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Password reset failed: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ResizeImage(
              const AssetImage('Assets/background/login.png'),
              width: (size.width * devicePixelRatio).toInt(),
              height: (size.height * devicePixelRatio).toInt(),
            ),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color.fromARGB(15, 0, 0, 0).withOpacity(0.3),
                const Color.fromARGB(47, 0, 0, 0).withOpacity(0.2),
                const Color.fromARGB(22, 0, 0, 0).withOpacity(0.3),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '📱 Reset Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _codeSent 
                            ? 'Enter the SMS code and new password'
                            : 'Enter your phone number to receive SMS code',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        
                        // Country Phone Field
                        CountryPhoneField(
                          controller: _phoneController,
                          selectedCountry: _selectedCountry,
                          enabled: !_codeSent, // Disable after SMS sent
                          onCountrySelected: (country) {
                            setState(() {
                              _selectedCountry = country;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // SMS Code field (shown after SMS sent)
                        if (_codeSent) ...[
                          TextField(
                            controller: _codeController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '6-digit SMS Code',
                              hintStyle: const TextStyle(color: Colors.white60),
                              prefixIcon: const Icon(Icons.sms_outlined, color: Colors.white70),
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
                          const SizedBox(height: 16),

                          // New Password field
                          TextField(
                            controller: _newPasswordController,
                            style: const TextStyle(color: Colors.white),
                            obscureText: _obscureNewText,
                            decoration: InputDecoration(
                              hintText: 'New Password',
                              hintStyle: const TextStyle(color: Colors.white60),
                              prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewText ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureNewText = !_obscureNewText;
                                  });
                                },
                              ),
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
                          const SizedBox(height: 24),
                        ],

                        // Action Button
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 139, 203, 255),
                                Color.fromARGB(255, 35, 107, 151),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading 
                              ? null 
                              : (_codeSent ? _handleVerifyAndReset : _handleSendSMS),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _codeSent ? 'Reset Password' : 'Send SMS Code',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Resend SMS button (shown after SMS sent)
                        if (_codeSent) ...[
                          TextButton(
                            onPressed: _isLoading ? null : () {
                              setState(() {
                                _codeSent = false;
                                _codeController.clear();
                                _newPasswordController.clear();
                              });
                            },
                            child: const Text(
                              'Resend SMS',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],

                        // Back to Login
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            'Back to Login',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 