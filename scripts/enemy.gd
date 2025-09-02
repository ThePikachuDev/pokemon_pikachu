extends Node2D
@onready var ray_cast_left: RayCast2D = $RayCast2D
@onready var ray_cast_right: RayCast2D = $RayCast2D2
@onready var leaves: Sprite2D = $Leaves
@onready var timer: Timer = $Leaves/Timer
var direction: int
var SPEED = 1
@onready var animated_enemy_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event):	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_cast_left.is_colliding():
		direction = -1
		
		throw_leaves(direction)
		timer.start()
		print("collided with left ray cast")
	if ray_cast_right.is_colliding():
		direction = 1
		timer.start()
		leaves.visible = true
		throw_leaves(direction)
		print("collided with right ray cast")
	pass

func throw_leaves(dir: int):
	leaves.visible = true
	leaves.position.x += SPEED * dir

func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().reload_current_scene()
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	leaves.visible = false
	leaves.position = global_position
	
