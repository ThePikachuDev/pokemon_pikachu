# Make sure your node structure looks like this:
# └─ Node2D (This script is attached here)
#    ├─ AnimatedSprite2D (animated_enemy_sprite)
#    ├─ RayCast2D (ray_cast_left)
#    ├─ RayCast2D2 (ray_cast_right)
#    ├─ Area2D
#    │  └─ CollisionShape2D
#    ├─ Sprite2D (leaves)
#    │  └─ Timer
#    └─ ... other nodes

extends Node2D

# Get nodes using @onready for proper initialization
@onready var ray_cast_left: RayCast2D = $RayCast2D
@onready var ray_cast_right: RayCast2D = $RayCast2D2
@onready var leaves: Sprite2D = $Leaves
@onready var timer: Timer = $Leaves/Timer
@onready var animated_enemy_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var leaves_collision_shape: CollisionShape2D = $Leaves/Area2D/CollisionShape2D
@onready var head: Area2D = $head

# Set a constant for the movement speed for better organization.
const SPEED = 100.0  # Adjust this value to change how fast the leaves move.

# A variable to track the current direction of movement.
var current_direction: int = 1

# A boolean to prevent multiple leaf spawns at once.
var is_throwing: bool = false

# This function is called once when the node is ready.
func _ready() -> void:
	# Connect the timer's timeout signal to the _on_timer_timeout function
	#if timer:
		#timer.timeout.connect(_on_timer_timeout)
	pass

# This function is called every frame and is used for game logic.
func _process(delta: float) -> void:
	# Cast rays to check for collisions only if not currently throwing leaves.
	if not is_throwing:
		if ray_cast_left.is_colliding():
			current_direction = -1
			throw_leaves(current_direction)
		elif ray_cast_right.is_colliding():
			current_direction = 1
			throw_leaves(current_direction)

	# Move the leaves while they are visible.
	if leaves.visible:
		leaves.position.x += SPEED * current_direction * delta

# This function initiates the leaf-throwing action.
func throw_leaves(dir: int) -> void:
	is_throwing = true
	leaves.position = animated_enemy_sprite.position
	leaves.visible = true
	timer.start()

# This function is called when the leaves timer runs out.
func _on_timer_timeout() -> void:
	is_throwing = false
	leaves.visible = false
	# Reset the leaves position to the enemy sprite's position.
	leaves.position = animated_enemy_sprite.position

# This function handles the player colliding with the enemy.
func _on_area_2d_body_entered(body: Node2D) -> void:
	# Check if the body is a player or another specific node.
	if body.name == "Player": 
		get_tree().reload_current_scene()


func _on_head_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print('you died ?')
		self.queue_free()
