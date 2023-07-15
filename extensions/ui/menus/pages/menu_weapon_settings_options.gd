extends Control

const WEAPON_SETTINGS_SAVE_FILE = "user://weapon_settings_save_file.save"
const WEAPON_SETTINGS_DEFAULTS_SAVE_FILE = "user://weapon_settings_defaults_save_file.save"
var weapon_settings_save_data  = {}
var weapon_settings_defaults  = {}

signal back_button_pressed

onready var back_button = $"%BackButton"
onready var weapons_form = $"%WeaponFormHolderInner"
onready var weapons_form_holder = $"%WeaponFormWrapper"
onready var all_buttons = $"%AllButtons"
onready var reset_button = $"%ResetButton"
onready var labels = $"%Labels"
onready var inputs = $"%Inputs"
onready var defaults = $"%Defaults"

onready var melee_weapons_buttons = $"%MeleeWeaponsButtons"
onready var ranged_weapons_buttons = $"%RangedWeaponsButtons"

onready var weapon_name_container = $"%Name"
onready var tier_slot_holder = $"%TierSlotHolder"
onready var tier_button = $"%TierButton"
onready var mini_spacer = $"%MiniSpacer"

var allPanels = [];
var allTierPanles = [];
var basetheme = load("res://resources/themes/base_theme.tres")
var weapons_theme = load("res://mods-unpacked/MincedMeatMole-WeaponSettings/ui/menus/weapons_settings_menu_theme.tres")
var weapon_buttons = {}
var tier_buttons = {}
var value_labels = {}

func _ready():

	pass

func init():
	back_button.grab_focus()
	back_button.connect("pressed", self, "_on_BackButton_pressed")

	_weapon_settings_load_data()
	_weapon_settings_load_defaults()

	var melee_weapons = get_weapon_list("melee")
	var ranged_weapons = get_weapon_list("ranged")
	
	delete_children(melee_weapons_buttons)
	delete_children(ranged_weapons_buttons)
	allPanels = []
	
	for melee_weapon in melee_weapons:
		melee_weapons_buttons.add_child(create_new_weapons_button(melee_weapons[melee_weapon], "melee"))

	for ranged_weapon in ranged_weapons:
		ranged_weapons_buttons.add_child(create_new_weapons_button(ranged_weapons[ranged_weapon], "ranged"))

func create_new_weapons_button(weapon, type):
	var panel = PanelContainer.new()
	var new_button = TextureButton.new()
	new_button.texture_normal = load(weapon.icon)
	new_button.connect("pressed", self, "_on_weapon_button_pressed", [panel, weapon, type])

	var dot = TextureRect.new()
	dot.texture = load("res://mods-unpacked/MincedMeatMole-WeaponSettings/ui/menus/weapon_settings_dot.png")
	dot.anchor_left = 1
	dot.anchor_right = 1
	dot.margin_left = -5
	dot.margin_top = -5
	dot.margin_right = 5
	dot.margin_bottom = 5
	dot.visible = _is_weapon_modified(weapon.internal_name)
	weapon_buttons[weapon.internal_name] = dot
	new_button.add_child(dot)

	panel.add_child(new_button)
	allPanels.append(panel)
	return panel

func create_new_tier_button(tier,weapon,type):
	var panel = PanelContainer.new()
	var new_button = tier_button.duplicate()
	if int(tier) == 0:
		new_button.texture_normal = load("res://mods-unpacked/MincedMeatMole-WeaponSettings/ui/menus/weapons_settings_plusminus.png")
	else:
		new_button.texture_normal = load("res://ui/menus/run/difficulty_selection/difficulty_icons/" + tier + ".png")
	new_button.connect("pressed", self, "_on_tier_button_pressed", [panel, tier, weapon,type])
	
	var dot = TextureRect.new()
	dot.texture = load("res://mods-unpacked/MincedMeatMole-WeaponSettings/ui/menus/weapon_settings_dot.png")
	dot.anchor_left = 1
	dot.anchor_right = 1
	dot.margin_left = 0
	dot.margin_top = -10
	dot.margin_right = 10
	dot.margin_bottom = 0
	dot.visible = _is_tier_modified(weapon.internal_name, tier)
	tier_buttons[tier] = dot
	new_button.add_child(dot)
	
	panel.add_child(new_button)
	allTierPanles.append(panel)
	return panel

func create_new_number_input(default, start, stop, step, weapon, tier, label, stat):
	var spinboxItem = SpinBox.new()
	if stat == "lifesteal" or stat == "crit_chance" or stat == "accuracy":
		default = default * 100
	spinboxItem.min_value = start
	spinboxItem.max_value = stop
	spinboxItem.step = step
	spinboxItem.rect_min_size.y = 54
	spinboxItem.value = default
	spinboxItem.connect("value_changed", self, "_save_single_value", [weapon, tier, stat]);

	buildInputRow(spinboxItem, label, tier, stat, weapon, 54)

