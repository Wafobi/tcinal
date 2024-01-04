class_name SpawnHandler extends Node2D

signal loaded
signal doorSignal
signal levelDone

var leaving_level = false
var player : Player = null

func getTileMap() -> TileMap:
	return null

func getLevelBounds() -> Area2D:
	return null

func getLevelGoal() -> Area2D:
	return null

func getReward() -> String:
	return ""

func requirements() -> Array:
	return []


var levelEntitiesLoaded : int = 0
var levelEntities : int = 0
func entityLoaded():
	levelEntitiesLoaded += 1
	if levelEntities == levelEntitiesLoaded:
		loaded.emit()

# Called when the node enters the scene tree for the first time.
func _ready():
	leaving_level = false
	for door : Area2D in getDoors():
		door.collision_layer = 0
		door.set_collision_layer_value(5,true)
		door.set_collision_mask_value(2,true)
		door.z_index = 0

	levelEntities = getEntities().size()
	if levelEntities > 0:
		for entity in getEntities():
			entity.loaded.connect(entityLoaded)
	else:
		loaded.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func respawnPlayer():
	print("player respawning")
	if Checkpoints.last_checkpoint:
		player.position = Checkpoints.last_checkpoint
	else:
		player.position = Checkpoints.levelspawn
	respawning = false

var respawning = false
func levelBoundsHit(body):
	if body is Player and not leaving_level and not respawning:
		respawning = true
		call_deferred("respawnPlayer")

func goalReched(body):
	print("player hit goal")
	if body is Player:
		levelDone.emit(name)

func setFeatherType(ft):
	for feather in getFeathers():
		feather.setType(ft)

func prepare():
	for feather in getRainbowFeathers():
		feather.setType(Feather.Type.rainbow)
	var lb = getLevelBounds()
	if lb:
		lb.body_entered.connect(levelBoundsHit)
		lb.collision_layer = 0
		lb.collision_mask = 0
		lb.set_collision_layer_value(9, true)
		lb.set_collision_mask_value(2, true)
		print("level bounds setup")

	var goal = getLevelGoal()
	if goal:
		goal.z_index = 1
		goal.collision_layer = 0
		goal.collision_mask = 0
		goal.set_collision_layer_value(11, true)
		goal.set_collision_mask_value(2, true)
		goal.body_entered.connect(goalReched)
		print("goal setup")

func getEntities() -> Array:
	return getTileMap().get_tree().get_nodes_in_group("entity")

func getFrogs() -> Array:
	return getTileMap().get_tree().get_nodes_in_group("Frog")

func getFeathers() -> Array:
	return getTileMap().get_tree().get_nodes_in_group("Feather")
	
func getRainbowFeathers() -> Array:
	return getTileMap().get_tree().get_nodes_in_group("RainbowFeather")

func getSpawnPoints() -> Array:
	return getTileMap().get_tree().get_nodes_in_group("SpawnPoint")

func getTextMarkers() -> Array:
	return getTileMap().get_tree().get_nodes_in_group("textmarker")

func getDoors() -> Array:
	return getTileMap().get_tree().get_nodes_in_group("door")

func getAIWalkPoints() -> Array:
	return getTileMap().get_tree().get_nodes_in_group("aiWalkpoint")

func setupPlayer(newPlayer : Player):
	if newPlayer:
		player = newPlayer
		setupBody(player)
		player.spawn()

func cleanup(defer = false):
	queue_free()
	if player:
		removeBody(player,defer)
		player = null

func setupBody(body,coords : Vector2 = Vector2.ZERO):
	getTileMap().add_child(body)
	getTileMap().move_child(body,-1)
	body.set_owner(getTileMap())
	if coords:
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

