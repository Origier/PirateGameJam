class_name Enemy2D

extends Area2D

# Basic attributes
@export var body_damage := 1
@export var max_health := 100
@export var current_health := 100
@export var armor_rating := 10

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


func _on_body_entered(body):
	if body is CharacterBody2D:
		body.take_damage(body_damage)
