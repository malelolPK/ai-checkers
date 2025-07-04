class_name SelectMenu
extends Control


@onready var min_button = $MarginContainer/HBoxContainer/VBoxContainer/min_button as Button
@onready var alpha_button = $MarginContainer/HBoxContainer/VBoxContainer/alpha_button as Button
@onready var start_level = preload("res://main.tscn") as PackedScene


func _ready():
	min_button.button_down.connect(minimax_pressed)
	alpha_button.button_down.connect(alpha_beta_pressed)
	
func minimax_pressed() -> void:
	get_tree().set_meta("algorithm_choice", 1)
	get_tree().change_scene_to_packed(start_level)

func alpha_beta_pressed() -> void:
	get_tree().set_meta("algorithm_choice", 2)
	get_tree().change_scene_to_packed(start_level)
