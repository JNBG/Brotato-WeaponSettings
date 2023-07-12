extends Control

const WEAPON_SETTINGS_SAVE_FILE = "user://weapon_settings_save_file.save"
var weapon_settings_save_data  = {}

signal back_button_pressed

onready var back_button = $"%BackButton"
onready var weapons_form = $"%WeaponFormHolderInner"
onready var weapons_form_holder = $"%WeaponFormWrapper"
onready var reset_button = $"%ResetButton"
onready var weapon_name = $"%Name"
onready var melee_weapons_buttons = $"%MeleeWeaponsButtons"
onready var ranged_weapons_buttons = $"%RangedWeaponsButtons"
onready var button_stencil = $"%ButtonStencil"

func _ready():
	pass

func init():
	back_button.grab_focus()
	back_button.connect("pressed", self, "_on_BackButton_pressed")
	
	_weapon_settings_load_data()
	
	var melee_weapons = get_weapon_list("melee")
	var ranged_weapons = get_weapon_list("ranged")
	
	for melee_weapon in melee_weapons:
		var btn = create_new_button(melee_weapons[melee_weapon])
		melee_weapons_buttons.add_child(btn)
		
	for ranged_weapon in ranged_weapons:
		var btn = create_new_button(ranged_weapons[ranged_weapon])
		ranged_weapons_buttons.add_child(btn)

func create_new_button(weapon):
	var panel = PanelContainer.new()
	var new_button = TextureButton.new()
	new_button.texture_normal = load(weapon.icon)
	panel.add_child(new_button)
	return panel
		
func get_weapon_list(type):	
	var weapons = get_list_of_directories("res://weapons/" + type)
	var weapons_by_name = {}
	for weapon_name in weapons:
		weapons_by_name[weapon_name] = {}
		var weapon_tiers = get_list_of_directories("res://weapons/"+type+"/" + weapon_name)
		weapons_by_name[weapon_name]['icon'] = "res://weapons/"+type+"/" + weapon_name +"/" + weapon_name.replace("sniper_gun", "sniper") + "_icon.png"
		weapons_by_name[weapon_name]['tiers'] = {}
		for tier in weapon_tiers:
			weapons_by_name[weapon_name]['tiers'][tier] = "res://weapons/"+type+"/" + weapon_name + "/" + tier + "/" + weapon_name + "_stats.tres"
			
	return weapons_by_name
	
func get_list_of_directories(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif dir.current_is_dir() and not file.begins_with(".") and file != "knuckles":
			files.append(file)
	dir.list_dir_end()
	return files


func _weapon_settings_save_data():
	var file = File.new()
	file.open(WEAPON_SETTINGS_SAVE_FILE, File.WRITE)
	file.store_var(weapon_settings_save_data)
	file.close()


func _weapon_settings_load_data():
	var file = File.new()
	if not file.file_exists(WEAPON_SETTINGS_SAVE_FILE):
		weapon_settings_save_data = {}
		_weapon_settings_save_data()
	file.open(WEAPON_SETTINGS_SAVE_FILE, File.READ)
	weapon_settings_save_data = file.get_var()
	file.close()

func _on_BackButton_pressed():
	weapons_form.visible = false
	reset_button.visible = false
	emit_signal("back_button_pressed")
