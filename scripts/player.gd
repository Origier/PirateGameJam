extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D

# Controls player movement throughout the game
@export var speed := 15000
@export var sprint_speed := 30000
@export var jump_speed := -500

# Values for how hard the player gets pushed back
@export var push_back_force := 500
# Player gets disabled when struck by an enemy
@export var disabled_time = 0.7
var disabled = false
var disabled_timer = 0

# Health values for the player
@export var max_health := 50
var current_health := max_health
# Lockout for taking damage to recently
var damage_received_lockout := false

# Stamina values for the player
@export var max_stamina := 100.0
# These values are per second
@export var stamina_regen_rate := 5.0
@export var stamina_burn_rate := -20.0
var sprinting := false
var current_stamina := max_stamina
var sprinting_lockout = false

# Signal for indicating the player is changing to the shadow
signal controls_toggle

# Signals that the player has perished
signal death

# Effects the speed at which the player falls
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Effects the speed at which the player slows down when disabled
var x_gravity = 500

# Flips when the player presses tab
var controlled := true

# Handles player signals
func _process(_delta):
	# Emits a message to the world that the player is toggling to the shadow
	if (Input.is_action_just_pressed("ToggleShadow")):
		controls_toggle.emit()
	
	#plays animations
	if Input.is_action_pressed("StrafeRight"):
		if Input.is_action_pressed("Jump"):
			_animated_sprite.play("jump_right")
		else:
			_animated_sprite.play("walking_right")
			if Input.is_action_pressed("Sprint"):
				_animated_sprite.speed_scale = 1.5
			else:
				_animated_sprite.speed_scale = 1
	elif Input.is_action_pressed("StrafeLeft"):
		if Input.is_action_pressed("Jump"):
			_animated_sprite.play("jump_left")
		else:
			_animated_sprite.play("walking_left")
			if Input.is_action_pressed("Sprint"):
				_animated_sprite.speed_scale = 1.5
			else:
				_animated_sprite.speed_scale = 1
	else:
		_animated_sprite.play("to_right")
		_animated_sprite.speed_scale = 1


# Handles player movement in the game
func _physics_process(delta):
	# Adding the gravity
	velocity.y += gravity * delta
	# If the player is currently controllable
	if controlled && not disabled:
		control_player(delta)
	# If the player was struck by an enemy then they are disabled temporarily
	elif disabled:
		control_disabled_player(delta)
	# Base case where the player isn't controlled - slow their momentum
	else:
		slow_down_player_x(delta)
	# Finally move the player according to have the velocity has changed
	move_and_slide()
	detect_enemy_collision()
	
# Function to work around RigidBody limitations and detemine if the player hit an enemy 
func detect_enemy_collision():
	# Work around for detecting rigid bodies
	var kc = get_last_slide_collision()
	if (kc != null):
		var node = kc.get_collider()
		if node is Enemy2D:
			take_damage(node.body_damage)
			push_back()

# Function for handling a disabled player
func control_disabled_player(delta):
	disabled_timer += delta
	# Slowing the player down gradually
	slow_down_player_x(delta)
	if disabled_timer >= disabled_time:
		disabled = false

# Main function for controlling player input
func control_player(delta):
	# Handle Jump
	if Input.is_action_just_pressed("Jump") && is_on_floor():
		velocity.y += jump_speed
	
	# Toggles the sprinting state of the player
	if Input.is_action_just_pressed("Sprint") && not sprinting_lockout:
		sprinting = true
	elif Input.is_action_just_released("Sprint"):
		sprinting = false
	
	# Get the input direction
	var direction = Input.get_axis("StrafeLeft", "StrafeRight")
	# Update the stamina based on sprinting status
	update_stamina(delta)
	# Toggle the sprint state if the player runs out of stamina
	# Locking them out from sprinting again for a set time
	if (current_stamina <= 0.0):
		sprinting = false
		sprinting_lockout = true
		$SprintingLockoutTimer.start()
		
	# Modify the players velocity accordingly
	if sprinting:
		velocity.x = direction * sprint_speed * delta
	else:
		velocity.x = direction * speed * delta

# Slows the player down along the x-axis
func slow_down_player_x(delta):
	if velocity.x > 0.0:
		velocity.x -= x_gravity * delta
		if velocity.x < 0.0:
			velocity.x = 0.0
	else:
		velocity.x += x_gravity * delta
		if velocity.x > 0.0:
			velocity.x = 0.0

# Destroy player when they take too much damage
func take_damage(damage_in):
	if not damage_received_lockout:
		current_health -= damage_in
		damage_received_lockout = true
		$DamageReceivedLockoutTimer.start()
		# TODO - Implement the UI changes here to show the player taking damage
		print("Remaining Health: " + String.num_int64(current_health))
		# Delete player
		if (current_health <= 0):
			death.emit()
			queue_free()

# Pushes the player in the opposite direction of their direction of travel
func push_back():
	var new_player_direction = velocity.normalized() * -1
	velocity = new_player_direction * push_back_force
	disabled = true
	disabled_timer = 0

# Toggles the player to no longer have control until activated again
func controls_toggled():
	if controlled:
		controlled = false
	else:
		controlled = true

# Updates the players stamina based on if they are sprinting or not, locking it between 0 - max_stamina
# TODO: Modifiy a UI element to show the players stamina in real time
func update_stamina(delta):
	var delta_stamina = 0
	if sprinting:
		delta_stamina = delta * stamina_burn_rate
	else:
		delta_stamina = delta * stamina_regen_rate
	current_stamina += delta_stamina
	if current_stamina <= 0.0:
		current_stamina = 0.0
	elif current_stamina >= max_stamina:
		current_stamina = max_stamina

# Resets the lockout to allow the player to sprint again
func _on_sprinting_lockout_timer_timeout():
	sprinting_lockout = false

func _on_damage_received_lockout_timer_timeout():
	damage_received_lockout = false
