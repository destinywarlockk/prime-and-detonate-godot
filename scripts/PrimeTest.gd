extends Node

# PrimeTest - Simple test script to verify prime/detonate system works
# This can be attached to a scene to test the core functionality

func _ready():
	print("=== PRIME & DETONATE SYSTEM TEST ===")
	await test_data_manager()
	await test_prime_effects()
	await test_abilities()
	await test_weapons()
	await test_actor_system()
	print("=== ALL TESTS COMPLETED ===")

func test_data_manager():
	print("\n--- Testing DataManager ---")
	
	# Test loading data
	if DataManager.is_data_loaded():
		print("✓ DataManager loaded successfully")
	else:
		print("✗ DataManager failed to load")
		return
	
	# Test ability loading
	var burn_ability = DataManager.get_ability_by_id("thermal_burn")
	if burn_ability.size() > 0:
		print("✓ Thermal Burn ability loaded: " + burn_ability.name)
	else:
		print("✗ Thermal Burn ability not found")
	
	# Test weapon loading
	var railgun = DataManager.get_weapon_by_id("kinetic_railgun")
	if railgun.size() > 0:
		print("✓ Kinetic Railgun loaded: " + railgun.name)
	else:
		print("✗ Kinetic Railgun not found")
	
	# Test character loading
	var nova = DataManager.get_character_by_id("nova")
	if nova.size() > 0:
		print("✓ Nova character loaded: " + nova.name + " (" + nova.class + ")")
	else:
		print("✗ Nova character not found")

func test_prime_effects():
	print("\n--- Testing PrimeEffect System ---")
	
	# Test Burn effect
	var burn = PrimeEffect.create_burn(3, 15)
	print("✓ Created Burn effect: " + burn.get_display_name() + " for " + str(burn.duration) + " turns")
	
	# Test Overload effect
	var overload = PrimeEffect.create_overload(1, 0.3)
	print("✓ Created Overload effect: " + overload.get_display_name() + " with " + str(overload.effect_value * 100) + "% stun chance")
	
	# Test Suppress effect
	var suppress = PrimeEffect.create_suppress(2, 0.5)
	print("✓ Created Suppress effect: " + suppress.get_display_name() + " with " + str(suppress.effect_value * 100) + "% speed reduction")
	
	# Test detonation compatibility
	if burn.can_be_detonated_by("thermal"):
		print("✓ Burn can be detonated by Thermal")
	else:
		print("✗ Burn cannot be detonated by Thermal")
	
	if overload.can_be_detonated_by("arc"):
		print("✓ Overload can be detonated by Arc")
	else:
		print("✗ Overload cannot be detonated by Arc")
	
	# Test turn processing
	var initial_duration = burn.duration
	var damage = burn.process_turn()
	print("✓ Burn processed turn: " + str(damage) + " damage, " + str(burn.duration) + " turns remaining")

func test_abilities():
	print("\n--- Testing Ability System ---")
	
	# Test creating abilities from data
	var burn_ability = Ability.create_from_id("thermal_burn")
	if burn_ability:
		print("✓ Thermal Burn ability created: " + burn_ability.name)
		print("  - Element: " + burn_ability.element)
		print("  - Is Prime: " + str(burn_ability.is_prime))
		print("  - Is Detonator: " + str(burn_ability.is_detonator))
		print("  - Damage: " + str(burn_ability.damage))
	else:
		print("✗ Failed to create Thermal Burn ability")
	
	var burst_ability = Ability.create_from_id("thermal_burst")
	if burst_ability:
		print("✓ Thermal Burst ability created: " + burst_ability.name)
		print("  - Is Prime: " + str(burst_ability.is_prime))
		print("  - Is Detonator: " + str(burst_ability.is_detonator))
		print("  - Can detonate Burn: " + str(burst_ability.can_detonate_prime("burn")))
	else:
		print("✗ Failed to create Thermal Burst ability")

