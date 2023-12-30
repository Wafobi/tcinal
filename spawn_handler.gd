class_name SpawnHandler extends ResourceHandler

signal loaded
signal doorSignal

var leaving_level = false
var player : Player = null

func getTileMap() -> TileMap:
	return null

# Called when the node enters the scene tree for the first time.
func _ready():
	leaving_level = false
	for door : Area2D in getDoors():
		door.collision_layer = 0
		door.set_collision_layer_value(5,true)
		door.set_collision_mask_value(2,true)
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
		setupBody(player,coords)

func cleanup(defer = false):
	queue_free()
	if player:
		removeBody(player,defer)
		player = null

func setupBody(body,coords):
	getTileMap().add_child(body)
	getTileMap().move_child(body,-1)
	body.set_owner(getTileMap())
	body.spawn(coords)
	
func removeBody(body, defer=false):
	if defer:
		getTileMap().call_deferred("remove_child",body)
	else:
		getTileMap().remove_child(body)
	body.hide()

func _input(_event):
	if Input.is_action_just_pressed("use"):
		for door in getDoors():
			var overlaps = door.get_overlapping_bodies()
			if overlaps.size() > 0:
				for overlap in overlaps:
					if overlap is Player:
						print("Player on ", door.name," ", name+"_SpawnPoint" )
						leaving_level = true
						doorSignal.emit(door.name, name+"_SpawnPoint")
						return

func respawnPlayer():
	print("player respawning")
	player.active = false
	if Checkpoints.last_checkpoint:
		player.spawn(Checkpoints.last_checkpoint)
	else:
		player.spawn(Checkpoints.levelspawn)

func _on_level_bounds_body_exited(body):
	if body is Player and not leaving_level:
		call_deferred("respawnPlayer")
