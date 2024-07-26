class_name EnemyAI2D

extends Node2D

# Controllable parameters to dictate how the AI will act
# Constant: Type that cannot jump and cannot move off the ground - only moves along the x-axis
# Flight: Does not obey gravity, can move along the x and y-axis
# Bouncing: Moves via impluses applied in a jumping manner
@export_enum("Constant:1", "Flight:2", "Bouncing:3") var movement_type : int = 1

# Aggressive: Actively seeks the player if they can be found
# Cowardly: Actively runs away from the player if they can be found
# Passive: Simply wanders aimlessly - not caring about the player
@export_enum("Aggressive:1", "Cowardly:2", "Passive:3") var aggression : int = 1

# Movement parameters
@export var movement_speed := 400
@export var jump_speed := -50
@export var time_between_moves := 1
@export var max_constant_move_time := 5
@export var y_bounce_max := 0.75
@export var y_bounce_min := 0.45
@export var x_bounce_max := 0.75
@export var x_bounce_min := 0.45
# Default directions of movement - used to apply constant forces
var movement_direction : Vector2 = Vector2(0.0, 0.0)
# Flag for bypassing randomization - indicating the enemy is currently in motion
var constant_motion := false
var move_time := 0.0
var time_last_move := 0.0

# Movement signals
signal force(force_vector)
signal constant_move(move_vector)

# Player parameters
@export var player_detection_radius := 100
var player_target = null

# Base function that should be used by the enemy script to call the AI to perform tasks
func _perform_ai_tasks(delta):
	attempt_target_player()
	determine_move(delta)

# Trys to find the player within the given radius to target them
# TODO: Find the player based on the detection radius
func attempt_target_player():
	pass

# Moves the enemy either towards or away from the player depending
# on the to_player flag [default = true]
# TODO: Implement movement towards and away from player
func move_toward_player(delta, to_player := true):
	pass

# Determines a direction for the enemy to move in
# Will move towards player if given the flag
# Default chooses a random direction
# TODO: Implement towards the player
func determine_direction_of_travel(to_player := false):
	# Move randomly if not towards the player
	if not to_player:
		# Constant move type - pick a direciton along the x-axis
		if movement_type == 1:
			movement_direction.x = randi_range(-1, 1)
			movement_direction.y = 0.0
		# Flight move type - pick a directional vector to travel in
		elif movement_type == 2:
			movement_direction.x = randf_range(-1.0, 1.0)
			movement_direction.y = randf_range(-1.0, 1.0)
			# Make the distance equal to 1
			movement_direction = movement_direction.normalized()
			print(movement_direction)
		# Bouncing move type - pick a x direction and then a y direction set to a threshold
		elif movement_type == 3:
			# finding a random sign for the x direction
			var movement_x_sign = randi_range(1, 10)
			if movement_x_sign % 2 == 0:
				movement_x_sign = -1
			else:
				movement_x_sign = 1
			# Calculating the normalized vector of movement as a "bounce"
			movement_direction.x = randf_range(x_bounce_min * movement_x_sign, x_bounce_max * movement_x_sign)
			movement_direction.y = randf_range(y_bounce_min, y_bounce_max)
			movement_direction = movement_direction.normalized()
			
# Moves in a random direction regardless of where the player may be
# TODO: Implement other movemnt types
func move_randomly(delta):
	# Constant and Flight move types
	if movement_type == 1 or movement_type == 2:
		print(movement_direction * movement_speed)
		constant_move.emit(movement_direction * movement_speed * delta)
		constant_motion = true
	elif movement_type == 3:
		force.emit(movement_direction * jump_speed)

# Moves the enemy according to their AI
func move(delta):
	# Aggressive enemy
	if aggression == 1 and player_target != null:
		move_toward_player(delta)
	# Cowardly enemy
	elif aggression == 2 and player_target != null:
		move_toward_player(delta, false)
	# Passive enemies or enemies without a target
	else:
		move_randomly(delta)

# Determines if it is time to move and how to move
# Passive means the enemy will always move randomly - this is also the default behavior with no player
# Aggressive means the enemy will move towards the player if it can target it
# Cowardly means the enemy will move away from the player if it can target it
func determine_move(delta):
	if constant_motion:
		move(delta)
		move_time += delta
		# Reset constant move time when it goes beyond the bounds - end the movement
		if move_time >= max_constant_move_time:
			constant_motion = false
			move_time = 0.0
	# Do nothing if not enough time has elapsed since last move and not currently in_motion
	elif time_last_move <= time_between_moves:
		time_last_move += delta
	# If not in motion then reset the timer here and start moving
	else:
		determine_direction_of_travel()
		time_last_move = 0
		move(delta)
	
