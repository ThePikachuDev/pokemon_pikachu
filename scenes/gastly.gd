extends CharacterBody2D

@export var player: CharacterBody2D
@export var speed: int = 50
@export var chase_speed: int = 150
@export var acceleration: int = 300

@export var left_boundary: float = -125
@export var right_boundary: float  = 125


@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var ray_cast_2d: RayCast2D = $Sprite2D/RayCast2D
@onready var timer: Timer = $Timer
@onready var game_manager = %GameManager
@onready var hurt_box: Area2D = $hurtBox

var gravity: float = 980.0
var direction: Vector2
var right_bounds: Vector2
var left_bounds: Vector2

enum States{
	WANDER,
	CHASE
}
var current_state = States.WANDER

func _ready() -> void:
	left_bounds = self.position + Vector2(left_boundary, 0)
	right_bounds = self.position + Vector2(right_boundary, 0 )
	

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_movement(delta)
	change_direction()
	look_for_player()

func look_for_player():
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		if collider == player:
			chase_player()
		elif current_state == States.CHASE:
			stop_chase()
	elif current_state == States.CHASE:
		stop_chase()


func chase_player() -> void:
	timer.stop()
	current_state = States.CHASE
	

func stop_chase() -> void:
	if timer.time_left <= 0:
		timer.start()
	

func handle_movement(delta: float) -> void:
	if current_state == States.WANDER:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(direction * chase_speed , acceleration * delta)
	move_and_slide()

func change_direction() -> void:
	if current_state == States.WANDER:
		if sprite_2d.flip_h:
			if self.position.x <= right_bounds.x:
				direction = Vector2(1,0)
			else:
				sprite_2d.flip_h = false
				ray_cast_2d.target_position = Vector2(left_boundary,0)
		else:
			if self.position.x >= left_bounds.x:
				direction = Vector2(-1,0)
			else: 
				sprite_2d.flip_h = true
				ray_cast_2d.target_position = Vector2(right_boundary,0)
	else:
		direction = (player.position - self.position).normalized()
		direction = sign(direction)
		if direction.x == 1:
			sprite_2d.flip_h = true
			ray_cast_2d.target_position = Vector2(right_boundary,0)
		else:
			sprite_2d.flip_h = false
			ray_cast_2d.target_position = Vector2(left_boundary,0)

func handle_gravity(delta:float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func _on_timer_timeout() -> void:
	current_state = States.WANDER

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.name == player.name:
		game_manager.take_damage()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.name == player.name:
		self.queue_free()
