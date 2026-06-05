import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {

  static const String baseUrl = 'https://worldcupapi.projects.gzgroup.dev/';

  // ─── Countries ────────────────────────────────────────────
  Future<List<Country>> getCountries() async {
    final response = await http.get(Uri.parse('$baseUrl/countries/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Country.fromJson(json)).toList();
    }
    throw Exception('Error al cargar países: ${response.statusCode}');
  }

  // ─── Confederations ───────────────────────────────────────
  Future<List<Confederation>> getConfederations() async {
    final response = await http.get(Uri.parse('$baseUrl/confederations/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Confederation.fromJson(json)).toList();
    }
    throw Exception('Error al cargar confederaciones: ${response.statusCode}');
  }

  // ─── Matches ──────────────────────────────────────────────
  Future<Match> createMatch(Match match) async {
    final response = await http.post(
      Uri.parse('$baseUrl/matches/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(match.toJson()),
    );
    if (response.statusCode == 200) {
      return Match.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear partido: ${response.statusCode}');
  }

  Future<List<Match>> getMatches() async {
    final response = await http.get(
      Uri.parse('$baseUrl/matches/')
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Match.fromJson(json)).toList();
    }

    throw Exception(
      'Error al cargar partidos: ${response.statusCode}'
    );
  }

  Future<Match> updateMatch(int matchId, Match match) async {
    final response = await http.put(
      Uri.parse('$baseUrl/matches/$matchId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(match.toJson()),
    );
    if (response.statusCode == 200) {
      return Match.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al actualizar partido: ${response.statusCode}');
  }

  Future<void> deleteMatch(int matchId) async {
    final response = await http.delete(Uri.parse('$baseUrl/matches/$matchId'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar partido: ${response.statusCode}');
    }
  }
}