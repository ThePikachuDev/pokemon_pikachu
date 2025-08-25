extends CharacterBody2D

var SPEED = 200.0
var JUMP_VELOCITY = -300.0
@onready var sprite_2d = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@export var max_jumps = 2

const lines: Array[String] = [
	"less goo !",
	"i made it !!",
	"I am sooo much happy !",
	"you dont bileve me that i dont know how to speel that 3rd word in this line"
]

var jumps_done: int = 0


func give_powerup():
	var powerup_duration = 6
	

		
	sprite_2d.scale *= 2
	sprite_2d.position.y *= 2
	SPEED = 300
	JUMP_VELOCITY = -450
	collision.scale *= 2
	collision.position.y *= 2
	
	await get_tree().create_timer(powerup_duration).timeout
	
	SPEED = 200
	JUMP_VELOCITY = -300
	
	sprite_2d.scale /= 2
	sprite_2d.position.y /= 2
	
	collision.scale /= 2
	collision.position.y /= 2
	
	#
#
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("dialogue"):
		#DialogManager.start_dialog(global_position, lines)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else: 
		jumps_done = 0
	
	# Jump input
	if Input.is_action_just_pressed("jump") and jumps_done < max_jumps:		
		velocity.y = JUMP_VELOCITY
		jumps_done += 1

	# Movement input
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# ---- Animation Logic ----
	if not is_on_floor():
		if velocity.y < 0:
			sprite_2d.play("jump")   # going up
		#else:
			#sprite_2d.play("fall")   # going down
	elif direction != 0:
		sprite_2d.play("run")
	else:
		sprite_2d.play("idle")


	# Flip sprite
	if direction < 0:
		sprite_2d.flip_h = false
	elif direction > 0:
		sprite_2d.flip_h = true

	move_and_slide()
