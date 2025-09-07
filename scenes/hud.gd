extends CanvasLayer
@onready var rich_text_label: RichTextLabel = $RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rich_text_label.text = "[img=80x80]res://assets/my aesprite assets/ui/heart.png[/img][b][font s=48]bolts : 0[/font]"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
