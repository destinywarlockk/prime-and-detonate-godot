extends RefCounted
class_name PrimeEffect

# PrimeEffect - Represents a status effect that can be applied to targets
# Based on the prime/detonate system where primes apply status and detonators consume them

enum PrimeType {
	BURN,        # Thermal DoT
	OVERLOAD,    # Arc stun chance
	SUPPRESS,    # Void initiative delay
	SHIELD_OVERCHARGE,  # Shield buff
	HASTE,       # Speed buff
	DEFENSE_BREAK,  # Defense debuff
	ACCURACY_JAM  # Accuracy debuff
}

var type: PrimeType
var duration: int
var damage_per_turn: int = 0
var element: String = ""
var effect_value: float = 0.0  # For non-damage effects (chance, multiplier, etc.)
var source_element: String = ""  # Element that applied this prime

func _init(effect_type: PrimeType = PrimeType.BURN, dur: int = 3, dot: int = 0, elem: String = "", value: float = 0.0):
	type = effect_type
	duration = dur
	damage_per_turn = dot
	element = elem
	effect_value = value

# Factory methods for common prime effects
static func create_burn(duration: int = 3, damage_per_turn: int = 15) -> PrimeEffect:
	var effect = PrimeEffect.new(PrimeType.BURN, duration, damage_per_turn, "thermal")
	return effect

static func create_overload(duration: int = 1, stun_chance: float = 0.3) -> PrimeEffect:
	var effect = PrimeEffect.new(PrimeType.OVERLOAD, duration, 0, "arc", stun_chance)
	return effect

static func create_suppress(duration: int = 2, speed_reduction: float = 0.5) -> PrimeEffect:
	var effect = PrimeEffect.new(PrimeType.SUPPRESS, duration, 0, "void", speed_reduction)
	return effect

static func create_shield_overcharge(duration: int = 3, shield_bonus: int = 20) -> PrimeEffect:
	var effect = PrimeEffect.new(PrimeType.SHIELD_OVERCHARGE, duration, 0, "kinetic", shield_bonus)
	return effect

static func create_haste(duration: int = 3, speed_multiplier: float = 1.5) -> PrimeEffect:
	var effect = PrimeEffect.new(PrimeType.HASTE, duration, 0, "kinetic", speed_multiplier)
	return effect

# Check if this prime can be detonated by a specific element/ability
func can_be_detonated_by(detonator_element: String) -> bool:
	match type:
		PrimeType.BURN:
			return detonator_element == "thermal" or detonator_element == "kinetic"
		PrimeType.OVERLOAD:
			return detonator_element == "arc" or detonator_element == "kinetic"
		PrimeType.SUPPRESS:
			return detonator_element == "void" or detonator_element == "kinetic"
		_:
			return detonator_element == "kinetic"  # Kinetic can detonate most effects

# Get the bonus damage when this prime is detonated
func get_detonation_bonus() -> int:
	match type:
		PrimeType.BURN:
			return 50  # High damage for burn detonation
		PrimeType.OVERLOAD:
			return 40  # Good damage + stun
		PrimeType.SUPPRESS:
			return 35  # Moderate damage + debuff
		_:
			return 25  # Default bonus

# Process the effect for one turn (for DoT effects)
func process_turn() -> int:
	if duration <= 0:
		return 0
	
	duration -= 1
	
	if type == PrimeType.BURN:
		return damage_per_turn
	
	return 0

# Check if the effect has expired
func is_expired() -> bool:
	return duration <= 0

# Get display information for UI
func get_display_name() -> String:
	match type:
		PrimeType.BURN:
			return "Burn"
		PrimeType.OVERLOAD:
			return "Overload"
		PrimeType.SUPPRESS:
			return "Suppress"
		PrimeType.SHIELD_OVERCHARGE:
			return "Shield Overcharge"
		PrimeType.HASTE:
			return "Haste"
		PrimeType.DEFENSE_BREAK:
			return "Defense Break"
		PrimeType.ACCURACY_JAM:
			return "Accuracy Jam"
		_:
			return "Unknown Effect"

# Get the color associated with this prime effect
func get_color() -> Color:
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

# Duplicate this prime effect
func duplicate() -> PrimeEffect:
	var new_effect = PrimeEffect.new(type, duration, damage_per_turn, element, effect_value)
	new_effect.source_element = source_element
	return new_effect