func create_new_bool_input(default, weapon, tier, label, stat):
	var checkboxItem = CheckButton.new()
	checkboxItem.pressed = default
	checkboxItem.rect_min_size.y = 54
	checkboxItem.connect("toggled", self, "_save_single_value", [weapon, tier, stat]);
	buildInputRow(checkboxItem, label, tier, stat, weapon, 70)

func create_new_label(label, size, stat, weapon, tier):
	var labelItem = Label.new()
	labelItem.text = tr(label) + "  "
	labelItem.rect_min_size.y = size
	labelItem.valign = 1
	labelItem.align = 2	

	var dot = TextureRect.new()
	dot.texture = load("res://mods-unpacked/MincedMeatMole-WeaponSettings/ui/menus/weapon_settings_dot.png")
	dot.anchor_left = 1
	dot.anchor_right = 1
	dot.margin_left = -20
	dot.margin_top = -2
	dot.margin_right = -10
	dot.margin_bottom = 8
	dot.visible = _is_value_modified(weapon.internal_name, tier, stat)
	value_labels[stat] = dot
	labelItem.add_child(dot)

	return labelItem

func create_new_default_label(tier, stat, weaponname, size):
	var defaultLabelItem = Label.new()
	if int(tier) != 0:
		var value = weapon_settings_defaults[weaponname].tiers[tier][stat]
		if stat == "lifesteal" or stat == "crit_chance" or stat == "accuracy":
			value = value * 100
		defaultLabelItem.text = "  " + str(value) + "  "
	else:
		defaultLabelItem.text = "  "
	defaultLabelItem.rect_min_size.y = size
	defaultLabelItem.valign = 1
	return defaultLabelItem

func buildInputRow(input,label,tier,stat,weapon, size):
	var labelItem = create_new_label(label, size, stat, weapon, tier)
	var defaultItem = create_new_default_label(tier,stat,weapon.internal_name, size)

	labels.add_child(mini_spacer.duplicate())
	labels.add_child(labelItem)
	inputs.add_child(mini_spacer.duplicate())
	inputs.add_child(input)
	defaults.add_child(mini_spacer.duplicate())
	defaults.add_child(defaultItem)

func _on_weapon_button_pressed(panel:PanelContainer, weapon, type):
	for single_panel in allPanels:
		single_panel.set_theme(basetheme)
	panel.set_theme(weapons_theme)

	var weapon_data_max = load(weapon.tiers["4"].data);
	weapon_name_container.text = weapon_data_max.name

	allTierPanles = []
	delete_children(tier_slot_holder)
	var defaultTier = weapon.tiers.keys()[0];
	if (weapon.tiers.size() > 1):
		tier_slot_holder.add_child(create_new_tier_button(0, weapon, type))
		defaultTier = 0
	for tier in weapon.tiers:
		tier_slot_holder.add_child(create_new_tier_button(tier, weapon, type))

	_on_tier_button_pressed(tier_slot_holder.get_children()[0],defaultTier,weapon,type)

	weapons_form.visible = true

