extends Area2D

@onready var game_manager = %GameManager
@onready var pick_up_sound: AudioStreamPlayer2D = $PickUpSound

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		pick_up_sound.pitch_scale = randf_range(0.8, 1.2)
		pick_up_sound.play()
		await pick_up_sound.finished
		game_manager.add_bolt()
		self.queue_free()
