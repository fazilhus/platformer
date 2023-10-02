extends CharacterBody2D

const SPEED = 150.0
const ACCELERATION = 1000.0
const FRICTION = 1200.0
const JUMP_VELOCITY = -300.0
const MAX_HEALTH = 10

var health

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim_player = get_node("AnimationPlayer")
@onready var anim_sprite_2d = get_node("AnimatedSprite2D")


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
	
	move_and_slide()

func handle_jump():
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			self.velocity.y = JUMP_VELOCITY
	else:
		if Input.is_action_just_released("jump") and self.velocity.y < JUMP_VELOCITY / 2:
			self.velocity.y = JUMP_VELOCITY / 2


func apply_gravity(delta):
	if not is_on_floor():
		self.velocity.y += gravity * delta


func handle_horizontal_acceleration(delta, input_axis):
	if input_axis:
		self.velocity.x = move_toward(self.velocity.x, SPEED * input_axis, ACCELERATION * delta)


func apply_friction(delta, input_axis):
	if not input_axis and is_on_floor():
		self.velocity.x = move_toward(self.velocity.x, 0, FRICTION * delta)
