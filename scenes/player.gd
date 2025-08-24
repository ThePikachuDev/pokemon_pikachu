extends CharacterBody2D

var SPEED = 200.0
var JUMP_VELOCITY = -300.0
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@export var max_jumps = 2


var jumps_done: int = 0


func give_powerup():
	var powerup_duration = 10
	
	sprite_2d.scale *= 2
	sprite_2d.position.y *= 2
	SPEED = 300
	JUMP_VELOCITY = -250
	collision.scale *= 2
	collision.position.y *= 2
	
	await get_tree().create_timer(powerup_duration).timeout
	
	SPEED = 200
	JUMP_VELOCITY = -300
	
	sprite_2d.scale /= 2
	sprite_2d.position.y /= 2
	
	collision.scale /= 2
	collision.position.y /= 2
	
	



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else: 
		jumps_done = 0

	# Handle jump.
	if Input.is_action_just_pressed("jump") and jumps_done < max_jumps:		
		velocity.y = JUMP_VELOCITY
		jumps_done +=1
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
