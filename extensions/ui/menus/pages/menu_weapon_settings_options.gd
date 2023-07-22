extends Control

const WEAPON_SETTINGS_SAVE_FILE = "user://weapon_settings_save_file.save"
const WEAPON_SETTINGS_DEFAULTS_SAVE_FILE = "user://weapon_settings_defaults_save_file.save"
const WEAPON_SETTINGS_OPTIONS_SAVE_FILE = "user://weapon_settings_options_save_file.save"
var weapon_settings_save_data  = {}
var weapon_settings_defaults  = {}
var weapon_settings_options  = {}

signal back_button_pressed

onready var back_button = $"%BackButton"
onready var weapons_form = $"%WeaponFormHolderInner"
onready var settings_controls = $"%SettingsControls"
onready var reset_tier_button = $"%ResetTier"
onready var reset_weapon_button = $"%ResetWeapon"
onready var labels = $"%Labels"
onready var inputs = $"%Inputs"
onready var defaults = $"%Defaults"
onready var scaling_button = $"%ScalingButton"
onready var scaling_container = $"%ScalingContainer"
onready var scaling_labels = $"%ScalingLabels"
onready var scaling_inputs = $"%ScalingInputs"
onready var scaling_defaults = $"%ScalingDefaults"

onready var melee_weapons_buttons = $"%MeleeWeaponsButtons"
onready var ranged_weapons_buttons = $"%RangedWeaponsButtons"

onready var weapon_name_container = $"%Name"
onready var tier_slot_holder = $"%TierSlotHolder"
onready var tier_button = $"%TierButton"
onready var mini_spacer = $"%MiniSpacer"
onready var mini_spacer_v = $"%MiniSpacerV"
onready var tier_info = $"%TierInfo"

var allPanels = []
var allTierPanles = []
var allInputs = {}
var scalingInputs = {}
var basetheme = load("res://resources/themes/base_theme.tres")
var weapons_theme = load("res://mods-unpacked/MincedMeatMole-WeaponSettings/ui/menus/weapons_settings_menu_theme.tres")
var weapon_buttons = {}
var tier_buttons = {}
var value_labels = {}
var current_weapon
var current_tier
var current_type
var scaling_shown = false

