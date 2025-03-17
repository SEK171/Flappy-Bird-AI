extends CanvasLayer

# signal for starting game
signal start_game

# signal for starting AI simulation
signal start_simulation

# refrences
onready var start_screen: Node = $StartMenu
onready var user_choice: Node = $UserChoice
onready var game_over_menu: Node = $GameOverMenu
onready var run_score_label: Node = $GameOverMenu/VBoxContainer/RunScore
onready var high_score_label: Node = $GameOverMenu/VBoxContainer/HighScore
onready var tween: Node = $Tween

# boolean checks of weather the game or simulationstarted yet
var game_started: bool = false
var simulation_started: bool = false


# start the game
func start_gaming() -> void:
	emit_signal("start_game")
	tween.interpolate_property(start_screen, "modulate:a", 1, 0, 0.5)
	tween.start()
	user_choice.visible = false
	game_started = true


func show_game_over_menu(score: int, high_score: int) -> void:
	run_score_label.text = "SCORE: " + str(score)
	high_score_label.text = "BEST: " + str(high_score)
	game_over_menu.visible = true



func show_start_game_menu() -> void:
	tween.interpolate_property(start_screen, "modulate:a", 0, 1, 0.5)
	tween.start()
	user_choice.visible = true
	game_started = false
	simulation_started = false


# start the game
func start_simulation() -> void:
	emit_signal("start_simulation")
	tween.interpolate_property(start_screen, "modulate:a", 1, 0, 0.5)
	tween.start()
	user_choice.visible = false
	simulation_started = true




func _on_RestartButton_pressed():
	# reload the game when restart is clicked
	get_tree().reload_current_scene()


func _on_Play_pressed():
	if not game_started and not simulation_started:
		start_gaming()


func _on_AI_pressed():
	if not game_started and not simulation_started:
		start_simulation()
