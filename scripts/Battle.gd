extends Node2D

@onready var party_manager: PartyManager = $Party
@onready var enemies := $Enemies
@onready var turn_label := $UI/TurnLabel
@onready var party_stats_container := $UI/PartyStatsContainer
@onready var attack_btn := $UI/Buttons/ActionRow1/AttackButton
@onready var heal_btn := $UI/Buttons/ActionRow1/HealButton
@onready var fireball_btn := $UI/Buttons/ActionRow2/FireballButton
@onready var lightning_btn := $UI/Buttons/ActionRow2/LightningButton
@onready var end_btn := $UI/Buttons/EndRow/EndTurnButton
@onready var fireball_effect := $SpellEffects/FireballEffect
@onready var lightning_effect := $SpellEffects/LightningEffect
@onready var heal_effect := $SpellEffects/HealEffect
@onready var small_explosion_effect := $SpellEffects/SmallExplosionEffect
@onready var large_explosion_effect := $SpellEffects/LargeExplosionEffect
@onready var bullet_hit_effect := $SpellEffects/BulletHitEffect
@onready var bullet_effect := $SpellEffects/BulletEffect
@onready var stars_container := $Stars

var current_actor: Actor
var selected_party_member: Actor

# Button navigation
var button_index: int = 0
var buttons: Array[Button] = []
var is_button_navigation_active: bool = false

func _ready():
	# Connect party manager signals
	party_manager.character_selected.connect(_on_character_selected)
	party_manager.ui_transition_complete.connect(_on_ui_transition_complete)
	
	# Set initial selected character
	selected_party_member = party_manager.get_selected_character()
	
	# Initialize button array for navigation
	buttons = [attack_btn, heal_btn, fireball_btn, lightning_btn, end_btn]
	
	# Collect living actors
	var all: Array = []
	all.append_array(party_manager.party_members)
	all.append_array(enemies.get_children().filter(func(n): return n is Actor))

	# Connect per-actor acted signal so enemy turns can auto-advance
	for a in all:
		a.acted.connect(_on_actor_acted)
		# Connect HP changes for party members to update UI
		if a.team == "player":
			a.hp_changed.connect(_on_party_member_hp_changed)

	# Hook up model signals
	BattleModel.turn_started.connect(_on_turn_started)
	BattleModel.turn_ended.connect(_on_turn_ended)
	BattleModel.battle_over.connect(_on_battle_over)

	# Wire buttons
	attack_btn.pressed.connect(_on_attack_pressed)
	heal_btn.pressed.connect(_on_heal_pressed)
	fireball_btn.pressed.connect(_on_fireball_pressed)
	lightning_btn.pressed.connect(_on_lightning_pressed)
	end_btn.pressed.connect(_on_end_pressed)

	# Update UI with initial character
	_update_character_ui()

	# Start
	BattleModel.start_battle(all)
	
	# Start star twinkling effects
	_start_star_twinkling()

func _input(event):
	if not current_actor or current_actor.team != "player":
		return
		
	# Tab to cycle through party members (only Tab, not arrow keys)
	if event.is_action_pressed("ui_accept") and event.keycode == KEY_TAB:
		_cycle_party_member()
		return  # Prevent arrow key navigation when using Tab
	
	# Arrow keys for button navigation only (not party member selection)
	if event.is_action_pressed("ui_right"):
		_navigate_buttons(1)
	elif event.is_action_pressed("ui_left"):
		_navigate_buttons(-1)
	elif event.is_action_pressed("ui_down"):
		_navigate_buttons(1)
	elif event.is_action_pressed("ui_up"):
		_navigate_buttons(-1)
	
	# Enter to activate selected button
	if event.is_action_pressed("ui_accept") and event.keycode == KEY_ENTER:
		_activate_selected_button()

func _cycle_party_member():
	var current_index = party_manager.selected_index
	var next_index = (current_index + 1) % party_manager.party_members.size()
	party_manager.switch_to_character(next_index)

func _navigate_buttons(direction: int):
	if not is_button_navigation_active:
		is_button_navigation_active = true
		button_index = 0
	
	button_index = (button_index + direction) % buttons.size()
	if button_index < 0:
		button_index = buttons.size() - 1
	
	_highlight_selected_button()

