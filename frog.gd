class_name Frog extends CharacterBody2D

signal killed

const SPIT_SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var active : bool = false

enum Type {water = 0, acid = 16, fire = 32}

@export var type : Frog.Type = Frog.Type.water

var target : Player
var shootTimer : Timer
var lineOfSight :RayCast2D
func _ready():
	lineOfSight = $LineOfSight
	target = null
	shootTimer = $shootTimer
	shootTimer.one_shot = true
	call_deferred("setup")

signal loaded
func setup():
	await get_tree().physics_frame
	active = true
	show()
	loaded.emit()

func looks_right() -> bool :
	return $Sprite2D.flip_h

func looks_left() -> bool :
	return not $Sprite2D.flip_h

func spit():
	if lineOfSight.is_colliding():
		return

	var spit : FrogSpit = null
	match type:
		Type.water : spit = ResourceHandler.instantiate_resource("frog_spit")
		Type.acid : spit = ResourceHandler.instantiate_resource("frog_acid")
		Type.fire : spit = ResourceHandler.instantiate_resource("frog_fire")

	if spit:
		get_owner().add_child(spit)
		get_owner().move_child(spit,-1)
		spit.set_owner(get_owner())
		spit.position = to_global(lineOfSight.position)
		spit.setTargetPosition(to_global(lineOfSight.target_position))

func _process(delta):
	if active:
		if target:
			var target_pos = Vector2(target.position.x, target.position.y-8)			
			var spit_position : Vector2
			if looks_right():
				spit_position = position + Vector2(5, -5)
			if looks_left():
				spit_position = position + Vector2(-5, -5)

			lineOfSight.position = to_local(spit_position)
			lineOfSight.target_position = to_local(target_pos)
			if shootTimer.is_stopped():
				shootTimer.start(0.8)

func _physics_process(delta):
	# Add the gravity.	
	if target and active:
		if target.position.x < position.x: #left
			$Sprite2D.flip_h = false
		if target.position.x > position.x: #right
			$Sprite2D.flip_h = true
	
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

func _on_aggro_range_body_entered(body):
	if body is Player:
		print("Targeting Player")
		target = body

func _on_aggro_range_body_exited(body):
	if body is Player and active:
		print("Not Targeting Player")
		target = null
		shootTimer.stop()

func _on_shoot_timer_timeout():
	if active:
		spit()

func _on_area_2d_body_entered(body):
	if body is Player and active:
		print("Player killed frog")
		hide()
		killed.emit()
		queue_free()
