extends CharacterBody2D

const SPEED = 80.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var player = get_node("../../Player/Player")
@onready var anim_sprite = get_node("AnimationPlayer")
var chase = false

func _ready():
	anim_sprite.play("Idle")

func _physics_process(delta):
	if not is_on_floor():
		self.velocity.y += gravity * delta
	
	if chase:
		var dir = (player.position - self.position).normalized()
		if dir.x > 0:
			anim_sprite.flip_h = false
		else:
			anim_sprite.flip_h = true
			
		self.velocity.x = dir.x * SPEED
		if anim_sprite.animation != "Hit":
			anim_sprite.play("Walk")
	else:
		self.velocity.x = 0
		if anim_sprite.animation != "Hit":
			anim_sprite.play("Idle")
	
	move_and_slide()


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		chase = true


func _on_area_2d_body_exited(body):
	if body.name == "Player":
		chase = false


func _on_attack_vision_body_entered(body):
	if body.name == "Player":
		anim_sprite.play("Hit")
		await anim_sprite.animation_finished
		anim_sprite.play("Idle")
