extends Node2D
class_name PartyManager

signal character_selected(character: Actor)
signal ui_transition_complete

@export var party_members: Array[Actor] = []
@export var selected_index: int = 0
@export var transition_duration: float = 0.3

var ui_container: Control
var character_panels: Array[Control] = []
var is_transitioning: bool = false

# Character themes - Very subtle, muted colors
var character_themes = [
	{"primary": Color(0.7, 0.6, 0.6, 1.0), "secondary": Color(0.5, 0.4, 0.4, 0.6), "accent": Color(0.9, 0.85, 0.85, 1.0)},  # Very muted red
	{"primary": Color(0.6, 0.65, 0.75, 1.0), "secondary": Color(0.45, 0.5, 0.6, 0.6), "accent": Color(0.85, 0.9, 0.95, 1.0)},  # Very muted blue
	{"primary": Color(0.6, 0.7, 0.6, 1.0), "secondary": Color(0.45, 0.55, 0.45, 0.6), "accent": Color(0.9, 0.95, 0.9, 1.0)}   # Very muted green
]

func _ready():
	# Collect party members from children
	for child in get_children():
		if child is Actor and child.team == "player":
			party_members.append(child)
	
	# Ensure we have exactly 3 party members
	if party_members.size() != 3:
		print("Warning: PartyManager expects exactly 3 party members, found ", party_members.size())
	
	# Initialize all character sprites to white
	for member in party_members:
		var sprite = member.get_node("PlayerSprite")
		sprite.modulate = Color.WHITE
	
	# Set up initial selection
	if party_members.size() > 0:
		_select_character(0)

func _input(event):
	if is_transitioning:
		return
		
	# Handle character switching with number keys only (arrow keys handled by Battle script)
	if event.is_action_pressed("character_1"):
		switch_to_character(0)
	elif event.is_action_pressed("character_2"):
		switch_to_character(1)
	elif event.is_action_pressed("character_3"):
		switch_to_character(2)

func switch_to_character(index: int):
	if index < 0 or index >= party_members.size() or index == selected_index:
		return
	
	if is_transitioning:
		return
	
	_select_character(index)

func _select_character(index: int):
	if index < 0 or index >= party_members.size():
		return
	
	var previous_index = selected_index
	selected_index = index
	
	# Start transition animation
	_animate_character_selection(previous_index, selected_index)
	
	# Emit signal for battle system
	character_selected.emit(party_members[selected_index])

func _animate_character_selection(from_index: int, to_index: int):
	is_transitioning = true
	
	# Scale down previous character
	if from_index >= 0 and from_index < party_members.size():
		var prev_char = party_members[from_index]
		_animate_character_deselect(prev_char)
	
	# Scale up and highlight new character
	var new_char = party_members[to_index]
	_animate_character_select(new_char)
	
	# Wait for animations to complete
	await get_tree().create_timer(transition_duration).timeout
	is_transitioning = false
	ui_transition_complete.emit()

func _animate_character_select(character: Actor):
	var sprite = character.get_node("PlayerSprite")
	var current_scale = sprite.scale  # Use current scale from scene
	var target_scale = current_scale * 1.15  # Much smaller scale increase
	
	# Create selection glow effect
	var glow_effect = _create_glow_effect(character)
	
	# Animate scale up with character theme color tint
	var tween = create_tween()
	tween.parallel().tween_property(sprite, "scale", target_scale, transition_duration)
	var character_tint = Color.WHITE.lerp(character_themes[selected_index]["primary"], 0.4)  # Match menu color intensity
	tween.parallel().tween_property(sprite, "modulate", character_tint, transition_duration)
	
	# Add gentle bounce effect
	tween.tween_property(sprite, "scale", target_scale * 0.98, 0.1)
	tween.tween_property(sprite, "scale", target_scale, 0.1)

func _animate_character_deselect(character: Actor):
	var sprite = character.get_node("PlayerSprite")
	var original_scale = sprite.scale / 1.15  # Calculate original scale from current
	
	# Remove glow effect
	_remove_glow_effect(character)
	
	# Animate scale down and return to white
	var tween = create_tween()
	tween.parallel().tween_property(sprite, "scale", original_scale, transition_duration)
	tween.parallel().tween_property(sprite, "modulate", Color.WHITE, transition_duration)

func _create_glow_effect(character: Actor):
	# No glow effect - just rely on scaling and color tinting for selection feedback
	# This prevents the "weird box" issue while maintaining visual selection feedback
	pass

func _remove_glow_effect(character: Actor):
	# Clean up any existing glow effects (for compatibility)
	var glow = character.get_node_or_null("SelectionGlow")
	var old_inner = character.get_node_or_null("SelectionGlowInner")
	var old_outer = character.get_node_or_null("SelectionGlowOuter")
	
	if glow:
		glow.queue_free()
	if old_inner:
		old_inner.queue_free()
	if old_outer:
		old_outer.queue_free()

func get_selected_character() -> Actor:
	if selected_index >= 0 and selected_index < party_members.size():
		return party_members[selected_index]
	return null

func get_character_theme(index: int) -> Dictionary:
	if index >= 0 and index < character_themes.size():
		return character_themes[index]
	return character_themes[0]

func set_ui_container(container: Control):
	ui_container = container
