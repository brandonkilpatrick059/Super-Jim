extends Node
class_name shop_manager

@export var wares : Array[PackedScene] = []
@export var stage_locations : Array[Node] = []
# 0 -> n for stock which can run out. once reduced to 0, ware disappears
# -1 for stock which is infinite
# -2 for stock which is infinite but still disappears after being bought
@export var ware_stock : Array[int] = [] 
@export_multiline var ware_comment : Array[String] = []
#@export var disappears_after_buying : Array[bool] = []
@export var save_tag : String = ""
@export var comment_voice : String = ""
@export_multiline var are_you_sure_comment : String = ""


@export_multiline var sold_out_comment : String = ""

var staged_ware_indexes : Array[int] = []
#var staged_ware_comments : Array[String] = []
#var staged_ware_stock : Array[int] = []
#var staged_ware_disappears : Array[bool] = []

var staged_wares : Array[Node] = []

var random = RandomNumberGenerator.new()

var wares_staged = false

func get_save_tag():
	return save_tag

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("shop_manager")
	shuffle_staged_items()
	wares_staged = true

func dispose_of_staged_wares():
	for ware in staged_wares:
		ware.queue_free()
	staged_wares = []
	staged_ware_indexes = []

func get_comment_voice() -> String:
	return comment_voice

func get_sold_out_comment() -> String:
	return sold_out_comment

func get_stock_for_ware(ware : Node):
	var index = staged_wares.find(ware)
	var ware_index = staged_ware_indexes[index]
	return ware_stock[ware_index]

#func decrement_ware_stock(ware : Node):
	#var index = staged_wares.find(ware)
	#var ware_index = staged_ware_indexes[index]
	#var stock = get_ware_stock(index)
	#ware_stock[index] = stock - 1

func get_ware_stock(index : int) -> int:
	return ware_stock[index]

func get_ware_comment(ware : Node) -> String:
	var index = staged_wares.find(ware)
	var ware_index = staged_ware_indexes[index]
	return ware_comment[ware_index]

func get_are_you_sure_comment() -> String:
	return are_you_sure_comment

func get_stageable_wares() -> Array[PackedScene]:
	var stageable_wares : Array[PackedScene] = []
	var check_idx = 0
	for ware in wares:
		var stock = ware_stock[check_idx]
		if(stock != 0):
			stageable_wares.append(ware)
		check_idx = check_idx + 1
	return stageable_wares

func shuffle_staged_items():
	dispose_of_staged_wares()
	var indices : Array[int] =[]
	var iterator = 0
	
	var stageable_wares = get_stageable_wares()
	while(iterator < stage_locations.size()):
		var index = random.randi_range(0,stageable_wares.size()-1)
		if(iterator >= stageable_wares.size()):
			break
		if (!indices.has(index)):
			indices.append(index)
			var ware = stageable_wares[index].instantiate()
			stage_locations[iterator].add_child(ware)
			ware.global_position = stage_locations[iterator].global_position
			staged_wares.append(ware)
			var ware_index = wares.find(stageable_wares[index])
			staged_ware_indexes.append(ware_index)
			#if(ware_comment.size() > 0):
				#var comment = ware_comment[index]
				#staged_ware_comments.append(comment)
			iterator += 1

func get_save_dictionary() -> Dictionary:
	var save_tag : String = get_save_tag()
	var save_dictionary = {
		"type" : "shop",
		"ware_stock": ware_stock,
		"save_tag": save_tag
	}
	return save_dictionary

func load_from_dictionary(load_dictionary : Dictionary):
	ware_stock = []
	var load_ware_stock = load_dictionary.get("ware_stock")
	var index = 0
	while(index < load_ware_stock.size()):
		ware_stock.append(int(load_ware_stock[index]))
		index = index + 1
	shuffle_staged_items()

func get_staged_wares():
	return staged_wares

func remove_staged_ware(index : int):
	var ware = staged_wares[index]
	staged_wares.erase(ware)
	staged_ware_indexes.remove_at(index)
	ware.queue_free()

func buy_given_ware(ware : Node):
	var index = staged_wares.find(ware)
	staged_wares[index].buy_item()
	var ware_index = staged_ware_indexes[index]
	var current_stock = int(ware_stock[ware_index])
	if(current_stock > 0):
		ware_stock[ware_index] = current_stock - 1
	if(ware_stock[ware_index] == 0 || current_stock == -2):
		remove_staged_ware(index)
	

func buy_ware(index : int):
	staged_wares[index].buy_item()
	var ware_index = staged_ware_indexes[index]
	var current_stock = ware_stock[ware_index]
	if(current_stock != -1):
		current_stock = current_stock - 1
		ware_stock[ware_index] = current_stock
		if(current_stock == 0 || current_stock == -2):
			remove_staged_ware(index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#if(!wares_staged):
		
