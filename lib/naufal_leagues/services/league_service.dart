import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:arena_invicta_mobile/global/environments.dart'; // Pastikan path ini benar untuk baseUrl
import 'package:arena_invicta_mobile/naufal_leagues/models/league.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/match.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/standing.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/team.dart';

class LeagueService {
  // Fungsi umum untuk fetch data apapun
  // Ini membantu agar kita tidak menulis ulang logika try-catch berulang kali
  Future<List<T>> _fetchData<T>({
    required CookieRequest request,
    required String endpoint,
    required List<T> Function(String) parser,
  }) async {
    // 1. URL Endpoint (Sesuaikan jika ada prefix /leagues/ di urls.py kamu)
    final String url = '$baseUrl/$endpoint'; 

    try {
      // 2. Pemanggilan Asinkronus (Async Call)
      final response = await request.get(url);
      
      // 3. Pengolahan Data Response JSON
      // request.get dari pbp_django_auth biasanya mengembalikan JSON Object/List langsung
      // atau String. Kita perlu memastikan formatnya string untuk parser Quicktype.
      
      // Trik: json.encode agar menjadi string JSON murni untuk parser kita
      String jsonString = json.encode(response); 
      
      return parser(jsonString);
    } catch (e) {
      // Error handling sederhana
      print("Error fetching $endpoint: $e");
      return [];
    }
  }

  // --- Public Methods untuk UI ---

  Future<List<League>> fetchLeagues(CookieRequest request) async {
    return _fetchData<League>(
      request: request,
      endpoint: 'leagues/api/leagues/', // Sesuaikan dengan urls.py
      parser: leagueFromJson,
    );
  }

  Future<List<Team>> fetchTeams(CookieRequest request) async {
    return _fetchData<Team>(
      request: request,
      endpoint: 'leagues/api/teams/',
      parser: teamFromJson,
    );
  }

  Future<List<Match>> fetchMatches(CookieRequest request) async {
    return _fetchData<Match>(
      request: request,
      endpoint: 'leagues/api/matches/',
      parser: matchFromJson,
    );
  }

  Future<Map<String, dynamic>> createMatch(
      CookieRequest request, Map<String, dynamic> data) async {
    return _postData(
      request: request,
      endpoint: 'leagues/api/matches/create/',
      data: data,
    );
  }

  Future<Map<String, dynamic>> editMatch(
      CookieRequest request, int id, Map<String, dynamic> data) async {
    return _postData(
      request: request,
      endpoint: 'leagues/api/matches/edit/$id/',
      data: data,
    );
  }

  Future<Map<String, dynamic>> deleteMatch(
      CookieRequest request, int id) async {
    final String url = '$baseUrl/leagues/api/matches/delete/$id/';
    try {
      final response = await request.postJson(url, jsonEncode({}));
      return response;
    } catch (e) {
      print("Error deleting match $id: $e");
      return {"status": "error", "message": e.toString()};
    }
  }

  Future<List<Standing>> fetchStandings(CookieRequest request) async {
    return _fetchData<Standing>(
      request: request,
      endpoint: 'leagues/api/standings/',
      parser: standingFromJson,
    );
  }

  // --- Helper untuk POST Request ---
  Future<Map<String, dynamic>> _postData({
    required CookieRequest request,
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    final String url = '$baseUrl/$endpoint';
    try {
      final response = await request.postJson(
        url,
        jsonEncode(data),
      );
      return response; // Biasanya mengembalikan {"status": "success", ...}
    } catch (e) {
      print("Error posting to $endpoint: $e");
      return {"status": "error", "message": e.toString()};
    }
  }

  // --- Public Methods untuk Create/Edit/Delete ---

  // Cocok dengan views.py: create_team_flutter
  Future<Map<String, dynamic>> createTeam(
      CookieRequest request, Map<String, dynamic> data) async {
    return _postData(
      request: request,
      endpoint: 'leagues/api/teams/create/',
      data: data,
    );
  }

  Future<Map<String, dynamic>> editTeam(
      CookieRequest request, int id, Map<String, dynamic> data) async {
    return _postData(
      request: request,
      endpoint: 'leagues/api/teams/edit/$id/',
      data: data,
    );
  }

  Future<Map<String, dynamic>> deleteTeam(
      CookieRequest request, int id) async {
    final String url = '$baseUrl/leagues/api/teams/delete/$id/';
    try {
      final response = await request.postJson(url, jsonEncode({}));
      return response;
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // Cocok dengan views.py: create_standing_flutter
  Future<Map<String, dynamic>> createStanding(
      CookieRequest request, Map<String, dynamic> data) async {
    return _postData(
      request: request,
      endpoint: 'leagues/api/standings/create/',
      data: data,
    );
  }

  // Cocok dengan views.py: edit_standing_flutter
  Future<Map<String, dynamic>> editStanding(
      CookieRequest request, int id, Map<String, dynamic> data) async {
    return _postData(
      request: request,
      endpoint: 'leagues/api/standings/edit/$id/',
      data: data,
    );
  }

  // Cocok dengan views.py: delete_standing_flutter
  Future<Map<String, dynamic>> deleteStanding(
      CookieRequest request, int id) async {
    final String url = '$baseUrl/leagues/api/standings/delete/$id/';
    try {
      final response = await request.postJson(url, jsonEncode({}));
      return response;
    } catch (e) {
      print("Error deleting standing $id: $e");
      return {"status": "error", "message": e.toString()};
    }
  }
}