func _highlight_selected_button():
	# Remove highlight from all buttons
	for button in buttons:
		if button:
			button.modulate = Color.WHITE
	
	# Highlight selected button
	if button_index < buttons.size() and buttons[button_index]:
		buttons[button_index].modulate = Color.YELLOW

func _activate_selected_button():
	if button_index < buttons.size() and buttons[button_index] and not buttons[button_index].disabled:
		buttons[button_index].emit_signal("pressed")

func _auto_select_next_party_member():
	# Find the next living party member
	var current_index = party_manager.selected_index
	var next_index = current_index
	
	# Try to find the next living party member
	for i in range(party_manager.party_members.size()):
		next_index = (current_index + i + 1) % party_manager.party_members.size()
		var next_member = party_manager.party_members[next_index]
		if next_member and next_member.hp > 0:
			party_manager.switch_to_character(next_index)
			return
	
	# If no living party members found, end turn
	_on_end_pressed()

func _on_turn_started(actor: Actor) -> void:
	current_actor = actor
	turn_label.text = "Turn: %s (%s)" % [actor.display_name, actor.team]
	var is_player = actor.team == "player"
	attack_btn.disabled = not is_player
	heal_btn.disabled = not is_player
	fireball_btn.disabled = not is_player
	lightning_btn.disabled = not is_player
	end_btn.disabled = not is_player
	
	# Reset button navigation for new turn
	is_button_navigation_active = false
	button_index = 0
	_highlight_selected_button()

	if not is_player:
		# Enemy AI: wait, then pick target and attack
		await get_tree().create_timer(1.0).timeout  # 1 second thinking delay
		var targets: Array[Actor] = []
		for child in party_manager.get_children():
			if child is Actor:
				targets.append(child)
		var t = actor.choose_target(targets)
		if t and not t.is_dead():  # Make sure target is still alive
			actor.perform_basic_attack(t)
		await get_tree().create_timer(0.5).timeout  # Brief pause after attack
		BattleModel.end_turn(actor) # auto-end

func _on_attack_pressed() -> void:
	if current_actor and current_actor.team == "player" and selected_party_member:
		var targets: Array[Actor] = []
		for child in enemies.get_children():
			if child is Actor and not child.is_dead():
				targets.append(child)
		var t = selected_party_member.choose_target(targets)
		if t:
			# Get the enemy sprite position for effects
			var enemy_sprite = t.get_node("EnemySprite")
			var target_pos = enemy_sprite.global_position
			
			# Check if the selected party member is the knight (Nova) or Evil Wizard (Zara)
			if selected_party_member.display_name == "Nova":
				# Use melee attack for knight - damage will be applied during the attack animation
				await _show_knight_melee_attack(target_pos, t)
			elif selected_party_member.display_name == "Zara":
				# Use spell casting attack for Evil Wizard - damage will be applied when projectile hits
				await _show_wizard_spell_attack(target_pos, t)
			else:
				# Show bullet traveling and hit effect for other characters
				await _show_bullet_effect(target_pos)
				selected_party_member.perform_basic_attack_with_hit_effect(t)
		BattleModel.end_turn(current_actor)
		_auto_select_next_party_member()

func _on_end_pressed() -> void:
	if current_actor:
		BattleModel.end_turn(current_actor)

func _on_actor_acted() -> void:
	# Not strictly needed; kept for extensibility (animations, SFX, etc.)
	pass

func _on_turn_ended(actor: Actor) -> void:
	# Could play end-turn SFX/anim here
	pass

func _on_heal_pressed() -> void:
	if current_actor and current_actor.team == "player" and selected_party_member:
		# Get the player sprite position for accurate heal effect
		var player_sprite = selected_party_member.get_node("PlayerSprite")
		var heal_pos = player_sprite.global_position
		# Show heal effect on player
		_show_heal_effect(heal_pos)
		selected_party_member.heal(15)  # Heal for 15 HP
		await get_tree().create_timer(0.8).timeout
		BattleModel.end_turn(current_actor)
		_auto_select_next_party_member()

