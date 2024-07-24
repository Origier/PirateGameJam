extends CharacterBody2D

# Controls player movement throughout the game
@export var speed := 20000
@export var sprint_speed := 30000
@export var jump_speed := -550

# Signal for indicating the player is changing to the shadow
signal controls_toggle

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

# Toggles the player to no longer have control until activated again
func controls_toggled():
	if controlled:
		controlled = false
		velocity.x = 0.0
	else:
		controlled = true
