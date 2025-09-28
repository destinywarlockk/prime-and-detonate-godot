extends Node

signal turn_started(actor)
signal turn_ended(actor)
signal battle_over(winner_team)

var actors: Array = []        # Filled by Battle scene at runtime
var turn_index: int = 0

func start_battle(list_of_actors: Array) -> void:
    actors = list_of_actors.filter(func(a): return not a.is_dead())
    # simplest initiative: sort by speed once, loop forever
    actors.sort_custom(func(a, b): return a.speed > b.speed)
    turn_index = -1
    _next_turn()

func _next_turn() -> void:
    # skip dead
    if actors.is_empty():
        emit_signal("battle_over", "none")
        return
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
    emit_signal("turn_started", a)

func end_turn(actor) -> void:
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
