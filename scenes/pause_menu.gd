extends Control
@onready var main = $"../../"





func _on_resume_pressed():
	main.pauseMenu()


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")


func _on_quit_pressed():
	get_tree().quit()
