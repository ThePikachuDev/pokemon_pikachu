extends Area2D

@onready var game_manager = %GameManager

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.position = game_manager.active_checkpoint.position
		game_manager.take_damage()
