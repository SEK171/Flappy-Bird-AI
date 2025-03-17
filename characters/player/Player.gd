extends RigidBody2D
class_name Player


# variable types are not needed but i like adding them

signal died

# variable to determine the flapping force, negative is up in godot
export var FLAP_FORCE: float = -340.0

# refrence to the animation player
onready var animator: Node = $AnimationPlayer

# ready up the sounds
onready var hit: Node = $Hit
onready var wing: Node = $Wing

# maximum rotation so we don't spin
const MAX_ROTATION_DEGREES: float = -30.0

# variable to hold the gravity scale
const GRAVITY: float = 10.0

# boolean check for starting the game
var started: bool = false
# check for if the player is alive
var alive: bool = true



func _physics_process(_delta: float) -> void:
	# check if the player flaps and start playing
	if Input.is_action_just_pressed("flap") and alive:
		flap()
	
	# check so that the player does not spin
	if rotation_degrees <= MAX_ROTATION_DEGREES:
		angular_velocity = 0
		rotation_degrees = MAX_ROTATION_DEGREES
	
	
	# fall
	if linear_velocity.y > 0:
		if rotation_degrees <= 90:
			angular_velocity = 5
		else:
			angular_velocity = 0



# function to start the game
func start() -> void:
	if started:
		return
	
	# start the game and set initial parameters
	started = true
	gravity_scale = GRAVITY
	flap()


# function to perform a flap
func flap() -> void:
	linear_velocity.y = FLAP_FORCE
	angular_velocity = -8.0
	wing.play()


# function to simulate a game over
func die() -> void:
	if not alive:
		return
	alive = false
	animator.stop()
	hit.play()
	emit_signal("died")






