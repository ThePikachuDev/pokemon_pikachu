extends Area2D
@onready var game_manager = %GameManager
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var no_default_texture: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.position = GameManager.active_checkpoint.position
		game_manager.take_damage()
	
	if no_default_texture:
		sprite_2d.texture = null
