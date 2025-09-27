extends Node2D

@onready var game_manager = %GameManager

func _on_area_2d_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		give_heart()


func give_heart():
	if game_manager.health < 3:
		game_manager.health += 1
	queue_free()
