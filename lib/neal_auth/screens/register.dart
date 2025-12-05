import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';
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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Variabel state untuk checkbox
  String? _selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Opsi Role Arena Invicta
  final List<String> _roleOptions = [
    'Registered (Can Comment & Create Profiles)',
    'Content Staff (Writer & Editor)',
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: ArenaColor.mainBackgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.03),

              // Card Form Register
              // 1. Card Form yang lebih Modern
              const Icon(
                Icons.person_add_alt_1,
                size: 50,
                color: ArenaColor.dragonFruit,
              ),
              const SizedBox(height: 8),
              const Text(
                'JOIN THE ARENA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const Text(
                'Create your profile to start.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 24.0),

              Container(
                decoration: BoxDecoration(
                  color: ArenaColor.darkAmethyst.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20), // Lebih bulat
                  border: Border.all(
                    color: ArenaColor.purpleX11.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // Bayangan berwarna
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // --- Username ---
                        _buildLabel("Username"),
                        TextFormField(
                          controller: _usernameController,
                          style: TextStyle(color: ArenaColor.textWhite),
                          decoration: _inputDecoration(
                            "Choose a unique username",
                          ),
                          validator: (value) =>
                              value!.isEmpty ? "Username required" : null,
                        ),
                        const SizedBox(height: 16),

                        // --- Password ---
                        _buildLabel("Password"),
                        TextFormField(
                          controller: _passwordController,
                          style: TextStyle(color: ArenaColor.textWhite),
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration("Min. 8 characters")
                              .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Password required";
                            if (value.length < 8) return "Min. 8 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // --- Confirm Password ---
                        _buildLabel("Confirm Password"),
                        TextFormField(
                          controller: _confirmPasswordController,
                          style: TextStyle(color: ArenaColor.textWhite),
                          obscureText: _obscureConfirmPassword,
                          decoration: _inputDecoration("Re-enter your password")
                              .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  ),
                                ),
                              ),
                          validator: (value) {
                            if (value != _passwordController.text)
                              return "Passwords do not match";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // --- Role Selection ---
                        _buildLabel("Your Role"),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,                    // pakai value
                          isExpanded: true,
                          dropdownColor: ArenaColor.darkAmethyst,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(""),        // kosongkan hint dari decoration
                          hint: const Text(                        // <-- INI placeholder, warnanya putih
                            "Select your role",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,                 // PUTIH
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          items: _roleOptions.map((String role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(
                                role,
                                style: const TextStyle(              // <-- font di setiap item
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (context) {
                            return _roleOptions.map((role) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  role,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList();
                          },
                          onChanged: (val) => setState(() => _selectedRole = val),
                          validator: (value) => value == null ? "Please select a role" : null,
                        ),
                        const SizedBox(height: 32),

                        // --- 3. Button Gradient/Solid yang Mewah ---
                        SizedBox(
                          width: double.infinity,
                          height: 55, // Sedikit lebih tinggi biar gagah
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ArenaColor.dragonFruit,
                              foregroundColor: Colors.white, // Warna teks
                              elevation: 10,
                              shadowColor: ArenaColor.dragonFruit.withOpacity(
                                0.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : () async {
                              if (_formKey.currentState!.validate()) {

                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  // LOGIKA LOGIN SAMA SEPERTI SEBELUMNYA
                                  final response = await request.post(
                                    "$baseUrl/accounts/api/register/", // TODO: JANLUP GANTI LAGI KE "https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/accounts/api/register/"
                                    {
                                      'username': _usernameController.text,
                                      'password': _passwordController.text,
                                      'confirmPassword':
                                          _confirmPasswordController.text,
                                      'role':
                                          _selectedRole ==
                                              'Content Staff (Writer & Editor)'
                                          ? 'content_staff'
                                          : 'registered',
                                    },
                                  );

                                  if (context.mounted) {
                                    if (response['status']) {
                                      // 1. Ambil data
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.only(bottom: 90, left: 16, right: 16),
                                          content: Text("Welcome to the Arena!"),
                                          backgroundColor: Colors.greenAccent,
                                        ),
                                      );
                                      Navigator.pushNamed(
                                        context,
                                        LoginPage.routeName,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response['message'] ??
                                                "Registration Failed",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent,),
                                    );
                                  }
                                } finally {
                                  // 3. Stop Loading
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }                                
                              }
                            },
                            child: _isLoading 
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )                             
                            : const Text(
                              "CREATE ACCOUNT",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
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
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.white70),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ArenaColor.dragonFruit,
                        decoration: TextDecoration.underline,
                        decorationColor: ArenaColor.dragonFruit,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      // ignore: deprecated_member_use
      filled: true,
      fillColor: Colors.black.withOpacity(0.2), // Isi field agak abu sangat muda
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: ArenaColor.dragonFruit, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}
