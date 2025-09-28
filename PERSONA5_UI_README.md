# Persona 5-Style Battle UI System

## Overview
This implementation adds a dynamic, Persona 5-inspired UI system to the battle screen with a three-character party and animated transitions.

## Features

### Character Selection
- **Three Party Members**: Kai (Red theme), Nova (Blue theme), Zara (Green theme)
- **Dynamic Selection**: Use arrow keys (Left/Right/Down) or number keys (1/2/3) to switch between characters
- **Visual Feedback**: Selected character scales up with glowing effects and color themes

### UI Animations
- **Character Scaling**: Selected character grows 30% larger with smooth transitions
- **Glow Effects**: Pulsing glow behind selected character using character-specific colors
- **UI Transitions**: Button panel "pops" with scale animation when switching characters
- **Color Themes**: Each character has unique color scheme applied to UI elements

### Character Themes (Soft & Subtle)
1. **Kai (Character 1)**: Soft coral red with warm accents
2. **Nova (Character 2)**: Gentle sky blue with cool accents  
3. **Zara (Character 3)**: Muted forest green with natural accents

### Controls
- **Arrow Keys**: Left (Kai), Right (Nova), Down (Zara)
- **Number Keys**: 1 (Kai), 2 (Nova), 3 (Zara)
- **Battle Actions**: Attack, Heal, Fireball, Lightning, End Turn

### UI Components
- **Party Stats Panels**: Shows all three party members' stats simultaneously with individual HP bars
- **Dynamic Panel Highlighting**: Selected character's panel lights up with themed styling
- **Dynamic Button Styling**: Action buttons change colors to match selected character (softer colors)
- **Turn Display**: Shows current turn with character-specific coloring
- **Real-time HP Updates**: Health bars and stats update immediately when characters take damage
- **Instructions**: On-screen guide for character switching

## Technical Implementation

### Key Scripts
- `PartyManager.gd`: Handles character selection, animations, and theme management
- `Battle.gd`: Updated to work with party selection system
- `Actor.gd`: Base character class with combat abilities

### Animation System
- Uses Godot's Tween system for smooth transitions
- Character scaling with bounce effects
- Glow sprite creation and pulsing animations
- UI element color transitions

### Character Stats
- **Kai**: 35 HP, 10 ATK, 12 SPD (Balanced fighter)
- **Nova**: 28 HP, 12 ATK, 15 SPD (Fast attacker)
- **Zara**: 32 HP, 8 ATK, 18 SPD (Speed specialist)

## Usage
1. Start the battle scene
2. Use arrow keys or number keys to select different party members
3. Watch the smooth animations and color theme changes
4. Execute actions with the selected character
5. UI dynamically updates to reflect the active character's theme

The system provides a visually engaging way to manage a party of characters with smooth, Persona 5-inspired transitions and theming.
