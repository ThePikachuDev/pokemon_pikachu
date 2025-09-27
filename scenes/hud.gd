extends CanvasLayer
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var resume_button: Button = $PauseMenu/VBoxContainer/resume_button
@onready var pause_menu: Panel = $PauseMenu
@onready var options_page: Control = $OptionsPage
@onready var retro_shader = $OptionsPage.retro_shader
@onready var game_manager = %GameManager
@onready var notification_container: VBoxContainer = $NotificationContainer
@onready var notification: Panel = $NotificationContainer/Notification

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rich_text_label.text = "[img=80x80]res://assets/my aesprite assets/ui/heart.png[/img][b][font s=48]bolts : 0[/font]"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	retro_shader.visible = GameManager.is_shader_enabled
	if Input.is_action_just_pressed("exit") and !get_tree().paused:
		get_tree().paused = true
		pause_menu.visible = get_tree().paused 


#func launch_notification():
	#notification.position = Vector2.ZERO
	#var tween := create_tween()
	#tween.tween_property(notification,"global_position", -notification.size,1)

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = get_tree().paused 


func _on_options_button_pressed() -> void:
	if options_page.visible:
		options_page.visible = false
	else:
		options_page.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/windowUI.tscn")


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
