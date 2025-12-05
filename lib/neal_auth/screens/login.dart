import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/main.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  // Inisiasi route name untuk navigasi
  static const String routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk input text
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variabel State
  bool _obscurePassword = true;
  bool _isLoading = false;

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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),

              // --- LOGO / JUDUL ---
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.4,
                padding: const EdgeInsets.all(20),
                child: ClipOval(
                  child: Image.asset(
                    "assets/images/arena-invicta.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 5),
              const Text(
                'ARENA INVICTA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900, // Lebih tebal ala gaming
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),

              const Text(
                'Welcome back, Player.',
                style: TextStyle(fontSize: 24, color: ArenaColor.dragonFruit, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 40),

              // --- CARD FORM ---
              Container(
                decoration: BoxDecoration(
                  color: ArenaColor.darkAmethyst.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ArenaColor.purpleX11.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // ----- Username Field -----
                        _buildLabel("Username"),
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Enter your Username"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Username tidak boleh kosong";
                            } else {
                              return null;
                            }
                          },
                        ),

                        const SizedBox(height: 20),

                        _buildLabel("Password"),
                        TextFormField(
                          controller: _passwordController,
                          style: TextStyle(color: ArenaColor.textWhite),
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Enter your password")
                              .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password tidak boleh kosong";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // --- Tombol Login ---
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ArenaColor.dragonFruit,
                              foregroundColor: Colors.white,
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

                                // TODO: Ganti URL dengan URL endpoint Django kamu yang asli
                                // Contoh: "https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/auth/login/"
                                try {
                                  final response = await request.login(
                                    "$baseUrl/accounts/api/login/", // TODO: INI JG JANLUP DIUBAH
                                    {
                                      'username': _usernameController.text,
                                      'password': _passwordController.text,
                                    },
                                  );
                                  
                                  if (context.mounted) {
                                    if (response['status']) {
                                      // 1. Ambil data role dari respon Django (Asumsi di views.py Anda mengirim 'role')
                                      // Jika views.py belum mengirim role, dia akan default ke "registered"
                                      String usernameFromBackend = response['username'];
                                      String roleStr = response['role'];
                                      String avatarUrl = response['avatar_url'] ?? "";

                                      // 2. Konversi string role dari Django ke Enum UserRole di Flutter
                                      UserRole roleEnum;

                                      if (roleStr == "admin") {
                                        roleEnum = UserRole.admin;
                                      } else if (roleStr == "content_staff") {
                                        roleEnum = UserRole.staff;
                                      } else {
                                        roleEnum = UserRole.registered;
                                      }

                                      // 3. Panggil Provider untuk update status login secara global!
                                      // Pake listen: false karena kita hanya memanggil fungsi, tidak me-rebuild widget ini
                                      Provider.of<UserProvider>(
                                        context,
                                        listen: false,
                                      ).login(roleEnum, usernameFromBackend, avatarUrl: avatarUrl);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.only(bottom: 90, left: 16, right: 16),
                                          content: Text("Login Berhasil!", style: TextStyle(color: Colors.black),),
                                          backgroundColor: Colors.greenAccent,
                                        ),
                                      );

                                      // 4. Kembali ke Halaman Utama
                                      // Gunakan pushReplacementNamed agar lebih rapi
                                      Navigator.pushReplacementNamed(
                                        context,
                                        MyApp.routeName,
                                      );

                                      // TODO: Jika ada UserProvider, update state user di sini
                                      // final userProvider = context.read<UserProvider>();
                                      // userProvider.setUser(response['user_data']); // Sesuaikan dengan format response Django
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response['message'] ??
                                                "Login Gagal",
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  // Handle Error Koneksi dsb
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Error: $e"))
                                    );
                                  } 
                                } finally {
                                  // 3. Set Loading FALSE (Berhenti Putar)
                                  // Blok 'finally' akan selalu dijalankan baik sukses maupun error
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
                                : 
                              const Text(
                              "LOGIN",
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

              const SizedBox(height: 24),

              // --- Footer: Already have an account? ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.white),),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ArenaColor.dragonFruit,
                        decoration: TextDecoration.underline,
                        decorationColor: ArenaColor.dragonFruit,
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

  // Helper Widget untuk Label di atas Input Field (Sama seperti RegisterPage)
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Helper Decoration agar tampilan input konsisten (Sama seperti RegisterPage)
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      filled: true,
      fillColor: Colors.black.withOpacity(0.2),
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
