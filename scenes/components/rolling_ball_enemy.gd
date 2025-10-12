extends CharacterBody2D

var ball_speed: float = 50.0
const GRAVITY = 980.0

func _ready() -> void:
	add_to_group("electrode")
	pass

func _process(delta: float) -> void:
	rotation -= 1 * delta
	velocity.x -= ball_speed * delta
	if not is_on_floor() :
		velocity.y += GRAVITY * delta
	move_and_slide()
	pass