var common_int_data = [
	"value"
]
var common_int_stats = [
	"cooldown",
	"damage",
	"crit_chance",
	"crit_damage",
	"min_range",
	"max_range",
	"knockback",
	"lifesteal",
	"recoil",
	"recoil_duration",
	"additional_cooldown_every_x_shots",
	"additional_cooldown_multiplier",
]
var ranged_int_stats = [
	"accuracy",
	"nb_projectiles",
	"projectile_spread",
	"piercing",
	"piercing_dmg_reduction",
	"bounce",
	"bounce_dmg_reduction",
	"projectile_speed"
]
var melee_bool_stats = [
	"attack_type",
	"alternate_attack_type"
]
var ranged_bool_stats = [
	"increase_projectile_speed_with_range"
]
var infos = {
	"value": {
		"min": 0,
		"max": 100000,
		"step": 1,
		"label": "WEAPON_SETTINGS_PRICE"
	},
	"cooldown": {
		"min": 0,
		"max": 100000,
		"step": 1,
		"label": "WEAPON_SETTINGS_COOLDOWN"
	},
	"damage": {
		"min": 0,
		"max": 100000,
		"step": 1,
		"label": "WEAPON_SETTINGS_DAMAGE"
	},
	"crit_chance": {
		"min": 0,
		"max": 100,
		"step": 1,
		"label": "WEAPON_SETTINGS_CRIT_CHANGE"
	},
	"crit_damage": {
		"min": 0,
		"max": 100,
		"step": 0.01,
		"label": "WEAPON_SETTINGS_CRIT_DAMAGE"
	},
	"min_range": {
		"min": 0,
		"max": 10000,
		"step": 1,
		"label": "WEAPON_SETTINGS_MIN_RANGE"
	},
	"max_range": {
		"min": 0,
		"max": 10000,
		"step": 1,
		"label": "WEAPON_SETTINGS_MAX_RANGE"
	},
	"knockback": {
		"min": 0,
		"max": 10000,
		"step": 1,
		"label": "WEAPON_SETTINGS_KNOCKBACK"
	},
	"lifesteal": {
		"min": 0,
		"max": 100,
		"step": 1,
		"label": "WEAPON_SETTINGS_LIFESTEAL"
	},
	"recoil": {
		"min": 0,
		"max": 10000,
		"step": 1,
		"label": "WEAPON_SETTINGS_RECOIL"
	},
	"recoil_duration": {
		"min": 0,
		"max": 100,
		"step": 0.001,
		"label": "WEAPON_SETTINGS_RECOIL_DURATION"
	},
	"additional_cooldown_every_x_shots": {
		"min": -1,
		"max": 1000000,
		"step": 1,
		"label": "WEAPON_SETTINGS_ADDED_COOLDOWN"
	},
	"additional_cooldown_multiplier": {
		"min": -1,
		"max": 1000000,
		"step": 1,
		"label": "WEAPON_SETTINGS_ADDED_COOLDOWN_MULTIPLIER"
	},
	"accuracy": {
		"min": 0,
		"max": 100,
		"step": 1,
		"label": "WEAPON_SETTINGS_ACCURACY"
	},
	"nb_projectiles": {
		"min": 0,
		"max": 100,
		"step": 1,
		"label": "WEAPON_SETTINGS_NB_PROJECTILES"
	},
	"projectile_spread": {
		"min": 0,
		"max": 10,
		"step": 0.1,
		"label": "WEAPON_SETTINGS_PROJECTILE_SPREAD"
	},
	"piercing": {
		"min": 0,
		"max": 100,
		"step": 1,
		"label": "WEAPON_SETTINGS_PIERCING"
	},
	"piercing_dmg_reduction": {
		"min": 0,
		"max": 1000,
		"step": 0.1,
		"label": "WEAPON_SETTINGS_PIERCING_DMG_REDUCTION"
	},
	"bounce": {
		"min": 0,
		"max": 100,
		"step": 1,
		"label": "WEAPON_SETTINGS_BOUNCE"
	},
	"bounce_dmg_reduction": {
		"min": 0,
		"max": 1000,
		"step": 0.1,
		"label": "WEAPON_SETTINGS_BOUNCE_DMG_REDUCTION"
	},
	"projectile_speed": {
		"min": 0,
		"max": 1000000,
		"step": 1,
		"label": "WEAPON_SETTINGS_PROJECTILE_SPEED"
	},
	"increase_projectile_speed_with_range": {
		"default": false,
		"label": "WEAPON_SETTINGS_INCREASE_PROJECTILE_SPEED_WITH_RANGE"
	},
	"attack_type": {
		"default": 0,
		"label": "WEAPON_SETTINGS_ATTACK_TYPE"
	},
	"alternate_attack_type": {
		"default": false,
		"label": "WEAPON_SETTINGS_ALTERNATE_ATTACK_TYPE"
	}
}
var scaling_stats_holder = [
	"stat_max_hp",
	"stat_hp_regeneration",
	"stat_lifesteal",
	"stat_percent_damage",
	"stat_melee_damage",
	"stat_ranged_damage",
	"stat_elemental_damage",
	"stat_attack_speed",
	"stat_crit_chance",
	"stat_engineering",
	"stat_range",
	"stat_armor",
	"stat_dodge",
	"stat_speed",
	"stat_luck",
	"stat_harvesting",
	"stat_levels"
]

func _ready():
	pass

func init():
	back_button.grab_focus()
	back_button.connect("pressed", self, "_on_BackButton_pressed")

	scaling_button.connect("pressed", self, "_on_scaling_button_pressed")

	_weapon_settings_load_data()
	_weapon_settings_load_defaults()
	_weapon_settings_load_options()

	if (weapon_settings_options.show_scaling):
		scaling_container.visible = true
	else:
		scaling_container.visible = false

	var melee_weapons = get_weapon_list("melee")
	var ranged_weapons = get_weapon_list("ranged")

	delete_children(melee_weapons_buttons)
	delete_children(ranged_weapons_buttons)
	allPanels = []

	for melee_weapon in melee_weapons:
		melee_weapons_buttons.add_child(create_new_weapons_button(melee_weapons[melee_weapon], "melee"))

	for ranged_weapon in ranged_weapons:
		ranged_weapons_buttons.add_child(create_new_weapons_button(ranged_weapons[ranged_weapon], "ranged"))

	reset_tier_button.connect("pressed", self, "_on_reset_tier_button_pressed")
	reset_weapon_button.connect("pressed", self, "_on_reset_weapon_button_pressed")

