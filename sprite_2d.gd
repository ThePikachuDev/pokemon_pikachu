extends Sprite2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var tween = create_tween()
		tween.tween_property(self,"global_position", Vector2(100,100),2.0)
