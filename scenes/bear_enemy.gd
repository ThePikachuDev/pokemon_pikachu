extends CharacterBody2D

@export var speed: float = 80.0          
@export var gravity: float = 1200.0       
@export var walk_time: float = 3.0        
@export var ray_cast_length: float = 15.0 
@export var edge_check_offset_x: float = 10.0 

@onready var sprite = $BearEnemySprite
@onready var player_detect = $PlayerDetect
@onready var wall_check = $WallCheck     
@onready var edge_check = $EdgeCheck      

var direction: int = 1 
var walk_timer: float = 0.0
var is_chasing_player: bool = false
var target_position: Vector2 = Vector2.ZERO 

func _ready():
	sprite.flip_h = false
	walk_timer = walk_time
	
	player_detect.body_entered.connect(_on_player_detect_body_entered)
	player_detect.body_exited.connect(_on_player_detect_body_exited)
	
	update_raycasts()

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_chasing_player:
		chase_player()
	else:
		patrol_movement(delta)
	
	move_and_slide()
	
	update_animation_and_facing()

func patrol_movement(delta: float):
	update_raycasts() 
	
	if wall_check.is_colliding():
		change_direction()
		walk_timer = walk_time
	
	if not edge_check.is_colliding() and is_on_floor():
		change_direction()
		walk_timer = walk_time
	
	walk_timer -= delta
	if walk_timer <= 0:
		change_direction()
		walk_timer = walk_time
	
	velocity.x = speed * direction

func chase_player():
	var direction_to_target = sign(target_position.x - global_position.x)
	
	direction = int(direction_to_target)
	
	velocity.x = speed * direction

func change_direction():
	direction *= -1
	update_raycasts()

func update_raycasts():
	wall_check.target_position = Vector2(ray_cast_length * direction, 0)
	edge_check.position.x = edge_check_offset_x * direction

func update_animation_and_facing():
	if is_on_floor() and abs(velocity.x) > 1:
		sprite.play("run")
	else:
		sprite.stop() 
	
	if direction < 0:
		sprite.flip_h = true
	elif direction > 0:
		sprite.flip_h = false 

func _on_player_detect_body_entered(body: Node2D):
	if body.is_in_group("player"): 
		is_chasing_player = true
		target_position = body.global_position

func _on_player_detect_body_exited(body: Node2D):
	if body.is_in_group("player"):
		is_chasing_player = false
		velocity.x = 0 
		walk_timer = walk_time 
