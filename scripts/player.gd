extends CharacterBody2D

@export var movement_data : PlayerMovementData
@export var MAX_HEALTH = 10

var health

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim_player = $AnimationPlayer
@onready var anim_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer


func _ready():
	health = MAX_HEALTH


func _process(delta):
	var dir = Input.get_axis("move_left", "move_right")
	handle_anim(dir)


func handle_anim(input_axis):
	if input_axis == 0:
		anim_player.play("Idle")
	else:
		anim_sprite_2d.flip_h = input_axis < 0
		anim_player.play("Run")
		
	if not is_on_floor():
		anim_player.play("Jump")


func _physics_process(delta):
	# Handle Jump.
	handle_jump()
	apply_gravity(delta)

	var dir = Input.get_axis("move_left", "move_right")
	
	handle_horizontal_acceleration(delta, dir)
	apply_friction(delta, dir)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	if was_on_floor and not is_on_floor() and self.velocity.y >= 0:
		coyote_jump_timer.start()

func handle_jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			self.velocity.y = movement_data.jump_velocity
	if not is_on_floor():
		if Input.is_action_just_released("jump") and self.velocity.y < movement_data.jump_velocity / 2:
			self.velocity.y = movement_data.jump_velocity / 2


func apply_gravity(delta):
	if not is_on_floor():
		self.velocity.y += gravity * movement_data.gravity_scale * delta


func handle_horizontal_acceleration(delta, input_axis):
	if input_axis:
		self.velocity.x = move_toward(self.velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)


func apply_friction(delta, input_axis):
	if not input_axis:
		if is_on_floor():
			self.velocity.x = move_toward(self.velocity.x, 0, movement_data.friction * delta)
		else:
			self.velocity.x = move_toward(self.velocity.x, 0, movement_data.air_resistance * delta)
