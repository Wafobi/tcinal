class_name DemoRoom extends SpawnHandler

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
