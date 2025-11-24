import 'package:arena_invicta_mobile/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk input text
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Variabel state untuk checkbox
  String? _selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Opsi Role Arena Invicta
  final List<String> _roleOptions = [
    'Registered (Can Comment & Create Profiles)',
    'Content Staff (Writer & Editor)',
  ];

  // --- PALET WARNA ---
  final Color primaryColor = const Color(0xFF1F5F7A); // Dark Teal
  final Color accentColor = const Color(0xFFD4AF37);  // Gold (Invicta)
  final Color backgroundColor = const Color(0xFFF0F4F8); // Soft Blue-Grey

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Card Form Register
              // 1. Card Form yang lebih Modern
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // Lebih bulat
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.15), // Bayangan berwarna
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [                        
                        const Text(
                          'Register',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F5F7A),
                          ),
                        ),

                        const SizedBox(height: 30.0),

                        // --- Username ---
                        _buildLabel("Username"),
                        TextFormField(
                          controller: _usernameController,
                          decoration: _inputDecoration(
                            "Choose a unique username",
                          ),
                          validator: (value) => value!.isEmpty ? "Username required" : null,
                        ),
                        const SizedBox(height: 20),

                        // --- Password ---
                        _buildLabel("Password"),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(
                            "At least 8 characters",
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Password required";
                            if (value.length < 8) return "Min. 8 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // --- Confirm Password ---
                        _buildLabel("Confirm Password"),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: _inputDecoration(
                            "Re-enter your password",
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) return "Passwords do not match";
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // --- Role Selection ---
                        _buildLabel("Your Role"),
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration(
                            "Select your role",
                          ),
                          value: _selectedRole,
                          items: _roleOptions.map((String role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(
                                role,
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedRole = val),
                          validator: (value) => value == null ? "Please select a role" : null,
                          isExpanded: true,
                        ),
                        const SizedBox(height: 32),

                        // --- 3. Button Gradient/Solid yang Mewah ---
                        SizedBox(
                          width: double.infinity,
                          height: 55, // Sedikit lebih tinggi biar gagah
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white, // Warna teks
                              elevation: 5,
                              shadowColor: primaryColor.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // LOGIKA LOGIN SAMA SEPERTI SEBELUMNYA
                                final response = await request.post(
                                    "http://10.0.2.2:8000/accounts/api/register/",
                                    {
                                      'username': _usernameController.text,
                                      'password': _passwordController.text,
                                      'confirmPassword': _confirmPasswordController.text,
                                      'role': _selectedRole == 'Content Staff (Writer & Editor)' ? 'content_staff' : 'registered',
                                    });

                                if (context.mounted) {
                                  if (response['status']) {

                                    // 1. Ambil data
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text("Welcome to the Arena!"),
                                      backgroundColor: Colors.green,
                                    ));
                                    Navigator.pushNamed(context, LoginPage.routeName);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(response['message'] ?? "Registration Failed"),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                }
                              }
                            },
                            child: const Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- Footer: Already have an account? ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 14,
      ),
      // ignore: deprecated_member_use
      filled: true,
      fillColor: Colors.grey[50], // Isi field agak abu sangat muda
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFF1F5F7A), width: 2),
      ),
    );
  }

}