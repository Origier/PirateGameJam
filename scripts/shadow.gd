extends Node2D

# Used to determine how much time should pass before updating the path node for the shadow to follow
@export var time_between_path_nodes := 0.1
@export var speed := 400
# How the shadow will be positioned relative to the player
# The x_offset will flip its sign when the player moves the opposite direction
@export var x_offset_from_player := -50
@export var y_offset_from_player := -10
var flipped_x := false

var last_player_x := 0.0
var time_since_last_path_update = 0


# Leaves the player open for the developer to add in production
@export var player : CharacterBody2D = null

func _ready():
	$ShadowPath2D/PathFollow2D.loop = false
	if player != null:
		$ShadowPath2D.get_curve().add_point(player.position)
		last_player_x = player.position.x

func _process(delta):
	if (player.position.x < last_player_x && not flipped_x):
		x_offset_from_player *= -1
		flipped_x = true
	elif (player.position.x > last_player_x && flipped_x):
		x_offset_from_player *= -1
		flipped_x = false
	last_player_x = player.position.x
	update_path(delta)
	move_along_path(delta)
	
# Updates the shadows path for following the player
func update_path(delta):
	time_since_last_path_update += delta
	if time_since_last_path_update >= time_between_path_nodes && player != null:
		# Applies the offsets directly to the shadows path
		$ShadowPath2D.get_curve().add_point(Vector2(player.position.x + x_offset_from_player, player.position.y + y_offset_from_player))
		time_since_last_path_update = 0

# Pushes the shadow along its path to the player
func move_along_path(delta):
	$ShadowPath2D/PathFollow2D.progress += delta * speed
	position = $ShadowPath2D/PathFollow2D.position
