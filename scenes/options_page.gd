extends Control

#@onready var game_manager = %GameManager
@onready var retro_shader_toggle_button: Button = $Panel/RetroBoxContainer/VBoxContainer/RetroShaderToggleButton

var music_volume_before_mute: float = 0.0
var sfx_volume_before_mute: float = 0.0
var is_music_muted: bool = false
var is_sfx_muted: bool = false
const MUTE_VOLUME_DB: float = -80.0 # Define a minimum volume for mute


@export var retro_shader: ColorRect 

func _on_retro_shader_toggle_button_pressed() -> void:
	if GameManager.is_shader_enabled:
		GameManager.is_shader_enabled = false
		retro_shader.visible = GameManager.is_shader_enabled 
		retro_shader_toggle_button.text = "Turn ON"
	else:
		GameManager.is_shader_enabled = true
		retro_shader.visible = GameManager.is_shader_enabled 
		retro_shader_toggle_button.text = "Turn OFF"


func _on_mouse_entered() -> void:
	self.visible = false

func _on_button_pressed() -> void:
	var music_bus_index: int = AudioServer.get_bus_index("music")
	
	if is_music_muted:
		# UNMUTE: Restore previous volume
		AudioServer.set_bus_volume_db(
			music_bus_index, 
			music_volume_before_mute
		)
		is_music_muted = false
	else:
		# MUTE: Save current volume and set to mute level
		music_volume_before_mute = AudioServer.get_bus_volume_db(music_bus_index)
		AudioServer.set_bus_volume_db(
			music_bus_index, 
			MUTE_VOLUME_DB
		)
		is_music_muted = true


func _on_mute_sfx_button_pressed() -> void:
	var sfx_bus_index: int = AudioServer.get_bus_index("sfx")
	if is_sfx_muted:
		# UNMUTE: Restore previous volume
		AudioServer.set_bus_volume_db(
			sfx_bus_index, 
			sfx_volume_before_mute
		)
		is_sfx_muted = false
	else:
		# MUTE: Save current volume and set to mute level
		sfx_volume_before_mute = AudioServer.get_bus_volume_db(sfx_bus_index)
		AudioServer.set_bus_volume_db(
			sfx_bus_index, 
			MUTE_VOLUME_DB
		)
		is_sfx_muted = true
