extends CharacterBody2D

@onready var game_manager = %GameManager
var is_player_in_range: bool = false
var spike_speed = 300.0

func _on_player_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range = true
		print("player detected")

func _physics_process(delta: float) -> void:
	if is_player_in_range:
		velocity.y = spike_speed 
		move_and_slide()

	elif is_on_floor():
		velocity.y = 0 
		is_player_in_range = false
		rotation_degrees = 180.0
		move_and_slide() 

func _on_player_on_spike_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.position = GameManager.active_checkpoint.position
		game_manager.take_damage()
		self.queue_free()
