import 'package:flutter/material.dart';

/// FitTrack "Kinetic Slate" design system — colour tokens extracted from Stitch.
abstract final class AppColors {
  // ── Primary brand ──────────────────────────────────────────────────────────
  static const kineticMint = Color(0xFF00D68F);
  static const kineticMintDark = Color(0xFF00B87A);
  static const kineticMintLight = Color(0xFFE6FAF3);
  static const kineticMintGlow = Color(0x4700D68F); // 28% opacity

  // ── Surface / Background Palettes ─────────────────────────────────────────
  static const surface = Color(0xFFF7F9FB);
  static const cardWhite = Color(0xFFFFFFFF);
  static const lightSurfaceContainer = Color(0xFFF1F5F9);

  // Slate Dark Mode
  static const darkBackground = Color(0xFF0B131F);
  static const darkSurface = Color(0xFF15202E);
  static const darkSurfaceContainer = Color(0xFF1C2A3D);
  static const darkOutline = Color(0xFF212B3C);

  // Pure OLED Dark Mode
  static const oledBackground = Color(0xFF000000);
  static const oledSurface = Color(0xFF0C1017);
  static const oledSurfaceContainer = Color(0xFF141A24);
  static const oledOutline = Color(0xFF1F2633);

  // ── Dark / Text ────────────────────────────────────────────────────────────
  static const slateDark = Color(0xFF0F172A); // slate-900
  static const slate800 = Color(0xFF1E293B);
  static const slate700 = Color(0xFF334155);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const slate400 = Color(0xFF94A3B8);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);

  // ── Status colours ─────────────────────────────────────────────────────────
  static const emerald700 = Color(0xFF047857);
  static const errorRed = Color(0xFFBA1A1A);
}
