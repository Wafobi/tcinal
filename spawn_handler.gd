class_name SpawnHandler extends Node2D

# ========INTERFACE TO BE IMPLEMENTED BY EXTENING CLASS ==================
func getTileMap() -> TileMap:
	return null

func getLevelBounds() -> Area2D:
	return null

func getLevelGoal() -> Area2D:
	return null
	
func getChicken() -> Chicken:
	return null
# ========================================================================

signal loaded
signal doorSignal
signal levelDone
signal respawn

var leaving_level = false
var player : Player = null
var playerRespawnCount : int = 0

var levelTime : float = 0

var levelFeatherCount : int = 0
var feathersCollected : int = 0

var rainbowfeathersCollected : int = 0
var levelRainbowFeatherCount : int = 0

var levelFrogCount : int = 0
var frogsKilled : int = 0

var levelPoints : int = 0

var levelEntitiesLoaded : int = 0
var levelEntities : int = 0

var levelName = name

var respawnCount = 0
var respawning = false

func entityLoaded():
	levelEntitiesLoaded += 1
	if levelEntities == levelEntitiesLoaded: # all entities are ready to be enabled
		loaded.emit()

# serializes entitiy activity with player activity.
# main takes care of setting this
func activateEntities():
	for entity in getEntities():
		entity.activate()
		
func deactivateEntities():
	for entity in getEntities():
		entity.deactivate()

func cameraOn():
	pass

func cameraOff():
	pass

func getCamera() -> Camera2D:
	return $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	respawnCount = 0
	levelTime = 0
	levelFeatherCount = getFeathers().size()
	levelRainbowFeatherCount = getRainbowFeathers().size()
	levelFrogCount = getFrogs().size()
	levelPoints = 0
	feathersCollected = 0
	frogsKilled = 0
	leaving_level = false
	playerRespawnCount = 0
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
func _process(delta):
	if player and player.active:
		levelTime += delta

func frogKilled():
	levelPoints += 2
	frogsKilled += 1

func featherCollected(feather : Feather):
	feathersCollected+=1
	levelPoints += feather.points
	if feather.type == Feather.Type.rainbow:
		rainbowfeathersCollected += 1

func respawnPlayer():
	respawnCount += 1
	if Checkpoints.last_checkpoint:
		player.position = Checkpoints.last_checkpoint
	else:
		player.position = Checkpoints.levelspawn
	if feathersCollected > 0:
		feathersCollected -= 1
	respawning = false

func levelBoundsHit(body):
	if body is Player and not leaving_level and not respawning:
		respawning = true
		call_deferred("respawnPlayer")
	if body is Frog:
		removeBody(body, true)

func goalReached(body):
	if body is Player:
		levelDone.emit()

func getCurrentStatistics() -> String:
	if not player:
		return ""
	return "%d | Time: %d" %  [feathersCollected, int(levelTime)]

func getLevelStatistics() -> String :
	var rainbowChickenString : String = ""
	if ResourceHandler.isChikckenCoopFull():
		rainbowChickenString = """
		You hear a chicken approaching
"""
	return """Congratulations!
Finished Level: %s.
You caught %s the %s chicken.

Health restored.

Time: %d seconds.
Feathers collected: %d / %d.
Rainbow Feathers collected %d / %d.
Feathers lost by respawn: %d

Frogs killed: %d / %d
%s
Game saved""" % [levelName,
getChicken().chickenName,
getChicken().featherTypeName,
int(levelTime),
feathersCollected, levelFeatherCount,
rainbowfeathersCollected, levelRainbowFeatherCount,
respawnCount,
frogsKilled, levelFrogCount, rainbowChickenString]

func setFeatherType(ft : Feather.Type):
	for feather in getFeathers():
		feather.setType(ft)

func prepare():
	for feather in getFeathers():
		feather.collected.connect(featherCollected)
	if getFeathers().size() > 0:
		print("Feathers fluffed up")

	for frog : Frog in getFrogs():
		frog.killed.connect(frogKilled)
	if getFrogs().size() > 0:
		print("Frogs ready to be killed")

	#RAINBOW OVERRIDE!!!
	for feather in getRainbowFeathers():
		feather.setType(Feather.Type.rainbow)
	if getRainbowFeathers().size() > 0:
		print("Some feathers magically enhanced with rainbows")

	var lb = getLevelBounds()
	if lb:
		lb.body_entered.connect(levelBoundsHit)
		lb.collision_layer = 0
		lb.collision_mask = 0
		lb.set_collision_layer_value(9, true)
		lb.set_collision_mask_value(2, true)
		print("Pit of doom placed")

	var goal = getLevelGoal()
	if goal:
		goal.z_index = 1
		goal.collision_layer = 0
		goal.collision_mask = 0
		goal.set_collision_layer_value(11, true)
		goal.set_collision_mask_value(2, true)
		goal.body_entered.connect(goalReached)
		print("Chicken set free")

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
		#player.hookCamera(getCamera().get_path())
		player.spawn()

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

func cleanup(defer = false):
	queue_free()
	if player:
		removeBody(player,defer)
		player = null

func _input(_event):
	if Input.is_action_just_pressed("use"):
		for door in getDoors():
			var overlaps = door.get_overlapping_bodies()
			if overlaps.size() > 0:
				for overlap in overlaps:
					if overlap is Player and overlap.active:
						print("Player on ", door.name," ", name+"_SpawnPoint" )
						leaving_level = true
						overlap.velocity = Vector2.ZERO
						deactivateEntities()
						doorSignal.emit(door.name, name+"_SpawnPoint")
						return