func _on_reset_tier_button_pressed():
	if int(current_tier) != 0:
		reset_tier(current_tier)
		reset_inputs()
	else:
		_on_reset_weapon_button_pressed()

func reset_tier(tier):
	for default_value_key in weapon_settings_defaults[current_weapon.internal_name].tiers[tier]:
		var default_value = weapon_settings_defaults[current_weapon.internal_name].tiers[tier][default_value_key]
		if default_value_key == "scaling_stats":
			_reset_scaling_tier(default_value, current_weapon, tier)
		elif default_value_key == "alternate_attack_type":
			_save_single_value(default_value, current_weapon, tier, default_value_key)
		elif default_value_key == "attack_type":
			_save_single_value(default_value, current_weapon, tier, default_value_key)
		elif default_value_key == "increase_projectile_speed_with_range":
			_save_single_value(default_value, current_weapon, tier, default_value_key)
		elif default_value_key == "crit_chance" or default_value_key == "lifesteal" or default_value_key == "accuracy":
			default_value = default_value * 100
			_save_single_value(default_value, current_weapon, tier, default_value_key)
		else:
			_save_single_value(default_value, current_weapon, tier, default_value_key)

func reset_inputs():
	for default_value_key in weapon_settings_defaults[current_weapon.internal_name].tiers[current_tier]:
		var default_value = weapon_settings_defaults[current_weapon.internal_name].tiers[current_tier][default_value_key]
		if default_value_key == "scaling_stats":
			continue
		if default_value_key == "alternate_attack_type":
			allInputs[default_value_key].pressed = default_value
			continue
		if default_value_key == "attack_type":
			allInputs[default_value_key].pressed = default_value
			continue
		if default_value_key == "increase_projectile_speed_with_range":
			allInputs[default_value_key].pressed = default_value
			continue
		if default_value_key == "crit_chance" or default_value_key == "lifesteal" or default_value_key == "accuracy":
			default_value = default_value * 100

		allInputs[default_value_key].value = default_value

func _reset_scaling_tier(default_value, cur_weapon, tier):
	var defaultTierLevels = weapon_settings_defaults[cur_weapon.internal_name].tiers
	weapon_settings_save_data[cur_weapon.internal_name].tiers[tier].scaling_stats = defaultTierLevels[tier].scaling_stats
	if int(tier) == int(current_tier):
		var parsedDefaults = {}
		for stat in default_value:
			parsedDefaults[stat[0]] = stat[1] * 100
		for spinbox in scalingInputs:
			scalingInputs[spinbox].value = parsedDefaults[spinbox]
	if int(tier) != 0:
		var file = load(cur_weapon.tiers[tier].stats)
		file.scaling_stats = remove_zero_entries_from_scaling(defaultTierLevels[tier].scaling_stats)

	_weapon_settings_save_data()

func _on_reset_weapon_button_pressed():
	reset_inputs()
	if current_weapon.tiers.size() > 1:
		reset_tier(0)
	for tier in current_weapon.tiers:
		reset_tier(tier)

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
	if stat == "attack_type":
		checkboxItem.set_theme(weapons_theme)

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
		if stat == "alternate_attack_type":
			if value:
				value = tr("WEAPON_SETTINGS_YES")
			else:
				value = tr("WEAPON_SETTINGS_NO")
		if stat == "increase_projectile_speed_with_range":
			if value:
				value = tr("WEAPON_SETTINGS_YES")
			else:
				value = tr("WEAPON_SETTINGS_NO")
		if stat == "attack_type":
			if value == 0:
				value = tr("WEAPON_SETTINGS_STAB")
			elif value == 1:
				value = tr("WEAPON_SETTINGS_SWING")
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

	allInputs[stat] = input

