import 'dart:async';
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:intl/intl.dart';

import 'package:arena_invicta_mobile/main.dart'; // Import UserProvider
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/match_detail_page.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/match_form_page.dart'; // Import Form

class LeagueMatchesTab extends StatefulWidget {
  const LeagueMatchesTab({super.key});

  @override
  State<LeagueMatchesTab> createState() => _LeagueMatchesTabState();
}

class _LeagueMatchesTabState extends State<LeagueMatchesTab> {
  final LeagueService _service = LeagueService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  bool _isLoading = true;
  List<dynamic> _allMatches = []; 
  List<dynamic> _filteredMatches = []; 
  
  String _activeTab = "all"; 
  String _searchQuery = "";
  DateTime? _startDate;
  DateTime? _endDate;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMatches();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchMatches() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    
    final request = context.read<CookieRequest>();
    final response = await _service.fetchMatchesPage(request, tab: _activeTab, query: _searchQuery);

    if (!mounted) return;
    if (response['status'] == 'success') {
      setState(() {
        _allMatches = response['matches'];
        _applyLocalFilters(); 
        _isLoading = false; 
      });
    } else {
      setState(() { _errorMessage = response['message'] ?? "Error."; _isLoading = false; });
    }
  }

  void _applyLocalFilters() {
    List<dynamic> temp = List.from(_allMatches);

    if (_startDate != null) {
      temp = temp.where((m) {
        DateTime mDate = DateTime.parse(m['date']);
        return mDate.isAfter(_startDate!.subtract(const Duration(seconds: 1))); 
      }).toList();
    }

    if (_endDate != null) {
      temp = temp.where((m) {
        DateTime mDate = DateTime.parse(m['date']);
        DateTime endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        return mDate.isBefore(endOfDay);
      }).toList();
    }

    setState(() {
      _filteredMatches = temp;
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() { _searchQuery = value; });
      _fetchMatches();
    });
  }

  void _onTabChanged(String tab) {
    if (_activeTab != tab) {
      setState(() { _activeTab = tab; });
      _fetchMatches();
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: ArenaColor.dragonFruit,
              onPrimary: Colors.white,
              surface: Color(0xFF2A1B54),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E123B),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
      _applyLocalFilters(); 
    }
  }

  void _clearDateFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _applyLocalFilters();
  }

  // --- LOGIKA HAPUS MATCH ---
  void _confirmDelete(int matchId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A1B54),
        title: const Text("Hapus Pertandingan?", style: TextStyle(color: Colors.white)),
        content: const Text("Tindakan ini tidak dapat dibatalkan.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(child: const Text("Batal"), onPressed: () => Navigator.pop(ctx)),
          TextButton(
            child: const Text("Hapus", style: TextStyle(color: Colors.redAccent)), 
            onPressed: () async {
              Navigator.pop(ctx);
              final req = context.read<CookieRequest>();
              final res = await _service.deleteMatch(req, matchId);
              if (res['status'] == 'success') {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil dihapus")));
                _fetchMatches();
              } else {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
              }
            }
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isAdmin = userProvider.isLoggedIn && 
        (userProvider.role == UserRole.admin || userProvider.role == UserRole.staff);

    return Column(
      children: [
        // --- FILTER SECTION (Sama seperti sebelumnya) ---
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              // Search Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1B54).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      cursorColor: ArenaColor.dragonFruit,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.3), 
                        hintText: "Search team...",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 22),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Date Filters
              Row(
                children: [
                  Expanded(child: _buildDatePickerButton(label: _startDate == null ? "Start Date" : DateFormat('d MMM').format(_startDate!), icon: Icons.calendar_today_rounded, isActive: _startDate != null, onTap: () => _selectDate(true))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDatePickerButton(label: _endDate == null ? "End Date" : DateFormat('d MMM').format(_endDate!), icon: Icons.event_rounded, isActive: _endDate != null, onTap: () => _selectDate(false))),
                  if (_startDate != null || _endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: _clearDateFilters,
                        child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.close, color: Colors.redAccent, size: 20)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterPill("All Matches", "all", ArenaColor.purpleX11),
                    const SizedBox(width: 8),
                    _buildFilterPill("Finished", "finished", ArenaColor.dragonFruit),
                    const SizedBox(width: 8),
                    _buildFilterPill("Upcoming", "upcoming", Colors.greenAccent.shade700),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- MATCH LIST ---
        Expanded(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit))
            : _filteredMatches.isEmpty
                ? const Center(child: Text("No matches found.", style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 0, bottom: 100, left: 16, right: 16),
                    itemCount: _filteredMatches.length,
                    itemBuilder: (context, index) => _buildMatchCard(_filteredMatches[index], isAdmin),
                  ),
        ),
      ],
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildDatePickerButton({required String label, required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? ArenaColor.dragonFruit.withOpacity(0.2) : const Color(0xFF2A1B54).withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? ArenaColor.dragonFruit : Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : Colors.white60),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white60, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, String value, Color activeColor) {
    bool isActive = _activeTab == value;
    return GestureDetector(
      onTap: () => _onTabChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isActive ? activeColor : Colors.white.withOpacity(0.1)),
        ),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white60, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
      ),
    );
  }

  Widget _buildMatchCard(dynamic match, bool isAdmin) {
    DateTime date = DateTime.parse(match['date']);
    String dateStr = DateFormat('d MMM yyyy').format(date);
    String timeStr = DateFormat('HH:mm').format(date);
    bool isFinished = match['is_finished'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isFinished 
            ? LinearGradient(colors: [const Color(0xFF1E123B).withOpacity(0.9), const Color(0xFF0F0821).withOpacity(0.9)])
            : LinearGradient(colors: [ArenaColor.purpleX11.withOpacity(0.15), ArenaColor.darkAmethyst.withOpacity(0.15)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isFinished ? Colors.white.withOpacity(0.1) : ArenaColor.purpleX11.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MatchDetailPage(matchId: match['id'])));
          }, 
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Stack(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white38),
                            const SizedBox(width: 6),
                            Text("$dateStr • $timeStr", style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isFinished ? Colors.white.withOpacity(0.1) : ArenaColor.dragonFruit.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(isFinished ? "FT" : "UPCOMING", style: TextStyle(color: isFinished ? Colors.white70 : ArenaColor.dragonFruit, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Text(match['home_team'], textAlign: TextAlign.right, style: TextStyle(color: isFinished ? Colors.white : Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 15))),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: EdgeInsets.symmetric(horizontal: isFinished ? 16 : 12, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFF1A103C), borderRadius: BorderRadius.circular(10)),
                          child: Text(isFinished ? "${match['home_score']} - ${match['away_score']}" : "VS", style: TextStyle(color: isFinished ? Colors.white : Colors.white38, fontWeight: FontWeight.w900, fontSize: 18)),
                        ),
                        Expanded(child: Text(match['away_team'], textAlign: TextAlign.left, style: TextStyle(color: isFinished ? Colors.white : Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 15))),
                      ],
                    ),
                  ],
                ),
                
                // --- ADMIN EDIT BUTTON ---
                if (isAdmin)
                  Positioned(
                    top: -10,
                    right: 40, // Geser sedikit agar tidak menumpuk status
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.5)),
                      color: const Color(0xFF2A1B54),
                      onSelected: (val) async {
                        if (val == 'edit') {
                          // Buka Form Edit dengan data Map
                          final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => MatchFormPage(matchData: match)));
                          if (res == true) _fetchMatches();
                        } else if (val == 'delete') {
                          _confirmDelete(match['id']);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text("Edit", style: TextStyle(color: Colors.white))),
                        const PopupMenuItem(value: 'delete', child: Text("Hapus", style: TextStyle(color: Colors.redAccent))),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}