func _on_tier_button_pressed(panel, tier, weapon,type):
	for single_panel in allTierPanles:
		single_panel.set_theme(basetheme)
	panel.set_theme(weapons_theme)

	delete_children(labels)
	delete_children(inputs)
	delete_children(defaults)

	if int(tier) == 0:
		var data = load(weapon.tiers[weapon.tiers.keys()[0]].data)
		var stats = load(weapon.tiers[weapon.tiers.keys()[0]].stats)
	else:
		var data = load(weapon.tiers[tier].data)
		var stats = load(weapon.tiers[tier].stats)
		
		var value = data.value
		if (_is_value_modified(weapon.internal_name, tier, "value")):
			value = weapon_settings_save_data[weapon.internal_name].tiers[tier]["value"]
		var cooldown = stats.cooldown
		if (_is_value_modified(weapon.internal_name, tier, "cooldown")):
			cooldown = weapon_settings_save_data[weapon.internal_name].tiers[tier]["cooldown"]
		var damage = stats.damage
		if (_is_value_modified(weapon.internal_name, tier, "damage")):
			damage = weapon_settings_save_data[weapon.internal_name].tiers[tier]["damage"]
		var crit_chance = stats.crit_chance
		if (_is_value_modified(weapon.internal_name, tier, "crit_chance")):
			crit_chance = weapon_settings_save_data[weapon.internal_name].tiers[tier]["crit_chance"]
		var crit_damage = stats.crit_damage
		if (_is_value_modified(weapon.internal_name, tier, "crit_damage")):
			crit_damage = weapon_settings_save_data[weapon.internal_name].tiers[tier]["crit_damage"]
		var min_range = stats.min_range
		if (_is_value_modified(weapon.internal_name, tier, "min_range")):
			min_range = weapon_settings_save_data[weapon.internal_name].tiers[tier]["min_range"]
		var max_range = stats.max_range
		if (_is_value_modified(weapon.internal_name, tier, "max_range")):
			max_range = weapon_settings_save_data[weapon.internal_name].tiers[tier]["max_range"]
		var knockback = stats.knockback
		if (_is_value_modified(weapon.internal_name, tier, "knockback")):
			knockback = weapon_settings_save_data[weapon.internal_name].tiers[tier]["knockback"]
		var lifesteal = stats.lifesteal
		if (_is_value_modified(weapon.internal_name, tier, "lifesteal")):
			lifesteal = weapon_settings_save_data[weapon.internal_name].tiers[tier]["lifesteal"]
		var recoil = stats.recoil
		if (_is_value_modified(weapon.internal_name, tier, "recoil")):
			recoil = weapon_settings_save_data[weapon.internal_name].tiers[tier]["recoil"]
		var recoil_duration = stats.recoil_duration
		if (_is_value_modified(weapon.internal_name, tier, "recoil_duration")):
			recoil_duration = weapon_settings_save_data[weapon.internal_name].tiers[tier]["recoil_duration"]
		var additional_cooldown_every_x_shots = stats.additional_cooldown_every_x_shots
		if (_is_value_modified(weapon.internal_name, tier, "additional_cooldown_every_x_shots")):
			additional_cooldown_every_x_shots = weapon_settings_save_data[weapon.internal_name].tiers[tier]["additional_cooldown_every_x_shots"]
		var additional_cooldown_multiplier = stats.additional_cooldown_multiplier
		if (_is_value_modified(weapon.internal_name, tier, "additional_cooldown_multiplier")):
			additional_cooldown_multiplier = weapon_settings_save_data[weapon.internal_name].tiers[tier]["additional_cooldown_multiplier"]

		create_new_number_input(value, 0, 100000, 1, weapon, tier, "WEAPON_SETTINGS_PRICE", "value")
		create_new_number_input(cooldown, 0, 100000, 1, weapon, tier, "WEAPON_SETTINGS_COOLDOWN", "cooldown")
		create_new_number_input(damage, 0, 100000, 1, weapon, tier, "WEAPON_SETTINGS_DAMAGE", "damage")
		create_new_number_input(crit_chance, 1, 100, 1, weapon, tier, "WEAPON_SETTINGS_CRIT_CHANGE", "crit_chance")
		create_new_number_input(crit_damage, 0.01, 100, 0.01, weapon, tier, "WEAPON_SETTINGS_CRIT_DAMAGE", "crit_damage")
		create_new_number_input(min_range, 0, 10000, 1, weapon, tier, "WEAPON_SETTINGS_MIN_RANGE", "min_range")
		create_new_number_input(max_range, 0, 10000, 1, weapon, tier, "WEAPON_SETTINGS_MAX_RANGE", "max_range")
		create_new_number_input(knockback, 0, 10000, 1, weapon, tier, "WEAPON_SETTINGS_KNOCKBACK", "knockback")
		create_new_number_input(lifesteal, 0, 100, 1, weapon, tier, "WEAPON_SETTINGS_LIFESTEAL", "lifesteal")
		create_new_number_input(recoil, 0, 10000, 1, weapon, tier, "WEAPON_SETTINGS_RECOIL", "recoil")
		create_new_number_input(recoil_duration, 0.001, 100, 0.001, weapon, tier, "WEAPON_SETTINGS_RECOIL_DURATION", "recoil_duration")
		create_new_number_input(additional_cooldown_every_x_shots, -1, 1000000, 1, weapon, tier, "WEAPON_SETTINGS_ADDED_COOLDOWN", "additional_cooldown_every_x_shots")
		create_new_number_input(additional_cooldown_multiplier, -1, 1000000, 1, weapon, tier, "WEAPON_SETTINGS_ADDED_COOLDOWN_MULTIPLIER", "additional_cooldown_multiplier")

		if type == "ranged":
			var accuracy = stats.accuracy
			if (_is_value_modified(weapon.internal_name, tier, "accuracy")):
				accuracy = weapon_settings_save_data[weapon.internal_name].tiers[tier]["accuracy"]
			create_new_number_input(accuracy, 1, 100, 1, weapon, tier, "WEAPON_SETTINGS_ACCURACY", "accuracy")

		if type == "melee":
			var attack_type = stats.attack_type
			if (_is_value_modified(weapon.internal_name, tier, "attack_type")):
				attack_type = weapon_settings_save_data[weapon.internal_name].tiers[tier]["attack_type"]
			var alternate_attack_type = stats.alternate_attack_type
			if (_is_value_modified(weapon.internal_name, tier, "alternate_attack_type")):
				alternate_attack_type = weapon_settings_save_data[weapon.internal_name].tiers[tier]["alternate_attack_type"]
			create_new_bool_input(attack_type, weapon, tier, "WEAPON_SETTINGS_ATTACK_TYPE", "attack_type")
			create_new_bool_input(alternate_attack_type, weapon, tier, "WEAPON_SETTINGS_ALTERNATE_ATTACK_TYPE", "alternate_attack_type")