func _on_fireball_pressed() -> void:
	if current_actor and current_actor.team == "player" and selected_party_member:
		var targets: Array[Actor] = []
		for child in enemies.get_children():
			if child is Actor and not child.is_dead():
				targets.append(child)
		var t = selected_party_member.choose_target(targets)
		if t:
			# Get the enemy sprite position for accurate targeting
			var enemy_sprite = t.get_node("EnemySprite")
			var target_pos = enemy_sprite.global_position
			# Show fireball effect and apply damage when it completes
			await _show_fireball_effect(target_pos)
			selected_party_member.cast_fireball(t)
		BattleModel.end_turn(current_actor)
		_auto_select_next_party_member()

func _on_lightning_pressed() -> void:
	if current_actor and current_actor.team == "player" and selected_party_member:
		var targets: Array[Actor] = []
		for child in enemies.get_children():
			if child is Actor and not child.is_dead():
				targets.append(child)
		var t = selected_party_member.choose_target(targets)
		if t:
			# Get the enemy sprite position for accurate targeting
			var enemy_sprite = t.get_node("EnemySprite")
			var target_pos = enemy_sprite.global_position
			# Show lightning effect and apply damage when it completes
			await _show_lightning_effect(target_pos)
			selected_party_member.cast_lightning(t)
		BattleModel.end_turn(current_actor)
		_auto_select_next_party_member()

func _show_fireball_effect(target_pos: Vector2) -> void:
	# Get the player sprite position for accurate start position
	var player_sprite = selected_party_member.get_node("PlayerSprite")
	var start_pos = player_sprite.global_position
	
	# Start at player sprite position
	fireball_effect.position = start_pos
	fireball_effect.visible = true
	fireball_effect.modulate = Color.ORANGE
	fireball_effect.scale = Vector2(4, 4)
	fireball_effect.play("fly")
	
	# Animate rocket travel from player to enemy
	var tween = create_tween()
	tween.parallel().tween_property(fireball_effect, "position", target_pos, 0.6)
	tween.parallel().tween_property(fireball_effect, "scale", Vector2(5, 5), 0.3)
	tween.parallel().tween_property(fireball_effect, "modulate", Color.YELLOW, 0.3)
	
	# Hit effect at target
	tween.tween_callback(_fireball_hit_effect.bind(target_pos))
	tween.tween_interval(0.1)
	tween.tween_callback(_hide_fireball_effect)
	
	# Wait for the entire effect to complete
	await tween.finished

func _hide_fireball_effect() -> void:
	fireball_effect.visible = false
	fireball_effect.scale = Vector2(4, 4)
	fireball_effect.modulate = Color.WHITE

func _hide_large_explosion_effect() -> void:
	large_explosion_effect.visible = false
	large_explosion_effect.scale = Vector2(4, 4)
	large_explosion_effect.modulate = Color.WHITE

func _show_lightning_effect(target_pos: Vector2) -> void:
	# Get the player sprite position for accurate start position
	var player_sprite = selected_party_member.get_node("PlayerSprite")
	var start_pos = player_sprite.global_position
	
	# Start at player sprite position
	lightning_effect.position = start_pos
	lightning_effect.visible = true
	lightning_effect.modulate = Color.CYAN
	lightning_effect.scale = Vector2(3, 3)
	lightning_effect.play("beam")
	
	# Animate laser travel from player to enemy (very fast)
	var tween = create_tween()
	tween.parallel().tween_property(lightning_effect, "position", target_pos, 0.2)
	tween.parallel().tween_property(lightning_effect, "scale", Vector2(4, 4), 0.1)
	tween.parallel().tween_property(lightning_effect, "modulate", Color.WHITE, 0.1)
	
	# Hit effect at target
	tween.tween_callback(_lightning_hit_effect.bind(target_pos))
	tween.tween_interval(0.05)
	tween.tween_callback(_hide_lightning_effect)
	
	# Wait for the entire effect to complete
	await tween.finished

func _hide_lightning_effect() -> void:
	lightning_effect.visible = false
	lightning_effect.scale = Vector2(3, 3)
	lightning_effect.modulate = Color.WHITE

