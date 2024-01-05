class_name Frog extends CharacterBody2D

signal killed

const SPIT_SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var active : bool = false

enum Type {water = 0, acid = 16, fire = 32}

@export var type : Frog.Type = Type.water

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
	setType(type)
	show()
	loaded.emit()

func looks_right() -> bool :
	return $Sprite2D.flip_h

func looks_left() -> bool :
	return not $Sprite2D.flip_h

func spit():
	if lineOfSight.is_colliding():
		return

	var spitType : FrogSpit = null
	match type: #something prevents the atlassprite update here -.-
		Type.water : spitType = ResourceHandler.instantiate_resource("frog_spit")
		Type.acid : spitType = ResourceHandler.instantiate_resource("frog_acid")
		Type.fire : spitType = ResourceHandler.instantiate_resource("frog_fire")

	if spitType:
		get_owner().add_child(spitType)
		get_owner().move_child(spitType,-1)
		spitType.set_owner(get_owner())
		spitType.position = to_global(lineOfSight.position)
		spitType.setTargetPosition(to_global(lineOfSight.target_position))
		if target:
			spitType.active = true
			shootTimer.start(0.8)

func updateSpitTarget(doSpit : bool = false):
	var target_pos = Vector2(target.position.x, target.position.y-8)			
	var spit_position : Vector2
	if looks_right():
		spit_position = Vector2(5, -5)
	if looks_left():
		spit_position = Vector2(-5, -5)
	lineOfSight.position = spit_position
	lineOfSight.target_position = to_local(target_pos)
	await  get_tree().physics_frame
	if doSpit:
		shootTimer.start(0.1)

func _process(_delta):
	if active:
		if target:
			if target.position.x < position.x: #left
				$Sprite2D.flip_h = false
			if target.position.x > position.x: #right
				$Sprite2D.flip_h = true
			updateSpitTarget()


func _physics_process(delta):
	if not active:
		pass #add movement
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func setType(frogType : Frog.Type):
	type = frogType
	var sprite :Sprite2D = $Sprite2D
	print(frogType, self, type, sprite)
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
	if body is Player and active:
		print("Targeting Player")
		target = body
		updateSpitTarget(true)

func _on_aggro_range_body_exited(body):
	if body is Player and active:
		print("Not Targeting Player")
		shootTimer.stop()
		target = null
		lineOfSight.target_position = Vector2(0,50)

func _on_shoot_timer_timeout():
	if active:
		spit()

func _on_area_2d_body_entered(body):
	if body is Player and active:
		print("Player killed frog")
		hide()
		killed.emit()
		queue_free()
