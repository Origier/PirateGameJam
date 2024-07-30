extends Node2D

@onready var pause_menu = $Player/PauseMenu
var paused = false

func _on_player_controls_toggle():
	get_tree().call_group("player", "controls_toggled")

func _process(_delta):
	if Input.is_action_just_pressed("Pause"):
		pauseMenu()
		
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	paused = !paused
