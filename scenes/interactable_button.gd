extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var is_button_pressed: bool = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.frame = 0
		is_button_pressed = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.frame = 1
		is_button_pressed = false
