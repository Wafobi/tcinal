extends Node2D
var screen_size # Size of the game window.

var player : Player


func _ready():
	screen_size = get_viewport_rect().size	
	player = $TileMap/player
	player.setupDone.connect(setup)

func setup():
	print("player ready")
	player.show()
	player.active = true

func _process(delta):
	pass
