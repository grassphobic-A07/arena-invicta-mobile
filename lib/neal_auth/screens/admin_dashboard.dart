// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<dynamic> _users = [];
  

  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }

  Future<void> fetchAdminData() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get("https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/accounts/api/admin/dashboard/");

      if (response['status']) {
        setState(() {
          _stats = response['counts'];
          _users = response['users'];
          _isLoading = false;
        });
      } else {
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Failed to load admin data.")));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> performAction(String op, int userId, {String? role}) async {
    final request = context.read<CookieRequest>();
    try {
      // --- PERBAIKAN FINAL ---
      // Kita paksa tipe data Map<String, String>
      // Artinya SEMUA value WAJIB String.
      final Map<String, String> data = {
        'op': op,
        'user_id': userId.toString(), // <--- Pastikan ini .toString()
      };

      if (role != null) {
        data['role'] = role;
      }

      // Kirim data map (JANGAN di-jsonEncode, biarkan Map mentah)
      // Karena ini Map<String, String>, library akan menerimanya dengan senang hati.
      final response = await request.post(
        "https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/accounts/api/admin/dashboard/",
        data, 
      );
      // -------------------------

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ?? "Action successful."),
          backgroundColor: Colors.greenAccent,
        ));
        fetchAdminData(); // Refresh UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ?? "Action failed."),
          backgroundColor: Colors.redAccent,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));    
    }
  }

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _createRole = "registered"; // Default role saat create
  bool _isCreating = false;

  Future<void> createNewUser() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Username dan Password tidak boleh kosong."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() { _isCreating = true; }); // Mulai loading

    final request = context.read<CookieRequest>();
    try {
      final Map<String, String> data = {
        'op': 'create_user',
        'username': _usernameController.text,
        'password': _passwordController.text,
        'role': _createRole,
      };

      final response = await request.post(
        "https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/accounts/api/admin/dashboard/",
        data,
      );

      if (response['status'] == true) {
        // Reset Form
        _usernameController.clear();
        _passwordController.clear();
        setState(() { _createRole = "registered"; });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.greenAccent,
        ));
        
        fetchAdminData(); // Refresh List User
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ?? "Gagal membuat user."),
          backgroundColor: Colors.redAccent,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() { _isCreating = false; }); // Stop loading
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      appBar: AppBar(
        title: const Text("Arena Invicta - Admin Dashboard"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),

      body: _isLoading 
      ? const Center(child: CircularProgressIndicator(color: ArenaColor.purpleX11,)) 
      : RefreshIndicator(
        onRefresh: fetchAdminData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              children: [
                _buildStatCard("Total Users", _stats['total'].toString(), ArenaColor.purpleX11),
                const SizedBox(width: 10.0),
                _buildStatCard("Staff", _stats['content_staff'].toString(), ArenaColor.dragonFruit),
                const SizedBox(width: 10.0),
                _buildStatCard("Registered", _stats['registered'].toString(), Colors.greenAccent)
              ],
            ),

            const SizedBox(height: 24),
            _buildCreateUserForm(),
            const SizedBox(height: 24),        
            const Text("User Management", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // --- LIST USER ---
            ..._users.map((user) => _buildUserCard(user)).toList(),
          ],
        ), 
        
      ),
    );
  }


  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ArenaColor.darkAmethystLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5))
        ),

        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4,),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70),)
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    bool isActive = user['is_active'];
    String role = user['role'];

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ArenaColor.darkAmethystLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ArenaColor.purpleX11,
                backgroundImage: (user['avatar_url'] != "") ? NetworkImage(user['avatar_url']) : null,
                child: (user['avatar_url'] == "") ? Text(user['username'][0].toUpperCase()) : null,
              ),

              const SizedBox(width: 12,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['username'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(user['display_name'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color: isActive ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text(
                  isActive ? "Active" : "Inactive",
                  style: TextStyle(
                    color: isActive ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),

          const Divider(color: Colors.white10, height: 24,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              (role == 'admin') ?
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_rounded, size: 16, color: Colors.amberAccent,),
                    SizedBox(width: 8),
                    Text("Admin Protected", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              )              
              : DropdownButton<String>(
                value: role,
                dropdownColor: ArenaColor.darkAmethystLight,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                underline: Container(),
                items: const [
                  DropdownMenuItem(value: "registered", child: Text("Registered")),
                  DropdownMenuItem(value: "content_staff", child: Text("Content Staff")),
                  DropdownMenuItem(value: "admin", child: Text("Admin")),
                ],
                onChanged: (val) {
                  if (val != null && val != role) {
                    performAction("set_role", user['id'], role: val);
                  }
                },
              ),

              Row(
                children: [ 
                  IconButton(
                    icon: Icon(isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded, color: isActive ? Colors.orangeAccent : Colors.greenAccent,),
                    tooltip: isActive ? "Deactivate User" : "Activate User",
                    onPressed: () {
                      performAction("toggle_active", user['id']);
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: ArenaColor.darkAmethystLight,
                          title: const Text("Hapus User?", style: TextStyle(color: Colors.white)),
                          content: Text("Yakin ingin menghapus ${user['username']}?", style: const TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(child: const Text("Batal"), onPressed: () => Navigator.pop(ctx)),
                            TextButton(
                              child: const Text("Hapus", style: TextStyle(color: Colors.red)), 
                              onPressed: () {
                                Navigator.pop(ctx);
                                performAction("delete_user", user['id']);
                              }
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCreateUserForm() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: ArenaColor.darkAmethystLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ArenaColor.purpleX11), // Border Ungu Terang
      ),
      child: ExpansionTile(
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Colors.white),
            SizedBox(width: 10),
            Text("Create New User", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Input Username
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Username",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Input Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),

                // Dropdown Role
                DropdownButtonFormField<String>(
                  value: _createRole,
                  dropdownColor: ArenaColor.darkAmethyst,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Role",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: "registered", child: Text("Registered")),
                    DropdownMenuItem(value: "content_staff", child: Text("Content Staff")),
                    DropdownMenuItem(value: "admin", child: Text("Admin")),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _createRole = val);
                  },
                ),
                const SizedBox(height: 20),

                // Tombol Create
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ArenaColor.purpleX11,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isCreating ? null : createNewUser,
                    child: _isCreating 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Create Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}