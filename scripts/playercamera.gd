extends Camera2D

@export var player : CharacterBody2D = null

func _ready():
	if player != null:
		position = player.position

func _process(_delta):
	if player != null:
		position = player.position
