extends Control

@onready var play_button: Button = $VBoxContainer/play_button
@onready var quit_button: Button = $VBoxContainer/quit_button



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		_on_play_button_pressed()	
	if event.is_action_pressed("exit"):
		_on_quit_button_pressed()	
	

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
