# Prime & Detonate - Godot Implementation Roadmap

## Overview
This roadmap breaks down the implementation of the Prime & Detonate game design into manageable sessions that can be completed in 2-4 hours each. Each session builds upon the previous work while maintaining a playable state.

---

## Session 1: Core Data Structures & Prime/Detonate Foundation
**Duration:** 3-4 hours  
**Goal:** Establish the fundamental data structures for the prime/detonate system

### Tasks:
1. **Create Data Configuration System**
   - Create `data/` folder in project root
   - Create JSON files for: `abilities.json`, `weapons.json`, `enemies.json`, `characters.json`
   - Create `DataManager.gd` singleton to load and manage JSON data

2. **Implement Prime/Detonate System**
   - Create `PrimeEffect.gd` class for status effects
   - Create `Ability.gd` class with prime/detonator types
   - Create `Weapon.gd` class with element types (Kinetic, Arc, Thermal, Void)
   - Add prime/detonate logic to `Actor.gd`

3. **Update Battle System**
   - Modify `BattleModel.gd` to handle prime effects
   - Add prime effect display to UI (simple icons above enemy portraits)
   - Test basic prime application and detonation

### Deliverables:
- Working prime/detonate system with JSON data
- Basic UI showing prime effects
- Simple test abilities (Burn prime, Thermal Burst detonator)

---

## Session 2: Element System & Damage Types
**Duration:** 3-4 hours  
**Goal:** Implement the four element types and their interactions

### Tasks:
1. **Element System Implementation**
   - Create `ElementType.gd` enum (Kinetic, Arc, Thermal, Void)
   - Create `DamageType.gd` class with element-specific effects
   - Implement damage flow: Shields → Armor → HP

2. **Element-Specific Effects**
   - Arc: Shield damage bonus, Overload chance
   - Thermal: Armor damage bonus, Burn DoT
   - Void: Armor pierce, Suppress chance
   - Kinetic: Balanced damage, no special effects

3. **Update Actor Class**
   - Add shields and armor properties
   - Implement element-based damage calculations
   - Add status effect processing (Overload, Burn, Suppress)

### Deliverables:
- Four-element damage system
- Status effects working (Burn DoT, Overload stun, Suppress delay)
- Updated UI showing shields/armor/HP bars

---

## Session 3: Character Classes & Abilities
**Duration:** 4 hours  
**Goal:** Implement the four character classes with their unique abilities

### Tasks:
1. **Character Class System**
   - Create `CharacterClass.gd` enum (Vanguard, Technomancer, Pyromancer, Voidrunner)
   - Create `Character.gd` class extending Actor
   - Map existing characters to classes (Nova→Vanguard, etc.)

2. **Class-Specific Abilities**
   - Vanguard: Shield-focused abilities, defensive primes
   - Technomancer: Arc abilities, tech-based detonators
   - Pyromancer: Thermal abilities, fire-based primes
   - Voidrunner: Void abilities, debuff-focused primes

3. **Ability System Enhancement**
   - Create ability cooldowns
   - Implement ability costs (super energy)
   - Add ability descriptions and tooltips

### Deliverables:
- Four distinct character classes
- Class-specific ability sets
- Working cooldown and cost systems

---

## Session 4: Weapon System & Loadouts
**Duration:** 3-4 hours  
**Goal:** Implement weapon system that determines basic attack elements

### Tasks:
1. **Weapon Implementation**
   - Create weapon archetypes: Kinetic Railgun, Arc Blaster, Thermal Lance, Void Projector
   - Implement weapon stats (damage, modifiers, special effects)
   - Create weapon unlock system (defeat enemies to unlock)

2. **Loadout System**
   - Create `LoadoutManager.gd` for managing character equipment
   - Implement weapon switching between battles
   - Add weapon preview in loadout screen

3. **Basic Attack Enhancement**
   - Make basic attack use weapon's element
   - Add weapon-specific visual effects
   - Implement weapon damage calculations

### Deliverables:
- Working weapon system
- Basic loadout management
- Element-based basic attacks

---

## Session 5: Super System & Individual Meters
**Duration:** 3-4 hours  
**Goal:** Implement individual super meters with tiered abilities

### Tasks:
1. **Super Meter System**
   - Add individual super meters (0-300) for each character
   - Implement super energy gain from dealing/taking damage
   - Create tiered super usage (100, 200, 300 points)

2. **Super Abilities**
   - Create cinematic super abilities for each class
   - Implement super ability effects and animations
   - Add super meter UI display

3. **Super Integration**
   - Add super buttons to battle UI
   - Implement super ability targeting
   - Create super ability cooldowns

### Deliverables:
- Individual super meters working
- Tiered super abilities
- Super meter UI integration

---

## Session 6: Enemy Factions & AI
**Duration:** 4 hours  
**Goal:** Implement the four enemy factions with distinct AI behaviors

### Tasks:
1. **Faction System**
   - Create `Faction.gd` enum (Voidborn, Syndicate, Accord, Outlaws)
   - Create faction-specific enemy types
   - Implement faction-specific abilities and resistances

2. **AI Enhancement**
   - Implement smarter enemy AI based on faction
   - Add elite and mini-boss enemy types
   - Create faction-specific attack patterns

