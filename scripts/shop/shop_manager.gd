extends Node
class_name shop_manager

@export var wares : Array[PackedScene] = []
@export var stage_locations : Array[Node] = []
@export var ware_stock : Array[int] = []
@export_multiline var ware_comment : Array[String] = []
@export var save_tag : String = ""
@export var comment_voice : String = ""
@export_multiline var are_you_sure_comment : String = ""

var staged_ware_comments : Array[String] = []

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
	staged_ware_comments = []

func get_comment_voice() -> String:
	return comment_voice

func get_ware_stock(index : int) -> int:
	return ware_stock[index]

func get_ware_comment(ware : Node) -> String:
	var index = staged_wares.find(ware)
	return staged_ware_comments[index]

func get_are_you_sure_comment() -> String:
	return are_you_sure_comment

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
			if(ware_comment.size() > 0):
				var comment = ware_comment[index]
				staged_ware_comments.append(comment)
			iterator += 1

func get_save_dictionary() -> Dictionary:
	var save_tag : String = get_save_tag()
	var save_dictionary = {
		"type" : "shop",
		"ware_stock": ware_stock
	}
	return save_dictionary

func load_from_dictionary(load_dictionary : Dictionary):
	ware_stock = []
	var load_ware_stock = load_dictionary.get("ware_stock")
	var index = 0
	while(index < load_ware_stock.size()):
		ware_stock.append(int(load_ware_stock[index]))
		index = index + 1

func get_staged_wares():
	return staged_wares

func buy_ware(index : int):
	staged_wares[index].buy_item()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#if(!wares_staged):
		
