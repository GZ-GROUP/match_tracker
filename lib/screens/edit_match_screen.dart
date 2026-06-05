import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/match_provider.dart';
import '../models/models.dart';

class EditMatchScreen extends StatefulWidget {
  final Match match;
  const EditMatchScreen({super.key, required this.match});

  @override
  State<EditMatchScreen> createState() => _EditMatchScreenState();
}

class _EditMatchScreenState extends State<EditMatchScreen> {
  late Country? _homeTeam;
  late Country? _awayTeam;
  late DateTime _selectedDate;
  late String _stage;
  late int _homeScore;
  late int _awayScore;

  final List<String> _stages = [
    'Fase de grupos',
    'Octavos de final',
    'Cuartos de final',
    'Semifinal',
    'Tercer puesto',
    'Final',
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<MatchProvider>();
    _homeTeam = provider.getCountryById(widget.match.homeTeamId);
    _awayTeam = provider.getCountryById(widget.match.awayTeamId);
    _selectedDate = widget.match.date;
    _stage = _stages.contains(widget.match.stage) ? widget.match.stage : _stages.first;
    _homeScore = widget.match.homeTeamScore;
    _awayScore = widget.match.awayTeamScore;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2026, 6, 1),
      lastDate: DateTime(2026, 7, 31),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF3B82F6),
            surface: Color(0xFF1A1F2E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_homeTeam == null || _awayTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFF59E0B),
          content: Text(
            'Selecciona ambos equipos',
            style: GoogleFonts.barlow(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final updated = widget.match.copyWith(
      homeTeamId: _homeTeam!.id,
      awayTeamId: _awayTeam!.id,
      homeTeamScore: _homeScore,
      awayTeamScore: _awayScore,
      date: _selectedDate,
      stage: _stage,
    );

    final provider = context.read<MatchProvider>();
    final success = await provider.updateMatch(widget.match.id!, updated);

    if (context.mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            content: Text(
              'Partido actualizado exitosamente',
              style: GoogleFonts.barlow(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text(
              provider.error ?? 'Error al actualizar',
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
    final provider = context.watch<MatchProvider>();
    final countries = provider.countries;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1117),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Editar Partido',
          style: GoogleFonts.barlow(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Score editor ──────────────────────────────────
          _ScoreEditor(
            homeTeam: _homeTeam,
            awayTeam: _awayTeam,
            homeScore: _homeScore,
            awayScore: _awayScore,
            onHomeScoreChanged: (v) => setState(() => _homeScore = v),
            onAwayScoreChanged: (v) => setState(() => _awayScore = v),
          ),

          const SizedBox(height: 28),

          // ── Home team ────────────────────────────────────
          _Label(icon: '🏠', text: 'Equipo Local'),
          const SizedBox(height: 10),
          _TeamDropdown(
            value: _homeTeam,
            countries: countries,
            hint: 'Seleccionar equipo local',
            onChanged: (c) => setState(() => _homeTeam = c),
          ),

          const SizedBox(height: 20),

          _Label(icon: '✈️', text: 'Equipo Visitante'),
          const SizedBox(height: 10),
          _TeamDropdown(
            value: _awayTeam,
            countries: countries,
            hint: 'Seleccionar equipo visitante',
            onChanged: (c) => setState(() => _awayTeam = c),
          ),

          const SizedBox(height: 20),

          _Label(icon: '📅', text: 'Fecha del partido'),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: Color(0xFF3B82F6), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy', 'es').format(_selectedDate),
                    style: GoogleFonts.barlow(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          _Label(icon: '🏆', text: 'Fase'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2D3347)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _stage,
                dropdownColor: const Color(0xFF1A1F2E),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF6B7280)),
                items: _stages.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(
                      s,
                      style:
                          GoogleFonts.barlow(color: Colors.white, fontSize: 15),
                    ),
                  );
                }).toList(),
                onChanged: (s) => setState(() => _stage = s!),
              ),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              onPressed: provider.isLoading ? null : _submit,
              child: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Guardar cambios',
                      style: GoogleFonts.barlow(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Score editor ─────────────────────────────────────────────
class _ScoreEditor extends StatelessWidget {
  final Country? homeTeam;
  final Country? awayTeam;
  final int homeScore;
  final int awayScore;
  final ValueChanged<int> onHomeScoreChanged;
  final ValueChanged<int> onAwayScoreChanged;

  const _ScoreEditor({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.onHomeScoreChanged,
    required this.onAwayScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'MARCADOR',
            style: GoogleFonts.barlow(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF10B981),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ScoreColumn(
                  label: homeTeam?.displayName ?? 'Local',
                  score: homeScore,
                  onChanged: onHomeScoreChanged,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ':',
                  style: GoogleFonts.barlow(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              Expanded(
                child: _ScoreColumn(
                  label: awayTeam?.displayName ?? 'Visitante',
                  score: awayScore,
                  onChanged: onAwayScoreChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  final String label;
  final int score;
  final ValueChanged<int> onChanged;

  const _ScoreColumn({
    required this.label,
    required this.score,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.barlow(
            fontSize: 12,
            color: const Color(0xFF9CA3AF),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ScoreButton(
              icon: Icons.remove,
              onTap: score > 0 ? () => onChanged(score - 1) : null,
            ),
            const SizedBox(width: 10),
            Text(
              '$score',
              style: GoogleFonts.barlow(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            _ScoreButton(
              icon: Icons.add,
              onTap: () => onChanged(score + 1),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScoreButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ScoreButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFF374151)
              : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? Colors.white : const Color(0xFF4B5563),
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ───────────────────────────────────────
class _Label extends StatelessWidget {
  final String icon;
  final String text;
  const _Label({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.barlow(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9CA3AF),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _TeamDropdown extends StatelessWidget {
  final Country? value;
  final List<Country> countries;
  final String hint;
  final ValueChanged<Country?> onChanged;

  const _TeamDropdown({
    required this.value,
    required this.countries,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D3347)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Country>(
          value: value,
          hint: Text(hint,
              style: GoogleFonts.barlow(color: const Color(0xFF6B7280))),
          dropdownColor: const Color(0xFF1A1F2E),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6B7280)),
          items: countries.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(c.displayName,
                  style:
                      GoogleFonts.barlow(color: Colors.white, fontSize: 15)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}