extends KinematicBody

export (float) var speed = 100
export (Vector2) var mouse_sensitivity = Vector2(0.3,0.1)

const floor_normal = Vector3(0,1,0)
const horizontal_invert = false
const GRAVITY_FORCE = Vector3(0,-10,0)
const MAX_SLOPE_ANGLE = 30
const JUMP_SPEED = 300

var mouse_last_pos = Vector2()
var velocity = Vector3()
var movement = Vector3()
var gravity = Vector3()

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	_movement(delta)
	_handle_camera(delta)

func _handle_camera(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_move = mouse_last_pos - mouse_pos
	
	if horizontal_invert:
		mouse_move *= -1
	
	rotate_y(mouse_move.x * delta * mouse_sensitivity.x)
	mouse_last_pos = mouse_pos
	
	$camera.rotate_z(mouse_move.y * delta * mouse_sensitivity.y)
	#$camera.rotation.y = clamp($camera.rotation.y, -2, -0.8)
	$camera.rotation.x = clamp($camera.rotation.x, -0.9, 0.7) #odd
	
	$cam2.rotate_z(mouse_move.y * delta * mouse_sensitivity.y)
	$cam2.rotation.z = clamp($cam2.rotation.z, -0.4, 0.25)

func _movement(delta):
	gravity += GRAVITY_FORCE
	
	if is_on_floor():
		movement.x = Input.is_action_pressed("player_up") - Input.is_action_pressed("player_down")
		movement.z = Input.is_action_pressed("player_right") - Input.is_action_pressed("player_left")
		movement = movement.normalized()
	
	velocity = ((movement * speed) + gravity) * delta
	
	move_and_slide(get_transform().basis * velocity, floor_normal)
	
	if is_on_floor():
		gravity = Vector3()
		
		if Input.is_action_just_pressed("player_jump"):
			gravity += Vector3(0,JUMP_SPEED,0)
	
	if is_on_ceiling():
		velocity.y = 0
		gravity.y = 0