class_name Frog extends CharacterBody2D

signal killed
signal loaded

const SPIT_SPEED = 350.0
const WALK_SPEED = 50.0
const JUMP_VELOCITY = -100.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var active : bool = false

enum Type {water = 0, acid = 16, fire = 32}

@export var type : Frog.Type = Type.water

var target : Player
var shootTimer : Timer
var lineOfSight :RayCast2D

var jumpLeftDetector : RayCast2D
var jumpRightDetector : RayCast2D

var jumpDetectorR : RayCast2D
var jumpDetectorL : RayCast2D

var groundLeft : RayCast2D
var groundRight : RayCast2D
var fallDetector : RayCast2D
var obstacleDetector : RayCast2D

var navi: NavigationAgent2D

var homePosition : Vector2
var target_position : Vector2
var direction : Vector2 = Vector2.ZERO

var animatedSprite : AnimatedSprite2D

func getAnimatedSprite() -> AnimatedSprite2D :
	return $frogAnimation

func _ready():
	hide()
	homePosition = Vector2.ZERO
	target_position = Vector2.ZERO
	lineOfSight = $LineOfSight
	target = null
	shootTimer = $shootTimer
	shootTimer.one_shot = true

	navi = $NavigationAgent2D

	jumpLeftDetector = $JumpLeft
	jumpRightDetector = $JumpRight

	groundLeft = $groundLeft
	groundRight = $groundRight

	jumpDetectorL = $TopLeft
	jumpDetectorR = $TopRight
	fallDetector = $fallOk
	obstacleDetector = $walkWay
	
	animatedSprite = getAnimatedSprite()
	playAnimation("idle")
	call_deferred("setup")

func setup():
	await get_tree().physics_frame
	setType(type)
	show()
	loaded.emit()

func activate():
	active = true
	homePosition = position
	navi.target_position = homePosition

func deactivate():
	active = false

func looks_right() -> bool :
	return animatedSprite.flip_h

func looks_left() -> bool :
	return not animatedSprite.flip_h

func spit():
	if lineOfSight.is_colliding():
		shootTimer.start(0.1)
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
			shootTimer.start(0.5)
	else:
		print("Frog has no Spit")

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

func getJumpYDistance():
	return ceil(abs(target_position.y - position.y))

func getJumpXDistance():
	return ceil(abs(target_position.x - position.x))

func isFallOkay():
	if not groundRight.is_colliding():
		fallDetector.position = groundRight.position
	if not groundLeft.is_colliding():
		fallDetector.position = groundLeft.position
	return fallDetector.is_colliding()

func is_on_edge():
	return is_on_floor_only() and (not groundLeft.is_colliding() or not groundRight.is_colliding())

func isWayBlocked():
	return obstacleDetector.is_colliding()

func canJumpRight():
	return not jumpRightDetector.is_colliding()

func canJumpLeft():
	return not jumpLeftDetector.is_colliding()

func hasTopSpace():
	return not jumpDetectorL.is_colliding() and not jumpDetectorR.is_colliding()

func canJump():
	return hasTopSpace() and ( canJumpLeft() or canJumpRight())

func shouldJump():
	var y_margin = 8
	var x_margin = 2
	var y_distance = getJumpYDistance()
	var x_distance_to_jump = getJumpXDistance()

	if y_distance < 30:
		x_margin = 10
	if y_distance >= 20:
		x_margin = 1

	var jump_distance_ok = x_distance_to_jump <= x_margin and ((floor(target_position.y) + y_margin) < floor(position.y))

	return is_on_floor_only() and jump_distance_ok

func shouldFall():
	return floor(lineOfSight.target_position.y) > 0

func move(_delta):
	if not navi.is_navigation_finished():
		target_position = navi.get_next_path_position()
		direction = position.direction_to(target_position).normalized()

		if direction.x:
			velocity.x = direction.x * WALK_SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, WALK_SPEED)

		if is_on_edge():
			if isFallOkay():
				if not groundRight.is_colliding():
					velocity.x += 30
				if not groundLeft.is_colliding():
					velocity.x -= 30
			else:
				velocity.x = 0
		if isWayBlocked():
			jump()
	else:
		velocity = Vector2.ZERO

func jump():
	if canJump():
		var y_distance = getJumpYDistance()
		velocity.y = -220
		if y_distance > 20:
			velocity.y = -340

func _physics_process(delta):
	if active:
		move(delta)
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func _process(_delta):
	if not navi.is_navigation_finished():
		if navi.target_position.x <= floor(position.x): #left
			animatedSprite.flip_h = false
		if navi.target_position.x >= floor(position.x): #right
			animatedSprite.flip_h = true
		if looks_right():
			obstacleDetector.target_position.x = 15
		if looks_left():
			obstacleDetector.target_position.x = -15
	if velocity.x != 0:
		playAnimation("walk")
	else:
		playAnimation("idle")

func playAnimation(animation : String):
	match type:
		Type.acid: animatedSprite.play("acid_"+animation)
		Type.fire: animatedSprite.play("fire_"+animation)
		Type.water: animatedSprite.play("water_"+animation)

func setType(frogType : Frog.Type):
	type = frogType

func _on_aggro_range_body_entered(body):
	if body is Player and body.active and active:
		target = body
		updateSpitTarget(true)

func _on_aggro_range_body_exited(body):
	if body is Player and active:
		shootTimer.stop()
		target = null
		lineOfSight.target_position = Vector2(0,50)

func _on_shoot_timer_timeout():#
	if active:
		spit()

func _on_hitbox_body_entered(body):
	if body is Player and active:
		hide()
		killed.emit()
		queue_free()

func _on_target_timer_timeout():
	if target:
		updateSpitTarget()
		navi.target_position.x = floor(target.position.x)
		navi.target_position.y = floor(target.position.y)
	else:
		navi.target_position = homePosition

func _on_navigation_agent_2d_velocity_computed(_safe_velocity):
	#kills the agent :)
	pass

func _on_navigation_agent_2d_target_reached():
	pass
