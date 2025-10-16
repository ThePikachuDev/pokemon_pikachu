extends CharacterBody2D

const SPEED: float = 200.0 
const GRAVITY: float = 980.0
const ROTATION_RATE: float = 5.0 

var current_velocity: Vector2 = Vector2.ZERO
var direction: float = -1.0 

@onready var sprite_node: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("electrode")
	current_velocity = velocity

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		current_velocity.y += GRAVITY * delta
	else:
		current_velocity.y = 0
	current_velocity.x = direction * SPEED
	
	if sprite_node != null:
		sprite_node.rotation_degrees += ROTATION_RATE * direction * delta * SPEED / 10.0
	
	velocity = current_velocity
	move_and_slide()


func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print(GameManager.active_checkpoint.position)
		body.position = GameManager.active_checkpoint.position
