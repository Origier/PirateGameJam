extends Node2D

func _on_player_controls_toggle():
	get_tree().call_group("player", "controls_toggled")
