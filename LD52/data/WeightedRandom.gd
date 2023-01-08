extends Object

class_name WeightedRandom

static func create_item_array(dictionary:Dictionary)->Array:
	var array = []
	for key in dictionary.keys():
		array.append(dictionary[key])
	return array
	
static func create_weight_array(array:Array, property:String)->Array:
	var weights = []
	for item in array:
		var weigth = item[property]
		if weigth != null:
			weights.append(weigth)
		else:
			weights.append(1)
	return weights
	
static func pickdp(dictionary: Dictionary, property:String):
	var array = create_item_array(dictionary)
	var weights = create_weight_array(array, property)
	return pick(array, weights)
	
static func pickp(array: Array, property:String):
	
	var weights = []
	for item in array:
		if property in item:
			weights.append(item[property])
		else:
			weights.append(1)
			
	return pick(array, weights)

static func pick(array: Array, weights: Array):
	assert(array.size() == weights.size())

	var sum:float = 0.0
	for val in weights:
		sum += val

	var normalizedWeights = []

	for val in weights:
		normalizedWeights.append(val / sum)

#	var rng = RandomNumberGenerator.new()
#	rng.randomize()
#	var rnd = rng.randf()
	var rnd = randf()

	var i = 0
	var summer:float = 0.0

	for val in normalizedWeights:
		summer += val
		if summer >= rnd:
		  return array[i]
		i += 1
