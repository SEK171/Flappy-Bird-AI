extends Node
class_name Connection

# define the connections between the nodes in the neural network
var source_node: Neuron
var destination_node: Neuron
var weight: float


# initialize the parameters upon instancing
func _init(given_source_node: Neuron, given_destination_node: Neuron,
												given_weight: float) -> void:
	source_node = given_source_node
	destination_node = given_destination_node
	weight = given_weight


func mutate_weight() -> void:
	# 10% chance
	if rand_range(0, 1) < 0.1:
		weight = rand_range(-1, 1)
	else:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		weight += rng.randfn(0, 1) / 10
		
		# clip to boundaries
		if weight > 1:
			weight = 1
		if weight < -1:
			weight = -1


func clone(given_source_node: Neuron, given_destination_node: Neuron) -> Connection:
	var clone: Connection = get_script().new(given_source_node, given_destination_node, weight)
	return clone




