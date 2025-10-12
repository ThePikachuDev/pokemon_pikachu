extends CharacterBody2D
#
## Constants for movement
const SPEED: float = 200.0 # Set a consistent horizontal speed for rolling
const GRAVITY: float = 980.0
const ROTATION_RATE: float = 5.0 # Visual rotation speed (adjust to look right)

## Velocity is managed by the CharacterBody2D, but we'll use it to apply forces
var current_velocity: Vector2 = Vector2.ZERO
var direction: float = -1.0 # -1.0 for left movement

#@onready var game_manager = %GameManager
@onready var sprite_node: Sprite2D = $Sprite2D # **Change this to the actual name of your ball's visual component (e.g., Sprite2D, MeshInstance2D)**

func _ready() -> void:
	# 1. Add to group for the destroyer to check
	add_to_group("electrode")
	# 2. Initialize starting velocity
	current_velocity = velocity

## Use _physics_process for physics-related movement and gravity
func _physics_process(delta: float) -> void:
	#
	## --- 1. Apply Gravity (Falling) ---
	## Gravity is applied in every frame when the body is not on the floor.
	if not is_on_floor():
		current_velocity.y += GRAVITY * delta
	else:
		## If on the ground, reset vertical speed to 0 to prevent bouncing/jittering
		current_velocity.y = 0
#
	## --- 2. Apply Rolling Movement (Left) ---
	## Set the horizontal velocity directly for consistent speed.
	current_velocity.x = direction * SPEED
	
	if sprite_node != null:
		sprite_node.rotation_degrees += ROTATION_RATE * direction * delta * SPEED / 10.0
#
	velocity = current_velocity
	move_and_slide()


func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print(GameManager.active_checkpoint.position)
		body.position = GameManager.active_checkpoint.position
		#GameManager.take_damage()
