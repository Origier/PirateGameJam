extends CharacterBody2D

# Controls player movement throughout the game
@export var speed := 20000
@export var sprint_speed := 30000
@export var jump_speed := -550

# Health values for the player
@export var max_health := 50
var current_health := max_health

# Signal for indicating the player is changing to the shadow
signal controls_toggle

# Signals that the player has perished
signal death

# Effects the speed at which the player falls
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Flips when the player presses tab
var controlled := true

# Handles player signals
func _process(_delta):
	# Emits a message to the world that the player is toggling to the shadow
	if (Input.is_action_just_pressed("ToggleShadow")):
		controls_toggle.emit()

# Handles player controlls
func _physics_process(delta):
	# Adding the gravity
	velocity.y += gravity * delta
	if controlled:
		# Handle Jump
		if Input.is_action_just_pressed("Jump") && is_on_floor():
			velocity.y += jump_speed
			
		# Get the input direction
		var direction = Input.get_axis("StrafeLeft", "StrafeRight")
		if Input.is_action_pressed("Sprint"):
			velocity.x = direction * sprint_speed * delta
		else:
			velocity.x = direction * speed * delta
	
	move_and_slide()

# Destroy player when they take too much damage
func take_damage(damage_in):
	current_health -= damage_in
	# TODO - Implement the UI changes here to show the player taking damage
	print("Remaining Health: " + String.num_int64(current_health))
	# Delete player
	if (current_health <= 0):
		death.emit()
		queue_free()

# Toggles the player to no longer have control until activated again
func controls_toggled():
	if controlled:
		controlled = false
		velocity.x = 0.0
	else:
		controlled = true
