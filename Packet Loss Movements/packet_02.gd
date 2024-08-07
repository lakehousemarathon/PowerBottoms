extends CharacterBody2D

const speed = 550
const jump_power = -2000

const acc = 50
const friction = 70

const gravity = 120

const max_jumps = 1
var current_jumps = 1
var canPick = true

const wall_jump_pushback = 700

const wall_slide_gravity = 100
var is_wall_sliding = false

func _physics_process(delta):
	var input_dir: Vector2 = input()
	
	if input_dir != Vector2.ZERO:
		accelerate(input_dir)
		#play_animation()
	else:
		add_friction()
		#play_animation()
	player_movement()
	jump()
	wall_slide(delta)

func input() -> Vector2:
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir = input_dir.normalized()
	return input_dir

func accelerate(direction):
	velocity = velocity.move_toward(speed * direction, acc)
	
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

func player_movement():
	move_and_slide()
	
func jump():
	velocity.y += gravity
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_power
		if is_on_wall() and Input.is_action_pressed("ui_right"):
			velocity.y = jump_power
			velocity.x = -wall_jump_pushback
		if is_on_wall() and Input.is_action_pressed("ui_left"):
			velocity.y = jump_power
			velocity.x = wall_jump_pushback
			
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
		
		
		
		
