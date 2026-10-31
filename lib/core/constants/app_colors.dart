import 'package:flutter/material.dart';

/// DESIGN.md 기반 컬러 팔레트 상수 정의
class AppColors {
  AppColors._();

  // Brand & Accent Colors
  static const Color primary = Color(0xFFFF5A5F);        // Zesty Coral
  static const Color primaryActive = Color(0xFFE04348);  // Coral Pressed
  static const Color primarySoft = Color(0xFFFFF0F1);    // Coral Tint
  static const Color secondary = Color(0xFF00D19A);      // Fresh Mint
  static const Color secondarySoft = Color(0xFFE6FBF5);  // Mint Tint
  static const Color accentPop = Color(0xFFFFB800);      // Sunny Amber

  // Surface & Canvas
  static const Color canvas = Color(0xFFFFFFFF);         // Pure White
  static const Color surfaceSoft = Color(0xFFF8FAFC);    // Cool Alabaster
  static const Color surfaceStrong = Color(0xFFF1F5F9);  // Slate Wash
  static const Color surfaceGlass = Color(0xD1FFFFFF);   // rgba(255, 255, 255, 0.82)

  // Typography & Ink
  static const Color ink = Color(0xFF111827);            // Deep Charcoal
  static const Color body = Color(0xFF334155);           // Slate Body
  static const Color muted = Color(0xFF64748B);          // Cool Muted
  static const Color mutedSoft = Color(0xFF94A3B8);      // Placeholder
  static const Color onPrimary = Color(0xFFFFFFFF);      // Pure White on Accent

  // Hairlines & Semantic
  static const Color hairline = Color(0xFFE2E8F0);       // Border 1px
  static const Color hairlineSoft = Color(0xFFF1F5F9);   // Divider 1px
  static const Color borderFocus = Color(0xFF111827);    // Focus 2px
  static const Color error = Color(0xFFF43F5E);          // Rose Error
  static const Color scrim = Color(0x730F172A);          // rgba(15, 23, 42, 0.45)
}
