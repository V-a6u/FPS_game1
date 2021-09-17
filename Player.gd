extends KinematicBody

#stats
var curHp : int = 10
var maxHp : int = 10
var ammo : int = 15
var score : int = 0

# physics
var moveSpeed : float = 5.0
var jumpForce : float = 5.0
var gravity : float = 10.0

#cam look
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
export var mouseLookSensitivity : float = 0.3
export var joyStickLookSensitivity : float = 2

#vector data
var vel : Vector3 = Vector3()
var mouseDelta : Vector2 = Vector2()
var joyStickDelta : Vector2 = Vector2()

# player components
onready var camera = get_node("Camera")
onready var muzzle = get_node("Camera/GunModel/Muzzle")
onready var bulletScene = preload("res://Bullet.tscn") 

onready var ui : Node = get_node("/root/MainScene/CanvasLayer/UI")

func _ready():
	#hide and lock the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# set the UI
	ui.update_health_bar(curHp, maxHp)
	ui.update_ammo_text(ammo)
	ui.update_score_text(score)
	
#look around
func _input(event):
	
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
		
		
func _process (delta):	
	# rotate camera along X axis
	camera.rotation_degrees -= Vector3(rad2deg(mouseDelta.y), 0, 0) * mouseLookSensitivity * delta
	
	# clamp the vertical camera rotation
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
  
	# rotate player along Y axis
	rotation_degrees -= Vector3(0, rad2deg(mouseDelta.x), 0) * mouseLookSensitivity * delta
  
	# reset the mouse delta vector
	mouseDelta = Vector2()
	
	#joystick look around
	camera.rotate_x(Input.get_action_strength("look_up") * joyStickLookSensitivity * delta)
	camera.rotate_x(Input.get_action_strength("look_down") * joyStickLookSensitivity * delta * -1)
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	rotate_y(Input.get_action_strength("look_left") * joyStickLookSensitivity * delta)
	rotate_y(Input.get_action_strength("look_right") * joyStickLookSensitivity * delta * -1)
	
	#if clicked shoot
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
		
func shoot():
	if(ammo > 0):
		var bullet = bulletScene.instance()
		get_node("/root/MainScene").add_child(bullet)
		
		bullet.global_transform = muzzle.global_transform
		bullet.scale = Vector3.ONE
		
		ammo -= 1
	
	ui.update_ammo_text(ammo)
	
#player movement
func _physics_process(delta):
	vel.x = 0
	vel.z = 0
	
	var input = Vector2()
	
	# movement inputs
	if Input.is_action_pressed("move_forward"):
		input.y -= 1
	if Input.is_action_pressed("move_backward"):
		input.y += 1
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1
	input = input.normalized()
	
	#get forward and right positions
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	
	#set the velocity
	vel.z = (forward * input.y + right * input.x).z * moveSpeed
	vel.x = (forward * input.y + right * input.x).x * moveSpeed
	
	#gravity
	vel.y -= gravity * delta
	
	#move the player
	vel = move_and_slide(vel, Vector3.UP)
	
	#jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vel.y = jumpForce
		
#when enemy does damage
func take_damage(damage):
	curHp -= damage
	ui.update_health_bar(curHp, maxHp)
	
	if curHp <= 0:
		die()
	

func die():
	get_tree().reload_current_scene()

#when we kill an enemy
func add_score(amount):
	score += amount
	ui.update_score_text(score)

#pickables
#health
func add_health(amount):
	curHp = clamp(curHp + amount, 0, maxHp)
	ui.update_health_bar(curHp, maxHp)

#add ammo
func add_ammo(amount):
	ammo += amount
	ui.update_ammo_text(ammo)
	


