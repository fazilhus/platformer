extends CharacterBody2D

@export var movement_data : PlayerMovementData
@export var MAX_HEALTH = 10

var health
var air_jump

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim_player = $AnimationPlayer
@onready var anim_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer


func _ready():
	health = MAX_HEALTH
	air_jump = false


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
	handle_wall_jump()
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
	if is_on_floor(): air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			self.velocity.y = movement_data.jump_velocity
	if not is_on_floor():
		if Input.is_action_just_released("jump") and self.velocity.y < movement_data.jump_velocity / 2:
			self.velocity.y = movement_data.jump_velocity / 2
			
		if Input.is_action_just_pressed("jump") and air_jump:
			self.velocity.y = movement_data.air_jump_velocity
			air_jump = false


func handle_wall_jump():
	if not is_on_wall() or is_on_floor(): return
	
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("move_left") and wall_normal == Vector2.LEFT or Input.is_action_just_pressed("move_right") and wall_normal == Vector2.RIGHT:
		self.velocity.x = movement_data.speed * wall_normal.x
		self.velocity.y = movement_data.wall_jump_velocity


func apply_gravity(delta):
	if not is_on_floor():
		self.velocity.y += gravity * movement_data.gravity_scale * delta


func handle_horizontal_acceleration(delta, input_axis):
	if input_axis:
		var target = movement_data.speed * input_axis
		var acceleration = movement_data.acceleration * delta
		if not is_on_floor():
			acceleration *= movement_data.air_accel_scale
		self.velocity.x = move_toward(self.velocity.x, target, acceleration)


func apply_friction(delta, input_axis):
	if not input_axis:
		if is_on_floor():
			self.velocity.x = move_toward(self.velocity.x, 0, movement_data.friction * delta)
		else:
			self.velocity.x = move_toward(self.velocity.x, 0, movement_data.air_resistance * delta)
