extends Node2D


# signal if all died to game over
signal player_died
signal extinct

# player ai classes to create instances of
var Player: Resource = preload("res://characters/player/Player.tscn")
var Ai: Resource = preload("res://characters/ai/ai.tscn")


# variable to hold the population size
var population_size: int = 1

# variable for the number of entities alive
var entities_alive: int = 1

# array to hold all ais if they exist (so that they have shared operations)
var ais: Array = []

# the current generation
var generation: int = 1

# a list of the species
var species: Array = []




# check weather we have achieaved the optimal selection through processes
var optimal: bool = false


# randomize parameters at the start if need be (mostly for positions)
func _ready() -> void:
	randomize()


func spawn_player() -> void:
	# create a playable player instance and set it's initial parameters
	var player: Player = Player.instance()
	add_child(player)
	player.position.x = 115
	player.position.y = 427
	player.connect("died", self, "player_death")
	player.start()


func spawn_ai(size: int) -> void:
	# set the population to the given size and create em
	population_size = size
	entities_alive = size
	for _i in range(size):
		# create an ai instance and set it's initial parameters
		var ai: AI = Ai.instance()
		add_child(ai)
		ai.position.x = 115
		ai.position.y = 427
		ai.connect("died", self, "ai_death")
		ai.start()
		ais.append(ai)



func ai_death() -> void:
	# check if we have gone extinct yet
	if entities_alive > 1:
		entities_alive -= 1
	else:
		emit_signal("extinct")


func player_death() -> void:
	emit_signal("player_died")



func natural_selection() -> void:
	print("species creation time")
	make_species()
	
	print("fitness time")
	calculate_fitness()
	
	print("species sorting time")
	sort_species_by_fitness()
	
	print("creating children of the new gen")
	next_generation()


func kill_old_generation():
	for ai in ais:
		ai.queue_free()


func make_species() -> void:
	# reinitialize the species
	for s in species:
		s.ais = []
	
	for ai in ais:
		var add_to_species: bool = false
		for s in species:
			if s.similarity(ai.brain):
				s.add_to_species(ai)
				add_to_species = true
				break
		if not add_to_species:
			species.append(Species.new(ai))


func calculate_fitness() -> void:
	# calculate the individual fitness of each ai
	for ai in ais:
		ai.calculate_fitness()
	
	# calculate the average fitness of each species
	for s in species:
		s.calculate_average_fitness()


func sort_species_by_fitness() -> void:
	# sort the ais in each species by fitness
	for s in species:
		s.sort_ais_by_fitness()
	
	# sort the list of species in a descending order with respect to the fitness
	species.sort_custom(Species, "sort_descending_fitness")


func next_generation() -> void:
	# initiallize a list to hold the next gen children
	var children: Array = []
	
	# clone the best member of each species
	for s in species:
		children.append(s.best.clone())
	
	var children_per_species: int = floor(((population_size - species.size()) / species.size()))
	
	
	# allocate the same number of children to each species
	for s in species:
		for _i in range(children_per_species):
			children.append(s.offspring())
	
	# if there is any empty space add the offspring of the best species
	while children.size() < population_size:
		children.append(species[0].offspring())
	
	
	# remove the old generation
	kill_old_generation()
	
	
	# create the next generation of ais
	ais = []
	for child in children:
		add_child(child)
		child.position.x = 115
		child.position.y = 427
		child.connect("died", self, "ai_death")
		child.start()
		ais.append(child)
	generation += 1
	# don't forget the number of living birds update burh..
	entities_alive = population_size




















