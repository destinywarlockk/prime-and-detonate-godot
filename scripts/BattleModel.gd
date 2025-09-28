extends Node

signal turn_started(actor)
signal turn_ended(actor)
signal battle_over(winner_team)
signal prime_effect_applied(actor, effect)
signal prime_effect_detonated(actor, effect)

var actors: Array = []        # Filled by Battle scene at runtime
var turn_index: int = 0
var turn_count: int = 0       # Track total turns for prime effect processing

func start_battle(list_of_actors: Array) -> void:
    actors = list_of_actors.filter(func(a): return not a.is_dead())
    # Enhanced initiative: sort by effective speed (includes speed modifiers from primes)
    actors.sort_custom(func(a, b): return a.get_effective_speed() > b.get_effective_speed())
    turn_index = -1
    turn_count = 0
    
    # Connect to actor signals for prime effects
    _connect_actor_signals()
    
    _next_turn()

func _next_turn() -> void:
    # skip dead
    if actors.is_empty():
        emit_signal("battle_over", "none")
        return
    
    turn_count += 1
    turn_index = (turn_index + 1) % actors.size()
    var a = actors[turn_index]
    
    if a.is_dead():
        # prune and retry
        actors = actors.filter(func(x): return not x.is_dead())
        if actors.is_empty():
            emit_signal("battle_over", "none")
            return
        _next_turn()
        return
    
    # Process prime effects at start of turn
    _process_turn_start_effects(a)
    
    emit_signal("turn_started", a)

func end_turn(actor) -> void:
    # Process turn end effects
    _process_turn_end_effects(actor)
    
    emit_signal("turn_ended", actor)
    _check_victory_then_advance()

func _check_victory_then_advance() -> void:
    var players_alive = actors.any(func(a): return a.team == "player" and not a.is_dead())
    var enemies_alive = actors.any(func(a): return a.team == "enemy" and not a.is_dead())
    if not players_alive:
        emit_signal("battle_over", "enemy")
    elif not enemies_alive:
        emit_signal("battle_over", "player")
    else:
        _next_turn()

# Prime Effect Management

func _connect_actor_signals() -> void:
    """Connect to all actor signals for prime effect handling"""
    for actor in actors:
        if actor.has_signal("prime_applied"):
            actor.prime_applied.connect(_on_prime_applied)
        if actor.has_signal("prime_detonated"):
            actor.prime_detonated.connect(_on_prime_detonated)

func _on_prime_applied(actor: Actor, effect: PrimeEffect) -> void:
    """Handle when a prime effect is applied"""
    emit_signal("prime_effect_applied", actor, effect)
    print("Prime applied: " + effect.get_display_name() + " to " + actor.display_name)

func _on_prime_detonated(actor: Actor, effect: PrimeEffect) -> void:
    """Handle when a prime effect is detonated"""
    emit_signal("prime_effect_detonated", actor, effect)
    print("Prime detonated: " + effect.get_display_name() + " on " + actor.display_name)

func _process_turn_start_effects(actor: Actor) -> void:
    """Process effects that happen at the start of a turn"""
    # Clear stun status (stuns last until next turn)
    actor.clear_stun()
    
    # Process prime effects (DoT, status effects)
    actor.process_prime_effects()
    
    # Reduce ability cooldowns
    actor.reduce_ability_cooldowns()

func _process_turn_end_effects(actor: Actor) -> void:
    """Process effects that happen at the end of a turn"""
    # Reset speed modifier (some effects are turn-based)
    actor.speed_modifier = 1.0
    
    # Gain super energy for taking damage or dealing damage
    # This could be expanded based on combat actions

# Battle State Queries

func get_actors_with_primes() -> Array[Actor]:
    """Get all actors that have active prime effects"""
    var actors_with_primes: Array[Actor] = []
    for actor in actors:
        if actor.get_active_primes().size() > 0:
            actors_with_primes.append(actor)
    return actors_with_primes

func get_prime_effects_by_type(effect_type: PrimeEffect.PrimeType) -> Array[PrimeEffect]:
    """Get all prime effects of a specific type across all actors"""
    var effects: Array[PrimeEffect] = []
    for actor in actors:
        for prime in actor.get_active_primes():
            if prime.type == effect_type:
                effects.append(prime)
    return effects

func get_current_actor() -> Actor:
    """Get the actor whose turn it currently is"""
    if actors.size() > 0 and turn_index >= 0 and turn_index < actors.size():
        return actors[turn_index]
    return null

func get_actors_by_team(team: String) -> Array[Actor]:
    """Get all actors on a specific team"""
    var team_actors: Array[Actor] = []
    for actor in actors:
        if actor.team == team and not actor.is_dead():
            team_actors.append(actor)
    return team_actors

func get_players() -> Array[Actor]:
    """Get all player actors"""
    return get_actors_by_team("player")

func get_enemies() -> Array[Actor]:
    """Get all enemy actors"""
    return get_actors_by_team("enemy")

func can_use_ability(actor: Actor, ability: Ability, target: Actor) -> bool:
    """Check if an ability can be used (cooldown, cost, target validity)"""
    if not actor.can_use_ability(ability):
        return false
    
    if target and target.is_dead():
        return false
    
    return true

func use_ability(actor: Actor, ability: Ability, target: Actor) -> void:
    """Use an ability and handle the turn flow"""
    if can_use_ability(actor, ability, target):
        actor.use_ability(ability, target)
        end_turn(actor)
    else:
        print("Cannot use ability: " + ability.name)
