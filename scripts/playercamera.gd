extends Camera2D

@export var player : CharacterBody2D = null
@export var shadow : Node2D = null

var follow_player := true
var player_dead := false

# Sets the position to the player
func _ready():
	if player != null && follow_player:
		position = player.position
	elif shadow != null:
		position = shadow.position

# Handles following the player
func _process(_delta):
	# Keeps the camera still when the player has died
	if not player_dead:
		if player != null && follow_player:
			position = player.position
		elif shadow != null && not follow_player:
			position = shadow.position

# Toggles the camera to look at the shadow
func controls_toggled():
	if follow_player:
		follow_player = false
	else:
		follow_player = true

# Called when the player has died
func player_died():
	player_dead = true
