import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class MatchProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Match> _matches = [];
  List<Country> _countries = [];
  List<Confederation> _confederations = [];
  bool _isLoading = false;
  String? _error;

  List<Match> get matches => _matches;
  List<Country> get countries => _countries;
  List<Confederation> get confederations => _confederations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Country? getCountryById(int id) {
    try {
      return _countries.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Load initial data ────────────────────────────────────
  Future<void> loadInitialData() async {
    _setLoading(true);

    try {
      _countries = await _api.getCountries();
      _confederations = await _api.getConfederations();
      _matches = await _api.getMatches();

      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  // ─── Matches CRUD ─────────────────────────────────────────
  Future<bool> createMatch(Match match) async {
    _setLoading(true);
    try {
      final created = await _api.createMatch(match);
      _matches.add(created);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateMatch(int matchId, Match match) async {
    _setLoading(true);
    try {
      final updated = await _api.updateMatch(matchId, match);
      final idx = _matches.indexWhere((m) => m.id == matchId);
      if (idx != -1) _matches[idx] = updated;
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteMatch(int matchId) async {
    _setLoading(true);
    try {
      await _api.deleteMatch(matchId);
      _matches.removeWhere((m) => m.id == matchId);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}