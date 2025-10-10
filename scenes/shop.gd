extends Node2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var bolts_label: RichTextLabel = $CanvasLayer/ShopContainer/BoltsLabel

@onready var game_manager = %GameManager
@onready var speed_timer: Timer = $CanvasLayer/ShopContainer/SpeedItemCard/SpeedTimer
@onready var jump_timer: Timer = $CanvasLayer/ShopContainer/JumpItemCard/JumpTimer
@onready var item_bought_pop_up: Label = $CanvasLayer/ShopContainer/ItemBoughtPopUp
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

@onready var speed_cost_label: RichTextLabel = $CanvasLayer/ShopContainer/SpeedItemCard/SpeedCostLabel
@onready var health_cost_label: RichTextLabel = $CanvasLayer/ShopContainer/HealthItemCard/HealthCostLabel
@onready var jump_cost_label: RichTextLabel = $CanvasLayer/ShopContainer/JumpItemCard/JumpCostLabel


var super_speed_cost: int = 5
var super_health_cost: int = 4
var super_jump_cost: int = 7

var is_speed_enabled: bool = false

func _ready() -> void:
	speed_cost_label.text = "[img=20x20]res://assets/my aesprite assets/ui/heart.png[/img][font s=16 ]cost: " + str(super_speed_cost) + "[/font]"
	health_cost_label.text = "[img=20x20]res://assets/my aesprite assets/ui/heart.png[/img][font s=16 ]cost: " + str(super_health_cost) + "[/font]"
	jump_cost_label.text = "[img=20x20]res://assets/my aesprite assets/ui/heart.png[/img][font s=16 ]cost: " + str(super_jump_cost) + "[/font]"


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		canvas_layer.visible = !canvas_layer.visible
	#
	#if is_speed_enabled:
		#game_manager.speed *= 2
		#speed_timer.start()

func _on_black_background_mouse_entered() -> void:
	canvas_layer.visible = false

func _on_speed_button_pressed() -> void:
	item_bought("Super Speed",super_speed_cost)
	if game_manager.bolts >= super_speed_cost:
		game_manager.bolts -= super_speed_cost
		game_manager.player_speed += 300
		print("game_manager speed : ", game_manager.player_speed)
		print("GameManager speed : ",GameManager.player_speed)
		speed_timer.start()

func _on_speed_timer_timeout() -> void:
	game_manager.player_speed /= 2
	is_speed_enabled = false

func _on_health_button_pressed() -> void:
	item_bought("Full Health",super_health_cost)
	if game_manager.bolts >= super_health_cost:
		game_manager.bolts -= super_health_cost
		game_manager.health = 3
		game_manager.update_heart_display()
		game_manager.load_hearts()

func _on_jump_button_pressed() -> void:
	item_bought("Super Jump", super_jump_cost)
	if game_manager.bolts >= super_jump_cost:
		game_manager.bolts -= super_jump_cost
		game_manager.player_jump_speed *= 2

func item_bought(item_text: String, cost: int):
	if game_manager.bolts >= cost:
		item_bought_pop_up.text = "you Bought " + item_text + " !!"
		animation_player.play("item_bought")
		await animation_player.animation_finished
	else:
		item_bought_pop_up.text = "You Need " + str( cost - game_manager.bolts) + " More Bolts !"
		animation_player.play("item_bought")
		await animation_player.animation_finished
	game_manager.update_bolt_label()
	print("game_manager bolts ", game_manager.bolts)
	print("GameManager bolts ", GameManager.bolts)


func _on_jump_timer_timeout() -> void:
	game_manager.player_jump_speed /= 2
