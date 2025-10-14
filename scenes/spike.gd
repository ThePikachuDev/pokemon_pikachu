extends CharacterBody2D

@onready var game_manager = %GameManager
var is_player_in_range: bool = false
var spike_speed = 300.0

func _on_player_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range = true
		print("player detected")

#func _on_body_entered(body: Node2D) -> void:
	#if body.is_in_group("player"):
		#print("player collided with spike")
		#body.position = GameManager.active_checkpoint.position
		#game_manager.take_damage()
	#self.queue_free()

func _physics_process(delta: float) -> void:
	if is_player_in_range:
		# Set a constant downward velocity for a sudden trap effect
		velocity.y = spike_speed 
		
		# NOTE: You don't need to multiply by delta here because move_and_slide handles time
		
		move_and_slide()
		# The damage is handled by the Area2D signal, so no need for collision checks here
	
	# If using CharacterBody2D, you should always call move_and_slide() if you want to use
	# is_on_floor(), even if velocity.y is 0
	elif is_on_floor():
		# Stop movement
		velocity.y = 0 
		is_player_in_range = false
		rotation_degrees = 180.0
		# Call move_and_slide() even when stationary to confirm it's grounded
		move_and_slide() 


func _on_player_on_spike_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.position = GameManager.active_checkpoint.position
		game_manager.take_damage()
		self.queue_free()
