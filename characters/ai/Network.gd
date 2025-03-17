extends Node
class_name Network


# necessary parameters
var connections: Array = [] # the connections
var neurons: Array = [] # the neurons
var inputs: int # the number of perceptors
var net: Array = [] # the network
var layers: int = 2 # the number of layers


# function to instance the neural net
func _init(given_inputs: int, cloning: bool = false) -> void:
	inputs = given_inputs
	if not cloning:
		create_initial_nodes_and_connections()


func _ready() -> void:
	randomize()


# function to create the nodes
func create_initial_nodes_and_connections() -> void:
	# the input nodes
	for i in range(inputs):
		var neuron: Neuron = Neuron.new(i)
		neuron.layer = 0
		neurons.append(neuron)
	# the bias node ( a fourth constant input for biasing the network )
	var bias_neuron: Neuron = Neuron.new(3)
	bias_neuron.layer = 0
	neurons.append(bias_neuron)
	
	# the output node
	var output_neuron: Neuron = Neuron.new(4)
	output_neuron.layer = 1
	neurons.append(output_neuron)
	
	# create the connections for the input nodes
	for i in range(4):
		var connection: Connection = Connection.new(neurons[i],
													neurons[4],
													rand_range(-1, 1))
		connections.append(connection)


# connect the nodes with each other (it is a fully connected net after all)
func connect_nodes() -> void:
	# initilize connections
	for i in range(neurons.size()):
		neurons[i].connections = []
	# set connections recursively
	for i in range(connections.size()):
		connections[i].source_node.connections.append(connections[i])


# generate the neural net
func generate_net() -> void:
	# connect the neurons
	connect_nodes()
	# initialize the network
	net = []
	# put all nodes to the net by order of layers
	for j in range(layers):
		for i in range(neurons.size()):
			if neurons[i].layer == j:
				net.append(neurons[i])


# the feed forward of the net
func feed_forward(vision: Array) -> float:
	# initialize all outputs to the vision of the birdie
	for i in range(inputs):
		neurons[i].output = vision[i]
	# don't forget the bias node
	neurons[3].output = 1.0
	
	# now activate the neurons
	for i in range(net.size()):
		net[i].activate()
	
	# now save the global output
	var output: float = neurons[4].output
	
	# reset the inputs of all nodes
	for i in range(neurons.size()):
		neurons[i].input = 0.0
	
	
	# return the global output
	return output


func mutate() -> void:
	# 80% chance
	if rand_range(0, 1) < 0.8:
		for i in range(connections.size()):
			connections[i].mutate_weight()


func getNeuron(id: int) -> Neuron:
	for neuron in neurons:
		if neuron.id == id:
			return neuron
	
	# just for the compiler to shut up
	return neurons[0]


func clone() -> Network:
	var clone: Network = get_script().new(self.inputs, true)
	
	for neuron in neurons:
		clone.neurons.append(neuron.clone())
	
	for connection in connections:
		clone.connections.append(connection.clone(clone.getNeuron(connection.source_node.id),
													clone.getNeuron(connection.destination_node.id)))
	
	clone.layers = self.layers
	clone.connect_nodes()
	return clone







