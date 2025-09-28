extends Node2D
class_name Actor

signal hp_changed(current, max)
signal shields_changed(current, max)
signal acted
signal prime_applied(effect: PrimeEffect)
signal prime_detonated(effect: PrimeEffect)

@export var display_name: String = "Hero"
@export var team: String = "player" # "player" or "enemy"
@export var max_hp: int = 30
@export var hp: int = 30
@export var max_shields: int = 20
@export var shields: int = 20
@export var armor: int = 5
@export var atk: int = 8
@export var speed: int = 10
@export var super_energy: int = 0
@export var max_super_energy: int = 300

# Prime/Detonate system
var active_primes: Array[PrimeEffect] = []
var equipped_weapon: Weapon
var abilities: Array[Ability] = []

# Combat state
var is_stunned: bool = false
var speed_modifier: float = 1.0

@onready var sprite: Node2D = $PlayerSprite if team == "player" else $EnemySprite

func _ready():
	# Set default idle animation for animated sprites
	if sprite and sprite is AnimatedSprite2D:
		var aspr: AnimatedSprite2D = sprite
		if aspr.sprite_frames and aspr.sprite_frames.has_animation(&"idle"):
			aspr.play(&"idle")

func is_dead() -> bool:
	return hp <= 0

func take_damage(amount: int, damage_type: String = "kinetic") -> void:
	# Apply damage flow: Shields → Armor → HP
	var remaining_damage = amount
	
	# Damage shields first
	if shields > 0 and remaining_damage > 0:
		var shield_damage = min(shields, remaining_damage)
		shields -= shield_damage
		remaining_damage -= shield_damage
		emit_signal("shields_changed", shields, max_shields)
	
	# Damage armor second (if any damage remains)
	if armor > 0 and remaining_damage > 0:
		var armor_damage = min(armor, remaining_damage)
		armor -= armor_damage
		remaining_damage -= armor_damage
	
	# Damage HP last (if any damage remains)
	if remaining_damage > 0:
		hp = max(0, hp - remaining_damage)
		emit_signal("hp_changed", hp, max_hp)
	
	_shake_effect()
	
	# Play damage animation
	if sprite:
		_play_damage_animation()
	
	# Play death animation if character dies
	if is_dead() and sprite:
		_play_death_animation()

func choose_target(candidates: Array[Actor]) -> Actor:
	# simplest AI: target first non-dead
	for c in candidates:
		if not c.is_dead():
			return c
	return null

func perform_basic_attack(target: Actor) -> void:
	if target and not target.is_dead():
		# Play attack animation for all characters
		if sprite:
			_play_attack_animation()
		
		# Calculate damage based on equipped weapon
		var damage = atk
		var damage_type = "kinetic"
		
		if equipped_weapon:
			damage = equipped_weapon.get_basic_attack_damage()
			damage_type = equipped_weapon.get_damage_type()
		
		target.take_damage(damage, damage_type)
		
		# Apply weapon prime effect if applicable
		if equipped_weapon and equipped_weapon.can_prime_with_basic_attack():
			var prime_effect = equipped_weapon.get_basic_attack_prime()
			if prime_effect:
				target.apply_prime_effect(prime_effect)
	
	emit_signal("acted")

func heal(amount: int) -> void:
	hp = min(max_hp, hp + amount)
	emit_signal("hp_changed", hp, max_hp)
	emit_signal("acted")

func cast_fireball(target: Actor) -> void:
	# This function is called when the visual effect completes
	if target and not target.is_dead():
		target.take_damage(atk + 5)  # Fireball does more damage
	emit_signal("acted")

func cast_lightning(target: Actor) -> void:
	# This function is called when the visual effect completes
	if target and not target.is_dead():
		target.take_damage(atk + 3)  # Lightning does moderate extra damage
	emit_signal("acted")

func perform_basic_attack_with_hit_effect(target: Actor) -> void:
	# This function is called when the bullet hit effect completes
	if target and not target.is_dead():
		target.take_damage(atk)
	emit_signal("acted")

func _shake_effect() -> void:
	var original_position = position
	var tween = create_tween()
	
	# Shake parameters
	var shake_intensity = 10.0
	var shake_duration = 0.3
	var shake_steps = 8
	
	# Create shake animation
	for i in range(shake_steps):
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		tween.tween_property(self, "position", original_position + shake_offset, shake_duration / shake_steps)
	
	# Return to original position
	tween.tween_property(self, "position", original_position, 0.1)

