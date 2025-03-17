extends RigidBody2D
class_name AI


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

# AI related parameters -------------------------------------------------------

# the threshold for making a decision
const threshold: float = 0.73

# the decision variable
var decision: float

# the vision of the birdie ( bottom pipe, middle, top pipe )
var vision: Array = [0.5, 1, 0.5]

# the number of inputs/perceptors
var inputs: int = 3

# the brain of the birdie
var brain: Network = Network.new(inputs)

# the fitness of the current ai
var fitness: float = 0

# the lifespan of the current ai
var lifespan: float = 0


# -----------------------------------------------------------------------------


func _physics_process(_delta: float) -> void:
	# check if the player flaps and start playing
	if alive:
		look()
		think()
	
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
	
	if alive:
		# update lifespan
		lifespan += 1



# function to start the game
func start() -> void:
	if started:
		return
	
	# start the game and set initial parameters
	alive = true
	started = true
	
	self.fitness = 0
	
	# once the game starts give the birdie a brain
	brain.generate_net()
	
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
	
	# reset parameters
	alive = false
	started = false
	
	animator.stop()
	hit.play()
	emit_signal("died")
	self.visible = false



func closest_obstacle() -> Obstacle:
	# get a refrence to the obstacle generator
	var obstacles = get_parent().get_parent().get_node("ObstacleSpawner")
	# loop through all the obstacles and get the first not passed one
	for obstacle in obstacles.get_children():
		if obstacle is Obstacle:
			if not obstacle.passed:
				return obstacle

	# otherwise just return the first child
	return obstacles.get_child(0)


# AI related functions --------------------------------------------------------

# function to simulate the vision of the birdie
func look() -> void:
	
	if closest_obstacle() is Obstacle:
		# get the closest obstacle to the entitie
		var obstacle: Obstacle = closest_obstacle()
		var d: float = 75 # distance from center of pipe to one end
		
		# vision vector of the bottom pipe
		vision[0] = max(0, -(global_position.y - obstacle.global_position.y + d)) / 400

		
#		# draw a line to simulate the vision
#		draw_line(Vector2.ZERO,
#					Vector2(obstacle.global_position.x, obstacle.global_position.y + d),
#					Color.red)
		
		# vision vector of the center/mid of the obstacle
		vision[1] = max(0, obstacle.global_position.x - global_position.x) / 400
		
#		# draw a line to simulate the vision
#		draw_line(Vector2.ZERO,
#					obstacle.global_position,
#					Color.red)
		
		# vision vector of the bottom pipe
		vision[2] = max(0, -(global_position.y - obstacle.global_position.y - d)) / 400
		
#		# draw a line to simulate the vision
#		draw_line(Vector2.ZERO,
#					Vector2(obstacle.global_position.x, obstacle.global_position.y - d),
#					Color.red)
	
	else:
		pass


# the ai action key
func think() -> void:
	decision = brain.feed_forward(vision)

	if decision > threshold:
		flap()

 

# custom sorter for species by fitness
static func sort_descending_fitness(ai1, ai2) -> bool:
	print("custom sorting ensues")
	print(ai1.fitness)
	print(ai2.fitness)
	if ai1.fitness > ai2.fitness:
		print("here we are")
		return true
	return false


func calculate_fitness() -> void:
	fitness = lifespan


func clone() -> AI:
	# get a refrence to the ai resource

	var Population = get_node("/root/World/Population")
	
	var clone: AI = Population.Ai.instance()
	
	Population.add_child(clone)
	
	clone.position.x = 115
	clone.position.y = 427
	clone.connect("died", self, "ai_death")
	
	
	clone.fitness = self.fitness
	clone.brain = self.brain.clone()
	
	clone.start()
	
	return clone

