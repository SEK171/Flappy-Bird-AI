extends Node2D


# signal for an obstacle being created
signal obstacle_created(obs)

# create a refrence to the timer
onready var timer: Node = $Timer

# create an object of the obstacle scene to instance later
var obstacles: Resource = preload("res://environment/Obstacle.tscn")


# each time the scene is initialized radomize random parameters
func _ready() -> void:
	randomize()


func _on_Timer_timeout() -> void:
	spawn_obstacle()


# funciton to spawn an obstacle
func spawn_obstacle() -> void:
	# create an obstacle instance and position it randomly
	var obstacle = obstacles.instance()
	add_child(obstacle)
	# give it a random position between 150 - 550(549)
	obstacle.position.y = randi() % 400 + 150
	# emit the singnal for obstacle creation
	emit_signal("obstacle_created", obstacle)


func clear_obstacles() -> void:
	for obstacle in self.get_children():
		if obstacle is Obstacle:
				obstacle.queue_free()


func start() -> void:
	spawn_obstacle()
	timer.start()


func stop() -> void:
	timer.stop()


