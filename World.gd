extends Node2D



# refrences to the game elements
onready var hud: Node = $HUD
onready var obstacle_spawner: Node = $ObstacleSpawner
onready var ground: Node = $Ground
onready var menu: Node = $Menu
onready var population: Node = $Population

# the high score and the path to the save file
const SAVE_FILE_PATH: String = "user://savedata.save"
var high_score: int = 0

# the score with it's setter
var score: int = 0 setget set_score


func _ready() -> void:
	# connect the signals for obstacle creation
	obstacle_spawner.connect("obstacle_created", self, "_on_obstacle_created")
	# get the saved high score
	load_high_score()
	# initialize the parameters and show start menu
	score = 0
	ground.get_node("AnimationPlayer").play()
	get_tree().call_group("Obstacles", "set_physics_process", true)
	menu.show_start_game_menu()
	
	

# initialize a new game with the player
func new_game() -> void:
	self.score = 0
	obstacle_spawner.start()
	population.spawn_player()


# scoring function
func update_score() -> void:
	self.score += 1

# the setter for the score variable
func set_score(new_score: int) -> void:
	score = new_score
	hud.update_score_label(score)


func game_over() -> void:
	obstacle_spawner.stop()
	ground.get_node("AnimationPlayer").stop()
	get_tree().call_group("Obstacles", "set_physics_process", false)
	
	if score > high_score:
		high_score = score
		save_high_score()
		
	
	menu.show_game_over_menu(score, high_score)

func game_over_ai() -> void:
	ground.get_node("AnimationPlayer").stop()
	obstacle_spawner.stop()
	obstacle_spawner.clear_obstacles()
	
	# wait for 2 seconds
	yield(get_tree().create_timer(2.0), "timeout")
	
	self.score = 0
	ground.get_node("AnimationPlayer").play()
	obstacle_spawner.start()
	population.natural_selection()
	




func save_high_score() -> void:
	var save_data = File.new()
	save_data.open(SAVE_FILE_PATH, File.WRITE)
	save_data.store_var(high_score)
	save_data.close()


func load_high_score() -> void:
	var save_data = File.new()
	if save_data.file_exists(SAVE_FILE_PATH):
		save_data.open(SAVE_FILE_PATH, File.READ)
		high_score = save_data.get_var()
		save_data.close()



func new_simulation() -> void:
	self.score = 0
	# set the ai switch to true
	obstacle_spawner.start()
	population.spawn_ai(25)



func _on_obstacle_created(obs) -> void:
	# connect the obstacles scoring signal with the function updating score
	obs.connect("player_scored", self, "update_score")


func _on_DeathZone_body_entered(body):
	if body.is_in_group("Entity"):
		if body.has_method("die"):
			body.die()



func _on_Population_player_died():
	game_over()


func _on_Population_extinct():
	# don't forget the other option to continue simulation
	# use the optimal value in the population
	game_over_ai()



func _on_Menu_start_game():
	new_game()


func _on_Menu_start_simulation():
	new_simulation()


