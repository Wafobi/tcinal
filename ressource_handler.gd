class_name ResourceHandler extends Node2D

var game_settings = {
	save_game = false
}

var resources = {
	"player" : "player",
	"fields" : "levels/fields",
}

var worldName="my_world"

var saveFolder="user://"+worldName+"/"
var worldMapSaveFile=saveFolder+"map.tscn"
var playerSaveFile=saveFolder+"player.tscn"

var saveFiles = {
	"fields" : saveFolder+"fields",
	"player" : saveFolder+"player",
}

func instantiate_resource(resource_name):
	if resource_name:
		return load(resources[resource_name]+".tscn").instantiate()
	return null


func loadIfSaveFileExists(szene):
	var resource = instantiate_resource(szene)
	if game_settings.save_game:
		var saveFileName = saveFiles[szene]
		print("Looking for SaveFile: " + saveFileName)
		if FileAccess.file_exists(saveFileName):
			print("M: loading saved " + resource.name)
			return load(saveFileName).instantiate()
	print("M: loading " + resource.name)
	return resource

func saveNode(node : Node , fileName : String):
	if game_settings.save_game:
		if not DirAccess.dir_exists_absolute(saveFolder):
			DirAccess.make_dir_absolute(saveFolder)
		var save = PackedScene.new()
		save.pack(node)
		ResourceSaver.save(save, fileName);

