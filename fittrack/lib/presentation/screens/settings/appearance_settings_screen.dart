import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class _AccentSwatch {
  final Color color;
  final String label;
  final String fullName;

  const _AccentSwatch({
    required this.color,
    required this.label,
    required this.fullName,
  });
}

const List<_AccentSwatch> _accentSwatches = [
  _AccentSwatch(
    color: Color(0xFF00D68F),
    label: 'Mint',
    fullName: 'Kinetic Mint',
  ),
  _AccentSwatch(
    color: Color(0xFF2563EB),
    label: 'Electric',
    fullName: 'Electric Blue',
  ),
  _AccentSwatch(
    color: Color(0xFF8B5CF6),
    label: 'Purple',
    fullName: 'Royal Purple',
  ),
  _AccentSwatch(
    color: Color(0xFFF97316),
    label: 'Sunset',
    fullName: 'Sunset Orange',
  ),
  _AccentSwatch(
    color: Color(0xFF10B981),
    label: 'Emerald',
    fullName: 'Emerald Green',
  ),
  _AccentSwatch(
    color: Color(0xFFDC2626),
    label: 'Crimson',
    fullName: 'Crimson Red',
  ),
  _AccentSwatch(
    color: Color(0xFF1D4ED8),
    label: 'Cobalt',
    fullName: 'Cobalt Navy',
  ),
  _AccentSwatch(
    color: Color(0xFFD946EF),
    label: 'Berry',
    fullName: 'Berry Magenta',
  ),
];

/// FitTrack Appearance Settings Screen.
///
/// Implemented strictly to match the Stitch design specification:
/// - Header with back navigation, "Appearance" title, and V3.4 badge pill
/// - Live Preview interactive mockup reactively styled by current accent color
/// - 3 square Theme Mode selector cards (Light, Dark, System)
/// - Dynamic Accent switch card with BETA tag
/// - 2x4 Color Accent swatches grid with active rings
/// - Ergonomics & Accessibility switches (Pure Black OLED, High Contrast, Auto-Dark, Keep Awake)
class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  String _getActiveColorName(int colorValue) {
    for (final swatch in _accentSwatches) {
      if (swatch.color.toARGB32() == colorValue) {
        return swatch.fullName;
      }
    }
    return 'Kinetic Mint';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    final accentColor = themeSettings.accentColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOled = themeSettings.useOledBlack && isDark;

    final scaffoldBg = isDark
        ? (isOled ? const Color(0xFF000000) : const Color(0xFF0F172A))
        : const Color(0xFFF7F9FB);
    final cardBg = isDark
        ? (isOled ? const Color(0xFF000000) : const Color(0xFF1E293B))
        : Colors.white;
    final borderColor = isDark
        ? (isOled ? const Color(0xFF262626) : const Color(0xFF334155))
        : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final iconBg =
        isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Navigation & Subtitle ───────────────────────────────
              _buildHeader(
                context: context,
                accentColor: accentColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                iconBg: iconBg,
              ),
              const SizedBox(height: 24),

              // ── Live Preview Section ───────────────────────────────────────
              _buildLivePreview(
                themeSettings: themeSettings,
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
              ),
              const SizedBox(height: 24),

              // ── Theme Mode Section ─────────────────────────────────────────
              _buildThemeModeSection(
                themeSettings: themeSettings,
                themeNotifier: themeNotifier,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                iconBg: iconBg,
              ),
              const SizedBox(height: 24),