func test_weapons():
	print("\n--- Testing Weapon System ---")
	
	# Test creating weapons from data
	var railgun = Weapon.create_from_id("kinetic_railgun")
	if railgun:
		print("✓ Kinetic Railgun created: " + railgun.name)
		print("  - Element: " + railgun.element)
		print("  - Base Damage: " + str(railgun.base_damage))
		print("  - Basic Attack Damage: " + str(railgun.get_basic_attack_damage()))
		print("  - Can Prime: " + str(railgun.can_prime_with_basic_attack()))
	else:
		print("✗ Failed to create Kinetic Railgun")
	
	var thermal_lance = Weapon.create_from_id("thermal_lance")
	if thermal_lance:
		print("✓ Thermal Lance created: " + thermal_lance.name)
		print("  - Can Prime: " + str(thermal_lance.can_prime_with_basic_attack()))
		if thermal_lance.can_prime_with_basic_attack():
			var prime = thermal_lance.get_basic_attack_prime()
			if prime:
				print("  - Basic Attack Prime: " + prime.get_display_name())
	else:
		print("✗ Failed to create Thermal Lance")

func test_actor_system():
	print("\n--- Testing Actor Prime/Detonate System ---")
	
	# Create test actors
	var test_actor = Actor.new()
	test_actor.display_name = "Test Hero"
	test_actor.team = "player"
	test_actor.max_hp = 100
	test_actor.hp = 100
	test_actor.max_shields = 50
	test_actor.shields = 50
	test_actor.armor = 10
	
	var target_actor = Actor.new()
	target_actor.display_name = "Test Enemy"
	target_actor.team = "enemy"
	target_actor.max_hp = 80
	target_actor.hp = 80
	target_actor.max_shields = 30
	target_actor.shields = 30
	target_actor.armor = 5
	
	print("✓ Created test actors")
	
	# Test weapon equipping
	var railgun = Weapon.create_from_id("kinetic_railgun")
	if railgun:
		test_actor.equip_weapon(railgun)
		print("✓ Equipped weapon: " + railgun.name)
	
	# Test ability adding
	var burn_ability = Ability.create_from_id("thermal_burn")
	if burn_ability:
		test_actor.add_ability(burn_ability)
		print("✓ Added ability: " + burn_ability.name)
	
	# Test prime application
	var burn_effect = PrimeEffect.create_burn(3, 15)
	target_actor.apply_prime_effect(burn_effect)
	print("✓ Applied Burn prime to target")
	print("  - Target has " + str(target_actor.get_active_primes().size()) + " active primes")
	
	# Test prime processing (DoT)
	var initial_hp = target_actor.hp
	target_actor.process_prime_effects()
	print("✓ Processed prime effects")
	print("  - Target HP: " + str(initial_hp) + " → " + str(target_actor.hp))
	
	# Test detonation
	var burst_ability = Ability.create_from_id("thermal_burst")
	if burst_ability:
		test_actor.add_ability(burst_ability)
		var bonus_damage = target_actor.detonate_primes("thermal")
		print("✓ Detonated primes for " + str(bonus_damage) + " bonus damage")
		print("  - Target has " + str(target_actor.get_active_primes().size()) + " active primes remaining")
	
	# Test damage flow (Shields → Armor → HP)
	print("\n--- Testing Damage Flow ---")
	target_actor.shields = 30
	target_actor.armor = 10
	target_actor.hp = 80
	var initial_shields = target_actor.shields
	var initial_armor = target_actor.armor
	var initial_hp = target_actor.hp
	
	target_actor.take_damage(50, "kinetic")
	print("✓ Applied 50 kinetic damage")
	print("  - Shields: " + str(initial_shields) + " → " + str(target_actor.shields))
	print("  - Armor: " + str(initial_armor) + " → " + str(target_actor.armor))
	print("  - HP: " + str(initial_hp) + " → " + str(target_actor.hp))
	
	# Clean up
	test_actor.queue_free()
	target_actor.queue_free()
	print("✓ Test actors cleaned up")
