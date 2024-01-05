class_name FrogSpit extends RigidBody2D

var direction  : Vector2 = Vector2.ZERO
var speed :int = 2
var damage = 1

var active : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if direction and active:
		var velocity = direction * speed
		move_and_collide(velocity)

var timer : Timer
var targetPosition : Vector2
func setTargetPosition(target_position : Vector2):
	targetPosition = target_position
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(destroy)
	add_child(timer)
	timer.start(1)
	rotation = targetPosition.angle_to_point(position)
	direction = position.direction_to(target_position)
	show()

func destroy():
	targetPosition = Vector2.ZERO
	hide()
	queue_free()

func _on_hitbox_body_entered(body):
	if body is TileMap:
		destroy()
