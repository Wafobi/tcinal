class_name Player extends CharacterBody2D

signal dead
signal setupDone
signal checkPoint

var coyote_timer : Timer
var coyote_time = 0.1
var can_coyote_jump = false
var jump_buffer = 0
var jumping = false

var has_double_jump = false
var has_dash = false
var has_wall_slide = false
var has_wall_jump = false

var fatal_y_velocity = 410 #TODO let player take fall damange

enum states {FLOOR = 1, AIR, WALL}
var state = states.AIR

var wallDetector : RayCast2D

var health :float = 3

var default_speed = 100.0
var jump_velocity = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction : Vector2 = Vector2.ZERO
var view_direction : Vector2 = Vector2.ZERO

var active

# Called when the node enters the scene tree for the first time.
func _ready():
	active = false
	health = 10
	coyote_timer = $"Coyote Timer"
	wallDetector = $wallDetector
	coyote_timer.one_shot = true
	coyote_timer.timeout.connect(_on_coyote_timer_timeout)
	setCollisions()

func setCollisions():
	set_collision_layer_value(2,true)
	set_collision_mask_value(1,true) # ground
	set_collision_mask_value(3,true) # traps
	set_collision_mask_value(9,true) # LevelBoundaries
	set_collision_mask_value(10,true) # CheckPoints
	set_collision_mask_value(11,true) # LevelGoal

func is_near_wall():
	return wallDetector.is_colliding()

var jump_count = 0
func can_double_jump():
	return has_double_jump and jump_count < 2

func coyote():
	can_coyote_jump = true
	coyote_timer.start(coyote_time)

func _on_coyote_timer_timeout():
	can_coyote_jump = false

var fall_velocity = 0
func checkFallDamage():
	if velocity.y > fall_velocity:
		fall_velocity = velocity.y
	if fall_velocity > 0 and velocity.y == 0:
		if fall_velocity >= fatal_y_velocity:
			print("player died from hitting the ground to hard ", fall_velocity)
			#dead.emit()
		fall_velocity = 0

func _process(_delta):
	if active:
		if direction:
			view_direction = direction

		if looks_right():
			wallDetector.target_position.x = 6
			$AnimatedSprite2D.flip_h = false
		elif looks_left():
			wallDetector.target_position.x = -6
			$AnimatedSprite2D.flip_h = true

		if jumping:
			$AnimatedSprite2D.play("jump")
		else:
			if velocity.x != 0:
				$AnimatedSprite2D.play("walk")
			else:
				$AnimatedSprite2D.play("idle")
		if state == states.FLOOR:
			jumping = false
		checkFallDamage()

var jump_started=false
func _physics_process(delta):
	if active:
		move(delta)
	doGravity(delta)
	if velocity:
		move_and_slide()

func move(delta):
	direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down").normalized()
	var speed = default_speed
	match state:
		states.WALL:
			if is_on_floor():
				state = states.FLOOR
				return
			elif not is_near_wall():
				state = states.AIR
				return
			if has_wall_jump:
				if Input.is_action_just_pressed("jump") and view_direction != direction:
					velocity.y = jump_velocity
					if Input.is_action_pressed("run"):
						velocity.y = jump_velocity * 0.5
					if looks_left():
						velocity.x = 100
						direction.x = 1
					if looks_right():
						velocity.x = -100
						direction.x = -1
					state = states.AIR
					return
			if has_wall_slide:
				velocity.y = 100 #slow us waaayy down
				if Input.is_action_pressed("run"):
					velocity.y = 200
		states.AIR:
			if jump_started:
				jump_started = false
				state = states.FLOOR
				return
			if is_on_floor():
				state = states.FLOOR
				return
			elif is_near_wall():
				state = states.WALL
				return
			if direction.x:
				velocity.x = direction.x * speed #do lerp
			if Input.is_action_just_pressed("jump"):
				jump_buffer = 0.1
				if can_coyote_jump or can_double_jump():
					jump()
			if Input.is_action_just_pressed("dash") and has_dash:
					pass
		states.FLOOR:
			jump_count = 0
			if not is_on_floor(): #falling off a cliff (coyote)
				state = states.AIR
				coyote()
				return
			if Input.is_action_pressed("run"):
				speed *= 1.5
			velocity.x = 0
			if direction.x:
				velocity.x = direction.x * speed
			if Input.is_action_just_pressed("jump") or jump_buffer > 0:
				jump_started = true
				jump()
				state = states.AIR
				jumping = true
			if Input.is_action_just_pressed("dash") and has_dash:
				# see https://www.youtube.com/watch?v=Q2oRzUXB27w&t=58s
				pass
	jump_buffer-=delta

func jump():
	jump_count += 1
	jump_buffer = 0
	velocity.y = jump_velocity

func getGravity(delta):
	return gravity * delta

func doGravity(delta):
	velocity.y += getGravity(delta)

func looks_right() -> bool :
	return view_direction.x > 0

func looks_left() -> bool :
	return view_direction.x < 0

func spawn(coords):
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	position = coords
	velocity = Vector2.ZERO
	fall_velocity = 0
	call_deferred("setup")

func setup():
	await get_tree().physics_frame
	show()
	setupDone.emit()

func _input(_event):
	pass

func _on_hitbox_body_entered(body):
	print(name, " was hit by ", body.name)
