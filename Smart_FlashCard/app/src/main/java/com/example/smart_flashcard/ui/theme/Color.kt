package com.example.smart_flashcard.ui.theme

import androidx.compose.ui.graphics.Color

// ==========================================
// PURE MEDICAL CLINICAL LIGHT THEME PALETTE
// Designed for MBBS Students (19-22 age group)
// ==========================================

// Core Identity
val MedicalPrimary = Color(0xFF0284C7)         // Electric Cyan / Teal (Main action)
val MedicalPrimaryVariant = Color(0xFF0369A1)  // Darker Cyan
val MedicalSecondary = Color(0xFF1E40AF)       // Deep Cobalt (Headers & Subjects)
val MedicalSecondaryVariant = Color(0xFF1D4ED8)

// Pure Light Canvas & Surfaces
val MedicalBackground = Color(0xFFF8FAFC)      // Soft Ice Slate (Anti-glare canvas)
val MedicalSurface = Color(0xFFFFFFFF)         // Pure White (Flashcard front/back)
val MedicalSurfaceVariant = Color(0xFFF1F5F9)  // Secondary containers
val MedicalBorder = Color(0xFFE2E8F0)          // Crisp hairline border (1dp)

// High-Contrast Medical Typography
val MedicalTextPrimary = Color(0xFF0F172A)     // Deep Obsidian (Questions, high contrast)
val MedicalTextSecondary = Color(0xFF475569)   // Slate (Explanations, counts)
val MedicalTextMuted = Color(0xFF94A3B8)       // Light slate (Metadata, timestamps)

// Active Recall & Study States
val StateKnown = Color(0xFF10B981)             // Emerald Mint ("Known" / Mastered)
val StateKnownContainer = Color(0xFFD1FAE5)    // Light Mint background
val StateReview = Color(0xFFF59E0B)            // Warm Amber ("Needs Revision")
val StateReviewContainer = Color(0xFFFEF3C7)   // Light Amber background
val StateAgain = Color(0xFFEF4444)             // Pulse Coral Red ("Again" / Missed)
val StateAgainContainer = Color(0xFFFEE2E2)    // Light Coral background

// AI Feature Highlights
val AiAccent = Color(0xFF8B5CF6)               // Electric Violet (AI distractors badge)
val AiAccentContainer = Color(0xFFEDE9FE)      // Soft Violet pill background

// Streaks & Motivation
val StreakFlame = Color(0xFFF43F5E)            // Energetic Rose (Study Streaks)
val StreakContainer = Color(0xFFFFE4E6)