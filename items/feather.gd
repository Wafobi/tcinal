class_name Feather extends Area2D

signal collected
var points = 10

enum Type {brown = 0, grey = 16, white = 32, rainbow = 48}

@export var type : Type = Type.brown

func setType(featherType):
	type = featherType
	var sprite = $Sprite2D
	sprite.set_region_rect(Rect2(type, 0, 16, 16))

func _on_body_entered(body):
	if body is Player:
		collected.emit(self)
		hide()
		call_deferred("queue_free")
