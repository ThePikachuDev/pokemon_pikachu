extends CharacterBody2D


@onready var game_manager = %GameManager

const GRAVITY = 980.0
const WALK_SPEED = 200.0
const JUMP_VELOCITY = -300.0
const acceleration = 0.1

@export var dash_speed = 500.0
@export var dash_max_distance = 300.0
@export var dash_curve : Curve 
@export var dash_cooldown = 1.0 

var is_dashing: bool = false
var dash_start_postion = 0 
var dash_direction = 0
var dash_timer = 0

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

var heart_list : Array[TextureRect]
var current_health = 3
const MAX_HEALTH = 3

#var can_dash: bool = true

# ----------------- Node References -----------------
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_audio: AudioStreamPlayer2D = $jump_audio
@onready var dash_audio: AudioStreamPlayer2D = $DashAudio
@onready var footstep_audio: AudioStreamPlayer2D = $footstep_audio


@export var dialogue_resource = "res://dialogue/StarterHelper.dialogue"
@export var dialogue_start: String = "start"

var jumps_left: int 


func _ready():
	game_manager.load_hearts()
	jumps_left = 2 if game_manager.can_double_jump else 1
	pass

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		jumps_left = 2 if game_manager.can_double_jump else 1
	
	handle_input()
	
	if Input.is_action_just_pressed("dialogue"):
		game_manager.play_dialogue(dialogue_resource,dialogue_start)
		pass
	
	var direction = Input.get_axis("left", "right")
	
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
	else:
		if direction:
			velocity.x = direction * WALK_SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		
	
		# Dash
	if Input.is_action_just_pressed("dash") and direction and not is_dashing and dash_timer <= 0:
		is_dashing = true
		dash_start_postion = position.x
		dash_direction = direction
		dash_timer = dash_cooldown
		start_dash()
	
	#perform dash
	if is_dashing:
		var current_distance = abs(position.x - dash_start_postion)
		$particles/dash_particles.emitting = true
		if current_distance >= dash_max_distance or is_on_wall():
			is_dashing = false
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			velocity.y = 0
	
	# reduce dash timer 
	if dash_timer > 0:
		dash_timer -= delta
	
	
	# Update sprite direction and animation, including footstep audio logic
	update_animation_and_direction()
	
	
	move_and_slide()

# ----------------- Input Handling -----------------
func handle_input():
	# Jump
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1
		footstep_audio.stop()
		jump_audio.play()

func apply_knockback(direction: Vector2, force: float , knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration
	pass


func start_dash():
	dash_audio.play()

# ----------------- Timer Callbacks -----------------
#func _on_dash_duration_timer_timeout():
	#is_dashing = false
#
#func _on_dash_cooldown_timer_timeout():
	#can_dash = true

# ----------------- Animation and Direction -----------------
func update_animation_and_direction():
	if is_dashing:
		animated_sprite.play("dash")
	elif not is_on_floor():
		animated_sprite.play("jump" if velocity.y < 0 else "fall")
	elif velocity.x != 0:
		animated_sprite.play("run")
		# Play footstep audio only if it's not already playing to avoid overlapping sounds
		if not footstep_audio.playing:
			footstep_audio.play()
	else:
		animated_sprite.play("idle")
		# Stop footstep audio when the player is idle
		if footstep_audio.playing:
			footstep_audio.stop()
		
	# Flip sprite based on movement direction
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true

# ----------------- Audio Callbacks -----------------
func _on_footstep_audio_finished():
	# When the current footstep sound finishes, check if the character is still moving.
	# If so, play the sound again to create a loop.
	if is_on_floor() and velocity.x != 0:
		footstep_audio.play()


func _on_kill_zone_below_world_body_entered(body: Node2D) -> void:
	await game_manager.take_damage()
	position = Vector2(0,0)
	pass # Replace with function body.
