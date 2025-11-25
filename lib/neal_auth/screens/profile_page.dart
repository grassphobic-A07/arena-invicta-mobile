import 'dart:convert';
import 'package:arena_invicta_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:arena_invicta_mobile/neal_auth/models/user_profile.dart'; // Sesuaikan path
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart'; // Sesuaikan path
import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controller untuk Form
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _favTeamController;
  late TextEditingController _avatarUrlController;
  late TextEditingController _bioController;

  bool _isEditing = false;
  bool _isLoading = true;
  UserProfile? _userProfile;

  @override
  void initState() {
    _displayNameController = TextEditingController();
    _favTeamController = TextEditingController();
    _avatarUrlController = TextEditingController();
    _bioController = TextEditingController();

    // Fetch data awal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProfile();
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _favTeamController.dispose();
    _avatarUrlController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> fetchProfile() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        "http://10.0.2.2:8000/accounts/api/profile/json/",
      );
      setState(() {
        _userProfile = UserProfile.fromJson(response);

        _displayNameController.text = _userProfile!.displayName;
        _favTeamController.text = _userProfile!.favouriteTeam;
        _avatarUrlController.text = _userProfile!.avatarUrl;
        _bioController.text = _userProfile!.bio;

        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat profile: $e")));
    }
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final request = context.read<CookieRequest>();
    try {
      final response = await request
          .post('http://10.0.2.2:8000/accounts/api/profile/edit/', {
            'display_name': _displayNameController.text,
            'favourite_team': _favTeamController.text,
            'avatar_url': _avatarUrlController.text,
            'bio': _bioController.text,
          });

      if (response['Ok'] == true || response['status'] == true) {
        setState(() {
          _isEditing = false;
          // Update local model
          _userProfile!.displayName = _displayNameController.text;
          _userProfile!.favouriteTeam = _favTeamController.text;
          _userProfile!.avatarUrl = _avatarUrlController.text;
          _userProfile!.bio = _bioController.text;
        });

        context.read<UserProvider>().updateProfileData(
          newAvatarUrl: _avatarUrlController.text,
        );

        // Refresh UserProvider jika perlu (untuk update nama/avatar di Drawer)
        // context.read<UserProvider>().refreshUserData(...);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui!"), backgroundColor: Colors.greenAccent,),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Gagal update profil"), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> deleteAccount() async {
    final request = context.read<CookieRequest>();
    // Implementasi delete account hit ke endpoint delete
    // Lalu logout dan redirect ke login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          ArenaColor.darkAmethyst, // Background terang seperti screenshot
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.transparent,
        foregroundColor: ArenaColor.textWhite,
        actions: [
          if (!_isLoading && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: "Edit Profile",
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel Editing',
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // Reset nilai form ke data asli
                  _displayNameController.text = _userProfile!.displayName;
                  _favTeamController.text = _userProfile!.favouriteTeam;
                  _avatarUrlController.text = _userProfile!.avatarUrl;
                  _bioController.text = _userProfile!.bio;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: ArenaColor.purpleX11),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- BAGIAN AVATAR ---
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ArenaColor.purpleX11,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ArenaColor.purpleX11.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 65,
                              backgroundColor: ArenaColor.darkAmethystLight,
                              backgroundImage:
                                  (_userProfile!.avatarUrl.isNotEmpty)
                                  ? NetworkImage(_userProfile!.avatarUrl)
                                  : null,
                              child: (_userProfile!.avatarUrl.isEmpty)
                                  ? Text(
                                      _userProfile!.username[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: ArenaColor.textWhite,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          if (_isEditing)
                            GestureDetector(
                              onTap: () {
                                _avatarUrlController.clear();
                                setState(() {
                                  _userProfile!.avatarUrl = "";
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: ArenaColor.dragonFruit,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "@${_userProfile!.username.toUpperCase()}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ArenaColor.dragonFruit.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ArenaColor.dragonFruit.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        _userProfile!.role.toUpperCase().replaceAll("_", " "),
                        style: TextStyle(
                          color: ArenaColor.dragonFruit,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- BAGIAN FORM / DISPLAY ---
                    _buildTextField(
                      label: "Display Name",
                      controller: _displayNameController,
                      hint: "Masukkan nama tampilan",
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      label: "Favourite Team",
                      controller: _favTeamController,
                      hint: "Tim Favorit",
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 20),
                    if (_isEditing) ...[
                      _buildTextField(
                        label: "Avatar URL",
                        controller: _avatarUrlController,
                        hint: "https://...",
                        enabled: true,
                        onChanged: (val) {
                          // Preview realtime jika mau
                        },
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Masukkan direct image URL (jpg/png/webp).",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 20),

                    _buildTextField(
                      label: "Bio",
                      controller: _bioController,
                      hint: "Tulis bio singkat",
                      maxLines: 4,
                      enabled: _isEditing,
                    ),

                    const SizedBox(height: 30),

                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ArenaColor.purpleX11,
                            elevation: 8,
                            shadowColor: ArenaColor.purpleX11.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: saveProfile,
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),

                    if (!_isEditing) ...[
                      const Divider(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.delete_forever),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                          ),
                          label: const Text("Delete Account"),
                          onPressed: () {
                            // Tampilkan dialog konfirmasi delete account
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  // Widget Helper untuk Input Field yang rapi mirip screenshot
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    if (!enabled) {
      // Tampilan Read-Only
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: ArenaColor.darkAmethystLight,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.5)),
            ),
            const SizedBox(height: 4),
            Text(
              controller.text.isEmpty ? "-" : controller.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ],
        ),
      );
    }

    // Tampilan Edit Mode
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: ArenaColor.darkAmethystLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: ArenaColor.darkAmethyst,
                width: 1.5,
              ),
            ),
          ),
          validator: (value) {
            if (label == "Display Name" && (value == null || value.isEmpty)) {
              return "Nama tampilan tidak boleh kosong";
            }
            return null;
          },
        ),
      ],
    );
  }
}
