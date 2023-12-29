class_name SpawnHandler extends ResourceHandler

signal loaded
signal doorSignal

var player : Player = null

func getTileMap() -> TileMap:
	return null

# Called when the node enters the scene tree for the first time.
func _ready():
	for door : Area2D in getDoors():
		door.collision_layer = 0
		door.set_collision_layer_value(5,true)
		door.set_collision_mask_value(1,true)
		door.z_index = 0
	loaded.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func prepare():
	pass

func getSpawnPoints() -> Array:
	return getTileMap().get_tree().get_nodes_in_group("SpawnPoint")

func getTextMarkers() -> Array:
	return getTileMap().get_tree().get_nodes_in_group("textmarker")

func getDoors() -> Array:
	return getTileMap().get_tree().get_nodes_in_group("door")

func getAIWalkPoints() -> Array:
	return getTileMap().get_tree().get_nodes_in_group("aiWalkpoint")

func setupPlayer(newPlayer : Player, coords : Vector2):
	if newPlayer:
		player = newPlayer
		if Checkpoints.last_checkpoint:
			coords = Checkpoints.last_checkpoint
		setupBody(player)
		player.setupDone.connect(playerReady)
		player.spawn(coords)

func playerReady():
	player.show()

func cleanup(defer = false):
	Checkpoints.last_checkpoint = null
	if player:
		removeBody(player,defer)
		player.queue_free()
	queue_free()

func setupBody(body):
	getTileMap().add_child(body)
	getTileMap().move_child(body,-1)
	body.set_owner(getTileMap())
	
func removeBody(body, defer=false):
	if defer:
		getTileMap().call_deferred("remove_child",body)
	else:
		getTileMap().remove_child(body)
	body.hide()
	body.queue_free()

func _input(_event):
	if Input.is_action_just_pressed("use"):
		for door in getDoors():
			var overlaps = door.get_overlapping_bodies()
			if overlaps.size() > 0:
				for overlap in overlaps:
					if overlap is Player:
						print("Player on " + door.name)
						doorSignal.emit(door.name, name+"_SpawnPoint")
						return

func _on_checkpoints_body_entered(body):
	if body is Player:
		print("Checkpoint reached")
		Checkpoints.last_checkpoint = player.position

func resetLevel():
	get_tree().reload_current_scene()

func _on_level_bounds_body_exited(body):
	if body is Player:
		call_deferred("resetLevel")