func _play_damage_animation() -> void:
	if not sprite:
		return
	
	# Play damage animation based on character type
	if team == "player":
		if sprite is Sprite2D:
			# Player damage animation - switch to gethit sprite
			var s: Sprite2D = sprite
			var original_texture = s.texture
			s.texture = preload("res://Images/space_sidescroller_game_assets/Hero/Hero_gethit.png")
			await get_tree().create_timer(0.2).timeout
			s.texture = original_texture
		elif sprite is AnimatedSprite2D:
			var aspr: AnimatedSprite2D = sprite
			# If a "gethit" animation exists, play it briefly; otherwise flash
			if aspr.sprite_frames and aspr.sprite_frames.has_animation(&"gethit"):
				aspr.play(&"gethit")
				await get_tree().create_timer(0.2).timeout
				# Return to idle after damage
				if aspr.sprite_frames.has_animation(&"idle"):
					aspr.play(&"idle")
			else:
				var original_modulate = aspr.modulate
				aspr.modulate = Color(1.0, 0.6, 0.6)
				await get_tree().create_timer(0.15).timeout
				aspr.modulate = original_modulate
	else:
		# Enemy damage animation - flash red
		if sprite and sprite is AnimatedSprite2D:
			var aspr: AnimatedSprite2D = sprite
			var original_modulate = aspr.modulate
			aspr.modulate = Color.RED
			await get_tree().create_timer(0.1).timeout
			aspr.modulate = original_modulate
		else:
			var original_modulate = sprite.modulate
			sprite.modulate = Color.RED
			await get_tree().create_timer(0.1).timeout
			sprite.modulate = original_modulate

func _play_attack_animation() -> void:
	if not sprite:
		return
	
	# Play attack animation based on character type
	if team == "player":
		if sprite is Sprite2D:
			# Player attack animation - switch to shoot sprite
			var s: Sprite2D = sprite
			var original_texture = s.texture
			s.texture = preload("res://Images/space_sidescroller_game_assets/Hero/Hero_shoot.png")
			await get_tree().create_timer(0.3).timeout
			s.texture = original_texture
		elif sprite is AnimatedSprite2D:
			var aspr: AnimatedSprite2D = sprite
			if aspr.sprite_frames and aspr.sprite_frames.has_animation(&"attack"):
				aspr.play(&"attack")
				await get_tree().create_timer(0.3).timeout
				# Return to idle after attack
				if aspr.sprite_frames.has_animation(&"idle"):
					aspr.play(&"idle")
			elif aspr.sprite_frames and aspr.sprite_frames.has_animation(&"shoot"):
				aspr.play(&"shoot")
				await get_tree().create_timer(0.3).timeout
				# Return to idle after shoot
				if aspr.sprite_frames.has_animation(&"idle"):
					aspr.play(&"idle")
			else:
				# Gentle scale punch as a fallback
				var original_scale = aspr.scale
				aspr.scale *= 1.1
				await get_tree().create_timer(0.12).timeout
				aspr.scale = original_scale
	else:
		# Enemy attack animation - simple scale effect
		var original_scale = sprite.scale
		sprite.scale *= 1.2
		await get_tree().create_timer(0.1).timeout
		sprite.scale = original_scale

func _play_death_animation() -> void:
	if not sprite:
		return
	
	# Play death animation based on character type
	if team == "player":
		if sprite is Sprite2D:
			# Player death animation - switch to death sprite then fade
			var s: Sprite2D = sprite
			s.texture = preload("res://Images/space_sidescroller_game_assets/Hero/Hero_death.png")
			await get_tree().create_timer(0.5).timeout
		elif sprite is AnimatedSprite2D:
			var aspr: AnimatedSprite2D = sprite
			if aspr.sprite_frames and aspr.sprite_frames.has_animation(&"death"):
				aspr.play(&"death")
				await get_tree().create_timer(0.5).timeout
		
	# Common death effect - fade out and shrink
	var tween = create_tween()
	tween.parallel().tween_property(sprite, "modulate", Color.TRANSPARENT, 0.5)
	tween.parallel().tween_property(sprite, "scale", Vector2.ZERO, 0.5)

# Prime/Detonate System Methods

func apply_prime_effect(effect: PrimeEffect) -> void:
	"""Apply a prime effect to this actor"""
	if not effect:
		return
	
	# Check if we already have this type of prime (max 2 primes per target)
	var existing_primes_of_type = 0
	for prime in active_primes:
		if prime.type == effect.type:
			existing_primes_of_type += 1
	
	if existing_primes_of_type < 2:  # Double Prime Rule
		var new_effect = effect.duplicate()
		active_primes.append(new_effect)
		emit_signal("prime_applied", new_effect)
		print(display_name + " has " + str(active_primes.size()) + " active primes")

