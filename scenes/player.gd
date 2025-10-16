extends CharacterBody2D


@onready var game_manager = %GameManager
@onready var hurt_animation: AnimationPlayer = $HurtAnimation

const GRAVITY = 980.0
@onready var WALK_SPEED = game_manager.player_speed
@onready var JUMP_VELOCITY = game_manager.player_jump_speed
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


var enemies_in_thunderbolt_area: Array = []


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_audio: AudioStreamPlayer2D = $jump_audio
@onready var dash_audio: AudioStreamPlayer2D = $DashAudio
@onready var footstep_audio: AudioStreamPlayer2D = $footstep_audio
@onready var jump_height_timer: Timer = $JumpHeightTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_particles: CPUParticles2D = $particles/JumpParticles
@onready var walk_particles: CPUParticles2D = $particles/WalkParticles
@onready var dash_particles: CPUParticles2D = $particles/dash_particles
@onready var thunder_bolt_audio: AudioStreamPlayer2D = $ThunderBoltAudio

@onready var attack_parent: Node2D = $Attack
@onready var attack_sprite: Sprite2D = $Attack/Sprite2D
@onready var attack_area_2d: Area2D = $Attack/Sprite2D/AttackArea2D


@onready var pikachu_idle_voice_timer: Timer = $PikachuIdleVoiceTimer
@onready var pikachu_idle_voice: AudioStreamPlayer2D = $PikachuIdleVoice

var look_dir: Vector2 = Vector2.RIGHT

var TotalAttackDuration: float = 0.26
var attack_duratoin_timer: float = 0.0
var attack_distance: float = 6.0

var is_tower_in_area: bool = false
var tower_node
var tower_activated: bool = false

@export var dialogue_resource = "res://dialogue/StarterHelper.dialogue"
@export var dialogue_start: String = "start"

var jumps_left: int 

var rng = RandomNumberGenerator.new()

func _ready():
	add_to_group("player")
	attack_sprite.modulate.a = 0.0
	attack_area_2d.get_node("CollisionShape2D").disabled = true
	
	if GameManager.checkpoint_position != Vector2(-999,-999):
		global_position = GameManager.checkpoint_position
	
	game_manager.load_hearts()
	jumps_left = 2 if game_manager.can_double_jump else 1
	pass
	pikachu_idle_voice_timer.wait_time = rng.randf_range(8.0, 30.0)
	pikachu_idle_voice_timer.start()

func _physics_process(delta: float) -> void:
	WALK_SPEED = game_manager.player_speed
	JUMP_VELOCITY = game_manager.player_jump_speed
	
	if not is_on_floor() :
		velocity.y += GRAVITY * delta
	
	if Input.is_action_just_pressed("jump"):
		jump_height_timer.start()
		if is_on_floor() || can_coyote_jump:
			jump_particles.emitting = true
			velocity.y = JUMP_VELOCITY
			if can_coyote_jump:
				can_coyote_jump = false 
	#
	#if Input.is_action_just_pressed("dialogue"):
		#pass
	
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
	
	if velocity.x:
		walk_particles.emitting = true
	else:
		walk_particles.emitting = false
	
	if Input.is_action_just_pressed("dash") and direction and not is_dashing and dash_timer <= 0:
		is_dashing = true
		dash_start_postion = position.x
		dash_direction = direction
		dash_timer = dash_cooldown
		start_dash()
	
	if is_dashing:
		var current_distance = abs(position.x - dash_start_postion)
		dash_particles.emitting = true
		if current_distance >= dash_max_distance or is_on_wall():
			is_dashing = false
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			velocity.y = 0
	
	if dash_timer > 0:
		dash_timer -= delta
	
	
	update_animation_and_direction()
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	if was_on_floor && !is_on_floor() && velocity.y >= 0:
		can_coyote_jump = true
		coyote_timer.start()

func _on_coyote_timer_timeout() -> void:
	can_coyote_jump = false


func _process(_delta: float) -> void:
	

	
	if game_manager.can_thunderbolt:
		if Input.is_action_just_pressed("thunderBolt"):
		
			if tower_node:
				print("attacking tower node")
				var thunder_animation = tower_node.get_node("ThunderAnimation")
				thunder_animation.visible = true
				thunder_animation.play("default")
				thunder_bolt_audio.play()
				var timer = get_tree().create_timer(1.0)
				await timer.timeout
				thunder_animation.stop()
				thunder_animation.visible = false
				game_manager.bolts -= 5
				game_manager.update_bolt_label()
			
			
			for enemy in enemies_in_thunderbolt_area:
				var thunder_animation = enemy.get_node("ThunderAnimation")
				print("enemy detected " , enemy.position)
				thunder_animation.visible = true
				thunder_animation.play("default")
				thunder_bolt_audio.play()
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

