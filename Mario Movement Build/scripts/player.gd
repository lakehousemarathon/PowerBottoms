extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

const speed = 300
const jump_power = -1500

const acc = 50
const friction = 70

const gravity = 80

const max_jumps = 1
var current_jumps = 1
var canPick = true

const wall_jump_pushback = 700

const wall_slide_gravity = 100
var is_wall_sliding = false

func _ready():
	#each player needs a unique identifier that aligns with the game manager
	#this unique identifier will be based on the player set name, so no duplicate names!
	#Will need to fix the duplicate names issue at some point; not worrying about that now.
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())	
	pass
		
func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		var input_dir: Vector2 = input()
	
		velocity.y += gravity
	
		if input_dir.x > 0:
			animated_sprite.flip_h = false
		elif input_dir.x < 0:
			animated_sprite.flip_h = true
	
		if is_on_floor():
			if input_dir == Vector2.ZERO:
				animated_sprite.play("idle")
			elif input_dir.x != 0:
				animated_sprite.play("walk")
			elif input_dir.y < 0:
				animated_sprite.play("crouch")
		elif is_wall_sliding:
			animated_sprite.play("wall_slide")
			animated_sprite.flip_h = !animated_sprite.flip_h 
		else:
			if input_dir.y < 0:
				animated_sprite.play("pound")
			else:
				animated_sprite.play("jump")
		if input_dir != Vector2.ZERO:
			accelerate(input_dir)
		else:
			add_friction()
			
		move_and_slide()
		jump(input_dir)
		pound(input_dir)
		wall_slide(delta)

func input() -> Vector2:
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.y = Input.get_axis("ui_down", "ui_up")
	input_dir = input_dir.normalized()
	return input_dir

func accelerate(direction):
	velocity = velocity.move_toward(speed * direction, acc)
	
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)
	
func jump(input_dir):
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_power
		if is_wall_sliding:
			velocity.y = jump_power
			velocity.x = wall_jump_pushback * input_dir.x * -1

func pound(input_dir):
	if Input.is_action_just_pressed("ui_down"):
		if !is_wall_sliding:
			animated_sprite.play("pound")
			
func wall_slide(delta):
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
		
	if is_wall_sliding:
		velocity.y += (wall_slide_gravity * delta)
		velocity.y = min(velocity.y, wall_slide_gravity)
		
		

