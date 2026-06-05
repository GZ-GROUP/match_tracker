import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/match_provider.dart';
import '../widgets/match_card.dart';
import '../models/models.dart';
import 'create_match_screen.dart';
import 'edit_match_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().loadInitialData();
    });
  }

  Future<void> _confirmDelete(BuildContext context, int matchId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Eliminar partido',
          style: GoogleFonts.barlow(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar este partido?',
          style: GoogleFonts.barlow(color: const Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.barlow(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar', style: GoogleFonts.barlow(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<MatchProvider>();
      final success = await provider.deleteMatch(matchId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: success
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
            content: Text(
              success ? 'Partido eliminado' : 'Error al eliminar',
              style: GoogleFonts.barlow(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Consumer<MatchProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: const Color(0xFF0F1117),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A1F2E), Color(0xFF0F1117)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('⚽', style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MUNDIAL 2026',
                                    style: GoogleFonts.barlow(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  Text(
                                    'Registro de partidos',
                                    style: GoogleFonts.barlow(
                                      fontSize: 13,
                                      color: const Color(0xFF6B7280),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              _StatsChip(count: provider.matches.length),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Error banner ─────────────────────────────
              if (provider.error != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFEF4444), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: GoogleFonts.barlow(
                              color: const Color(0xFFEF4444),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Loading ───────────────────────────────────
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                )

              // ── Empty state ───────────────────────────────
              else if (provider.matches.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🏟️',
                            style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text(
                          'No ha registrado ningún partido',
                          style: GoogleFonts.barlow(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toca + para agregar el primer partido',
                          style: GoogleFonts.barlow(
                            fontSize: 14,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // ── Match list ────────────────────────────────
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final match = provider.matches[index];
                      final home = provider.getCountryById(match.homeTeamId);
                      final away = provider.getCountryById(match.awayTeamId);
                      return MatchCard(
                        match: match,
                        homeTeam: home,
                        awayTeam: away,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditMatchScreen(match: match),
                            ),
                          );
                        },
                        onDelete: () => _confirmDelete(context, match.id!),
                      );
                    },
                    childCount: provider.matches.length,
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateMatchScreen()),
          );
        },
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

class _StatsChip extends StatelessWidget {
  final int count;
  const _StatsChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Text(
        '$count partidos',
        style: GoogleFonts.barlow(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF3B82F6),
        ),
      ),
    );
  }
}