func update_animation_and_direction():
	if is_dashing:
		animated_sprite.play("dash")
	elif not is_on_floor():
		animated_sprite.play("jump" if velocity.y < 0 else "fall")
	elif velocity.x != 0:
		animated_sprite.play("run")
		if not footstep_audio.playing:
			footstep_audio.play()
	else:
		animated_sprite.play("idle")
		if footstep_audio.playing:
			footstep_audio.stop()
	
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true

func _on_jump_height_timer_timeout() -> void:
	if !Input.is_action_pressed("jump"):
		if velocity.y < -20:
			velocity.y = -20

func _on_footstep_audio_finished():
	if is_on_floor() and velocity.x != 0:
		footstep_audio.play()

 
func _on_kill_zone_below_world_body_entered(_body: Node2D) -> void:
	await game_manager.take_damage()
	position = GameManager.active_checkpoint.global_position


func _on_thunder_bolt_area_body_entered(body: Node2D) -> void:
	
	print(body)
	
	if body.is_in_group("interactable_tower"):
		print("tower exited")
		is_tower_in_area = true
		tower_node = body
	
	if body.is_in_group("enemy"):
		enemies_in_thunderbolt_area.append(body)

func _on_thunder_bolt_area_body_exited(body: Node2D) -> void:
	print(body)
	
	if body.is_in_group("interactable_tower"):
		print("tower exited")
		is_tower_in_area = false
		tower_node = null
	
	if body.is_in_group("enemy"):
		enemies_in_thunderbolt_area.erase(body)


func _on_pikachu_idle_voice_timer_timeout() -> void:
	pikachu_idle_voice.play()
	await pikachu_idle_voice.finished
	var random_gastly_voice_number = rng.randi_range(3,8)
	pikachu_idle_voice_timer.wait_time = random_gastly_voice_number
	pikachu_idle_voice_timer.start()
	#
#extends CharacterBody2D
#
#
#@onready var game_manager = %GameManager
#@onready var hurt_animation: AnimationPlayer = $HurtAnimation
#
#const GRAVITY = 980.0
#@onready var WALK_SPEED = game_manager.player_speed
#@onready var JUMP_VELOCITY = game_manager.player_jump_speed
#const acceleration = 0.1
#
#@export var dash_speed = 400.0
#@export var dash_max_distance = 150.0
#@export var dash_curve : Curve 
#@export var dash_cooldown = 1.0 
#
#var is_dashing: bool = false
#var dash_start_postion = 0 
#var dash_direction = 0
#var dash_timer = 0
#
#var knockback: Vector2 = Vector2.ZERO
#var knockback_timer: float = 0.0
#
#var can_coyote_jump: bool = false
#
#var heart_list : Array[TextureRect]
#var current_health = 3
#const MAX_HEALTH = 3
#
#
#var enemies_in_thunderbolt_area: Array = []
#
#
#@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
#@onready var jump_audio: AudioStreamPlayer2D = $jump_audio
#@onready var dash_audio: AudioStreamPlayer2D = $DashAudio
#@onready var footstep_audio: AudioStreamPlayer2D = $footstep_audio
#@onready var jump_height_timer: Timer = $JumpHeightTimer
#@onready var coyote_timer: Timer = $CoyoteTimer
#@onready var jump_particles: CPUParticles2D = $particles/JumpParticles
#@onready var walk_particles: CPUParticles2D = $particles/WalkParticles
#@onready var dash_particles: CPUParticles2D = $particles/dash_particles
#@onready var thunder_bolt_audio: AudioStreamPlayer2D = $ThunderBoltAudio
#
#@onready var attack_parent: Node2D = $Attack
#@onready var attack_sprite: Sprite2D = $Attack/Sprite2D
#@onready var attack_area_2d: Area2D = $Attack/Sprite2D/AttackArea2D
#
#
#@onready var pikachu_idle_voice_timer: Timer = $PikachuIdleVoiceTimer
#@onready var pikachu_idle_voice: AudioStreamPlayer2D = $PikachuIdleVoice
#
#var look_dir: Vector2 = Vector2.RIGHT
#
#var TotalAttackDuration: float = 0.26
#var attack_duratoin_timer: float = 0.0
#var attack_distance: float = 6.0
#
#var is_tower_in_area: bool = false
#var tower_node
#var tower_activated: bool = false
#
#@export var dialogue_resource = "res://dialogue/StarterHelper.dialogue"
#@export var dialogue_start: String = "start"
#
#var jumps_left: int 
#
#var rng = RandomNumberGenerator.new()
#
#func _ready():
	#add_to_group("player")
	#attack_sprite.modulate.a = 0.0
	#attack_area_2d.get_node("CollisionShape2D").disabled = true
	#
	#if GameManager.checkpoint_position != Vector2(-999,-999):
		#global_position = GameManager.checkpoint_position
	#
	#game_manager.load_hearts()
	#jumps_left = 2 if game_manager.can_double_jump else 1
	#pass
	#pikachu_idle_voice_timer.wait_time = rng.randf_range(8.0, 30.0)
	#pikachu_idle_voice_timer.start()
