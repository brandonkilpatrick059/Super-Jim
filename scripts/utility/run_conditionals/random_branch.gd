extends Node

@export var low_index = 0
@export var high_index = 1

@export var no_repeats : bool = false
var temp_numbers : Array[int] = []
var numbers : Array[int]

func _ready() -> void:
	var index = low_index
	while(index <= high_index):
		numbers.append(index)
		index = index + 1
	temp_numbers.append_array(numbers)

func run_conditional() -> int:
	if(temp_numbers.size() == 0):
		temp_numbers.append_array(numbers)
	if(temp_numbers.size() > 0 && no_repeats):
		var num = temp_numbers[randi_range(0,temp_numbers.size() - 1)]
		temp_numbers.erase(num)
		return num
	else:
		return randi_range(low_index,high_index)
