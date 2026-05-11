extends Node
class_name shop_manager

@export var wares : Array[PackedScene] = []
@export var stage_locations : Array[Node] = []
@export var ware_stock : Array[int] = []
@export_multiline var ware_comment : Array[String] = []

var staged_wares : Array[Node] = []

var random = RandomNumberGenerator.new()

var wares_staged = false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("shop_manager")
	shuffle_staged_items()
	wares_staged = true

func dispose_of_staged_wares():
	for ware in staged_wares:
		ware.queue_free()
	staged_wares = []

func get_ware_stock(index : int) -> int:
	return ware_stock[index]

func get_ware_comment(index : int) -> String:
	return ware_comment[index]

func shuffle_staged_items():
	dispose_of_staged_wares()
	var indices : Array[int] =[]
	var iterator = 0
	while(iterator < stage_locations.size()):
		var index = random.randi_range(0,wares.size()-1)
		if (!indices.has(index)):
			indices.append(index)
			var ware = wares[index].instantiate()
			stage_locations[iterator].add_child(ware)
			ware.global_position = stage_locations[iterator].global_position
			staged_wares.append(ware)
			iterator += 1

func get_staged_wares():
	return staged_wares

func buy_ware(index : int):
	staged_wares[index].buy_item()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#if(!wares_staged):
		
