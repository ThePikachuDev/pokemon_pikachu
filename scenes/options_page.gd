extends Control

#@onready var game_manager = %GameManager
@onready var retro_shader_toggle_button: Button = $Panel/RetroBoxContainer/VBoxContainer/RetroShaderToggleButton

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

func _on_retro_shader_toggle_button_pressed() -> void:
	if GameManager.is_shader_enabled:
		GameManager.is_shader_enabled = false
		retro_shader.visible = GameManager.is_shader_enabled 
		retro_shader_toggle_button.text = "Turn Off"
		print(retro_shader.visible)
	else:
		GameManager.is_shader_enabled = true
		retro_shader.visible = GameManager.is_shader_enabled 
		retro_shader_toggle_button.text = "Turn On"
		print(retro_shader.visible)


func _on_mouse_entered() -> void:
	$".".visible = false
