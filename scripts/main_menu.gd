extends Control

@onready var play_button: Button = $VBoxContainer/play_button
@onready var quit_button: Button = $VBoxContainer/quit_button
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $VBoxContainer/play_button/AudioStreamPlayer2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		_on_play_button_pressed()	
	if event.is_action_pressed("exit"):
		_on_quit_button_pressed()	
	

func _on_play_button_pressed() -> void:
	audio_stream_player_2d.play(0.0)
	$play_button_click_animation.play("click")
	play_button.position.y += 5
	await audio_stream_player_2d.finished
	#await get_tree().create_timer(audio_stream_player_2d.e).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed() -> void:
	$quit_button_click_animation2.play("click")
	get_tree().quit()