#
#func _physics_process(delta: float) -> void:
	#WALK_SPEED = game_manager.player_speed
	#JUMP_VELOCITY = game_manager.player_jump_speed
	#
	#if not is_on_floor() :
		#velocity.y += GRAVITY * delta
	#
	#if Input.is_action_just_pressed("jump"):
		#jump_height_timer.start()
		#if is_on_floor() || can_coyote_jump:
			#jump_particles.emitting = true
			#velocity.y = JUMP_VELOCITY
			#if can_coyote_jump:
				#can_coyote_jump = false 
	##
	##if Input.is_action_just_pressed("dialogue"):
		##pass
	#
	#var direction = Input.get_axis("left", "right")
	#
	#if knockback_timer > 0.0:
		#velocity = knockback
		#knockback_timer -= delta
		#if knockback_timer <= 0.0:
			#knockback = Vector2.ZERO
	#else:
		#if direction:
			#velocity.x = direction * WALK_SPEED
		#else:
			#velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
	#
	#if velocity.x:
		#walk_particles.emitting = true
	#else:
		#walk_particles.emitting = false
	#
	#if Input.is_action_just_pressed("dash") and direction and not is_dashing and dash_timer <= 0:
		#is_dashing = true
		#dash_start_postion = position.x
		#dash_direction = direction
		#dash_timer = dash_cooldown
		#start_dash()
	#
	#if is_dashing:
		#var current_distance = abs(position.x - dash_start_postion)
		#dash_particles.emitting = true
		#if current_distance >= dash_max_distance or is_on_wall():
			#is_dashing = false
		#else:
			#velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			#velocity.y = 0
	#
	#if dash_timer > 0:
		#dash_timer -= delta
	#
	#
	#update_animation_and_direction()
	#
	#var was_on_floor = is_on_floor()
	#move_and_slide()
	#
	#if was_on_floor && !is_on_floor() && velocity.y >= 0:
		#can_coyote_jump = true
		#coyote_timer.start()
#
#func _on_coyote_timer_timeout() -> void:
	#can_coyote_jump = false
#
#
#func _process(_delta: float) -> void:
	#
#
	#
	#if game_manager.can_thunderbolt:
		#if Input.is_action_just_pressed("thunderBolt"):
		#
			#if tower_node:
				#print("attacking tower node")
				#var thunder_animation = tower_node.get_node("ThunderAnimation")
				#thunder_animation.visible = true
				#thunder_animation.play("default")
				#thunder_bolt_audio.play()
				#var timer = get_tree().create_timer(1.0)
				#await timer.timeout
				#thunder_animation.stop()
				#thunder_animation.visible = false
				#game_manager.bolts -= 5
				#game_manager.update_bolt_label()
			#
			#
			#for enemy in enemies_in_thunderbolt_area:
				#var thunder_animation = enemy.get_node("ThunderAnimation")
				#print("enemy detected " , enemy.position)
				#thunder_animation.visible = true
				#thunder_animation.play("default")
				#thunder_bolt_audio.play()
				#var timer = get_tree().create_timer(1.0)
				#await timer.timeout
				#if enemy:
					#enemy.queue_free()
					#game_manager.bolts -= 5
					#game_manager.update_bolt_label()
#
#
#func apply_knockback(direction: Vector2, force: float , knockback_duration: float) -> void:
	#knockback = direction * force
	#knockback_timer = knockback_duration
	#pass
#
#
#func start_dash():
	#dash_audio.play()
