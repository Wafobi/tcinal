class_name Frog extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var active : bool = false

enum Type {water = 0, acid = 16, fire = 32}

@export var type : Frog.Type = Frog.Type.water

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func setType(frogType : Frog.Type):
	type = frogType
	var sprite :Sprite2D = $Sprite2D
	sprite.set_region_rect(Rect2(type, 0, 16, 16))
	var animationPlayer : AnimationPlayer = $AnimationPlayer
	var animation : Animation = animationPlayer.get_animation("idle")
	animation.track_set_key_value(0, 0, Rect2(type, 0, 16, 16))
	animation.track_set_key_value(0, 1, Rect2(type, 16, 16, 16))
	animation.track_set_key_value(0, 2, Rect2(type, 32, 16, 16))
	animation.track_set_key_value(0, 3, Rect2(type, 48, 16, 16))
	animation.track_set_key_value(0, 4, Rect2(type, 32, 16, 16))
	animation.track_set_key_value(0, 5, Rect2(type, 16, 16, 16))
	animationPlayer.play("idle")