func _hide_small_explosion_effect() -> void:
	small_explosion_effect.visible = false
	small_explosion_effect.scale = Vector2(3, 3)
	small_explosion_effect.modulate = Color.WHITE

func _show_heal_effect(target_pos: Vector2) -> void:
	heal_effect.position = target_pos
	heal_effect.visible = true
	heal_effect.modulate = Color.GREEN
	heal_effect.play("heal")
	
	# Wait for heal animation to complete
	await get_tree().create_timer(0.4).timeout
	_hide_heal_effect()

func _hide_heal_effect() -> void:
	heal_effect.visible = false
	heal_effect.scale = Vector2(2, 2)
	heal_effect.modulate = Color.WHITE

func _fireball_hit_effect(hit_pos: Vector2) -> void:
	# Show large explosion effect at impact point
	large_explosion_effect.position = hit_pos
	large_explosion_effect.visible = true
	large_explosion_effect.modulate = Color.ORANGE
	large_explosion_effect.scale = Vector2(4, 4)
	large_explosion_effect.play("explode")
	
	# Wait for explosion animation to complete (8 frames at 15 fps = ~0.53 seconds)
	await get_tree().create_timer(0.53).timeout
	_hide_large_explosion_effect()

func _lightning_hit_effect(hit_pos: Vector2) -> void:
	# Show small explosion effect at impact point
	small_explosion_effect.position = hit_pos
	small_explosion_effect.visible = true
	small_explosion_effect.modulate = Color.CYAN
	small_explosion_effect.scale = Vector2(3, 3)
	small_explosion_effect.play("explode")
	
	# Wait for explosion animation to complete (5 frames at 12 fps = ~0.42 seconds)
	await get_tree().create_timer(0.42).timeout
	_hide_small_explosion_effect()

func _show_bullet_effect(target_pos: Vector2) -> void:
	# Get the player sprite position for accurate start position
	var player_sprite = selected_party_member.get_node("PlayerSprite")
	var start_pos = player_sprite.global_position
	
	# Start bullet at player sprite position
	bullet_effect.position = start_pos
	bullet_effect.visible = true
	bullet_effect.modulate = Color.WHITE
	bullet_effect.scale = Vector2(3, 3)
	bullet_effect.play("fly")
	
	# Animate bullet travel from player to enemy
	var tween = create_tween()
	tween.parallel().tween_property(bullet_effect, "position", target_pos, 0.3)
	
	# Hit effect at target
	tween.tween_callback(_show_bullet_hit_effect.bind(target_pos))
	tween.tween_interval(0.1)
	tween.tween_callback(_hide_bullet_effect)
	
	# Wait for the entire effect to complete
	await tween.finished

func _show_knight_melee_attack(target_pos: Vector2, target: Actor) -> void:
	# Get the player sprite and its original position
	var player_sprite = selected_party_member.get_node("PlayerSprite")
	var start_pos = player_sprite.global_position
	
	# Calculate attack position (close to enemy)
	var attack_pos = target_pos + Vector2(-60, 0)  # Position knight to the left of enemy
	
	# Start running animation
	if player_sprite is AnimatedSprite2D:
		var aspr: AnimatedSprite2D = player_sprite
		if aspr.sprite_frames and aspr.sprite_frames.has_animation(&"run"):
			aspr.play(&"run")
	
	# Move knight to enemy
	var tween = create_tween()
	tween.parallel().tween_property(player_sprite, "global_position", attack_pos, 0.6)
	
	# When knight reaches enemy, play attack animation
	tween.tween_callback(func(): 
		if player_sprite is AnimatedSprite2D:
			var aspr: AnimatedSprite2D = player_sprite
			if aspr.sprite_frames and aspr.sprite_frames.has_animation(&"attack"):
				aspr.play(&"attack")
	)
	
	# Apply damage at the end of attack animation (6 frames at 12 fps = 0.5 seconds)
	tween.tween_interval(0.5)
	tween.tween_callback(func(): selected_party_member.perform_basic_attack_with_hit_effect(target))
	
	# After attack, run back to original position
	tween.tween_callback(func(): 
		if player_sprite is AnimatedSprite2D:
			var aspr: AnimatedSprite2D = player_sprite
			if aspr.sprite_frames and aspr.sprite_frames.has_animation(&"run"):
				aspr.play(&"run")
	)
	tween.parallel().tween_property(player_sprite, "global_position", start_pos, 0.6)
	
	# Return to idle when back at original position
	tween.tween_callback(func(): 
		if player_sprite is AnimatedSprite2D:
			var aspr: AnimatedSprite2D = player_sprite
			if aspr.sprite_frames and aspr.sprite_frames.has_animation(&"idle"):
				aspr.play(&"idle")
	)
	
	# Wait for the entire sequence to complete
	await tween.finished

