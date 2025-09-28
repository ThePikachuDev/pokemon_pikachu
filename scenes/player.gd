extends CharacterBody2D


@onready var game_manager = %GameManager
@onready var hurt_animation: AnimationPlayer = $HurtAnimation

const GRAVITY = 980.0
const WALK_SPEED = 200.0
const JUMP_VELOCITY = -300.0
const acceleration = 0.1

@export var dash_speed = 400.0
@export var dash_max_distance = 150.0
@export var dash_curve : Curve 
@export var dash_cooldown = 1.0 

var is_dashing: bool = false
var dash_start_postion = 0 
var dash_direction = 0
var dash_timer = 0

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

var can_coyote_jump: bool = false

var heart_list : Array[TextureRect]
var current_health = 3
const MAX_HEALTH = 3

#var can_dash: bool = true

var enemies_in_thunderbolt_area: Array = []

# ----------------- Node References -----------------
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_audio: AudioStreamPlayer2D = $jump_audio
@onready var dash_audio: AudioStreamPlayer2D = $DashAudio
@onready var footstep_audio: AudioStreamPlayer2D = $footstep_audio
@onready var jump_height_timer: Timer = $JumpHeightTimer
@onready var coyote_timer: Timer = $CoyoteTimer


@export var dialogue_resource = "res://dialogue/StarterHelper.dialogue"
@export var dialogue_start: String = "start"

var jumps_left: int 


func _ready():
	add_to_group("player")
	
	if GameManager.checkpoint_position != Vector2(-999,-999):
		global_position = GameManager.checkpoint_position
	
	game_manager.load_hearts()
	jumps_left = 2 if game_manager.can_double_jump else 1
	pass

func _physics_process(delta: float) -> void:
#	&& (can_coyote_jump == false)
	if not is_on_floor() :
		velocity.y += GRAVITY * delta
	#else:
		#jumps_left = 2 if game_manager.can_double_jump else 1
	
	if Input.is_action_just_pressed("jump"):
		jump_height_timer.start()
		if is_on_floor() || can_coyote_jump:
			velocity.y = JUMP_VELOCITY
			if can_coyote_jump:
				can_coyote_jump = false 
	
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
	
	if dash_timer > 0:
		dash_timer -= delta
	
	
	# Update sprite direction and animation, including footstep audio logic
	update_animation_and_direction()
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	# Coyote Timer !
	if was_on_floor && !is_on_floor() && velocity.y >= 0:
		can_coyote_jump = true
		coyote_timer.start()

func _on_coyote_timer_timeout() -> void:
	can_coyote_jump = false


func _process(delta: float) -> void:
	if game_manager.can_thunderbolt:
		if Input.is_action_just_pressed("thunderBolt"):
			for enemy in enemies_in_thunderbolt_area:
				var thunder_animation = enemy.get_node("ThunderAnimation")
				print("enemy detected " , enemy.position)
				thunder_animation.visible = true
				thunder_animation.play("default")
				
				var timer = get_tree().create_timer(1.0)
				await timer.timeout
				if enemy:
					enemy.queue_free()
			game_manager.bolts -= 5
			game_manager.update_bolt_label()


func apply_knockback(direction: Vector2, force: float , knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration
	pass


func start_dash():
	dash_audio.play()


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




func _on_jump_height_timer_timeout() -> void:
	if !Input.is_action_pressed("jump"):
		if velocity.y < -20:
			velocity.y = -20
		

# ----------------- Audio Callbacks -----------------
func _on_footstep_audio_finished():
	# When the current footstep sound finishes, check if the character is still moving.
	# If so, play the sound again to create a loop.
	if is_on_floor() and velocity.x != 0:
		footstep_audio.play()

 
func _on_kill_zone_below_world_body_entered(body: Node2D) -> void:
	await game_manager.take_damage()
	position = GameManager.active_checkpoint.global_position


func _on_thunder_bolt_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		enemies_in_thunderbolt_area.append(body)
		#if Input.is_action_pressed("thunderBolt"):
			#print("fun ran")
			#var thunder_animation = body.get_node("ThunderAnimation")
			#print("enemy detected " , body.position)
			#thunder_animation.visible = true
			#thunder_animation.play("default")
			#var timer = get_tree().create_timer(1)
			#await timer.timeout
			#body.queue_free()
			


func _on_thunder_bolt_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		enemies_in_thunderbolt_area.erase(body)
