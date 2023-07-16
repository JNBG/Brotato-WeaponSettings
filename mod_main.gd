extends Node

const MOD_DIR = "MincedMeatMole-WeaponSettings/"
const WEAPON_SETTINGS_LOG = "MincedMeatMole-WeaponSettings"
const WEAPON_SETTINGS_SAVE_FILE = "user://weapon_settings_save_file.save"
const WEAPON_SETTINGS_DEFAULTS_SAVE_FILE = "user://weapon_settings_defaults_save_file.save"

var dir = ""
var ext_dir = ""
var trans_dir = ""
var weapon_settings_save_data  = {}
var weapon_list = {}


func _init(modLoader = ModLoader):
	ModLoaderLog.info("Init", WEAPON_SETTINGS_LOG)
	dir = ModLoaderMod.get_unpacked_dir() + MOD_DIR

	# Add Extensions
	ModLoaderMod.install_script_extension(dir + "extensions/ui/menus/pages/menu_choose_options.gd")
	ModLoaderMod.install_script_extension(dir + "extensions/ui/menus/menus.gd")

	# Add localizations
	ModLoaderMod.add_translation(dir + "translations/weapon_setting_translations.en.translation")
	ModLoaderMod.add_translation(dir + "translations/weapon_setting_translations.de.translation")


func _ready()->void:
	_weapon_settings_save_defaults()
	_weapon_settings_load_data()

	if (weapon_settings_save_data != null):
		for weapon in weapon_settings_save_data:
			for tier in weapon_settings_save_data[weapon].tiers:
				if int(tier) != 0:
					for entry in weapon_settings_save_data[weapon].tiers[tier]:
						var weaponSettings;
						if entry == "value":
							weaponSettings = load(weapon_list[weapon].tiers[tier].data)
						else:
							weaponSettings = load(weapon_list[weapon].tiers[tier].stats)
						weaponSettings[entry] = weapon_settings_save_data[weapon].tiers[tier][entry]
							

	ModLoaderLog.info("Ready", WEAPON_SETTINGS_LOG)

func get_weapon_list():
	var weapons_by_name = {}
	for type in ["melee", "ranged"]:
		var weapons = get_list_of_directories("res://weapons/" + type)
		for weapon_name in weapons:
			weapons_by_name[weapon_name] = {}
			weapon_list[weapon_name] = {}
			var weapon_tiers = get_list_of_directories("res://weapons/"+type+"/" + weapon_name)
			weapons_by_name[weapon_name]['tiers'] = {}
			weapon_list[weapon_name]['tiers'] = {}
			for tier in weapon_tiers:
				weapon_list[weapon_name].tiers[tier] = {}
				weapons_by_name[weapon_name]['tiers'][tier] = get_stat_n_data_files_in_dir("res://weapons/"+type+"/" + weapon_name + "/" + tier, type, tier, weapon_name)
			weapons_by_name[weapon_name]['tiers'][0] = get_0_tier(type, weapons_by_name[weapon_name]['tiers'][weapon_tiers[0]])
	return weapons_by_name

func get_list_of_directories(path):
	var files = []
	var dirx = Directory.new()
	dirx.open(path)
	dirx.list_dir_begin()
	while true:
		var file = dirx.get_next()
		if file == "":
			break
		elif dirx.current_is_dir() and not file.begins_with(".") and file != "knuckles":
			files.append(file)
	dirx.list_dir_end()
	return files

func get_0_tier(type, first_stats):
	var defaultsats = {
		"value": 0,
		"cooldown": 0,
		"damage": 0,
		"crit_chance": 0,
		"crit_damage": 0,
		"min_range": 0,
		"max_range": 0,
		"knockback": 0,
		"lifesteal": 0,
		"recoil": 0,
		"recoil_duration": 0,
		"additional_cooldown_every_x_shots": 0,
		"additional_cooldown_multiplier": 0,
		"scaling_stats": first_stats.scaling_stats
	}
	if type == "melee":
		defaultsats["attack_type"] = first_stats.attack_type
		defaultsats["alternate_attack_type"] = first_stats.alternate_attack_type
	if type == "ranged":
		defaultsats["accuracy"] = 0
		defaultsats["nb_projectiles"] = 0
		defaultsats["projectile_spread"] = 0
		defaultsats["piercing"] = 0
		defaultsats["piercing_dmg_reduction"] = 0
		defaultsats["bounce"] = 0
		defaultsats["bounce_dmg_reduction"] = 0
		defaultsats["projectile_speed"] = 0
		defaultsats["increase_projectile_speed_with_range"] = first_stats.increase_projectile_speed_with_range
	return defaultsats

func get_stat_n_data_files_in_dir(path, type, tier, weapon_name):
	var statfile = ""
	var datafile = ""
	var diry = Directory.new()
	diry.open(path)
	diry.list_dir_begin(true, true)
	var file_name = diry.get_next()
	while file_name != "":
		if not file_name.begins_with(".") and "stats" in file_name:
			statfile = load(path + "/" + file_name)
			weapon_list[weapon_name].tiers[tier]["stats"] = path + "/" + file_name
		elif not file_name.begins_with(".") and "data" in file_name:
			datafile = load(path + "/" + file_name)
			weapon_list[weapon_name].tiers[tier]["data"] = path + "/" + file_name
		file_name = diry.get_next()
	diry.list_dir_end()

	var defaultsats = {
		"value": datafile.value,
		"cooldown": statfile.cooldown,
		"damage": statfile.damage,
		"crit_chance": statfile.crit_chance,
		"crit_damage": statfile.crit_damage,
		"min_range": statfile.min_range,
		"max_range": statfile.max_range,
		"knockback": statfile.knockback,
		"lifesteal": statfile.lifesteal,
		"recoil": statfile.recoil,
		"recoil_duration": statfile.recoil_duration,
		"additional_cooldown_every_x_shots": statfile.additional_cooldown_every_x_shots,
		"additional_cooldown_multiplier": statfile.additional_cooldown_multiplier,
		"scaling_stats": statfile.scaling_stats
	}

	if type == "melee":
		defaultsats["attack_type"] = statfile.attack_type
		defaultsats["alternate_attack_type"] = statfile.alternate_attack_type

	if type == "ranged":
		defaultsats["accuracy"] = statfile.accuracy
		defaultsats["nb_projectiles"] = statfile.nb_projectiles
		defaultsats["projectile_spread"] = statfile.projectile_spread
		defaultsats["piercing"] = statfile.piercing
		defaultsats["piercing_dmg_reduction"] = statfile.piercing_dmg_reduction 
		defaultsats["bounce"] = statfile.bounce 
		defaultsats["bounce_dmg_reduction"] = statfile.bounce_dmg_reduction 
		defaultsats["projectile_speed"] = statfile.projectile_speed 
		defaultsats["increase_projectile_speed_with_range"] = statfile.increase_projectile_speed_with_range 

	return defaultsats

func _weapon_settings_save_defaults():
	var file = File.new()
	file.open(WEAPON_SETTINGS_DEFAULTS_SAVE_FILE, File.WRITE)
	file.store_var(get_weapon_list())
	file.close()

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