func _show_wizard_spell_attack(target_pos: Vector2, target: Actor) -> void:
	# Get the player sprite
	var player_sprite = selected_party_member.get_node("PlayerSprite")
	
	# Play spell casting animation (attack animation)
	if player_sprite is AnimatedSprite2D:
		var aspr: AnimatedSprite2D = player_sprite
		if aspr.sprite_frames and aspr.sprite_frames.has_animation(&"attack"):
			aspr.play(&"attack")
	
	# Wait for 8 frames into the attack animation (8 frames at 12 fps = ~0.67 seconds)
	await get_tree().create_timer(0.67).timeout
	
	# Launch projectile at 8 frames in (when she "throws" it)
	await create_spell_projectile_effect(player_sprite.global_position, target_pos, target)
	
	# Wait for remaining animation frames to complete (5 frames at 12 fps = ~0.42 seconds)
	await get_tree().create_timer(0.42).timeout
	
	# Return to idle animation
	if player_sprite is AnimatedSprite2D:
		var aspr: AnimatedSprite2D = player_sprite
		if aspr.sprite_frames and aspr.sprite_frames.has_animation(&"idle"):
			aspr.play(&"idle")

func create_spell_projectile_effect(start_pos: Vector2, target_pos: Vector2, target: Actor) -> void:
	# Create a magical projectile effect using the lightning effect
	# but styled differently for the wizard's spell
	lightning_effect.position = start_pos
	lightning_effect.visible = true
	lightning_effect.modulate = Color.PURPLE
	lightning_effect.scale = Vector2(2, 2)
	lightning_effect.play("beam")
	
	# Animate spell projectile travel from wizard to enemy
	var tween = create_tween()
	tween.parallel().tween_property(lightning_effect, "position", target_pos, 0.8)
	tween.parallel().tween_property(lightning_effect, "scale", Vector2(3, 3), 0.4)
	tween.parallel().tween_property(lightning_effect, "modulate", Color.MAGENTA, 0.4)
	
	# Hit effect and damage at target
	tween.tween_callback(_wizard_spell_hit_effect.bind(target_pos, target))
	tween.tween_interval(0.1)
	tween.tween_callback(_hide_wizard_spell_effect)
	
	# Wait for the entire effect to complete
	await tween.finished

func _wizard_spell_hit_effect(hit_pos: Vector2, target: Actor) -> void:
	# Show magical explosion effect at impact point
	small_explosion_effect.position = hit_pos
	small_explosion_effect.visible = true
	small_explosion_effect.modulate = Color.PURPLE
	small_explosion_effect.scale = Vector2(4, 4)
	small_explosion_effect.play("explode")
	
	# Apply damage when spell hits
	selected_party_member.perform_basic_attack_with_hit_effect(target)
	
	# Wait for explosion animation to complete
	await get_tree().create_timer(0.42).timeout
	_hide_small_explosion_effect()

func _hide_wizard_spell_effect() -> void:
	lightning_effect.visible = false
	lightning_effect.scale = Vector2(3, 3)
	lightning_effect.modulate = Color.WHITE

func _start_star_twinkling():
	# Create random twinkling effects for all stars
	var stars = stars_container.get_children()
	for star in stars:
		if star is AnimatedSprite2D:
			if star.name.begins_with("ShootingStar"):
				_animate_shooting_star(star)
			else:
				_twinkle_star(star)

