class_name Enemy2D

extends Area2D

# Basic attributes
@export var body_damage := 10
@export var max_health := 100
@export var current_health := 100
@export var armor_rating := 10

# Default values for what will be considered a wall vs the floor
@export var min_floor_angle := -130
@export var max_floor_angle := 130

# Gravity for enemies
var gravity_applied = ProjectSettings.get_setting("physics/2d/default_gravity") * 0.01

# Custom velocity to move the enemy like a player
var velocity = Vector2(0.0, 0.0)

func _physics_process(delta):
	velocity.y += gravity_applied * delta
	move_along_velocity()
	
func move_along_velocity():
	if $ShapeCast2D.is_colliding():
		for coll in $ShapeCast2D._get_collision_result():
			if coll["collider"] is StaticBody2D:
				var body_angle = rad_to_deg(coll["normal"].angle())
				var coll_normal = coll["normal"]
				# Colliding with flooring / ceiling
				if (body_angle >= min_floor_angle && body_angle <= max_floor_angle && velocity.y > 0.0):
					# If there is a x velocity in the same direction as the floor
					# Move up the floor relative to the normals orthogonal vector
					if (coll_normal.x > 0 && velocity.x < 0) || (coll_normal.x < 0 && velocity.x > 0):
						var ortho = coll_normal.orthogonal()
						print(ortho)
						var new_x = ortho.x * velocity.x * -1
						var new_y = ortho.y * velocity.x * -1
						velocity = Vector2(new_x, new_y)
						print(velocity)
					else:
						velocity.y = 0.0
				# Otherwise colliding with a wall
				# TODO: fix the velocity adjustment along the x-axis
				else:
					print("hit wall")
					velocity.x = 0.0
	position += velocity

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

# Handling entering different bodies
func _on_body_entered(body):
	if body is CharacterBody2D:
		body.take_damage(body_damage)
		body.push_back()
	# Determine floor vs wall
	elif body is StaticBody2D:
		velocity.y = 0.0
