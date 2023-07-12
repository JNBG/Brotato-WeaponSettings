extends Node

const MOD_DIR = "MincedMeatMole-WeaponSettings/"
const WEAPON_SETTINGS_LOG = "MincedMeatMole-WeaponSettings"
const WEAPON_SETTINGS_SAVE_FILE = "user://weapon_settings_save_file.save"

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
#	ModLoaderMod.add_translation(dir + "translations/weapon_setting_translations.en.translation")
#	ModLoaderMod.add_translation(dir + "translations/weapon_setting_translations.de.translation")


func _ready()->void:
#	for weapon in weapons:
#	_weapon_settings_load_data()
#	if (weapon_settings_save_data != null):
#		for weapon in weapon_settings_save_data:
#			var alien_data = load("res://entities/units/enemies/"+weapon+"/"+str(int(weapon))+"_stats.tres")
#			for value in weapon_settings_save_data[weapon]:
#				alien_data[value] = weapon_settings_save_data[weapon][value]
	
	ModLoaderLog.info("Ready", WEAPON_SETTINGS_LOG)