func create_new_scaling_input_row(label, stat_name, value, default, weapon, tier):
	var box = HBoxContainer.new()
	box.alignment = BoxContainer.ALIGN_END
	box.rect_min_size.y = 54

	var labelItem = Label.new()
	labelItem.text = tr(label) + "  "
	labelItem.rect_min_size.y = 54
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
	dot.visible = value != default
	value_labels[stat_name] = dot
	labelItem.add_child(dot)

	var statIcon = TextureRect.new()
	if stat_name == "stat_levels":
		statIcon.texture = load("res://items/upgrades/upgrade_icon.png")
	else:
		statIcon.texture = load("res://items/stats/" + stat_name.replace("stat_","") + ".png")
	statIcon.expand = true
	statIcon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	statIcon.rect_min_size.x = 24
	statIcon.rect_min_size.y = 54

	var spinboxItem = SpinBox.new()
	spinboxItem.min_value = -1000000
	spinboxItem.max_value = 1000000
	spinboxItem.step = 1
	spinboxItem.rect_min_size.y = 54
	spinboxItem.value = value * 100
	spinboxItem.connect("value_changed", self, "_save_single_scaling_value", [weapon, tier, stat_name]);
	scalingInputs[stat_name] = spinboxItem

	var defaultLabelItem
	if int(tier) != 0:
		defaultLabelItem = Label.new()
		defaultLabelItem.text = str(default * 100) + "%  "
		defaultLabelItem.rect_min_size.y = 54
		defaultLabelItem.valign = Label.VALIGN_CENTER

	box.add_child(statIcon)
	box.add_child(mini_spacer.duplicate())
	box.add_child(labelItem)
	scaling_labels.add_child(box)
	if (stat_name != "stat_levels"):
		scaling_labels.add_child(mini_spacer_v.duplicate())

	scaling_inputs.add_child(mini_spacer.duplicate())
	scaling_inputs.add_child(spinboxItem)

	if int(tier) != 0:
		scaling_defaults.add_child(mini_spacer.duplicate())
		scaling_defaults.add_child(defaultLabelItem)

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
	settings_controls.visible = true
	tier_slot_holder.visible = true
	current_weapon = weapon
	current_type = type

func _on_tier_button_pressed(panel, tier, weapon, type):
	allInputs = {}
	scalingInputs = {}

	for single_panel in allTierPanles:
		single_panel.set_theme(basetheme)
	panel.set_theme(weapons_theme)

	if int(tier) == 0:
		tier_info.visible = true
	else:
		tier_info.visible = false


	delete_children(labels)
	delete_children(inputs)
	delete_children(defaults)
	delete_children(scaling_labels)
	delete_children(scaling_inputs)
	delete_children(scaling_defaults)

	if int(tier) == 0:
		infos.value.min = -100000
		infos.cooldown.min = -100000
		infos.damage.min = -100000
		infos.crit_chance.min = -100
		infos.crit_damage.min = -100
		infos.min_range.min = -10000
		infos.max_range.min = -10000
		infos.knockback.min = -10000
		infos.lifesteal.min = -100
		infos.recoil.min = -10000
		infos.recoil_duration.min = -100
		infos.additional_cooldown_every_x_shots.min = -1000000
		infos.additional_cooldown_multiplier.min = -1000000
		if type == "ranged":
			infos.accuracy.min = -100
			infos.nb_projectiles.min = -10000
			infos.projectile_spread.min = -10000
			infos.piercing.min = -10000
			infos.piercing_dmg_reduction.min = -10000
			infos.bounce.min = -10000
			infos.bounce_dmg_reduction.min = -10000
			infos.projectile_speed.min =  -10000

	var stats = load(weapon.tiers[weapon.tiers.keys()[0]].stats)
	if type == "ranged":
		infos.increase_projectile_speed_with_range.default = stats.increase_projectile_speed_with_range
	if type == "melee":
		infos.attack_type.default = stats.attack_type
		infos.alternate_attack_type.default = stats.alternate_attack_type

	for entry in common_int_data:
		var val = 0
		if int(tier) != 0:
			var data = load(weapon.tiers[tier].data)
			val = data[entry]
		if (_is_value_modified(weapon.internal_name, tier, entry)):
			val = weapon_settings_save_data[weapon.internal_name].tiers[tier][entry]
		create_new_number_input(val, infos[entry].min, infos[entry].max, infos[entry].step, weapon, tier, infos[entry].label, entry)

	for entry in common_int_stats:
		var val = 0
		if int(tier) != 0:
			var data = load(weapon.tiers[tier].stats)
			val = data[entry]
		if (_is_value_modified(weapon.internal_name, tier, entry)):
			val = weapon_settings_save_data[weapon.internal_name].tiers[tier][entry]
		create_new_number_input(val, infos[entry].min, infos[entry].max, infos[entry].step, weapon, tier, infos[entry].label, entry)

	if type == "ranged":
		for entry in ranged_int_stats:
			var val = 0
			if int(tier) != 0:
				var data = load(weapon.tiers[tier].stats)
				val = data[entry]
			if (_is_value_modified(weapon.internal_name, tier, entry)):
				val = weapon_settings_save_data[weapon.internal_name].tiers[tier][entry]
			create_new_number_input(val, infos[entry].min, infos[entry].max, infos[entry].step, weapon, tier, infos[entry].label, entry)

		for entry in ranged_bool_stats:
			if (_is_value_modified(weapon.internal_name, tier, entry)):
				infos[entry].default = weapon_settings_save_data[weapon.internal_name].tiers[tier][entry]
			create_new_bool_input(infos[entry].default, weapon, tier, infos[entry].label, entry)

	if type == "melee":
		for entry in melee_bool_stats:
			if (_is_value_modified(weapon.internal_name, tier, entry)):
				infos[entry].default = weapon_settings_save_data[weapon.internal_name].tiers[tier][entry]
			create_new_bool_input(infos[entry].default, weapon, tier, infos[entry].label, entry)

	var data = []
	if int(tier) != 0:
		data = load(weapon.tiers[tier].stats)
		data = data.scaling_stats
	else:
		if weapon.internal_name in weapon_settings_save_data:
			if tier in weapon_settings_save_data[weapon.internal_name].tiers:
				data = weapon_settings_save_data[weapon.internal_name].tiers[tier].scaling_stats
			else:
				data = weapon_settings_defaults[weapon.internal_name].tiers[tier].scaling_stats
	var parsedStats = {}
	var parsedDefaultStats = {}
	for stat in data:
		parsedStats[stat[0]] = stat[1]
	for stat in weapon_settings_defaults[weapon.internal_name].tiers[tier].scaling_stats:
		parsedDefaultStats[stat[0]] = stat[1]
	for scaling_stat_name in scaling_stats_holder:
		var val = 0
		var default = 0
		if scaling_stat_name in parsedStats:
			val = parsedStats[scaling_stat_name]
		if scaling_stat_name in parsedDefaultStats:
			default = parsedDefaultStats[scaling_stat_name]
		create_new_scaling_input_row("WEAPON_SETTINGS_" + scaling_stat_name.to_upper(), scaling_stat_name, val, default, weapon, tier)

	current_tier = tier

