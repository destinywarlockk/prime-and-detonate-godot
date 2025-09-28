extends Node

# DataManager - Singleton for loading and managing JSON game data
# This handles loading all the JSON configuration files and provides access methods

signal data_loaded

var abilities_data: Dictionary = {}
var weapons_data: Dictionary = {}
var characters_data: Dictionary = {}
var enemies_data: Dictionary = {}

var data_path: String = "res://data/"

func _ready():
	# Load all data when the singleton starts
	load_all_data()

func load_all_data():
	"""Load all JSON data files"""
	print("Loading game data...")
	
	load_abilities()
	load_weapons()
	load_characters()
	load_enemies()
	
	print("All data loaded successfully")
	emit_signal("data_loaded")

func load_abilities():
	"""Load abilities from JSON file"""
	var file_path = data_path + "abilities.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		push_error("Failed to open abilities.json")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse abilities.json: " + json.get_error_message())
		return
	
	abilities_data = json.data
	print("Loaded " + str(abilities_data.abilities.size()) + " abilities")

func load_weapons():
	"""Load weapons from JSON file"""
	var file_path = data_path + "weapons.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		push_error("Failed to open weapons.json")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse weapons.json: " + json.get_error_message())
		return
	
	weapons_data = json.data
	print("Loaded " + str(weapons_data.weapons.size()) + " weapons")

func load_characters():
	"""Load characters from JSON file"""
	var file_path = data_path + "characters.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		push_error("Failed to open characters.json")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse characters.json: " + json.get_error_message())
		return
	
	characters_data = json.data
	print("Loaded " + str(characters_data.characters.size()) + " characters")

func load_enemies():
	"""Load enemies from JSON file"""
	var file_path = data_path + "enemies.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		push_error("Failed to open enemies.json")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse enemies.json: " + json.get_error_message())
		return
	
	enemies_data = json.data
	print("Loaded " + str(enemies_data.enemies.size()) + " enemies")

# Access methods for abilities
func get_ability_by_id(ability_id: String) -> Dictionary:
	"""Get an ability by its ID"""
	for ability in abilities_data.abilities:
		if ability.id == ability_id:
			return ability
	push_warning("Ability not found: " + ability_id)
	return {}

func get_all_abilities() -> Array:
	"""Get all abilities"""
	return abilities_data.abilities

func get_abilities_by_element(element: String) -> Array:
	"""Get all abilities of a specific element"""
	var filtered_abilities = []
	for ability in abilities_data.abilities:
		if ability.element == element:
			filtered_abilities.append(ability)
	return filtered_abilities

# Access methods for weapons
func get_weapon_by_id(weapon_id: String) -> Dictionary:
	"""Get a weapon by its ID"""
	for weapon in weapons_data.weapons:
		if weapon.id == weapon_id:
			return weapon
	push_warning("Weapon not found: " + weapon_id)
	return {}

func get_all_weapons() -> Array:
	"""Get all weapons"""
	return weapons_data.weapons

func get_unlocked_weapons() -> Array:
	"""Get all unlocked weapons"""
	var unlocked_weapons = []
	for weapon in weapons_data.weapons:
		if weapon.unlocked:
			unlocked_weapons.append(weapon)
	return unlocked_weapons

# Access methods for characters
func get_character_by_id(character_id: String) -> Dictionary:
	"""Get a character by its ID"""
	for character in characters_data.characters:
		if character.id == character_id:
			return character
	push_warning("Character not found: " + character_id)
	return {}

func get_all_characters() -> Array:
	"""Get all characters"""
	return characters_data.characters

func get_characters_by_class(character_class: String) -> Array:
	"""Get all characters of a specific class"""
	var filtered_characters = []
	for character in characters_data.characters:
		if character.class == character_class:
			filtered_characters.append(character)
	return filtered_characters

# Access methods for enemies
func get_enemy_by_id(enemy_id: String) -> Dictionary:
	"""Get an enemy by its ID"""
	for enemy in enemies_data.enemies:
		if enemy.id == enemy_id:
			return enemy
	push_warning("Enemy not found: " + enemy_id)
	return {}

func get_all_enemies() -> Array:
	"""Get all enemies"""
	return enemies_data.enemies

func get_enemies_by_faction(faction: String) -> Array:
	"""Get all enemies of a specific faction"""
	var filtered_enemies = []
	for enemy in enemies_data.enemies:
		if enemy.faction == faction:
			filtered_enemies.append(enemy)
	return filtered_enemies

# Utility methods
func is_data_loaded() -> bool:
	"""Check if all data has been loaded"""
	return abilities_data.size() > 0 and weapons_data.size() > 0 and characters_data.size() > 0 and enemies_data.size() > 0

func reload_data():
	"""Reload all data from JSON files"""
	abilities_data.clear()
	weapons_data.clear()
	characters_data.clear()
	enemies_data.clear()
	load_all_data()
