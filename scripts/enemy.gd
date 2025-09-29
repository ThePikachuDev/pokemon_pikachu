extends Node2D

# Get nodes using @onready for proper initialization
@onready var ray_cast_left: RayCast2D = $RayCast2D
@onready var ray_cast_right: RayCast2D = $RayCast2D2
@onready var leaves: Sprite2D = $Leaves
@onready var timer: Timer = $Leaves/Timer
@onready var animated_enemy_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var head: Area2D = $head
@onready var game_manager = %GameManager

# Set a constant for the movement speed for better organization.
const LEAVES_SPEED = 200.0 # Adjust this value to change how fast the leaves move.
const ATTACK_COOLDOWN = 1.0 # The time in seconds between each leaf throw.

# A variable to track the current direction of movement.
var current_direction: int = 1
# A boolean to prevent multiple leaf spawns at once.
var is_throwing: bool = false
# The time since the last attack.
var time_since_last_attack: float = 0.0

# This function is called once when the node is ready.
func _ready() -> void:
	add_to_group("enemy")
	# Make sure the leaves are invisible initially.
	leaves.visible = false
	# Connect the timer's timeout signal.
	timer.timeout.connect(_on_timer_timeout)
	
# This function is called every frame and is used for game logic.
func _process(delta: float) -> void:
	# Cast rays to check for collisions only if not currently throwing leaves.
	time_since_last_attack += delta

	if not is_throwing and time_since_last_attack >= ATTACK_COOLDOWN:
		if ray_cast_left.is_colliding():
			current_direction = -1
			throw_leaves(current_direction)
			time_since_last_attack = 0.0
		elif ray_cast_right.is_colliding():
			current_direction = 1
			throw_leaves(current_direction)
			time_since_last_attack = 0.0

	# Move the leaves while they are visible.
	if leaves.visible:
		leaves.position.x += LEAVES_SPEED * current_direction * delta
		# Flip the leaves sprite based on the direction.
		leaves.flip_h = current_direction == -1

# This function initiates the leaf-throwing action.
func throw_leaves(_dir: int) -> void:
	is_throwing = true
	leaves.position = animated_enemy_sprite.position
	leaves.visible = true
	timer.start()

# This function is called when the leaves timer runs out.
func _on_timer_timeout() -> void:
	is_throwing = false
	leaves.visible = false
	# Reset the leaves position.
	leaves.position = animated_enemy_sprite.position

# This function handles the player colliding with the leaves.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var knockback_direction = (body.global_position - global_position).normalized()
		# This assumes the Player has an 'apply_knockback' function.
		body.apply_knockback(knockback_direction, 300.0, 0.12)
		game_manager.take_damage()

		# Hide the leaves immediately on collision to prevent continuous damage.
		leaves.visible = false
		is_throwing = false
		leaves.position = animated_enemy_sprite.position
		timer.stop()
		
# This function handles the player colliding with the enemy's head.
func _on_head_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		self.queue_free()