              // ── Dynamic Accent Card ────────────────────────────────────────
              _buildDynamicAccentCard(
                themeSettings: themeSettings,
                themeNotifier: themeNotifier,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // ── Color Accent Swatches Grid ─────────────────────────────────
              _buildColorAccentSection(
                themeSettings: themeSettings,
                themeNotifier: themeNotifier,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
              ),
              const SizedBox(height: 24),

              // ── Ergonomics & Accessibility Section ─────────────────────────
              _buildErgonomicsSection(
                themeSettings: themeSettings,
                themeNotifier: themeNotifier,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                iconBg: iconBg,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Component ───────────────────────────────────────────────────────
  Widget _buildHeader({
    required BuildContext context,
    required Color accentColor,
    required Color textPrimary,
    required Color textMuted,
    required Color iconBg,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Appearance',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'V3.4',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 52),
          child: Text(
            'Customize your visual theme, kinetic accents, and display ergonomics.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textMuted,
            ),
          ),
        ),
      ],
    );
  }

  // ── Live Preview Section ───────────────────────────────────────────────────
  Widget _buildLivePreview({
    required ThemeSettings themeSettings,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textMuted,
  }) {
    final accent = themeSettings.accentColor;
    final onAccentColor = accent.computeLuminance() > 0.55
        ? const Color(0xFF0F172A)
        : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LIVE PREVIEW',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: textMuted,
              ),
            ),
            Row(
              children: [
                _PulsingDot(color: accent),
                const SizedBox(width: 6),
                Text(
                  'Real-time Canvas',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Accent radial glow on the top right
                Positioned(
                  top: -28,
                  right: -28,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accent.withValues(alpha: 0.20),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Workout Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.fitness_center,
                                  size: 16,
                                  color: onAccentColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chest & Triceps',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Hypertrophy Split · Push Day',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // "In Progress" Badge (Dynamically colored)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'In Progress',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Metric Chips
                      Row(
                        children: [
                          _buildMiniChip(
                            label: '45 min',
                            bg: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE6E8EA),
                            textColor: textPrimary,
                          ),
                          const SizedBox(width: 8),
                          _buildMiniChip(
                            label: '350 kcal',
                            bg: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE6E8EA),
                            textColor: textPrimary,
                          ),
                          const SizedBox(width: 8),
                          _buildMiniChip(
                            label: '6 Exercises',
                            bg: isDark
                                ? const Color(0xFF1E3A5F)
                                : const Color(0xFFDAE2FD),
                            textColor: isDark
                                ? const Color(0xFF93C5FD)
                                : const Color(0xFF1E293B),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Session Completion Progress Bar (Dynamically filled)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Session Completion',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: textMuted,
                            ),
                          ),
                          Text(
                            '68%',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFECEEF0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.68,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // "Resume Set" CTA Button (Dynamically colored)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 38,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              size: 16,
                              color: onAccentColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Resume Set 3 of 4',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: onAccentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniChip({
    required String label,
    required Color bg,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ── Theme Mode Section ─────────────────────────────────────────────────────
  Widget _buildThemeModeSection({
    required ThemeSettings themeSettings,
    required ThemeNotifier themeNotifier,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textMuted,
    required Color iconBg,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'THEME MODE',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: textMuted,
              ),
            ),
            Text(
              'Applied Globally',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildThemeModeCard(
                mode: ThemeMode.light,
                title: 'Light',
                subtitle: 'Crisp slate',
                icon: Icons.light_mode_outlined,
                isSelected: themeSettings.themeMode == ThemeMode.light,
                accentColor: themeSettings.accentColor,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                iconBg: iconBg,
                onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildThemeModeCard(
                mode: ThemeMode.dark,
                title: 'Dark',
                subtitle: 'Low-glare',
                icon: Icons.dark_mode_outlined,
                isSelected: themeSettings.themeMode == ThemeMode.dark,
                accentColor: themeSettings.accentColor,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                iconBg: iconBg,
                onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildThemeModeCard(
                mode: ThemeMode.system,
                title: 'System',
                subtitle: 'Auto sync',
                icon: Icons.brightness_auto_outlined,
                isSelected: themeSettings.themeMode == ThemeMode.system,
                accentColor: themeSettings.accentColor,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textMuted: textMuted,
                iconBg: iconBg,
                onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeModeCard({
    required ThemeMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color accentColor,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textMuted,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accentColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (isSelected)
              Positioned(
                top: -6,
                right: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.15)
                        : iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected ? accentColor : textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? accentColor : textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Dynamic Accent Card ────────────────────────────────────────────────────
  Widget _buildDynamicAccentCard({
    required ThemeSettings themeSettings,
    required ThemeNotifier themeNotifier,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    final accent = themeSettings.accentColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFDAE2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.palette_outlined,
              size: 20,
              color: isDark
                  ? const Color(0xFF93C5FD)
                  : const Color(0xFF475569),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Dynamic Accent',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFDAE2FD),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'BETA',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Sync palette with OS device wallpaper extraction (Material You & iOS Tint).',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: themeSettings.useDynamicAccent,
            activeThumbColor: accent,
            activeTrackColor: accent.withValues(alpha: 0.35),
            onChanged: (val) => themeNotifier.toggleDynamicAccent(val),
          ),
        ],
      ),
    );
  }

  // ── Color Accent Section ───────────────────────────────────────────────────
  Widget _buildColorAccentSection({
    required ThemeSettings themeSettings,
    required ThemeNotifier themeNotifier,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textMuted,
  }) {
    final activeColorName = _getActiveColorName(themeSettings.accentColorValue);
    final isDynamic = themeSettings.useDynamicAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COLOR ACCENT',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: textMuted,
              ),
            ),
            Text(
              activeColorName,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: themeSettings.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Applies to buttons, activity bars, rings, and active pills.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textMuted,
          ),
        ),
        const SizedBox(height: 10),
        IgnorePointer(
          ignoring: isDynamic,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isDynamic ? 0.4 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _accentSwatches.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final swatch = _accentSwatches[index];
                  final isSelected =
                      themeSettings.accentColorValue == swatch.color.toARGB32();

                  final onCheckColor =
                      swatch.color.computeLuminance() > 0.55
                          ? const Color(0xFF0F172A)
                          : Colors.white;

                  return GestureDetector(
                    onTap: () => themeNotifier.setAccentColor(swatch.color),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: swatch.color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: swatch.color.withValues(alpha: 0.3),
                                    width: 4,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: swatch.color.withValues(
                                  alpha: isSelected ? 0.4 : 0.15,
                                ),
                                blurRadius: isSelected ? 10 : 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 20,
                                  color: onCheckColor,
                                )
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          swatch.label,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? textPrimary : textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Ergonomics & Accessibility Section ─────────────────────────────────────
  Widget _buildErgonomicsSection({
    required ThemeSettings themeSettings,
    required ThemeNotifier themeNotifier,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textMuted,
    required Color iconBg,
  }) {
    final accent = themeSettings.accentColor;
    final isLightMode = themeSettings.themeMode == ThemeMode.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ERGONOMICS & ACCESSIBILITY',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Pure Black OLED Mode (Disabled in Light Mode)
              IgnorePointer(
                ignoring: isLightMode,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLightMode ? 0.4 : 1.0,
                  child: _buildSwitchRow(
                    icon: Icons.contrast,
                    title: 'Pure Black OLED Mode',
                    subtitle:
                        'Turns dark slate into #000000 to maximize pixel power saving',
                    value: themeSettings.useOledBlack,
                    accentColor: accent,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    iconBg: iconBg,
                    onChanged: (val) => themeNotifier.toggleOledBlack(val),
                  ),
                ),
              ),
              Divider(height: 1, thickness: 1, color: borderColor),

              // 2. High Contrast Text
              _buildSwitchRow(
                icon: Icons.text_fields,
                title: 'High Contrast Text',
                subtitle:
                    'Strengthen label contrast against subtle slate containers',
                value: themeSettings.useHighContrast,
                accentColor: accent,
                textPrimary: textPrimary,
                textMuted: textMuted,
                iconBg: iconBg,
                onChanged: (val) => themeNotifier.toggleHighContrast(val),
              ),
              Divider(height: 1, thickness: 1, color: borderColor),

              // 3. Auto-Dark During Workouts
              _buildSwitchRow(
                icon: Icons.dark_mode_outlined,
                title: 'Auto-Dark During Workouts',
                subtitle:
                    'Automatically switch to Dark Mode (with OLED Black if enabled) while an active workout session is running, reverting to system theme when finished.',
                value: themeSettings.autoDarkWorkout,
                accentColor: accent,
                textPrimary: textPrimary,
                textMuted: textMuted,
                iconBg: iconBg,
                onChanged: (val) => themeNotifier.toggleAutoDarkWorkout(val),
              ),
              Divider(height: 1, thickness: 1, color: borderColor),

              // 4. Keep Screen Awake
              _buildSwitchRow(
                icon: Icons.stay_current_portrait_outlined,
                title: 'Keep Screen Awake',
                subtitle:
                    'Prevent screen from sleeping or dimming while an active workout session is in progress.',
                value: themeSettings.keepScreenAwake,
                accentColor: accent,
                textPrimary: textPrimary,
                textMuted: textMuted,
                iconBg: iconBg,
                onChanged: (val) => themeNotifier.toggleKeepScreenAwake(val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color accentColor,
    required Color textPrimary,
    required Color textMuted,
    required Color iconBg,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeThumbColor: accentColor,
            activeTrackColor: accentColor.withValues(alpha: 0.35),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Helper widget to render an animated pulsing indicator for the real-time preview.
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 1.0 + (_controller.value * 1.0),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(
                    alpha: (1.0 - _controller.value) * 0.6,
                  ),
                ),
              ),
            ),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}
