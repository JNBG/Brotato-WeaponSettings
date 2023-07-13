extends Control

const WEAPON_SETTINGS_SAVE_FILE = "user://weapon_settings_save_file.save"
var weapon_settings_save_data  = {}

signal back_button_pressed

onready var back_button = $"%BackButton"
onready var weapons_form = $"%WeaponFormHolderInner"
onready var weapons_form_holder = $"%WeaponFormWrapper"
onready var reset_button = $"%ResetButton"

onready var melee_weapons_buttons = $"%MeleeWeaponsButtons"
onready var ranged_weapons_buttons = $"%RangedWeaponsButtons"

onready var weapon_name_container = $"%Name"
onready var tier_slot_holder = $"%TierSlotHolder"
onready var tier_button = $"%TierButton"

var allPanels = [];
var allTierPanles = [];
var basetheme = load("res://resources/themes/base_theme.tres")
var weapons_theme = load("res://mods-unpacked/MincedMeatMole-WeaponSettings/ui/menus/weapons_menu.tres")

func _ready():
	pass

func init():
	back_button.grab_focus()
	back_button.connect("pressed", self, "_on_BackButton_pressed")
	
	_weapon_settings_load_data()
	
	var melee_weapons = get_weapon_list("melee")
	var ranged_weapons = get_weapon_list("ranged")
	
	for melee_weapon in melee_weapons:
		melee_weapons_buttons.add_child(create_new_weapons_button(melee_weapons[melee_weapon]))
		
	for ranged_weapon in ranged_weapons:
		ranged_weapons_buttons.add_child(create_new_weapons_button(ranged_weapons[ranged_weapon]))

func create_new_weapons_button(weapon):
	var panel = PanelContainer.new()
	var new_button = TextureButton.new()
	new_button.texture_normal = load(weapon.icon)
	new_button.connect("pressed", self, "_on_weapon_button_pressed", [panel, weapon])
	panel.add_child(new_button)
	allPanels.append(panel)
	return panel

func create_new_tier_button(tier,weapon):
	var panel = PanelContainer.new()
	var new_button = tier_button.duplicate()
	new_button.texture_normal = load("res://ui/menus/run/difficulty_selection/difficulty_icons/" + tier + ".png")
	new_button.connect("pressed", self, "_on_tier_button_pressed", [panel, tier, weapon])
	panel.add_child(new_button)
	allTierPanles.append(panel)
	return panel
	
func _on_weapon_button_pressed(panel:PanelContainer, weapon):
	for single_panel in allPanels:
		single_panel.set_theme(basetheme)
	panel.set_theme(weapons_theme)
	
	var weapon_data_max = load(weapon.tiers["4"].data);
	weapon_name_container.text = weapon_data_max.name
	
	allTierPanles = []
	delete_children(tier_slot_holder)
	for tier in weapon.tiers:
		tier_slot_holder.add_child(create_new_tier_button(tier, weapon))
		
	_on_tier_button_pressed(tier_slot_holder.get_children()[0],weapon.tiers.keys()[0],weapon)
	
	weapons_form.visible = true
	
func _on_tier_button_pressed(panel, tier, weapon):
	for single_panel in allTierPanles:
		single_panel.set_theme(basetheme)
	panel.set_theme(weapons_theme)
		
	var tierData = weapon.tiers[tier]
	
	print(tierData.data)
	
func get_weapon_list(type):	
	var weapons = get_list_of_directories("res://weapons/" + type)
	var weapons_by_name = {}
	for weapon_name in weapons:
		weapons_by_name[weapon_name] = {}
		var weapon_tiers = get_list_of_directories("res://weapons/"+type+"/" + weapon_name)
		weapons_by_name[weapon_name]['icon'] = "res://weapons/"+type+"/" + weapon_name +"/" + weapon_name.replace("sniper_gun", "sniper") + "_icon.png"
		weapons_by_name[weapon_name]['tiers'] = {}
		for tier in weapon_tiers:
			weapons_by_name[weapon_name]['tiers'][tier] = get_stat_n_data_files_in_dir("res://weapons/"+type+"/" + weapon_name + "/" + tier)
						
			
	return weapons_by_name

func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
	
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
	
func get_stat_n_data_files_in_dir(path):
	var statfile = ""
	var datafile = ""
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()
	while file_name != "":
		if not file_name.begins_with(".") and "stats" in file_name:
			statfile = path + "/" + file_name
		elif not file_name.begins_with(".") and "data" in file_name:
			datafile = path + "/" + file_name
		file_name = dir.get_next()
	dir.list_dir_end()
	return {
		"stats": statfile,
		"data": datafile
	}

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
