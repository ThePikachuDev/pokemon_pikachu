extends CharacterBody2D
 
@export var speed = 100.0
@export var patrol_points: Array[Marker2D] = []
var current_point_index = 0
 
@onready var detection_area: Area2D = $Area2D  # Reference to the detection area
var player: Node2D = null  # Reference to the player, initially set to null
 
func _ready() -> void:
	if patrol_points.size() == 0:
		print("No patrol points assigned!")
		
	detection_area.body_entered.connect(_on_player_detected)
	detection_area.body_exited.connect(_on_player_lost)
 
func _on_player_detected(body: Node2D) -> void:
	if body.name == "Player":
		player = body  # Set the player reference when detected
 
func _on_player_lost(body: Node2D) -> void:
	if body == player:
		player = null  # Reset the player reference when they leave
 
func _process(delta: float) -> void:
	if player:
		chase_player()  # If a player is detected, chase them
	else:
		patrol()  # Call the patrol function every frame
	move_and_slide()  # Apply movement to the enemy
 
func chase_player() -> void:
	velocity = (player.global_position - global_position).normalized() * speed
	
func patrol() -> void:
	if patrol_points.size() > 0:
		var target = patrol_points[current_point_index].position
		velocity = (target - position).normalized() * speed
 
		if position.distance_to(target) < 10.0:
			current_point_index += 1
			if current_point_index >= patrol_points.size():
				current_point_index = 0 
 