3. **Enemy Variety**
   - Create diverse enemy rosters for each faction
   - Implement faction-specific visual themes
   - Add faction-specific dialogue and flavor text

### Deliverables:
- Four distinct enemy factions
- Improved AI behaviors
- Faction-specific enemies and abilities

---

## Session 7: Dialogue System & Skill Checks
**Duration:** 4 hours  
**Goal:** Implement the Art of War-inspired dialogue system

### Tasks:
1. **Dialogue System**
   - Create `DialogueManager.gd` for handling conversations
   - Implement visual novel-style dialogue UI
   - Create dialogue data structure with branching

2. **Skill Check System**
   - Implement 3 skill checks per dialogue scene
   - Create pass/fail consequences (party buffs/debuffs)
   - Add skip dialogue option with auto-debuff

3. **Dialogue Integration**
   - Connect dialogue to battle system
   - Implement dialogue consequences in combat
   - Create tutorial dialogue with skill checks

### Deliverables:
- Working dialogue system
- Skill check mechanics
- Dialogue-to-battle integration

---

## Session 8: UI Polish & HUD Enhancement
**Duration:** 3-4 hours  
**Goal:** Create the sci-fi HUD with Destiny/Halo aesthetic

### Tasks:
1. **Combat HUD Redesign**
   - Implement 6-slot ability layout (Basic, Sustain, 4 abilities)
   - Create sci-fi glass panel styling
   - Add holographic scanlines and effects

2. **Status Display Enhancement**
   - Improve prime effect icons above enemies
   - Add individual super meter displays
   - Create better health/shield/armor visualization

3. **UI Animations**
   - Add smooth transitions between screens
   - Implement button hover effects
   - Create sci-fi UI sound effects

### Deliverables:
- Polished sci-fi HUD
- Enhanced status displays
- Smooth UI animations

---

## Session 9: Mission Structure & Progression
**Duration:** 4 hours  
**Goal:** Implement the Mission Select → Dialogue → Loadout → Battle loop

### Tasks:
1. **Mission System**
   - Create `MissionManager.gd` for handling mission flow
   - Implement mission selection screen
   - Create mission data structure with rewards

2. **Progression System**
   - Implement weapon unlocking from mission completion
   - Create mission difficulty scaling
   - Add mission completion tracking

3. **Game Flow Integration**
   - Connect all screens (Mission → Dialogue → Loadout → Battle)
   - Implement save/load system for progress
   - Create mission completion rewards

### Deliverables:
- Complete game flow working
- Mission progression system
- Weapon unlocking mechanics

---

## Session 10: Tutorial Mission & Polish
**Duration:** 3-4 hours  
**Goal:** Create the tutorial mission and final polish

### Tasks:
1. **Tutorial Implementation**
   - Create guided tutorial mission
   - Implement step-by-step battle instructions
   - Add tooltips and help text

2. **Final Polish**
   - Balance combat numbers
   - Add sound effects and music
   - Implement victory/defeat screens

3. **Testing & Bug Fixes**
   - Test complete game flow
   - Fix any remaining bugs
   - Optimize performance

### Deliverables:
- Complete tutorial mission
- Polished, playable game
- Ready for content expansion

---

## Future Sessions (Post-MVP)

### Session 11: Content Expansion
- Add more abilities, weapons, and enemies
- Create additional missions
- Implement weekly/daily challenges

### Session 12: Advanced Features
- Faction reputation system
- Gear modification/crafting
- Achievement system

### Session 13: Mobile Optimization
- Touch controls optimization
- Mobile UI adjustments
- Performance optimization for mobile

---

## Technical Notes

### File Structure:
```
data/
├── abilities.json
├── weapons.json
├── enemies.json
├── characters.json
├── factions.json
└── missions.json

scripts/
├── data/
│   ├── DataManager.gd
│   ├── Ability.gd
│   ├── Weapon.gd
│   ├── Character.gd
│   └── PrimeEffect.gd
├── systems/
│   ├── LoadoutManager.gd
│   ├── MissionManager.gd
│   └── DialogueManager.gd
└── [existing files]
```

### Key Design Principles:
1. **JSON-Driven Content:** All game data in JSON files for easy modification
2. **Modular Systems:** Each system can be developed and tested independently
3. **Progressive Enhancement:** Each session adds functionality while maintaining playability
4. **Mobile-First:** UI designed for portrait mode and touch controls

### Testing Strategy:
- Test each session's deliverables before moving to the next
- Maintain a playable state after each session
- Use simple placeholder content initially, polish later
- Focus on core mechanics first, visual polish second

---

## Getting Started

1. **Session 1 Prerequisites:**
   - Current battle system working
   - Basic Actor class with HP/damage
   - Simple UI with buttons

2. **Session 1 Setup:**
   - Create `data/` folder
   - Set up JSON file structure
   - Create DataManager singleton

3. **Success Criteria:**
   - Can load JSON data
   - Can apply prime effects
   - Can detonate primes for bonus damage
   - UI shows prime status

This roadmap provides a clear path from the current state to a fully-featured Prime & Detonate game while maintaining manageable, testable progress at each step.
