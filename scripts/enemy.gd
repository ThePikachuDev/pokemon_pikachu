extends Node2D

@onready var ray_cast_left: RayCast2D = $RayCast2D
@onready var ray_cast_right: RayCast2D = $RayCast2D2
@onready var leaves: Sprite2D = $Leaves
@onready var timer: Timer = $Leaves/Timer
@onready var animated_enemy_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var head: Area2D = $head
@onready var game_manager = %GameManager
@onready var odish_voice: AudioStreamPlayer2D = $OdishVoice

const LEAVES_SPEED = 200.0
const ATTACK_COOLDOWN = 0.7 
var current_direction: int = 1
var is_throwing: bool = false
var time_since_last_attack: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	leaves.visible = false
	timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
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
	if leaves.visible:
		leaves.position.x += LEAVES_SPEED * current_direction * delta
		leaves.flip_h = current_direction == -1

func throw_leaves(_dir: int) -> void:
	is_throwing = true
	leaves.position = animated_enemy_sprite.position
	leaves.visible = true
	odish_voice.play()
	timer.start()

func _on_timer_timeout() -> void:
	is_throwing = false
	leaves.visible = false
	leaves.position = animated_enemy_sprite.position

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var knockback_direction = (body.global_position - global_position).normalized()
		body.apply_knockback(knockback_direction, 300.0, 0.12)
		game_manager.take_damage()
	
		leaves.visible = false
		is_throwing = false
		leaves.position = animated_enemy_sprite.position
		timer.stop()

func _on_head_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		self.queue_free()