func _save_single_value(value, weapon, tier, stat):
	if stat == "lifesteal" or stat == "crit_chance" or stat == "accuracy":
		value = value / 100
	
	if stat == "attack_type":
		value = int(value)

	var fileToSave = weapon.tiers[tier].stats
	if stat == "value":
		fileToSave = weapon.tiers[tier].data

	var data = load(fileToSave)
	data[stat] = value

	if !weapon.internal_name in weapon_settings_save_data:
		weapon_settings_save_data[weapon.internal_name] = {}
		weapon_settings_save_data[weapon.internal_name]['tiers'] = {}

	if !tier in weapon_settings_save_data[weapon.internal_name]['tiers']:
		weapon_settings_save_data[weapon.internal_name]['tiers'][tier] = {}

	weapon_settings_save_data[weapon.internal_name]['tiers'][tier][stat] = value
	
	if _is_weapon_modified(weapon.internal_name):
		weapon_buttons[weapon.internal_name].visible = true
	else:
		weapon_buttons[weapon.internal_name].visible = false
#		
	if _is_tier_modified(weapon.internal_name, tier):
		tier_buttons[tier].visible = true
	else:
		tier_buttons[tier].visible = false
	
	if _is_value_modified(weapon.internal_name, tier, stat):
		value_labels[stat].visible = true
	else:
		value_labels[stat].visible = false	

	_weapon_settings_save_data()

func _is_weapon_modified(weapon):
	if weapon in weapon_settings_save_data:
		for tier in weapon_settings_save_data[weapon].tiers:
			for value_to_check in weapon_settings_defaults[weapon].tiers[tier]:
				if value_to_check in weapon_settings_save_data[weapon].tiers[tier]:
					if weapon_settings_save_data[weapon].tiers[tier][value_to_check] != weapon_settings_defaults[weapon].tiers[tier][value_to_check]:
						return true
	return false
	
func _is_tier_modified(weapon, tier):
	if weapon in weapon_settings_save_data:
		if tier in weapon_settings_save_data[weapon].tiers:
			for value_to_check in weapon_settings_defaults[weapon].tiers[tier]:
				if value_to_check in weapon_settings_save_data[weapon].tiers[tier]:
					if weapon_settings_save_data[weapon].tiers[tier][value_to_check] != weapon_settings_defaults[weapon].tiers[tier][value_to_check]:
						return true
	return false

func _is_value_modified(weapon, tier, stat):
	if weapon in weapon_settings_save_data:
		if tier in weapon_settings_save_data[weapon].tiers:
			if stat in weapon_settings_save_data[weapon].tiers[tier]:
				if weapon_settings_save_data[weapon].tiers[tier][stat] != weapon_settings_defaults[weapon].tiers[tier][stat]:
					return true
	return false


### Just File Handlers and Preppers ###
func get_weapon_list(type):
	var weapons = get_list_of_directories("res://weapons/" + type)
	var weapons_by_name = {}
	for weapon_name in weapons:
		weapons_by_name[weapon_name] = {}
		var weapon_tiers = get_list_of_directories("res://weapons/"+type+"/" + weapon_name)
		weapons_by_name[weapon_name]['internal_name'] = weapon_name
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

func _weapon_settings_load_defaults():
	var file = File.new()
	if not file.file_exists(WEAPON_SETTINGS_DEFAULTS_SAVE_FILE):
		return
	file.open(WEAPON_SETTINGS_DEFAULTS_SAVE_FILE, File.READ)
	weapon_settings_defaults = file.get_var()
	file.close()

func _on_BackButton_pressed():
	weapons_form.visible = false
	reset_button.visible = false
	emit_signal("back_button_pressed")
