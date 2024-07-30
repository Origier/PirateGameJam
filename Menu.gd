extends Control


signal start_game()

func _on_play_pressed():
	# change scene to the game file
	get_tree().change_scene_to_file("res://scenes/Level_1.tscn")
	start_game.emit()
	hide()

func _on_settings_pressed():
	# change scene to options 
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")


func _on_quit_pressed():
	# quit the game
	get_tree().quit()