func _on_scaling_button_pressed():
	weapon_settings_options.show_scaling = not weapon_settings_options.show_scaling
	if (weapon_settings_options.show_scaling):
		scaling_container.visible = true
	else:
		scaling_container.visible = false
	_weapon_settings_save_options()

func _save_single_value(value, weapon, tier, stat):
	if stat == "lifesteal" or stat == "crit_chance" or stat == "accuracy":
		value = value / 100

	if stat == "attack_type":
		value = int(value)
	if int(tier) == 0:
		for tier in weapon.tiers:
			var fileToSave = weapon.tiers[tier].stats
			if stat == "value":
				fileToSave = weapon.tiers[tier].data
			var data = load(fileToSave)
			if stat == "attack_type":
				data[stat] = int(value)
			elif stat == "alternate_attack_type":
				data[stat] = value
			elif stat == "increase_projectile_speed_with_range":
				data[stat] = value
			else:
				data[stat] = weapon_settings_defaults[weapon.internal_name].tiers[tier][stat] + value
	else:
		var fileToSave = weapon.tiers[tier].stats
		if stat == "value":
			fileToSave = weapon.tiers[tier].data

		var data = load(fileToSave)
		data[stat] = value

	if !weapon.internal_name in weapon_settings_save_data:
		weapon_settings_save_data[weapon.internal_name] = {}
		weapon_settings_save_data[weapon.internal_name]['tiers'] = {}

	if int(tier) == 0:
		for tier in weapon.tiers:
			if !tier in weapon_settings_save_data[weapon.internal_name]['tiers']:
				weapon_settings_save_data[weapon.internal_name]['tiers'][tier] = {}

			if stat == "attack_type":
				weapon_settings_save_data[weapon.internal_name]['tiers'][tier][stat] = int(value)
			elif stat == "alternate_attack_type":
				weapon_settings_save_data[weapon.internal_name]['tiers'][tier][stat] = value
			elif stat == "increase_projectile_speed_with_range":
				weapon_settings_save_data[weapon.internal_name]['tiers'][tier][stat] = value
			else:
				weapon_settings_save_data[weapon.internal_name]['tiers'][tier][stat] = weapon_settings_defaults[weapon.internal_name].tiers[tier][stat] + value

			if _is_tier_modified(weapon.internal_name, tier):
				tier_buttons[tier].visible = true
			else:
				tier_buttons[tier].visible = false

	if !tier in weapon_settings_save_data[weapon.internal_name]['tiers']:
		weapon_settings_save_data[weapon.internal_name]['tiers'][tier] = {}

	weapon_settings_save_data[weapon.internal_name]['tiers'][tier][stat] = value

	if _is_weapon_modified(weapon.internal_name):
		weapon_buttons[weapon.internal_name].visible = true
	else:
		weapon_buttons[weapon.internal_name].visible = false

	if _is_tier_modified(weapon.internal_name, tier):
		tier_buttons[tier].visible = true
	else:
		tier_buttons[tier].visible = false

	if _is_value_modified(weapon.internal_name, tier, stat):
		value_labels[stat].visible = true
	else:
		value_labels[stat].visible = false

	_weapon_settings_save_data()

