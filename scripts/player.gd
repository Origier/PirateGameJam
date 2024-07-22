extends CharacterBody2D

@export var speed := 20000
@export var jump_speed := -550
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

	
func _physics_process(delta):
	# Adding the gravity
	velocity.y += gravity * delta
	
	# Handle Jump
	if Input.is_action_just_pressed("Jump") && is_on_floor():
		velocity.y += jump_speed
	
	# Get the input direction
	var direction = Input.get_axis("StrafeLeft", "StrafeRight")
	velocity.x = direction * speed * delta
	
	move_and_slide()
