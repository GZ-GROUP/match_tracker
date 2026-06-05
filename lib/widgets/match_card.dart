import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final Country? homeTeam;
  final Country? awayTeam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MatchCard({
    super.key,
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final result = match.result;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2D3347),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ── Teams & Score ──────────────────────────────
            Expanded(
              child: Row(
                children: [
                  // Teams column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TeamRow(
                          country: homeTeam,
                          score: match.homeTeamScore,
                          isWinner: result == MatchResult.homeWin,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            'VS',
                            style: GoogleFonts.barlow(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4B5563),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        _TeamRow(
                          country: awayTeam,
                          score: match.awayTeamScore,
                          isWinner: result == MatchResult.awayWin,
                        ),
                      ],
                    ),
                  ),

                  
                ],
              ),
            ),

            // ── Action buttons ─────────────────────────────
            const SizedBox(width: 12),
            Column(
              children: [
                _ActionButton(
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: onEdit,
                  tooltip: 'Editar',
                ),
                const SizedBox(height: 8),
                _ActionButton(
                  icon: Icons.delete_rounded,
                  color: const Color(0xFFEF4444),
                  onTap: onDelete,
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Team row with emoji, name and score ─────────────────────
class _TeamRow extends StatelessWidget {
  final Country? country;
  final int score;
  final bool isWinner;

  const _TeamRow({
    required this.country,
    required this.score,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          country?.emoji ?? '🌍',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            country?.name ?? 'Desconocido',
            style: GoogleFonts.barlow(
              fontSize: 14,
              fontWeight: isWinner ? FontWeight.w700 : FontWeight.w500,
              color: isWinner ? Colors.white : const Color(0xFF9CA3AF),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isWinner
                ? const Color(0xFF10B981).withOpacity(0.2)
                : const Color(0xFF374151),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            '$score',
            style: GoogleFonts.barlow(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isWinner ? const Color(0xFF10B981) : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}



// ── Icon action button ────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}