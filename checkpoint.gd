class_name CheckPoint extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$off.show()
	$on.hide()

func _on_body_entered(body):
	if body is Player:
		Checkpoints.last_checkpoint = body.position

func _on_body_exited(body):
	if body is Player:
		$off.hide()
		$on.show()
