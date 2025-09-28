# Prime & Detonate – Game Design Master Reference

## 1. Core Concept
- **Genre:** Turn-based, story-driven sci-fi RPG.
- **Inspiration:** Persona 5 (combat flow), Final Fantasy VII/VIII (structure), Destiny/Halo/Marathon (aesthetic).
- **Platform:** Portrait-mode Progressive Web App (PWA), mobile-first, thumb-friendly controls.
- **Loop:** Mission Select → Dialogue → Loadout → Battle.
- **Tone/Vibe:** Clean sci-fi HUD, Destiny/Halo UI polish, subtle Star Trek TNG influence.

---

## 2. Core Gameplay: Prime & Detonate
- **Abilities:**
  - Either **Prime** (applies status) or **Detonator** (consumes status).
  - Some abilities are both.
- **Double Prime Rule:**
  - Two primes can stack on a target.
  - A detonator may trigger both if compatible.
- **Damage Flow:** Shields → Armor → HP.
- **Damage Types:**
  - Kinetic: Balanced, no extra effect.
  - Arc: Strong vs shields, chance to Overload (stun).
  - Thermal: Strong vs armor, Burn DoT.
  - Void: Partial armor pierce, chance to Suppress (delay initiative).
- **Supers:** High-cost cinematic abilities. Each character has an **individual super meter** (0–300) with tiered usage at 100, 200, 300.

---

## 3. Buffs & Debuffs
- Unified into the prime/detonator system.
- **Examples:**
  - Buffs: Shield Overcharge, Haste.
  - Debuffs: Defense Break, Accuracy Jam.
- **Dialogue Consequences:**
  - Pass all skill checks → Party buff.
  - Fail checks → Party debuff.
  - Skip to battle → Auto-debuff.

---

## 4. Loadouts & Abilities
- **Weapons:**
  - One main weapon per character.
  - Weapon sets the **element for basic attack** (Kinetic, Arc, Thermal, Void).
- **Abilities:**
  - Independent of weapon.
  - Characters always keep their class-based ability set.
- **Unlocking Weapons:**
  - Completing a mission and defeating all enemies unlocks that mission’s weapon.

---

## 5. Weapons & Archetypes
- **Kinetic Railgun:** Precision, single-target.
- **Arc Blaster:** Chain lightning, primes Overload.
- **Thermal Lance:** Beam, primes Burn.
- **Void Projector:** Pierces armor, primes Suppress.
- **Design Rule:** Weapon = element for basic attack. Abilities remain independent.

---

## 6. Enemy Factions
- **Voidborn:** Eldritch alien machines, cryptic speech, debuff resistance, regeneration.  
- **Syndicate:** Corporate tech empire, cyber-enhanced soldiers, precision strikes, counter-attacks.  
- **Accord:** Militaristic authoritarian humans, disciplined formations, durable tanks.  
- **Outlaws:** Rogue scavengers, neon-cluttered spaces, swarm/grunt-heavy tactics.

---

## 7. Enemy AI
- **Grunts:** Attack nearest player, occasional defend.  
- **Elites:** Smarter targeting (weaker player focus), use special abilities on timers.  
- **Mini-Bosses:** Advanced elites with tactical behavior, extra ability variety.  
- **Bosses:** 3-phase encounters; attack patterns and abilities shift at HP thresholds, may gain extra turns.

---

## 8. Story & Dialogue
- **Structure:** Linear narrative broken into missions/chapters.  
- **Dialogue:** Visual novel style, top/mid screen text, tap to continue.  
- **Branching:** Not infinite — instead, dialogue choices function as **3 skill checks per scene.**  
- **System:**
  - Inspired by *Art of War* lessons.  
  - Passing checks → Buff.  
  - Failing → Debuff.  
  - Skip dialogue → Instant debuff, battle begins.

---

## 9. UI & UX
- **Combat HUD:**
  - 6 slots: Basic Attack, Sustain, 4 ability slots.
  - Enemy selection by tapping portraits.
  - Health/Shield/Armor bars segmented near portraits.
  - Super meters shown individually for each character.
  - Status primes displayed as glowing icons above enemy portraits.
  - Footer bar with **Use** button (auto-select flow for faster play).
- **Dialogue HUD:**
  - Text box bottom-third.
  - Speaker portraits on left/right; narrator text top.
  - Tap to advance; choices shown as buttons.
- **Menus:**
  - Glass panel overlays, subtle scanlines, holographic feel.
  - Diegetic helmet-HUD vibe.

---

## 10. Content Cadence
- **Monthly:** New mutator, 1–2 weapons, 1–2 enemies.  
- **Quarterly:** New story chapter + boss.  
- **Weekly:** Rotating modifiers/events.  
- All content defined via JSON configs for low-maintenance updates.

---

## 11. Technical Infrastructure
- **Frontend:** Next.js + React.  
- **Data:** `/src/data/*.json` files for primes, abilities, enemies, weapons.  
- **Workflow:** Feature flags for testing:
  ```json
  { "primeDecay": true, "comboSupers": true }
  ```
- **Hosting:** PWA-ready, offline via service worker.  
- **Icons & Sprites:** Start with Phosphor/Heroicons; expand with custom sets.  
- **Animations:** Lightweight CSS transforms, sprite sheets.

---

## 12. Game Data Example
```json
// Prime (Burn)
{
  "id": "burn",
  "type": "prime",
  "duration": 3,
  "effect": "thermal_dot",
  "compatibility": ["thermal_lance", "explosive_rounds"]
}

// Detonator (Thermal Burst)
{
  "id": "thermal_burst",
  "type": "detonator",
  "effect": "consume_burn",
  "bonusDamage": 1.5
}
```

---

## 13. Characters
- **Nova (Kinetic Bruiser):** Rogue Accord officer, redemption arc.  
- **Volt (Arc Specialist):** Syndicate defector, technomancer.  
- **Ember (Thermal Pyromancer):** Smuggler from Outlaw turf, unstable reactor powers.  
- **Shade (Void Debuffer):** Ex-Voidborn cult initiate, family ties inside cult.

---

## 14. Tutorial Mission
- Guided step-by-step battle: teach target select, basic attack, Prime, Detonate, Super.  
- Dialogue includes first **Art of War skill checks.**  
- Win → Reward weapon + buff.  
- Fail → Retry with tips.

---

## 15. Success & Fail Screens
- **Victory:** Heroic party splash art, mission wrap-up text, unlock rewards.  
- **Defeat:** “Mission Failed” banner, boss taunt, retry or adjust loadout.

---

## 16. Future Systems
- **Faction reputation system.**  
- **Daily/weekly challenges.**  
- **Gear modification/crafting.**  
- **Achievements/collectibles for lore.**
