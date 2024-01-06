class_name DemoRoom extends SpawnHandler

var chicken : Chicken

func _ready():
	chicken = $TileMap/chicken
	chicken.position = getChickenSpawnPoints().pick_random().position
	chicken.setCollisions(false)
	chicken.hide()
	super._ready()

func getTileMap() -> TileMap:
	return $TileMap

func activateEntities():
	pass

func cameraOn():
	$Camera2D.enabled = true

func cameraOff():
	$Camera2D.enabled = false

func getCurrentStatistics() -> String:
	return "%d" % [player.feathers]

func getChickenSpawnPoints() -> Array:
	return getTileMap().get_tree().get_nodes_in_group("chickenSpawnPoint")

func getLevelStatistics() -> String :
	return """You caught %s the %s chicken.
	You learned %s """ % [chicken.chickenName, chicken.featherTypeName, ResourceHandler.getReward(player)]

func goalReached(body):
	if body is Player:
		chicken.getHitBox().body_entered.disconnect(goalReached)
		chicken.hide()
		levelDone.emit()

func getChicken():
	return chicken

func prepare():
	if ResourceHandler.isChikckenCoopFull():
		chicken.getHitBox().body_entered.connect(goalReached)
		chicken.show()
