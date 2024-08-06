extends CharacterBody2D

@export var SPEED : int = 150
@export var JUMP_FORCE : int = 255
@export var GRAVITY : int = 900




func _player_process(delta):
	
	
	var direction = Input.get_axis("left", "Right")
	
	if direction:
		
		velocity.x = direction * SPEED
	
	else:
		
		velocity.x = 0
	
	#Rotate
	
	if direction == 1:
		$AnimatedSprite2D.flip_h = false
	elif direction == -1:
		$AnimatedSprite2D.flip_h = true
	
	# Gravity
	
	if not is_on_floor():
		
		velocity.y+= GRAVITY * delta
	
	
	
	move_and_slide()
