extends RefCounted
class_name Ability

# Ability - Represents a character ability with prime/detonator functionality
# Integrates with DataManager and PrimeEffect systems

enum AbilityType {
	OFFENSIVE,
	SUSTAIN,
	PRIME,
	DETONATOR
}

var id: String
var name: String
var description: String
var type: AbilityType
var element: String
var damage: int
var cooldown: int
var super_cost: int
var is_prime: bool
var is_detonator: bool
var prime_effect: PrimeEffect
var detonate_effect: Dictionary
var healing: int = 0

# Current cooldown state
var current_cooldown: int = 0

func _init(ability_data: Dictionary = {}):
	if ability_data.size() > 0:
		load_from_data(ability_data)

func load_from_data(data: Dictionary):
	"""Load ability data from JSON/Dictionary"""
	id = data.get("id", "")
	name = data.get("name", "Unknown Ability")
	description = data.get("description", "")
	element = data.get("element", "kinetic")
	damage = data.get("damage", 0)
	cooldown = data.get("cooldown", 0)
	super_cost = data.get("superCost", 0)
	is_prime = data.get("isPrime", false)
	is_detonator = data.get("isDetonator", false)
	healing = data.get("healing", 0)
	
	# Set ability type based on properties
	if healing > 0:
		type = AbilityType.SUSTAIN
	elif is_prime and is_detonator:
		type = AbilityType.DETONATOR  # Prioritize detonator for dual abilities
	elif is_prime:
		type = AbilityType.PRIME
	elif is_detonator:
		type = AbilityType.DETONATOR
	else:
		type = AbilityType.OFFENSIVE
	
	# Load prime effect if present
	if is_prime and data.has("primeEffect") and data.primeEffect != null:
		prime_effect = create_prime_effect_from_data(data.primeEffect)
	
	# Load detonate effect if present
	if is_detonator and data.has("detonateEffect") and data.detonateEffect != null:
		detonate_effect = data.detonateEffect

func create_prime_effect_from_data(data: Dictionary) -> PrimeEffect:
	"""Create a PrimeEffect from JSON data"""
	var effect_type = PrimeEffect.PrimeType.BURN
	var duration = data.get("duration", 3)
	var damage_per_turn = data.get("damagePerTurn", 0)
	var element = data.get("element", "kinetic")
	var effect_value = data.get("stunChance", data.get("speedReduction", data.get("shieldBonus", 0)))
	
	match data.get("type", "burn"):
		"burn":
			effect_type = PrimeEffect.PrimeType.BURN
		"overload":
			effect_type = PrimeEffect.PrimeType.OVERLOAD
		"suppress":
			effect_type = PrimeEffect.PrimeType.SUPPRESS
		"shield_overcharge":
			effect_type = PrimeEffect.PrimeType.SHIELD_OVERCHARGE
		"haste":
			effect_type = PrimeEffect.PrimeType.HASTE
		"defense_break":
			effect_type = PrimeEffect.PrimeType.DEFENSE_BREAK
		"accuracy_jam":
			effect_type = PrimeEffect.PrimeType.ACCURACY_JAM
	
	var effect = PrimeEffect.new(effect_type, duration, damage_per_turn, element, effect_value)
	return effect

# Check if ability is ready to use
func is_ready() -> bool:
	return current_cooldown <= 0

# Check if ability can be used with current super energy
func can_afford(cost: int) -> bool:
	return cost >= super_cost

# Start cooldown for this ability
func start_cooldown():
	current_cooldown = cooldown

# Reduce cooldown by 1 (call each turn)
func reduce_cooldown():
	if current_cooldown > 0:
		current_cooldown -= 1

# Reset cooldown (for new battles)
func reset_cooldown():
	current_cooldown = 0

# Get the prime effect this ability applies
func get_prime_effect() -> PrimeEffect:
	return prime_effect

# Get detonation bonus damage
func get_detonation_bonus() -> int:
	if is_detonator and detonate_effect.has("bonusDamage"):
		return detonate_effect.bonusDamage
	return 0

# Get which prime types this detonator can trigger
func get_detonatable_primes() -> Array:
	if not is_detonator or not detonate_effect.has("triggers"):
		return []
	return detonate_effect.triggers

# Check if this ability can detonate a specific prime type
func can_detonate_prime(prime_type: String) -> bool:
	if not is_detonator:
		return false
	
	var triggers = get_detonatable_primes()
	return prime_type in triggers

# Get ability color based on element
func get_element_color() -> Color:
	match element:
		"thermal":
			return Color.ORANGE
		"arc":
			return Color.CYAN
		"void":
			return Color.PURPLE
		"kinetic":
			return Color.GREEN
		_:
			return Color.WHITE

# Get ability type as string for UI
func get_type_string() -> String:
	match type:
		AbilityType.OFFENSIVE:
			return "Offensive"
		AbilityType.SUSTAIN:
			return "Sustain"
		AbilityType.PRIME:
			return "Prime"
		AbilityType.DETONATOR:
			return "Detonator"
		_:
			return "Unknown"

# Create a copy of this ability
func duplicate() -> Ability:
	var new_ability = Ability.new()
	new_ability.id = id
	new_ability.name = name
	new_ability.description = description
	new_ability.type = type
	new_ability.element = element
	new_ability.damage = damage
	new_ability.cooldown = cooldown
	new_ability.super_cost = super_cost
	new_ability.is_prime = is_prime
	new_ability.is_detonator = is_detonator
	new_ability.healing = healing
	new_ability.current_cooldown = current_cooldown
	
	if prime_effect != null:
		new_ability.prime_effect = prime_effect.duplicate()
	
	if detonate_effect.size() > 0:
		new_ability.detonate_effect = detonate_effect.duplicate()
	
	return new_ability

# Factory method to create ability from DataManager
static func create_from_id(ability_id: String) -> Ability:
	var data = DataManager.get_ability_by_id(ability_id)
	if data.size() == 0:
		push_error("Ability not found: " + ability_id)
		return null
	
	return Ability.new(data)
