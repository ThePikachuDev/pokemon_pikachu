extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("event ran")
	if "Player" in body.name:
		body.give_powerup()
		queue_free()
