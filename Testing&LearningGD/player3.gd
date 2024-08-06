extends CharacterBody2D

const speed = 550
const jump_power = -2000

const acc = 50
const friction = 70

const gravity = 120

const max_jumps = 2
var current_jumps = 1
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

func input() -> Vector2:
	var input_dir = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_A):
		move_local_x(-5)
	if Input.is_key_pressed(KEY_D):
		move_local_x(5)
	if Input.is_key_pressed(KEY_W):
		move_local_y(-5)
	if Input.is_key_pressed(KEY_S):
		move_local_y(5)
	return input_dir

func accelerate(direction):
	velocity = velocity.move_toward(speed * direction, acc)
	
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

func player_movement():
	move_and_slide()
	
func jump():
	if Input.is_key_pressed(KEY_W):
		if current_jumps < max_jumps:
			velocity.y = jump_power
			current_jumps = current_jumps + 1
	else:
		velocity.y += gravity
	
	if is_on_floor():
		current_jumps = 1
