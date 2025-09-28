extends Control

#@onready var game_manager = %GameManager
@onready var retro_shader_toggle_button: Button = $Panel/RetroBoxContainer/VBoxContainer/RetroShaderToggleButton

#@export var music_muted: bool = true
#@export var sfx_muted: bool = true

#@onready var close_optoins_page: Button = $CloseOptoinsPage

#@export var is_shader: bool = GameManager.is_shader_enabled
#
#func _ready() -> void:  
	#if is_shader:
		#retro_shader_toggle_button.text = "Turn Off"
	#else:
		#retro_shader_toggle_button.text = "Turn On"
#@onready var retro_shader: ColorRect = $RetroShader

@export var retro_shader: ColorRect 
#
#func _ready() -> void:
	#if music_muted:
		#AudioServer.set_bus_volume_db(
			#AudioServer.get_bus_index("music"),
			#0
		#)
		#
	#if sfx_muted:
		#AudioServer.set_bus_volume_db(
		#AudioServer.get_bus_index("sfx"),
		#0
	#)	

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
	$".".visible = false

#var bus_name: String
#
#var bus_index: int
#
#func _ready() -> void:
	#bus_index = AudioServer.get_bus_index(bus_name)
	#value_changed.connect(_on_value_changed)
	#value = db_to_linear(
		#AudioServer.get_bus_volume_db(bus_index)
	#)

func _on_button_pressed() -> void:
	AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("music"),
			0
		)
	pass # Replace with function body.


func _on_mute_sfx_button_pressed() -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("sfx"),
		0
	)
	pass # Replace with function body.
