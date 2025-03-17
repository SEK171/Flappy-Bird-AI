extends Node2D
class_name Obstacle

# a signal for scoring aka passing score area
signal player_scored

# the speed of the obstacle moving to the player
const SPEED: float = 215.0

# scoring sound
onready var point: Node = $Point

# a variable to check weather the obstacle is passed
var passed: bool = false


func _physics_process(delta: float) -> void:
	# move the obstacle to the player
	position.x += -SPEED * delta
	
	# if the obstacle left remove it
	if global_position.x <= -200:
		queue_free()


func _on_Wall_body_entered(body) -> void:
	if body.is_in_group("Entity"):
		if body.has_method("die"):
			if body.alive:
				body.die()


func _on_ScoreArea_body_exited(body) -> void:
	if body.is_in_group("Entity"):
		if body.alive:
			# play the scoring sound
			point.play()
			# flag the obstacle as passed
			passed = true
			# emit the signal for the player having scored
			emit_signal("player_scored")
			# if it is a player reinforce it
			if body.has_method("calculate_fitness"):
				body.calculate_fitness(20)
