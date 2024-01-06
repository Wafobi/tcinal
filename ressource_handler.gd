extends Node2D

var game_settings = {
	save_game = false,
	demo = true
}

var resources = {}

var levels = {} 
var characters = {}

var saveFiles = {}

var worldName="demo_world"

var saveFolder="user://"+worldName+"/"

func addSaveFile(nodeName : String):
	saveFiles[nodeName] = saveFolder+nodeName+".tscn"

func getSaveFileName(nodeName : String):
	return saveFiles[nodeName]

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
	addItem("frog_spit")
	addItem("frog_acid")
	addItem("frog_fire")

	resources.merge(levels, true)
	resources.merge(characters, true)

func instantiate_resource(resource_name):
	if resource_name and resource_name in resources:
		return load(resources[resource_name]+".tscn").instantiate()
	return null

func prune():
	if DirAccess.dir_exists_absolute(saveFolder):
		OS.move_to_trash(ProjectSettings.globalize_path(saveFolder))

func saveFileExists(szene):
	var saveFileName = getSaveFileName(szene)
	print("Looking for SaveFile: ", saveFileName)
	return FileAccess.file_exists(saveFileName)

func loadIfSaveFileExists(szene):
	var resource = instantiate_resource(szene)
	if game_settings.save_game:
		var saveFileName = getSaveFileName(szene)
		if FileAccess.file_exists(saveFileName):
			print("M: loading saved ", resource.name)
			return load(saveFileName).instantiate()
	if resource:
		print("M: loading ", resource.name)
		return resource
	return null

func saveNode(node : Node):
	if game_settings.save_game:
		if not DirAccess.dir_exists_absolute(saveFolder):
			DirAccess.make_dir_absolute(saveFolder)
		var save = PackedScene.new()
		save.pack(node)
		var fileName = getSaveFileName(node.name)
		print("saving ", fileName)
		ResourceSaver.save(save, fileName);
