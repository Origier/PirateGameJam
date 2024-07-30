extends Control


signal start_game()

func _on_play_pressed():
	# change scene to the game file
	get_tree().change_scene_to_file("res://scenes/test_scene.tscn")
	start_game.emit()
	hide()

func _on_options_pressed():
	# change scene to options 
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")


func _on_quit_pressed():
	# quit the game
	get_tree().quit()
