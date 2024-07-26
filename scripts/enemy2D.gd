@tool
class_name Enemy2D

extends RigidBody2D

# Basic attributes
@export var body_damage := 10
@export var max_health := 100
@export var current_health := 100
@export var armor_rating := 10

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

# Applies a force to the enemy as an impulse or constant - default impulse
func _on_enemy_ai_2d_force(force_vector):
	apply_impulse(force_vector)

func _on_enemy_ai_2d_constant_move(move_vector):
	var trans = self.get_transform()
	trans.origin.x += move_vector.x
	trans.origin.y += move_vector.y
	self.set_transform(trans)
