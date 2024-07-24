extends Node2D

func _on_player_controls_toggle():
	get_tree().call_group("player", "controls_toggled")

func _on_player_death():
	get_tree().call_group("player", "player_died")


func _process(_delta):
	
	# Testable functions - uncomment the test to run it
	if Input.is_action_just_pressed("TestAction"):
		_test_damage_to_player(10)

func _test_damage_to_player(damage):
	get_tree().call_group("player", "take_damage", damage)


