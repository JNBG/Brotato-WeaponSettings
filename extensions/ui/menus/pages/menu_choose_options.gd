extends "res://ui/menus/pages/menu_choose_options.gd"

signal weapon_settings_button_pressed

var _weapon_settings_button

func _ready():
	
	_weapon_settings_button = $Buttons / BackButton.duplicate()
	_weapon_settings_button.connect("pressed", self, "_on_weapon_settings_button_pressed")
	_weapon_settings_button.disconnect("pressed", self, "_on_BackButton_pressed")
	_weapon_settings_button.text = "Weapon Settings"
	var option_buttons = $Buttons.get_children()
	var before_to_last_index = $Buttons.get_child_count() - 2
	var before_to_last = option_buttons[before_to_last_index]
	$Buttons.add_child_below_node(before_to_last, _weapon_settings_button)

func _on_weapon_settings_button_pressed()->void : 
	emit_signal("weapon_settings_button_pressed")

