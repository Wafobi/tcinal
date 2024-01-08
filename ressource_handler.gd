extends Node2D

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

var resources = {}
var saveFiles = {}

var worldName="demo_world"
var saveFolder="user://"+worldName+"/"

var game_settings = {
	binary_save_game = false,
	demo = true,
	testing = false,
	volume = 0,
	defaultKeyMappings = {
		"controllerMapping" = { "Walk Left": "Joypad Button 13 (D-pad Left)", "Walk Right": "Joypad Button 14 (D-pad Right)", "Jump": "Joypad Button 0 (Bottom Action, Sony Cross, Xbox A, Nintendo B)", "Run": "Joypad Button 2 (Left Action, Sony Square, Xbox X, Nintendo Y)", "Interact": "Joypad Button 10 (Right Shoulder, Sony R1, Xbox RB)", "Pause Game": "Joypad Button 6 (Start, Xbox Menu, Nintendo +)" },
		"keyboardMapping" = { "Walk Left": "A", "Walk Right": "D", "Jump": "Space", "Run": "Shift", "Interact": "F", "Pause Game": "Escape" }
	},
	playerKeyMappings = {
		"controllerMapping" = { "Walk Left": "Joypad Button 13 (D-pad Left)", "Walk Right": "Joypad Button 14 (D-pad Right)", "Jump": "Joypad Button 0 (Bottom Action, Sony Cross, Xbox A, Nintendo B)", "Run": "Joypad Button 2 (Left Action, Sony Square, Xbox X, Nintendo Y)", "Interact": "Joypad Button 10 (Right Shoulder, Sony R1, Xbox RB)", "Pause Game": "Joypad Button 6 (Start, Xbox Menu, Nintendo +)" },
		"keyboardMapping" = { "Walk Left": "A", "Walk Right": "D", "Jump": "Space", "Run": "Shift", "Interact": "F", "Pause Game": "Escape" }
	}
}

func resetControllerMappings():
	game_settings.playerKeyMappings["controllerMapping"] = game_settings.defaultKeyMappings["controllerMapping"]

func resetPlayerKeyboardMappings():
	game_settings.playerKeyMappings["keyboardMapping"] = game_settings.defaultKeyMappings["keyboardMapping"]

func getPlayerControllerMappings() -> Dictionary:
	return game_settings.playerKeyMappings["controllerMapping"]

func getPlayerKeyboardMappings() -> Dictionary: 
	return game_settings.playerKeyMappings["keyboardMapping"]

func setPlayerMapping(mapping, key, value) :
	game_settings.playerKeyMappings[mapping][key] = value

func setPlayerKeyboardMapping(key, value) :
	game_settings.playerKeyMappings["keyboardMapping"][key] = value

func setPlayerControllerMapping(key, value) :
	game_settings.playerKeyMappings["controllerMapping"][key] = value

func getKeyMapping(mapping,key) -> String:
	if game_settings.playerKeyMappings[mapping].has_key(key):
		return game_settings.playerMapping[mapping][key]
	return game_settings.defaultKeyMappings[mapping][key]

var settingsSaveFile = saveFolder+"settings.json"
func loadSettings():
	if not settingsSaveFileExists():
		game_settings.volume = -10
		return
	var file = FileAccess.open(settingsSaveFile, FileAccess.READ)
	var savedData = JSON.parse_string(file.get_as_text())
	game_settings = savedData

func saveSettings():
	if not DirAccess.dir_exists_absolute(saveFolder):
		DirAccess.make_dir_absolute(saveFolder)
	var file = FileAccess.open(settingsSaveFile, FileAccess.WRITE)
	file.store_string(JSON.stringify(game_settings))

func settingsSaveFileExists():
	return FileAccess.file_exists(settingsSaveFile)

var chicken_coop = {
	var_to_str(Feather.Type.brown) : false,
	var_to_str(Feather.Type.grey) : false,
	var_to_str(Feather.Type.white) : false,
	var_to_str(Feather.Type.rainbow) : 0,
}

func addChicken(type : Feather.Type):
	if type == Feather.Type.rainbow:
		print("Rainbow Added")
		chicken_coop[var_to_str(type)] += 1
	else:
		chicken_coop[var_to_str(type)] = true

