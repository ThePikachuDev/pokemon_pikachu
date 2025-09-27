extends AnimatableBody2D

@export var texture: Texture2D
@export var collisionShapeScale: float 
@export var visible_by_default: bool = true


@onready var moving_platform_sprite: Sprite2D = $MovingPlatformSprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	if texture:
		moving_platform_sprite.texture = texture
		visible = true
	
	if collisionShapeScale:
		collision_shape_2d.scale = scale
	
	if visible_by_default:
		moving_platform_sprite.visible = true
	else:
		moving_platform_sprite.visible = false
