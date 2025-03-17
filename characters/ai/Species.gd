extends Node
class_name Species

# initialize an empty species
var ais: Array = []
var average_fitness: float = 0
var threshold: float = 1.2
var benchmark_fitness: float
var benchmark_brain: Network
var best: AI


func _init(ai: AI) -> void:
	ais.append(ai)
	benchmark_fitness = ai.fitness
	benchmark_brain = ai.brain.clone()
	best = ai.clone()


# custom sorter for species by fitness
static func sort_descending_fitness(s1, s2) -> bool:
	if s1.benchmark_fitness > s2.benchmark_fitness:
		return true
	return false


func similarity(brain: Network) -> bool:
	var similarity = weight_difference(benchmark_brain, brain)
	return threshold > similarity



static func weight_difference(brain1: Network, brain2: Network) -> float:
	var total_weight_difference: float = 0
	for i in range(brain1.connections.size()):
		for j in range(brain2.connections.size()):
			if i == j:
				total_weight_difference += abs(brain1.connections[i].weight - brain2.connections[j].weight)
	
	return total_weight_difference


func add_to_species(ai: AI) -> void:
	ais.append(ai)


func sort_ais_by_fitness() -> void:
	ais.sort_custom(AI, "sort_descending_fitness")
	if ais[0].fitness > benchmark_fitness:
		benchmark_fitness = ais[0].fitness
		best = ais[0].clone()


func calculate_average_fitness() -> void:
	var total_fitness: float = 0
	
	for ai in ais:
		total_fitness += ai.fitness
	
	if ais:
		average_fitness = int(total_fitness / ais.size())
	else:
		average_fitness = 0


func offspring() -> AI:
	var baby: AI = ais[randi() % ais.size()].clone()
	baby.brain.mutate()
	return baby



















