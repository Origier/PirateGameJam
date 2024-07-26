extends Camera2D

@export var player : CharacterBody2D = null
@export var shadow : Node2D = null

var follow_player := true

func _ready():
	if player != null && follow_player:
		position = player.position
	elif shadow != null:
		position = shadow.position

func _process(_delta):
	if player != null && follow_player:
		position = player.position
	elif shadow != null:
		position = shadow.position

func controls_toggled():
	if follow_player:
		follow_player = false
	else:
		follow_player = true
