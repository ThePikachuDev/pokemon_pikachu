extends Area2D

@onready var game_manager = %GameManager

func _on_player_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		transform.y += Vector2(2,0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.position = GameManager.active_checkpoint.position
		game_manager.take_damage()
