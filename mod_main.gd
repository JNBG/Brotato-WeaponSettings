extends Node

const MOD_DIR = "MincedMeatMole-WeaponSettings/"
const WEAPON_SETTINGS_LOG = "MincedMeatMole-WeaponSettings"
const WEAPON_SETTINGS_SAVE_FILE = "user://weapon_settings_save_file.save"
const WEAPON_SETTINGS_DEFAULTS_SAVE_FILE = "user://weapon_settings_defaults_save_file.save"

var dir = ""
var ext_dir = ""
var trans_dir = ""
var weapon_settings_save_data  = {}


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
	print("weapon_settings_save_data")
	print(weapon_settings_save_data)
	
#	var testweapon = load("res://weapons/melee/knife/1/knife_stats.tres")
#	testweapon.min_range = 400
#	testweapon.max_range = 1000
	
#	for weapon in weapons:
#	_weapon_settings_load_data()
#	if (weapon_settings_save_data != null):
#		for weapon in weapon_settings_save_data:
#			var alien_data = load("res://entities/units/enemies/"+weapon+"/"+str(int(weapon))+"_stats.tres")
#			for value in weapon_settings_save_data[weapon]:
#				alien_data[value] = weapon_settings_save_data[weapon][value]
	
	ModLoaderLog.info("Ready", WEAPON_SETTINGS_LOG)

func get_weapon_list():
	var weapons_by_name = {}
	for type in ["melee", "ranged"]:
		var weapons = get_list_of_directories("res://weapons/" + type)
		for weapon_name in weapons:
			weapons_by_name[weapon_name] = {}
			var weapon_tiers = get_list_of_directories("res://weapons/"+type+"/" + weapon_name)
			weapons_by_name[weapon_name]['tiers'] = {}
			for tier in weapon_tiers:
				weapons_by_name[weapon_name]['tiers'][tier] = get_stat_n_data_files_in_dir("res://weapons/"+type+"/" + weapon_name + "/" + tier, type)
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
	
func get_stat_n_data_files_in_dir(path, type):
	var statfile = ""
	var datafile = ""
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()
	while file_name != "":
		if not file_name.begins_with(".") and "stats" in file_name:
			statfile = load(path + "/" + file_name)
		elif not file_name.begins_with(".") and "data" in file_name:
			datafile = load(path + "/" + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
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
