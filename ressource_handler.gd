class_name ResourceHandler extends Node2D

var game_settings = {
	save_game = false
}

var resources = {}

var levels = {} 
var characters = {}

var saveFiles = {}

var worldName="my_world"

var saveFolder="user://"+worldName+"/"
var worldMapSaveFile=saveFolder+"map.tscn"
var playerSaveFile=saveFolder+"player.tscn"

func addSaveFile(fileName : String):
	saveFiles[fileName] = saveFolder+fileName

func addCharacter(charName : String):
	characters[charName] = charName
	addSaveFile(charName)

func addLevel(levelName : String):
	levels[levelName] = "levels/"+levelName
	addSaveFile(levelName)
	resources.merge(levels)

func addItem(itemName : String):
	resources[itemName] = "items/"+itemName

func _ready():
	#make this more dynamic
	addCharacter("player")

	addLevel("demo_room")
	addLevel("fields")
	addLevel("mountains")
	addLevel("castle")

	addItem("feathers")
	addItem("checkpoint")
	resources.merge(levels, true)
	resources.merge(characters, true)

func instantiate_resource(resource_name):
	if resource_name and resource_name in resources:
		return load(resources[resource_name]+".tscn").instantiate()
	return null

func loadIfSaveFileExists(szene):
	var resource = instantiate_resource(szene)
	if game_settings.save_game:
		var saveFileName = saveFiles[szene]
		print("Looking for SaveFile: ", saveFileName)
		if FileAccess.file_exists(saveFileName):
			print("M: loading saved ", resource.name)
			return load(saveFileName).instantiate()
	if resource:
		print("M: loading ", resource.name)
		return resource
	return null

func saveNode(node : Node , fileName : String):
	if game_settings.save_game:
		if not DirAccess.dir_exists_absolute(saveFolder):
			DirAccess.make_dir_absolute(saveFolder)
		var save = PackedScene.new()
		save.pack(node)
		ResourceSaver.save(save, fileName);

