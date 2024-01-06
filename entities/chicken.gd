class_name Chicken extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var type : Feather.Type = Feather.Type.brown

var active : bool = false

var reward = {
	Feather.Type.brown : "double_jump",
	Feather.Type.grey : "wall_slide",
	Feather.Type.white : "wall_jump",
}

signal loaded

func _ready():
	call_deferred("setup")

func setup():
	await get_tree().physics_frame
	loaded.emit()

func activate():
	active = true

func deactivate():
	active = false

func setType(featherType : Feather.Type):
	type = featherType
	var sprite :Sprite2D = $Sprite2D
	sprite.set_region_rect(Rect2(type, 0, 16, 16))
	var animationPlayer : AnimationPlayer = $AnimationPlayer
	var animation : Animation = animationPlayer.get_animation("idle")
	animation.track_set_key_value(0, 0, Rect2(type, 0, 16, 16))
	animation.track_set_key_value(0, 1, Rect2(type, 16, 16, 16))
	animation.track_set_key_value(0, 2, Rect2(type, 32, 16, 16))
	animation.track_set_key_value(0, 3, Rect2(type, 16, 16, 16))
	animationPlayer.play("idle")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	#todo make chickens move
	move_and_slide()

func getHitBox() -> Area2D :
	return $Area2D
