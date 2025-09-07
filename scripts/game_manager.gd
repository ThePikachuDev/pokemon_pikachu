extends Node

var bolt = 0

@onready var bolt_label: RichTextLabel = $HUD/RichTextLabel

func add_bolt():
	bolt += 1
	bolt_label.text = "[img=80x80]res://assets/my aesprite assets/ui/heart.png[/img][b][font s=48]bolts : " + str(bolt) + " [/font]" 
	print(bolt)
  