func freeChickens():
	chicken_coop[var_to_str(Feather.Type.brown)] = false
	chicken_coop[var_to_str(Feather.Type.grey)] = false
	chicken_coop[var_to_str(Feather.Type.white)] = false

func isChikckenCoopFull() -> bool:
	return chicken_coop[var_to_str(Feather.Type.brown)] and chicken_coop[var_to_str(Feather.Type.grey)] and chicken_coop[var_to_str(Feather.Type.white)] 

func getReward(player : Player) -> String:
	if chicken_coop[var_to_str(Feather.Type.rainbow)] == 1 : 
			player.has_double_jump = true
			return """Double Jump:
			When jumping press space to jump again.
			"""
	if chicken_coop[var_to_str(Feather.Type.rainbow)] == 2 : 
			player.has_wall_slide = true
			return """Wall Slide:
			This allows you to slide down vertical walls.
				
			When falling nagivate towards the wall to hold on to it.
			Try the run button when wallsliding."""
	if chicken_coop[var_to_str(Feather.Type.rainbow)] == 3 : 
			player.has_wall_jump = true
			return """Wall Jump:
			This allows you to jump or down narrow wall passages.
				
			Press space after jumping on a wall or when wall sliding.

			You don't need to change directions manually!
			Try the run buttons when wall jumping
			"""
	return "nothing"

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

var playerSaveFile = saveFolder+"/player.dat"

func savePlayerValues(player : Player):
	if not DirAccess.dir_exists_absolute(saveFolder):
		DirAccess.make_dir_absolute(saveFolder)
	var saveData = {
		"player" : {
		"health" : player.health,
		"points" : player.points,
		"feathers" : player.feathers,
		"has_double_jump" : player.has_double_jump,
		"has_wall_slide" : player.has_wall_slide,
		"has_wall_jump" : player.has_wall_jump,
		"has_dash" : player.has_dash,
		},
		"chicken_coop" : {
			var_to_str(Feather.Type.grey) : chicken_coop[var_to_str(Feather.Type.grey)],
			var_to_str(Feather.Type.brown) : chicken_coop[var_to_str(Feather.Type.brown)],
			var_to_str(Feather.Type.white) : chicken_coop[var_to_str(Feather.Type.white)],
			var_to_str(Feather.Type.rainbow) : chicken_coop[var_to_str(Feather.Type.rainbow)]
		}
	}
	var file = FileAccess.open(playerSaveFile, FileAccess.WRITE)
	file.store_string(JSON.stringify(saveData))

func loadPlayerValues(player : Player):
	if not playerSaveFileExists():
		return
	var file = FileAccess.open(playerSaveFile, FileAccess.READ)
	var savedData = JSON.parse_string(file.get_as_text())
	player.health = savedData["player"]["health"]
	player.points = savedData["player"]["points"]
	player.feathers = savedData["player"]["feathers"]
	player.has_double_jump = bool(savedData["player"]["has_double_jump"])
	player.has_wall_slide = bool(savedData["player"]["has_wall_slide"])
	player.has_wall_jump = bool(savedData["player"]["has_wall_jump"])
	player.has_dash = bool(savedData["player"]["has_wall_slide"])

func loadChickenCoop():
	if not playerSaveFileExists():
		return
	var file = FileAccess.open(playerSaveFile, FileAccess.READ)
	var savedData = JSON.parse_string(file.get_as_text())
	var chicken_coop_ = savedData["chicken_coop"]

	chicken_coop[var_to_str(Feather.Type.grey)] = chicken_coop_[var_to_str(Feather.Type.grey)]
	chicken_coop[var_to_str(Feather.Type.brown)] = chicken_coop_[var_to_str(Feather.Type.brown)]
	chicken_coop[var_to_str(Feather.Type.white)] = chicken_coop_[var_to_str(Feather.Type.white)]
	chicken_coop[var_to_str(Feather.Type.rainbow)] = chicken_coop_[var_to_str(Feather.Type.rainbow)]

func playerSaveFileExists():
	return FileAccess.file_exists(playerSaveFile)

func prune():
	if DirAccess.dir_exists_absolute(saveFolder):
		OS.move_to_trash(ProjectSettings.globalize_path(playerSaveFile))