func _twinkle_star(star: AnimatedSprite2D):
	# Random delay before starting to twinkle
	var delay = randf_range(0.5, 2.0)
	await get_tree().create_timer(delay).timeout
	
	while true:
		# Random twinkle intensity
		var original_alpha = star.modulate.a
		var twinkle_alpha = randf_range(0.3, 1.0)
		
		# Create twinkle effect
		var tween = create_tween()
		tween.tween_property(star, "modulate:a", twinkle_alpha, randf_range(0.5, 1.5))
		tween.tween_property(star, "modulate:a", original_alpha, randf_range(0.5, 1.5))
		
		# Random pause before next twinkle
		await get_tree().create_timer(randf_range(1.0, 4.0)).timeout

func _animate_shooting_star(star: AnimatedSprite2D):
	# Random delay before shooting star appears
	var delay = randf_range(2.0, 8.0)
	await get_tree().create_timer(delay).timeout
	
	while true:
		# Reset position off-screen
		star.position = Vector2(-100, randf_range(100, 250))
		star.modulate.a = 0.0
		
		# Fade in
		var tween = create_tween()
		tween.parallel().tween_property(star, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(star, "position", Vector2(get_viewport().size.x + 100, star.position.y + randf_range(-50, 50)), 1.5)
		
		# Fade out at the end
		tween.tween_property(star, "modulate:a", 0.0, 0.3)
		
		# Wait for animation to complete
		await tween.finished
		
		# Random delay before next shooting star
		await get_tree().create_timer(randf_range(5.0, 15.0)).timeout

func _show_bullet_hit_effect(target_pos: Vector2) -> void:
	# Show bullet hit effect at target position
	bullet_hit_effect.position = target_pos
	bullet_hit_effect.visible = true
	bullet_hit_effect.modulate = Color.WHITE
	bullet_hit_effect.scale = Vector2(2, 2)
	bullet_hit_effect.play("hit")
	
	# Wait for hit animation to complete (4 frames at 10 fps = 0.4 seconds)
	await get_tree().create_timer(0.4).timeout
	_hide_bullet_hit_effect()

func _hide_bullet_effect() -> void:
	bullet_effect.visible = false
	bullet_effect.scale = Vector2(3, 3)
	bullet_effect.modulate = Color.WHITE

func _hide_bullet_hit_effect() -> void:
	bullet_hit_effect.visible = false
	bullet_hit_effect.scale = Vector2(2, 2)
	bullet_hit_effect.modulate = Color.WHITE

func _on_battle_over(winner_team: String) -> void:
	attack_btn.disabled = true
	heal_btn.disabled = true
	fireball_btn.disabled = true
	lightning_btn.disabled = true
	end_btn.disabled = true
	turn_label.text = "Battle Over! Winner: %s" % winner_team

func _on_character_selected(character: Actor) -> void:
	selected_party_member = character
	_update_character_ui()
	_animate_ui_transition()

func _on_ui_transition_complete() -> void:
	# UI transition finished, can enable input again if needed
	pass

func _on_party_member_hp_changed(current: int, max: int) -> void:
	# Update the UI when any party member's HP changes
	_update_all_party_panels()

func _update_character_ui() -> void:
	# Update all party member panels
	_update_all_party_panels()
	
	# Update button colors to match selected character theme
	if selected_party_member:
		var theme = party_manager.get_character_theme(party_manager.selected_index)
		_update_button_theme(theme)
		
		# Update turn label
		turn_label.text = "Turn: %s (%s)" % [current_actor.display_name if current_actor else "None", current_actor.team if current_actor else ""]
		turn_label.modulate = theme["primary"]

func _update_all_party_panels() -> void:
	for i in range(party_manager.party_members.size()):
		var member = party_manager.party_members[i]
		var panel_name = "Player%dPanel" % (i + 1)
		var panel = party_stats_container.get_node_or_null(panel_name)
		
		if panel and member:
			_update_party_panel(panel, member, i)

func _update_party_panel(panel: Panel, member: Actor, index: int) -> void:
	var theme = party_manager.get_character_theme(index)
	var is_selected = (index == party_manager.selected_index)
	
	# Get panel elements
	var name_label = panel.get_node_or_null("Player%dName" % (index + 1))
	var hp_label = panel.get_node_or_null("Player%dStats/HPLabel" % (index + 1))
	var atk_label = panel.get_node_or_null("Player%dStats/ATKLabel" % (index + 1))
	var spd_label = panel.get_node_or_null("Player%dStats/SPDLabel" % (index + 1))
	var hp_bar = panel.get_node_or_null("Player%dHPBar" % (index + 1))
	
	# Update text content with very subtle color differences
	if name_label:
		name_label.text = member.display_name
		name_label.modulate = Color.WHITE.lerp(theme["primary"], 0.4) if is_selected else Color(0.9, 0.9, 0.9, 1.0)
	
	if hp_label:
		hp_label.text = "HP: %d/%d" % [member.hp, member.max_hp]
		hp_label.modulate = Color.WHITE.lerp(theme["accent"], 0.3) if is_selected else Color(0.8, 0.8, 0.8, 1.0)
	
	if atk_label:
		atk_label.text = "ATK: %d" % member.atk
		atk_label.modulate = Color.WHITE.lerp(theme["accent"], 0.3) if is_selected else Color(0.8, 0.8, 0.8, 1.0)
	
	if spd_label:
		spd_label.text = "SPD: %d" % member.speed
		spd_label.modulate = Color.WHITE.lerp(theme["accent"], 0.3) if is_selected else Color(0.8, 0.8, 0.8, 1.0)
	
	if hp_bar:
		hp_bar.max_value = member.max_hp
		hp_bar.value = member.hp
		hp_bar.modulate = Color.WHITE.lerp(theme["primary"], 0.5) if is_selected else Color(0.7, 0.7, 0.7, 1.0)
	
	# Style the panel with very subtle differences
	var style_box = StyleBoxFlat.new()
	if is_selected:
		style_box.bg_color = Color(0.25, 0.25, 0.25, 0.8).lerp(theme["secondary"], 0.3)  # Very subtle theme tint
		style_box.border_color = Color(0.5, 0.5, 0.5, 0.9).lerp(theme["primary"], 0.4)  # Subtle border tint
		style_box.border_width_left = 2
		style_box.border_width_right = 2
		style_box.border_width_top = 2
		style_box.border_width_bottom = 2
	else:
		style_box.bg_color = Color(0.2, 0.2, 0.2, 0.6)
		style_box.border_color = Color(0.4, 0.4, 0.4, 0.6)
		style_box.border_width_left = 1
		style_box.border_width_right = 1
		style_box.border_width_top = 1
		style_box.border_width_bottom = 1
	
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	
	panel.add_theme_stylebox_override("panel", style_box)

func _update_button_theme(theme: Dictionary) -> void:
	var buttons = [attack_btn, heal_btn, fireball_btn, lightning_btn, end_btn]
	
	for button in buttons:
		if button:
			# Create a softer style override for the larger buttons
			var style_box = StyleBoxFlat.new()
			style_box.bg_color = Color(theme["secondary"].r, theme["secondary"].g, theme["secondary"].b, 0.6)
			style_box.border_color = Color(theme["primary"].r, theme["primary"].g, theme["primary"].b, 0.8)
			style_box.border_width_left = 3
			style_box.border_width_right = 3
			style_box.border_width_top = 3
			style_box.border_width_bottom = 3
			style_box.corner_radius_top_left = 10
			style_box.corner_radius_top_right = 10
			style_box.corner_radius_bottom_left = 10
			style_box.corner_radius_bottom_right = 10
			
			button.add_theme_stylebox_override("normal", style_box)
			button.modulate = Color(0.95, 0.95, 0.95, 1.0)  # Slightly softer white
			
			# Make text larger for bigger buttons
			button.add_theme_font_size_override("font_size", 18)

func _animate_ui_transition() -> void:
	# Animate the button panel sliding/scaling
	var buttons_container = $UI/Buttons
	if buttons_container:
		var tween = create_tween()
		
		# Quick scale down and up for a "pop" effect
		tween.tween_property(buttons_container, "scale", Vector2(0.9, 0.9), 0.1)
		tween.tween_property(buttons_container, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(buttons_container, "scale", Vector2(1.0, 1.0), 0.1)