func _save_single_scaling_value(value, weapon, tier, stat_name):
	value = value / 100

	if int(tier) != 0:
		var statFile = load(weapon.tiers[tier].stats)

		var defaultStats = {}
		for stat in weapon_settings_defaults[weapon.internal_name].tiers[tier].scaling_stats:
			defaultStats[stat[0]] = stat[1]

		var saveStatDict = {}
		for stat in weapon_settings_defaults[weapon.internal_name].tiers[tier].scaling_stats:
			saveStatDict[stat[0]] = stat[1]
		for stat in statFile.scaling_stats:
			saveStatDict[stat[0]] = stat[1]

		saveStatDict[stat_name] = value

		var statsToSave = [];
		var nonZeroStatsToSave = [];
		for stat in saveStatDict:
			statsToSave.append([stat, saveStatDict[stat]])
			if (saveStatDict[stat] != 0):
				nonZeroStatsToSave.append([stat, saveStatDict[stat]])
		statFile.scaling_stats = nonZeroStatsToSave

		if !weapon.internal_name in weapon_settings_save_data:
			weapon_settings_save_data[weapon.internal_name] = {}
			weapon_settings_save_data[weapon.internal_name]["tiers"] = {}
		if !tier in weapon_settings_save_data[weapon.internal_name]["tiers"]:
			weapon_settings_save_data[weapon.internal_name]["tiers"][tier] = {}
		weapon_settings_save_data[weapon.internal_name]["tiers"][tier]["scaling_stats"] = statsToSave
	else:
		for tier in weapon.tiers:
			var statFile = load(weapon.tiers[tier].stats)
			var parsedStats = {}
			var defaultStats = {}
			for stat in statFile.scaling_stats:
				parsedStats[stat[0]] = stat[1]
			for stat in weapon_settings_defaults[weapon.internal_name].tiers[tier].scaling_stats:
				defaultStats[stat[0]] = stat[1]
			if !stat_name in defaultStats:
				defaultStats[stat_name] = 0
			parsedStats[stat_name] = defaultStats[stat_name] + value
			var statsToSave = [];
			for stat in parsedStats:
				if (parsedStats[stat] != 0):
					statsToSave.append([stat, parsedStats[stat]])
			statFile.scaling_stats = statsToSave

		if !weapon.internal_name in weapon_settings_save_data:
			weapon_settings_save_data[weapon.internal_name] = {}
			weapon_settings_save_data[weapon.internal_name]['tiers'] = {}

		var keys = weapon.tiers.keys()
		if !0 in keys:
			keys.append(0)
		for tier in keys:
			if !tier in weapon_settings_save_data[weapon.internal_name]['tiers']:
				weapon_settings_save_data[weapon.internal_name]['tiers'][tier] = {}
			if !"scaling_stats" in weapon_settings_save_data[weapon.internal_name]['tiers'][tier]:
				weapon_settings_save_data[weapon.internal_name]['tiers'][tier]["scaling_stats"] = {}

			var defaultStats = {}
			for stat in weapon_settings_defaults[weapon.internal_name].tiers[tier].scaling_stats:
				defaultStats[stat[0]] = stat[1]

			var saveStatDict = {}
			for stat in weapon_settings_defaults[weapon.internal_name].tiers[tier].scaling_stats:
				saveStatDict[stat[0]] = stat[1]

			for stat in weapon_settings_save_data[weapon.internal_name]['tiers'][tier].scaling_stats:
				saveStatDict[stat[0]] = stat[1]

			saveStatDict[stat_name] = defaultStats[stat_name] + value

			var statsToSave = [];
			for stat in saveStatDict:
				statsToSave.append([stat, saveStatDict[stat]])

			weapon_settings_save_data[weapon.internal_name].tiers[tier].scaling_stats = statsToSave

			if _is_tier_modified(weapon.internal_name, tier):
				tier_buttons[tier].visible = true
			else:
				tier_buttons[tier].visible = false

	if _is_weapon_modified(weapon.internal_name):
		weapon_buttons[weapon.internal_name].visible = true
	else:
		weapon_buttons[weapon.internal_name].visible = false

	if _is_tier_modified(weapon.internal_name, tier):
		tier_buttons[tier].visible = true
	else:
		tier_buttons[tier].visible = false

	if _is_value_modified(weapon.internal_name, tier, stat_name):
		value_labels[stat_name].visible = true
	else:
		value_labels[stat_name].visible = false

	_weapon_settings_save_data()

