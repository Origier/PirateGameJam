@tool
class_name Enemy2D

extends CharacterBody2D

# Basic attributes
@export var body_damage := 10
@export var max_health := 100
@export var current_health := 100
@export var armor_rating := 10
@export var affected_by_gravity := true
@export var movement_speed := 4000
@export var jump_speed := -500

# Expected to change each movement - changes the velocity
var last_direction := Vector2(0.0, 0.0)
var last_velocity := Vector2(0.0, 0.0)
var movement_velocity := Vector2(0.0, 0.0)

# Used to keep the jumpers in the air
var jumped = false
var in_motion = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Handling enemy controls
func _process(delta):
	# Providing hints when the correct children are not present
	if Engine.is_editor_hint():
		update_configuration_warnings()
	# Giving control of the enemy to the correct children
	if not Engine.is_editor_hint():
		for node in get_children():
			if node is EnemyAI2D:
				node._perform_ai_tasks(delta)
				find_velocity(node)
				if in_motion:
					apply_move_velocity(delta, node)
		
		# Apply gravity if applicable
		if affected_by_gravity:
			apply_gravity(delta)
		# Move in accordance with velocity
		last_velocity = velocity
		move_and_slide()

# Applies the current movement velocity to the enemy
func apply_move_velocity(delta, ainode):
	var type = ainode.movement_type
	# Catch any jumpers that have landed - they now stop moving
	if type == 3 and jumped and is_on_floor():
		velocity = Vector2(0.0, 0.0)
	# Constant type stays on the ground
	if type == 1:
		velocity.x = movement_velocity.x * delta
	# Flight type moves in its vector of movement
	elif type == 2:
		velocity = movement_velocity * delta
	# Jumping types move in a parabola
	elif type == 3 and not jumped:
		velocity = movement_velocity
		jumped = true

# Will only apply velocity to the enemy if they have changed direction
# Removes the previous direction when the direction changes
# Preserves gravity application
func find_velocity(ainode):
	var direction = ainode.movement_direction
	var type = ainode.movement_type
	
	# Direction has remained unchanged - do nothing, we are still in motion
	if direction == last_direction:
		return
	
	# Direction has now changed to a halt
	if direction.x == 0.0 and direction.y == 0.0:
		# Set the appropriate variables to 0
		in_motion = false
		if not affected_by_gravity:
			velocity = Vector2(0.0, 0.0)
			movement_velocity = Vector2(0.0, 0.0)
		else:
			velocity.x = 0.0
			movement_velocity.x = 0.0
	# Direction has now changed to start a new direction
	else:
		# Constant type movements
		if type == 1 or type == 2:
			in_motion = true
			movement_velocity.x = direction.x * movement_speed
			movement_velocity.y = direction.y * movement_speed
		# Jumping type
		elif type == 3:
			jumped = false
			in_motion = true
			movement_velocity.x = direction.x * jump_speed
			movement_velocity.y = direction.y * jump_speed
		last_direction = direction

# Applies gravity to the body
func apply_gravity(delta):
	velocity.y += gravity * delta

# Function for receiving damage
func take_damage(damage_in):
	var armor_adjusted_damage = adjust_damage(damage_in)
	current_health -= armor_adjusted_damage
	# If the enemy reaches 0 health then they die
	if current_health <= 0:
		queue_free()

# Adjusts damage recieved based on armor rating
# guarantees that at least 1 damage is always returned
func adjust_damage(damage_in):
	var adjusted_damage = damage_in - armor_rating
	if adjusted_damage <= 0:
		adjusted_damage = 1
	return adjusted_damage

# getter function for return the body damage
func get_body_damage():
	return body_damage

func is_enemy_ai(node):
	if node is EnemyAI2D:
		return true
	else:
		return false
	
func _get_configuration_warnings():
	if get_children().any(is_enemy_ai):
		return []
	else:
		return ["An enemy must contain an EnemyAI2D node to control it"]
