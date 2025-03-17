extends Node
class_name Neuron

# the id of the node in the neural net
var id: int
# the current layer: inputs, activation/sum, output
var layer: int = 0

# the input and output of the current node
var input: float = 0
var output: float = 0

# the connections from this node
var connections: Array = []


# initialize the neuron with it's id
func _init(given_id) -> void:
	id = given_id


# the activation of the neuron
func activate() -> void:
	# if the layer last layer pass it through sigmoid to get the output
	if layer == 1:
		output = sigmoid(input)	
	# if first layer then accumelate the linear activation of each neuron/node
	for i in range(connections.size()):
		connections[i].destination_node.input += connections[i].weight * output


func clone() -> Neuron:
	var clone: Neuron = get_script().new(id)
	clone.layer = self.layer
	return clone



func sigmoid(x: float) -> float:
	return 1 / (1 + exp(-x))