func _is_weapon_modified(weapon):
	if weapon in weapon_settings_save_data:
		for tier in weapon_settings_save_data[weapon].tiers:
			for value_to_check in weapon_settings_defaults[weapon].tiers[tier]:
				if value_to_check in weapon_settings_save_data[weapon].tiers[tier]:
					if value_to_check == "scaling_stats":
						for stat in scaling_stats_holder:
							if _find_scaling_value_by_statname(weapon_settings_save_data[weapon].tiers[tier].scaling_stats, stat) != _find_scaling_value_by_statname(weapon_settings_defaults[weapon].tiers[tier].scaling_stats, stat):
								return true
					else:
						if weapon_settings_save_data[weapon].tiers[tier][value_to_check] != weapon_settings_defaults[weapon].tiers[tier][value_to_check]:
							return true
	return false

func _is_tier_modified(weapon, tier):
	if weapon in weapon_settings_save_data:
		if tier in weapon_settings_save_data[weapon].tiers:
			for value_to_check in weapon_settings_defaults[weapon].tiers[tier]:
				if value_to_check in weapon_settings_save_data[weapon].tiers[tier]:
					if value_to_check == "scaling_stats":
						for stat in scaling_stats_holder:
							if _find_scaling_value_by_statname(weapon_settings_save_data[weapon].tiers[tier].scaling_stats, stat) != _find_scaling_value_by_statname(weapon_settings_defaults[weapon].tiers[tier].scaling_stats, stat):
								return true
					else:
						if weapon_settings_save_data[weapon].tiers[tier][value_to_check] != weapon_settings_defaults[weapon].tiers[tier][value_to_check]:
							return true
	return false

func _is_value_modified(weapon, tier, stat):
	if weapon in weapon_settings_save_data:
		if tier in weapon_settings_save_data[weapon].tiers:
			if stat in scaling_stats_holder:
				if "scaling_stats" in weapon_settings_save_data[weapon].tiers[tier]:
					if _find_scaling_value_by_statname(weapon_settings_save_data[weapon].tiers[tier].scaling_stats, stat) != _find_scaling_value_by_statname(weapon_settings_defaults[weapon].tiers[tier].scaling_stats, stat):
						return true
			else:
				if stat in weapon_settings_save_data[weapon].tiers[tier]:
					if weapon_settings_save_data[weapon].tiers[tier][stat] != weapon_settings_defaults[weapon].tiers[tier][stat]:
						return true
	return false

### Just File Handlers and Preppers ###
func remove_zero_entries_from_scaling(stats):
	var parsedStats = []
	for stat in stats:
		if (stat[1] != 0):
			parsedStats.append(stat)
	return parsedStats

func _find_scaling_value_by_statname(stats, statname):
	for stat in stats:
		if stat[0] == statname:
			return stat[1]

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
	settings_controls.visible = false
	tier_slot_holder.visible = false
	emit_signal("back_button_pressed")

func _weapon_settings_save_options():
	var file = File.new()
	file.open(WEAPON_SETTINGS_OPTIONS_SAVE_FILE, File.WRITE)
	file.store_var(weapon_settings_options)
	file.close()

func _weapon_settings_load_options():
	var file = File.new()
	if not file.file_exists(WEAPON_SETTINGS_OPTIONS_SAVE_FILE):
		weapon_settings_options = {
			"show_scaling": false
		}
		_weapon_settings_save_options()
	file.open(WEAPON_SETTINGS_OPTIONS_SAVE_FILE, File.READ)
	weapon_settings_options = file.get_var()
	file.close()
