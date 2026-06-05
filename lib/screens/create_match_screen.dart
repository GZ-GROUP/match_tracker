import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/match_provider.dart';
import '../models/models.dart';
import 'package:intl/date_symbol_data_local.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  Country? _homeTeam;
  Country? _awayTeam;
  DateTime? _selectedDate;
  String _stage = 'Fase de grupos';

  final List<String> _stages = [
    'Fase de grupos',
    'Octavos de final',
    'Cuartos de final',
    'Semifinal',
    'Tercer puesto',
    'Final',
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026, 6, 1),
      lastDate: DateTime(2026, 7, 31),
      builder: (context, child) => _darkDatePicker(context, child),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_homeTeam == null || _awayTeam == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFF59E0B),
          content: Text(
            'Selecciona ambos equipos y la fecha',
            style: GoogleFonts.barlow(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final match = Match(
      homeTeamId: _homeTeam!.id,
      awayTeamId: _awayTeam!.id,
      homeTeamScore: 0,
      awayTeamScore: 0,
      date: _selectedDate!,
      stage: _stage,
    );

    final provider = context.read<MatchProvider>();
    final success = await provider.createMatch(match);

    if (context.mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            content: Text(
              'Partido creado exitosamente',
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
              provider.error ?? 'Error al crear partido',
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
          'Nuevo Partido',
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
          // ── Header ──────────────────────────────────────
          _SectionHeader(icon: '1️⃣', label: 'Equipo 1'),
          const SizedBox(height: 10),
          _CountryDropdown(
            value: _homeTeam,
            countries: countries,
            hint: 'Seleccionar equipo 1',
            onChanged: (c) => setState(() => _homeTeam = c),
          ),

          const SizedBox(height: 24),

          _SectionHeader(icon: '2️⃣', label: 'Equipo 2'),
          const SizedBox(height: 10),
          _CountryDropdown(
            value: _awayTeam,
            countries: countries,
            hint: 'Seleccionar equipo 2',
            onChanged: (c) => setState(() => _awayTeam = c),
          ),

          // ── VS preview ───────────────────────────────────
          

          const SizedBox(height: 24),

          _SectionHeader(icon: '📅', label: 'Fecha del partido'),
          const SizedBox(height: 10),
          _DatePickerTile(
            selectedDate: _selectedDate,
            onTap: _pickDate,
          ),

          const SizedBox(height: 24),

          _SectionHeader(icon: '🏆', label: 'Fase'),
          const SizedBox(height: 10),
          _StageDropdown(
            value: _stage,
            stages: _stages,
            onChanged: (s) => setState(() => _stage = s!),
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'El marcador se guardará como 0-0. Podrás actualizarlo al editar el partido.',
                    style: GoogleFonts.barlow(
                      fontSize: 12,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Submit button ────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: provider.isLoading ? null : _submit,
              child: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Crear Partido',
                      style: GoogleFonts.barlow(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          label,
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

class _CountryDropdown extends StatelessWidget {
  final Country? value;
  final List<Country> countries;
  final String hint;
  final ValueChanged<Country?> onChanged;

  const _CountryDropdown({
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
          hint: Text(
            hint,
            style: GoogleFonts.barlow(color: const Color(0xFF6B7280)),
          ),
          dropdownColor: const Color(0xFF1A1F2E),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6B7280)),
          items: countries.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(
                c.displayName,
                style: GoogleFonts.barlow(color: Colors.white, fontSize: 15),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}



class _DatePickerTile extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const _DatePickerTile({required this.selectedDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedDate != null
                ? const Color(0xFF3B82F6).withOpacity(0.4)
                : const Color(0xFF2D3347),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: selectedDate != null
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFF6B7280),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              selectedDate != null
                  ? DateFormat('EEEE, d MMMM yyyy', 'es').format(selectedDate!)
                  : 'Seleccionar fecha',
              style: GoogleFonts.barlow(
                color: selectedDate != null ? Colors.white : const Color(0xFF6B7280),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageDropdown extends StatelessWidget {
  final String value;
  final List<String> stages;
  final ValueChanged<String?> onChanged;

  const _StageDropdown({
    required this.value,
    required this.stages,
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
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1A1F2E),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6B7280)),
          items: stages.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(
                s,
                style: GoogleFonts.barlow(color: Colors.white, fontSize: 15),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

Widget _darkDatePicker(BuildContext context, Widget? child) {
  return Theme(
    data: ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3B82F6),
        surface: Color(0xFF1A1F2E),
      ),
    ),
    child: child!,
  );
}