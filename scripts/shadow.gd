extends Node2D

@onready var _animated_sprite = $AnimatedSprite2D

# Used to determine how much time should pass before updating the path node for the shadow to follow
@export var time_between_path_nodes := 0.1
@export var speed := 400
var time_since_last_path_update = 0
# Maximum number of nodes in the Bezier curve to save on memory
@export var max_curve_nodes := 10

# How the shadow will be positioned relative to the player
# The x_offset will flip its sign when the player moves the opposite direction
@export var x_offset_from_player := -50
@export var y_offset_from_player := -10

# Flips when the player presses tab to bring control to the shadow
var controlled := false

# Used to determine if the player has move an opposite x-direction to control
# which side the shadow appears on
var last_player_x := 0.0
var flipped_x := false

# Player that the shadow will follow - must be added in the level
@export var player : CharacterBody2D = null

# Sets up the shadow to be positioned near the player
func _ready():
	$ShadowPath2D/PathFollow2D.loop = false
	if player != null:
		add_player_offset_position()
		last_player_x = player.position.x

# Determines how the shadow will move, either following the player or being controlled
func _process(delta):
	if controlled:
		control_shadow(delta)
	else:
		if player != null:
			# Flips the shadows position relative to player movement
			if (player.position.x < last_player_x && not flipped_x):
				x_offset_from_player *= -1
				flipped_x = true
			elif (player.position.x > last_player_x && flipped_x):
				x_offset_from_player *= -1
				flipped_x = false
			last_player_x = player.position.x
			update_path(delta)
			move_along_path(delta)
			
	#plays animations
	if Input.is_action_pressed("StrafeRight"):
			_animated_sprite.play("hover_side")
			if Input.is_action_pressed("Sprint"):
				_animated_sprite.speed_scale = 1.5
			else:
				_animated_sprite.speed_scale = 1
	elif Input.is_action_pressed("StrafeLeft"):
			_animated_sprite.play("walk_side")
			if Input.is_action_pressed("Sprint"):
				_animated_sprite.speed_scale = 1.5
			else:
				_animated_sprite.speed_scale = 1
	elif Input.is_action_pressed("Up"):
			_animated_sprite.play("hover_side")
			if Input.is_action_pressed("Sprint"):
				_animated_sprite.speed_scale = 1.5
			else:
				_animated_sprite.speed_scale = 1
	elif Input.is_action_pressed("Down"):
			_animated_sprite.play("walk_side")
			if Input.is_action_pressed("Sprint"):
				_animated_sprite.speed_scale = 1.5
			else:
				_animated_sprite.speed_scale = 1
	else:
		_animated_sprite.stop()
		_animated_sprite.speed_scale = 1

# Implements player controls for the shadow
func control_shadow(delta):
	var direction = Input.get_vector("StrafeLeft", "StrafeRight", "Up", "Down")
	position += direction * speed * delta

# Updates the shadows path for following the player
func update_path(delta):
	time_since_last_path_update += delta
	# Clearing the curve cache on the programmed variable
	if $ShadowPath2D.get_curve().point_count >= max_curve_nodes:
		reset_curve()
	
	if time_since_last_path_update >= time_between_path_nodes && player != null:
		# Applies the offsets directly to the shadows path
		add_player_offset_position()
		time_since_last_path_update = 0

func add_player_offset_position():
	$ShadowPath2D.get_curve().add_point(Vector2(player.position.x + x_offset_from_player, player.position.y + y_offset_from_player))
	
# Pushes the shadow along its path to the player
func move_along_path(delta):
	$ShadowPath2D/PathFollow2D.progress += delta * speed
	position = $ShadowPath2D/PathFollow2D.position

# Called on a set cadence to clear the memory for the curve 2d
func reset_curve():
	# clears the cache
	$ShadowPath2D.get_curve().clear_points()
	$ShadowPath2D/PathFollow2D.progress = 0
	# Adds starting positions
	$ShadowPath2D.get_curve().add_point(position)
	add_player_offset_position()
	time_since_last_path_update = 0

# Clears curve cache and toggles player controls for shadow
func controls_toggled():
	if controlled:
		controlled = false
		# Readding the players position to continue following
		$ShadowPath2D/PathFollow2D.progress = 0
		$ShadowPath2D.get_curve().add_point(position)
		add_player_offset_position()
	else:
		controlled = true
		# Remove all points from the curve to start again when the player flips control again
		$ShadowPath2D.get_curve().clear_points()
		