#
#func update_animation_and_direction():
	#if is_dashing:
		#animated_sprite.play("dash")
	#elif not is_on_floor():
		#animated_sprite.play("jump" if velocity.y < 0 else "fall")
	#elif velocity.x != 0:
		#animated_sprite.play("run")
		#if not footstep_audio.playing:
			#footstep_audio.play()
	#else:
		#animated_sprite.play("idle")
		#if footstep_audio.playing:
			#footstep_audio.stop()
	#
	#if velocity.x > 0:
		#animated_sprite.flip_h = false
	#elif velocity.x < 0:
		#animated_sprite.flip_h = true
#
#func _on_jump_height_timer_timeout() -> void:
	#if !Input.is_action_pressed("jump"):
		#if velocity.y < -20:
			#velocity.y = -20
#
#func _on_footstep_audio_finished():
	#if is_on_floor() and velocity.x != 0:
		#footstep_audio.play()
#
 #
#func _on_kill_zone_below_world_body_entered(_body: Node2D) -> void:
	#await game_manager.take_damage()
	#position = GameManager.active_checkpoint.global_position
#
#
#func _on_thunder_bolt_area_body_entered(body: Node2D) -> void:
	#
	#print(body)
	#
	#if body.is_in_group("interactable_tower"):
		#print("tower exited")
		#is_tower_in_area = true
		#tower_node = body
	#
	#if body.is_in_group("enemy"):
		#enemies_in_thunderbolt_area.append(body)
#
#func _on_thunder_bolt_area_body_exited(body: Node2D) -> void:
	#print(body)
	#
	#if body.is_in_group("interactable_tower"):
		#print("tower exited")
		#is_tower_in_area = false
		#tower_node = null
	#
	#if body.is_in_group("enemy"):
		#enemies_in_thunderbolt_area.erase(body)
#
#
#func _on_pikachu_idle_voice_timer_timeout() -> void:
	#pikachu_idle_voice.play()
	#await pikachu_idle_voice.finished
	#var random_gastly_voice_number = rng.randi_range(3,8)
	#pikachu_idle_voice_timer.wait_time = random_gastly_voice_number
	#pikachu_idle_voice_timer.start()
	#
#
#extends CharacterBody2D
#
#
#@onready var game_manager = %GameManager
#@onready var hurt_animation: AnimationPlayer = $HurtAnimation
#
#const GRAVITY = 980.0
#@onready var WALK_SPEED = game_manager.player_speed
#@onready var JUMP_VELOCITY = game_manager.player_jump_speed
#const acceleration = 0.1
#
#@export var dash_speed = 400.0
#@export var dash_max_distance = 150.0
#@export var dash_curve : Curve 
#@export var dash_cooldown = 1.0 
#
#var is_dashing: bool = false
#var dash_start_postion = 0 
#var dash_direction = 0
#var dash_timer = 0
#
#var knockback: Vector2 = Vector2.ZERO
#var knockback_timer: float = 0.0
#
#var can_coyote_jump: bool = false
#
#var heart_list : Array[TextureRect]
#var current_health = 3
#const MAX_HEALTH = 3
#
#
#var enemies_in_thunderbolt_area: Array = []
#
#
#@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
#@onready var jump_audio: AudioStreamPlayer2D = $jump_audio
#@onready var dash_audio: AudioStreamPlayer2D = $DashAudio
#@onready var footstep_audio: AudioStreamPlayer2D = $footstep_audio
#@onready var jump_height_timer: Timer = $JumpHeightTimer
#@onready var coyote_timer: Timer = $CoyoteTimer
#@onready var jump_particles: CPUParticles2D = $particles/JumpParticles
#@onready var walk_particles: CPUParticles2D = $particles/WalkParticles
#@onready var dash_particles: CPUParticles2D = $particles/dash_particles
#@onready var thunder_bolt_audio: AudioStreamPlayer2D = $ThunderBoltAudio
#
#@onready var attack_parent: Node2D = $Attack
#@onready var attack_sprite: Sprite2D = $Attack/Sprite2D
#@onready var attack_area_2d: Area2D = $Attack/Sprite2D/AttackArea2D
#
#
#@onready var pikachu_idle_voice_timer: Timer = $PikachuIdleVoiceTimer
#@onready var pikachu_idle_voice: AudioStreamPlayer2D = $PikachuIdleVoice
#
#var look_dir: Vector2 = Vector2.RIGHT
#
#var TotalAttackDuration: float = 0.26
#var attack_duratoin_timer: float = 0.0
#var attack_distance: float = 6.0
#
#var is_tower_in_area: bool = false
#var tower_node
#var tower_activated: bool = false
#
#@export var dialogue_resource = "res://dialogue/StarterHelper.dialogue"
#@export var dialogue_start: String = "start"
#
#var jumps_left: int 
#
#var rng = RandomNumberGenerator.new()
#
#func _ready():
	#add_to_group("player")
	#attack_sprite.modulate.a = 0.0
	#attack_area_2d.get_node("CollisionShape2D").disabled = true
	#
	#if GameManager.checkpoint_position != Vector2(-999,-999):
		#global_position = GameManager.checkpoint_position
	#
	#game_manager.load_hearts()
	#jumps_left = 2 if game_manager.can_double_jump else 1
	#pass
	#pikachu_idle_voice_timer.wait_time = rng.randf_range(8.0, 30.0)
	#pikachu_idle_voice_timer.start()
