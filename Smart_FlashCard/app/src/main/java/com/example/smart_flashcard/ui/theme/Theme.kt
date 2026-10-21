package com.example.smart_flashcard.ui.theme

import android.app.Activity
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

// Pure Medical Clinical Light Color Scheme (Locked to Light Mode)
private val MedicalLightColorScheme = lightColorScheme(
    primary = MedicalPrimary,
    onPrimary = MedicalSurface,
    primaryContainer = MedicalSurfaceVariant,
    onPrimaryContainer = MedicalTextPrimary,
    
    secondary = MedicalSecondary,
    onSecondary = MedicalSurface,
    secondaryContainer = MedicalSurfaceVariant,
    onSecondaryContainer = MedicalTextPrimary,
    
    tertiary = AiAccent,
    onTertiary = MedicalSurface,
    tertiaryContainer = AiAccentContainer,
    onTertiaryContainer = MedicalTextPrimary,
    
    background = MedicalBackground,
    onBackground = MedicalTextPrimary,
    
    surface = MedicalSurface,
    onSurface = MedicalTextPrimary,
    surfaceVariant = MedicalSurfaceVariant,
    onSurfaceVariant = MedicalTextSecondary,
    
    outline = MedicalBorder,
    outlineVariant = MedicalBorder,
    
    error = StateAgain,
    onError = MedicalSurface,
    errorContainer = StateAgainContainer,
    onErrorContainer = MedicalTextPrimary
)

@Composable
fun Smart_FlashCardTheme(
    content: @Composable () -> Unit
) {
    // Pure Clinical Light Theme - Always Light Mode
    val colorScheme = MedicalLightColorScheme
    val view = LocalView.current
    
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = MedicalBackground.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = true
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}