func detonate_primes(detonator_element: String) -> int:
	"""Detonate compatible primes and return bonus damage"""
	var total_bonus_damage = 0
	var primes_to_remove = []
	
	for prime in active_primes:
		if prime.can_be_detonated_by(detonator_element):
			total_bonus_damage += prime.get_detonation_bonus()
			primes_to_remove.append(prime)
			emit_signal("prime_detonated", prime)
			print(display_name + " detonated " + prime.get_display_name() + " for " + str(prime.get_detonation_bonus()) + " bonus damage")
	
	# Remove detonated primes
	for prime in primes_to_remove:
		active_primes.erase(prime)
	
	return total_bonus_damage

func process_prime_effects() -> void:
	"""Process all active prime effects for DoT and other effects"""
	var primes_to_remove = []
	
	for prime in active_primes:
		# Process DoT effects
		var damage = prime.process_turn()
		if damage > 0:
			take_damage(damage, prime.element)
			print(display_name + " takes " + str(damage) + " damage from " + prime.get_display_name())
		
		# Apply status effects
		match prime.type:
			PrimeEffect.PrimeType.OVERLOAD:
				if randf() < prime.effect_value:  # stunChance
					is_stunned = true
					print(display_name + " is stunned by Overload!")
			PrimeEffect.PrimeType.SUPPRESS:
				speed_modifier = prime.effect_value  # speedReduction
			PrimeEffect.PrimeType.HASTE:
				speed_modifier = prime.effect_value  # speedMultiplier
		
		# Remove expired effects
		if prime.is_expired():
			primes_to_remove.append(prime)
	
	# Remove expired primes
	for prime in primes_to_remove:
		active_primes.erase(prime)

func get_active_primes() -> Array[PrimeEffect]:
	"""Get all active prime effects"""
	return active_primes

func clear_all_primes() -> void:
	"""Clear all active prime effects"""
	active_primes.clear()

# Weapon and Ability Management

func equip_weapon(weapon: Weapon) -> void:
	"""Equip a weapon"""
	equipped_weapon = weapon
	if weapon:
		# Apply weapon bonuses
		max_shields += weapon.get_shield_bonus()
		max_hp += weapon.get_health_bonus()
		shields = min(shields + weapon.get_shield_bonus(), max_shields)
		hp = min(hp + weapon.get_health_bonus(), max_hp)
		emit_signal("shields_changed", shields, max_shields)
		emit_signal("hp_changed", hp, max_hp)

func add_ability(ability: Ability) -> void:
	"""Add an ability to this actor"""
	abilities.append(ability)

func get_abilities() -> Array[Ability]:
	"""Get all abilities"""
	return abilities

func can_use_ability(ability: Ability) -> bool:
	"""Check if an ability can be used"""
	return ability.is_ready() and ability.can_afford(super_energy)

func use_ability(ability: Ability, target: Actor) -> void:
	"""Use an ability on a target"""
	if not can_use_ability(ability):
		print("Cannot use ability: " + ability.name)
		return
	
	# Spend super energy
	super_energy -= ability.super_cost
	
	# Start cooldown
	ability.start_cooldown()
	
	# Apply damage/healing
	if ability.damage > 0:
		target.take_damage(ability.damage, ability.element)
	elif ability.healing > 0:
		target.heal(ability.healing)
	
	# Apply prime effect
	if ability.is_prime and ability.get_prime_effect():
		target.apply_prime_effect(ability.get_prime_effect())
	
	# Detonate primes
	if ability.is_detonator:
		var bonus_damage = target.detonate_primes(ability.element)
		if bonus_damage > 0:
			target.take_damage(bonus_damage, ability.element)
	
	emit_signal("acted")

func reduce_ability_cooldowns() -> void:
	"""Reduce cooldowns for all abilities"""
	for ability in abilities:
		ability.reduce_cooldown()

# Combat State Management

func is_stunned_this_turn() -> bool:
	"""Check if actor is stunned this turn"""
	return is_stunned

func clear_stun() -> void:
	"""Clear stun status"""
	is_stunned = false

func get_effective_speed() -> int:
	"""Get speed modified by status effects"""
	return int(speed * speed_modifier)

func restore_shields(amount: int) -> void:
	"""Restore shields"""
	shields = min(max_shields, shields + amount)
	emit_signal("shields_changed", shields, max_shields)
