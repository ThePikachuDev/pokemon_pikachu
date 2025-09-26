extends Sprite2D


@onready var marker: Marker2D = $Marker2D

func _ready() -> void:
	_update_sprite()

func _on_area_2d_body_entered(body: Node2D) -> void:
	GameManager.active_checkpoint = self
	if body.is_in_group("player"):
		GameManager.checkpoint_position = marker.global_position
		if GameManager.previous_checkpoint_node:
			GameManager.previous_checkpoint_node._update_sprite()
		GameManager.previous_checkpoint_node = self
		_update_sprite()

func _update_sprite() -> void:
	if marker.global_position == GameManager.checkpoint_position:
		frame = 1
	else: 
		frame = 0
