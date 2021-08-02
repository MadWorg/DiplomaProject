extends KinematicBody2D

const pearl = preload("res://Hazards/Pearl.tscn")

const GRAVITY = 600
const UP = Vector2(0,-1)
const ATTACK_MAX = 3


var step = 0
var radius = 10
var ready = true
var motion = Vector2(0,0)
var in_air = false
var immune = false
var playerRef = null
var pearlHp = 20

var _idle_count = 0
var _shell_damage = 0
var _state_machine


var test = true

export var shell_threshold = 4
export var spawn_point_count = 4
export var shoot_timer_seconds = 5
export var arc_points = Vector2(-180, -90)

"""
	- Ground slam attack
	- Different bullet patters

"""

func _ready(): 

	$Pearl/PearlHitbox.disabled = true
	$InsideClam/ClamInterior.disabled = true
	$OpenShape.disabled = true
	$ClosedShape.disabled = false
	_state_machine = $AnimationTree.get("parameters/playback")
	
	step = abs(arc_points.x - arc_points.y) / spawn_point_count

	for i in range(spawn_point_count):
		var spawn_point = Node2D.new()
		var pos = Vector2(radius, 0).rotated(deg2rad(arc_points.x + (step * i+1)))
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		$FiringPoint.add_child(spawn_point)
		

func _physics_process(delta):

	apply_gravity(delta)
	move_and_slide(motion, UP)
	
		
func apply_gravity(delta):
	
	if is_on_ceiling():
		motion.y -= 1
	elif is_on_floor():
		motion.y += GRAVITY * delta
		in_air = false
		#print("The island rumbles as the Grand Clam lands!")
	else:
		motion.y += GRAVITY * delta
		in_air = true
		
		
func jump():
	if is_on_floor():
		motion.y -= 400
		


func shoot():
	
	ready = false	
	for sp in $FiringPoint.get_children():
		var bullet = pearl.instance()
		get_tree().root.add_child(bullet)
		bullet.position = sp.global_position
		bullet.rotation = sp.global_rotation


func hurt(_enemy_pos : Vector2): # must detect thrown swords
	
	if _shell_damage < shell_threshold:
		_shell_damage += 1
		_state_machine.travel("hurt")
	elif _shell_damage == shell_threshold:
		_shell_damage += 1
		_state_machine.travel("open")
	elif not immune:
		immune = true
		pearlHp -= 1
		_state_machine.travel("hurt_open")
		immune = false


func eject_player():
	if playerRef != null:
		playerRef.hurt(position + Vector2(100, 0), 2.5)


func increase_idle_count():
	_idle_count += 1
		
	if _idle_count > ATTACK_MAX:
		_idle_count = 0
		_state_machine.travel("shoot")
	print("Idle increased")


func _on_Pearl_area_entered(area):
	hurt(Vector2())


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		playerRef = body


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		playerRef = null


func _on_CloseTimer_timeout():
	_shell_damage = 0
	_state_machine.travel("close")
