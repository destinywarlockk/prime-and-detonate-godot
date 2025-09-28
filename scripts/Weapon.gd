extends RefCounted
class_name Weapon

# Weapon - Represents a weapon that determines basic attack element and provides modifiers
# Based on the four weapon archetypes: Kinetic Railgun, Arc Blaster, Thermal Lance, Void Projector

enum WeaponType {
	KINETIC_RAILGUN,
	ARC_BLASTER,
	THERMAL_LANCE,
	VOID_PROJECTOR
}

var id: String
var name: String
var description: String
var weapon_type: WeaponType
var element: String
var base_damage: int
var icon: String
var modifiers: Dictionary
var unlocked: bool

func _init(weapon_data: Dictionary = {}):
	if weapon_data.size() > 0:
		load_from_data(weapon_data)

func load_from_data(data: Dictionary):
	"""Load weapon data from JSON/Dictionary"""
	id = data.get("id", "")
	name = data.get("name", "Unknown Weapon")
	description = data.get("description", "")
	element = data.get("element", "kinetic")
	base_damage = data.get("damage", 25)
	icon = data.get("icon", "")
	unlocked = data.get("unlocked", false)
	
	# Load modifiers
	modifiers = data.get("modifiers", {})
	
	# Set weapon type based on element
	match element:
		"kinetic":
			weapon_type = WeaponType.KINETIC_RAILGUN
		"arc":
			weapon_type = WeaponType.ARC_BLASTER
		"thermal":
			weapon_type = WeaponType.THERMAL_LANCE
		"void":
			weapon_type = WeaponType.VOID_PROJECTOR

# Get the basic attack damage with modifiers applied
func get_basic_attack_damage() -> int:
	var damage = base_damage
	var basic_mult = modifiers.get("basicMult", 1.0)
	var total_damage_mult = modifiers.get("totalDamageMult", 1.0)
	
	damage = int(damage * basic_mult * total_damage_mult)
	return damage

# Get shield bonus from weapon
func get_shield_bonus() -> int:
	return modifiers.get("maxShBonus", 0)

# Get health bonus from weapon
func get_health_bonus() -> int:
	return modifiers.get("maxHpBonus", 0)

# Get weapon color based on element
func get_element_color() -> Color:
	match element:
		"kinetic":
			return Color.GREEN
		"arc":
			return Color.CYAN
		"thermal":
			return Color.ORANGE
		"void":
			return Color.PURPLE
		_:
			return Color.WHITE

# Get weapon type as string
func get_type_string() -> String:
	match weapon_type:
		WeaponType.KINETIC_RAILGUN:
			return "Kinetic Railgun"
		WeaponType.ARC_BLASTER:
			return "Arc Blaster"
		WeaponType.THERMAL_LANCE:
			return "Thermal Lance"
		WeaponType.VOID_PROJECTOR:
			return "Void Projector"
		_:
			return "Unknown Weapon"

# Check if weapon can apply a prime effect with basic attack
func can_prime_with_basic_attack() -> bool:
	# Only some weapons can prime with basic attacks
	match weapon_type:
		WeaponType.ARC_BLASTER:
			return true  # Can prime Overload
		WeaponType.THERMAL_LANCE:
			return true  # Can prime Burn
		WeaponType.VOID_PROJECTOR:
			return true  # Can prime Suppress
		_:
			return false  # Kinetic Railgun is pure damage

# Get the prime effect this weapon can apply with basic attack
func get_basic_attack_prime() -> PrimeEffect:
	match weapon_type:
		WeaponType.ARC_BLASTER:
			return PrimeEffect.create_overload(1, 0.2)  # Low chance on basic attack
		WeaponType.THERMAL_LANCE:
			return PrimeEffect.create_burn(2, 10)  # Shorter duration, less damage
		WeaponType.VOID_PROJECTOR:
			return PrimeEffect.create_suppress(1, 0.3)  # Shorter duration
		_:
			return null

# Get weapon damage type for combat calculations
func get_damage_type() -> String:
	return element

# Get weapon effectiveness against different defense types
func get_effectiveness_multiplier(defense_type: String) -> float:
	match element:
		"arc":
			if defense_type == "shields":
				return 1.5  # Strong vs shields
			elif defense_type == "armor":
				return 0.8  # Weak vs armor
		"thermal":
			if defense_type == "armor":
				return 1.5  # Strong vs armor
			elif defense_type == "shields":
				return 0.9  # Slightly weak vs shields
		"void":
			if defense_type == "armor":
				return 1.2  # Partial armor pierce
			elif defense_type == "shields":
				return 1.0  # Normal vs shields
		"kinetic":
			return 1.0  # Balanced against all defenses
	
	return 1.0

# Check if weapon is unlocked
func is_unlocked() -> bool:
	return unlocked

# Unlock this weapon
func unlock():
	unlocked = true

# Lock this weapon
func lock():
	unlocked = false

# Create a copy of this weapon
func duplicate() -> Weapon:
	var new_weapon = Weapon.new()
	new_weapon.id = id
	new_weapon.name = name
	new_weapon.description = description
	new_weapon.weapon_type = weapon_type
	new_weapon.element = element
	new_weapon.base_damage = base_damage
	new_weapon.icon = icon
	new_weapon.modifiers = modifiers.duplicate()
	new_weapon.unlocked = unlocked
	return new_weapon

# Factory method to create weapon from DataManager
static func create_from_id(weapon_id: String) -> Weapon:
	var data = DataManager.get_weapon_by_id(weapon_id)
	if data.size() == 0:
		push_error("Weapon not found: " + weapon_id)
		return null
	
	return Weapon.new(data)

# Get all unlocked weapons from DataManager
static func get_unlocked_weapons() -> Array:
	var unlocked_weapons = []
	var all_weapons = DataManager.get_unlocked_weapons()
	
	for weapon_data in all_weapons:
		unlocked_weapons.append(Weapon.new(weapon_data))
	
	return unlocked_weapons

# Get weapon by element type
static func get_weapons_by_element(element_type: String) -> Array:
	var weapons = []
	var all_weapons = DataManager.get_all_weapons()
	
	for weapon_data in all_weapons:
		if weapon_data.element == element_type:
			weapons.append(Weapon.new(weapon_data))
	
	return weapons