#
#func _physics_process(delta: float) -> void:
	#WALK_SPEED = game_manager.player_speed
	#JUMP_VELOCITY = game_manager.player_jump_speed
	#
	#if not is_on_floor() :
		#velocity.y += GRAVITY * delta
	#
	#if Input.is_action_just_pressed("jump"):
		#jump_height_timer.start()
		#if is_on_floor() || can_coyote_jump:
			#jump_particles.emitting = true
			#velocity.y = JUMP_VELOCITY
			#if can_coyote_jump:
				#can_coyote_jump = false 
	##
	##if Input.is_action_just_pressed("dialogue"):
		##pass
	#
	#var direction = Input.get_axis("left", "right")
	#
	#if knockback_timer > 0.0:
		#velocity = knockback
		#knockback_timer -= delta
		#if knockback_timer <= 0.0:
			#knockback = Vector2.ZERO
	#else:
		#if direction:
			#velocity.x = direction * WALK_SPEED
		#else:
			#velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
	#
	#if velocity.x:
		#walk_particles.emitting = true
	#else:
		#walk_particles.emitting = false
	#
	#if Input.is_action_just_pressed("dash") and direction and not is_dashing and dash_timer <= 0:
		#is_dashing = true
		#dash_start_postion = position.x
		#dash_direction = direction
		#dash_timer = dash_cooldown
		#start_dash()
	#
	#if is_dashing:
		#var current_distance = abs(position.x - dash_start_postion)
		#dash_particles.emitting = true
		#if current_distance >= dash_max_distance or is_on_wall():
			#is_dashing = false
		#else:
			#velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			#velocity.y = 0
	#
	#if dash_timer > 0:
		#dash_timer -= delta
	#
	#
	#update_animation_and_direction()
	#
	#var was_on_floor = is_on_floor()
	#move_and_slide()
	#
	#if was_on_floor && !is_on_floor() && velocity.y >= 0:
		#can_coyote_jump = true
		#coyote_timer.start()
#
#func _on_coyote_timer_timeout() -> void:
	#can_coyote_jump = false
#
#
#func _process(_delta: float) -> void:
	#
#
	#
	#if game_manager.can_thunderbolt:
		#if Input.is_action_just_pressed("thunderBolt"):
		#
			#if tower_node:
				#print("attacking tower node")
				#var thunder_animation = tower_node.get_node("ThunderAnimation")
				#thunder_animation.visible = true
				#thunder_animation.play("default")
				#thunder_bolt_audio.play()
				#var timer = get_tree().create_timer(1.0)
				#await timer.timeout
				#thunder_animation.stop()
				#thunder_animation.visible = false
				#game_manager.bolts -= 5
				#game_manager.update_bolt_label()
			#
			#
			#for enemy in enemies_in_thunderbolt_area:
				#var thunder_animation = enemy.get_node("ThunderAnimation")
				#print("enemy detected " , enemy.position)
				#thunder_animation.visible = true
				#thunder_animation.play("default")
				#thunder_bolt_audio.play()
				#var timer = get_tree().create_timer(1.0)
				#await timer.timeout
				#if enemy:
					#enemy.queue_free()
					#game_manager.bolts -= 5
					#game_manager.update_bolt_label()
#
#
#func apply_knockback(direction: Vector2, force: float , knockback_duration: float) -> void:
	#knockback = direction * force
	#knockback_timer = knockback_duration
	#pass
#
#
#func start_dash():
	#dash_audio.play()
#
#func update_animation_and_direction():
	#if is_dashing:
		#animated_sprite.pla
