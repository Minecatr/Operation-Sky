extends Node3D

const SAVE_PATH = "user://save_config_file.ini"

@onready var username = $CanvasLayer/Control/VBoxContainer/Username
@onready var address = $CanvasLayer/Control/VBoxContainer/ServerMenu/Address
@onready var port = $CanvasLayer/Control/VBoxContainer/ServerMenu/Port
@onready var thememenu = $CanvasLayer/Control/VBoxContainer/Theme

func save():
	var config = ConfigFile.new()
	config.set_value("User", "themeindex", thememenu.selected)
	config.set_value("User", "name", username.text)
	config.set_value("User", "port", port.value)
	config.set_value("User", "address", address.text)
	config.save(SAVE_PATH)

func _on_Host_pressed():
	save()
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _on_Join_pressed():
	save()
	get_tree().change_scene_to_file("res://Scenes/World.tscn")
	

func _on_Quit_pressed():
	save()
	get_tree().quit()

func _ready():
	var config = ConfigFile.new()
	config.load(SAVE_PATH)
	port.value = config.get_value("User", "port", 11987)
	address.text = config.get_value("User", "address", "")
	thememenu.add_item("Swift")
	thememenu.add_item("Clean")
	thememenu.selected = config.get_value("User", "themeindex", 0)
	$CanvasLayer/Control.theme = load("res://Assets/Resources/"+thememenu.get_item_text(thememenu.selected)+".tres")
	username.text = config.get_value("User", "name", "")

func _on_Theme_item_selected(index):
	$CanvasLayer/Control.theme = load("res://Assets/Resources/"+thememenu.get_item_text(index)+".tres")
	var config = ConfigFile.new()
	config.set_value("User", "themeindex", index)
	config.save(SAVE_PATH)

func _on_Username_text_entered(new_text):
	var config = ConfigFile.new()
	config.set_value("User", "name", new_text)
	config.save(SAVE_PATH)
