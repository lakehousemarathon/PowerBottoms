extends RigidBody2D

var picked = false
# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if picked:
		self.position = get_node("../Player/Marker2D").global_position
		self.collision_layer = 0
		self.collision_mask = 0
	else:
		self.collision_layer = 1
		self.collision_mask = 1
		
func _input(event):
	if Input.is_action_pressed("ui_pick"):
		var bodies = $Area2D.get_overlapping_bodies()
		for body in bodies:
			if body.name == "Player" and get_node("../Player").canPick == true:
				picked = true
				get_node("../Player").canPick = false
	if Input.is_action_just_released("ui_pick") and picked:
		self.collision_layer = 1
		self.collision_mask = 1
		if get_node("../Player").animated_sprite.flip_h == false:
			apply_impulse(Vector2(300, -200), Vector2())
		else:
			apply_impulse(Vector2(-300,-200), Vector2())
		picked = false
		get_node("../Player").canPick = true
