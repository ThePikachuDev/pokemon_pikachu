extends Control

#@onready var game_manager = %GameManager
@onready var play_button: Button = $VBoxContainer/play_button
@onready var quit_button: Button = $VBoxContainer/quit_button
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $VBoxContainer/play_button/AudioStreamPlayer2D

@onready var retro_shader_toggle_button = $OptionsPage/Panel/RetroBoxContainer/VBoxContainer/RetroShaderToggleButton
@onready var retro_shader: ColorRect = $RetroShader

@onready var music_player: AudioStreamPlayer2D = $MusicPlayer
@onready var options_page: Control = $OptionsPage


const MUSIC_TRACKS = [
	preload("res://assets/music/main menu bg music/1-24. St. Anne.ogg"),
	preload("res://assets/music/main menu bg music/1-34. Casino.ogg"),
	preload("res://assets/music/main menu bg music/1-39. Theme Of Cinnabar Island.ogg")
]

var current_focus: Button = null
var buttons: Array = []

func play_randome_track():
	var random_index = randi() % MUSIC_TRACKS.size()
	var random_track = MUSIC_TRACKS[random_index]
	music_player.stream = random_track
	
	music_player.play()

func _ready() -> void:
	play_randome_track()
	
	options_page.visible = false
	
	buttons = [play_button, quit_button]
	
	play_button.focus_neighbor_bottom = quit_button.get_path()
	quit_button.focus_neighbor_top = play_button.get_path()
	
	# Connect focus events for visual feedback
	for button in buttons:
		button.connect("focus_entered", _on_button_focus_entered.bind(button))
		button.connect("focus_exited", _on_button_focus_exited.bind(button))
	
	# Set initial focus to play button
	play_button.grab_focus()
	current_focus = play_button

func _input(event: InputEvent) -> void:
	# Handle Enter key press on focused button
	if event.is_action_pressed("ui_accept"):
		if current_focus == play_button:
			_on_play_button_pressed()
		elif current_focus == quit_button:
			_on_quit_button_pressed()
		get_viewport().set_input_as_handled()
	
	# Handle arrow key navigation
	elif event.is_action_pressed("ui_down"):
		if current_focus == play_button:
			quit_button.grab_focus()
			current_focus = quit_button
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("ui_up"):
		if current_focus == quit_button:
			play_button.grab_focus()
			current_focus = play_button
		get_viewport().set_input_as_handled()
	
	# Keep your existing enter/exit actions if you still want them
	if event.is_action_pressed("enter"):
		_on_play_button_pressed()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("exit"):
		_on_quit_button_pressed()
		get_viewport().set_input_as_handled()

# Visual feedback for focused buttons
func _on_button_focus_entered(button: Button) -> void:
	button.modulate = Color(1.2, 1.2, 1.2)  # Brighten when focused
	current_focus = button

func _on_button_focus_exited(button: Button) -> void:
	button.modulate = Color(1, 1, 1)  # Reset color when focus lost

var i = 0
func _on_play_button_pressed() -> void:
	# Prevent multiple rapid clicks
	if i > 0:
		return
		
	audio_stream_player_2d.play(0.0)
	$play_button_click_animation.play("click")
	i += 1
	play_button.position.y += 5
	await audio_stream_player_2d.finished
	get_tree().change_scene_to_file("res://scenes/main_scene_v_2.tscn")

func _on_quit_button_pressed() -> void:
	$quit_button_click_animation2.play("click")
	# Add a small delay to allow the animation to play
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()

func _on_options_button_pressed() -> void:
	$OptionsPage.visible = true


func _on_music_player_finished() -> void:
	play_randome_track()
