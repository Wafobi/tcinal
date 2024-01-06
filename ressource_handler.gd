extends Node2D

var game_settings = {
	binary_save_game = false,
	demo = true,
	testing = false
}

func loadGameSettings():
	if not DirAccess.dir_exists_absolute(saveFolder):
		return
	#TODO when needed

var resources = {}

var saveFiles = {}

var worldName="demo_world"

var saveFolder="user://"+worldName+"/"
var playerSaveFile = saveFolder+"/player.dat"

func addSaveFile(nodeName : String):
	saveFiles[nodeName] = saveFolder+nodeName+".tscn"

func getSaveFileName(nodeName : String):
	return saveFiles[nodeName]

func addCharacter(charName : String):
	resources[charName] = charName

func addLevel(levelName : String, file : String = levelName):
	resources[levelName] = "levels/"+file

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


func instantiate_resource(resource_name):
	if resource_name and resource_name in resources:
		return load(resources[resource_name]+".tscn").instantiate()
	return null

func nodeSaveFileExists(szene):
	var saveFileName = getSaveFileName(szene)
	print("Looking for SaveFile: ", saveFileName)
	return FileAccess.file_exists(saveFileName)

func loadNodeIfSaveFileExists(szene):
	var resource = instantiate_resource(szene)
	if game_settings.binary_save_game:
		var saveFileName = getSaveFileName(szene)
		if FileAccess.file_exists(saveFileName):
			print("M: loading saved ", resource.name)
			return load(saveFileName).instantiate()
	if resource:
		print("M: loading ", resource.name)
		return resource
	return null

func saveNode(node : Node):
	if game_settings.binary_save_game:
		if not DirAccess.dir_exists_absolute(saveFolder):
			DirAccess.make_dir_absolute(saveFolder)
		var save = PackedScene.new()
		save.pack(node)
		var fileName = getSaveFileName(node.name)
		print("saving ", fileName)
		ResourceSaver.save(save, fileName)

func savePlayerValues(player : Player):
	if not DirAccess.dir_exists_absolute(saveFolder):
		DirAccess.make_dir_absolute(saveFolder)
	var playerData = {
		"player" : {
		"health" : player.health,
		"points" : player.points,
		"feathers" : player.feathers,
		"has_double_jump" : player.has_double_jump,
		"has_wall_slide" : player.has_wall_slide,
		"has_wall_jump" : player.has_wall_jump,
		"has_dash" : player.has_dash,
		}
	}
	var file = FileAccess.open(playerSaveFile, FileAccess.WRITE)
	file.store_string(JSON.stringify(playerData))

func loadPlayerValues(player : Player):
	if not DirAccess.dir_exists_absolute(saveFolder):
		return
	var file = FileAccess.open(playerSaveFile, FileAccess.READ)
	var savedPlayer = JSON.parse_string(file.get_as_text())
	player.health = savedPlayer["player"]["health"]
	player.points = savedPlayer["player"]["points"]
	player.feathers = savedPlayer["player"]["feathers"]
	player.has_double_jump = bool(savedPlayer["player"]["has_double_jump"])
	player.has_wall_slide = bool(savedPlayer["player"]["has_wall_slide"])
	player.has_wall_jump = bool(savedPlayer["player"]["has_wall_jump"])
	player.has_dash = bool(savedPlayer["player"]["has_wall_slide"])

func saveFileExists():
	return FileAccess.file_exists(playerSaveFile)
	
func prune():
	if DirAccess.dir_exists_absolute(saveFolder):
		OS.move_to_trash(ProjectSettings.globalize_path(saveFolder))
