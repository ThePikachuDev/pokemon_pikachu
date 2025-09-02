# This script is a self-contained CharacterBody2D controller with enhanced dashing.
# You can copy and paste this code directly onto a CharacterBody2D node in Godot.

extends CharacterBody2D

# ----------------- Physics Constants -----------------
const GRAVITY = 980.0
const WALK_SPEED = 200.0
const JUMP_VELOCITY = -300.0

const DASH_IMPULSE_SPEED = 800.0
const DASH_DURATION = 0.15
const DASH_COOLDOWN = 0.5
const AIR_DASH_VERTICAL_IMPULSE = -50.0

# ----------------- State Variables -----------------
var is_dashing: bool = false
var can_dash: bool = true
var jumps_left: int = 2

# ----------------- Node References -----------------
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_cooldown_timer: Timer = $DashEffectTimer
@onready var jump_audio: AudioStreamPlayer2D = $jump_audio
@onready var dash_audio: AudioStreamPlayer2D = $DashAudio

# ----------------- Main Functions -----------------
func _ready():
	# Timers are created dynamically if they don't exist, for "out of the box" functionality.
	# We'll just create them on the fly to avoid relying on the scene tree.
	if not has_node("DashDurationTimer"):
		dash_duration_timer = Timer.new()
		add_child(dash_duration_timer)
	dash_duration_timer.wait_time = DASH_DURATION
	dash_duration_timer.one_shot = true
	dash_duration_timer.timeout.connect(_on_dash_duration_timer_timeout)

	if not has_node("DashCooldownTimer"):
		dash_cooldown_timer = Timer.new()
		add_child(dash_cooldown_timer)
	dash_cooldown_timer.wait_time = DASH_COOLDOWN
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timer_timeout)

func _physics_process(delta: float) -> void:
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		# Reset jump and dash on the floor
		jumps_left = 2
		can_dash = true

	# Handle input for jumping and dashing
	handle_input()
	
	# Apply dash physics or normal movement
	if is_dashing:
		# Keep horizontal velocity constant during the dash
		velocity.y = 0 
	else:
		# Horizontal movement
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * WALK_SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
			
	# Update sprite direction and animation
	update_animation_and_direction()
	
	move_and_slide()

# ----------------- Input Handling -----------------
func handle_input():
	# Jump
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1
		# Uncomment this line if you have a JumpAudio node
		# jump_audio.play()

	# Dash
	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()

func start_dash():
	is_dashing = true
	can_dash = false
	
	var dash_direction = Input.get_axis("left", "right")
	if dash_direction == 0:
		dash_direction = 1 if not animated_sprite.flip_h else -1
	
	# Set a powerful, instantaneous horizontal velocity
	velocity.x = dash_direction * DASH_IMPULSE_SPEED
	
	# Add a slight vertical boost for a dynamic air dash feel
	if not is_on_floor():
		velocity.y = AIR_DASH_VERTICAL_IMPULSE

	dash_duration_timer.start()
	dash_cooldown_timer.start()

	# Uncomment this line if you have a DashAudio node
	# dash_audio.play()

# ----------------- Timer Callbacks -----------------
func _on_dash_duration_timer_timeout():
	is_dashing = false

func _on_dash_cooldown_timer_timeout():
	can_dash = true

# ----------------- Animation and Direction -----------------
func update_animation_and_direction():
	if is_dashing:
		animated_sprite.play("dash")
	elif not is_on_floor():
		animated_sprite.play("jump" if velocity.y < 0 else "fall")
	elif velocity.x != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
		
	# Flip sprite based on movement direction
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true
