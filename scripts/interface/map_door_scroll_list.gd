extends Node2D


@export var tabs : Array[Node2D] = []
var bottom_index = 0
var selected_index = 0

var player_ref = null

#var dial_height = 116
#var dial_step = 3.31

var map_node : Node

var door_nodes : Array[Node] = []

var selected_door_node : Node 

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	update_list()

func set_map(map : Node, select_name : String = ""):
	map_node = map
	door_nodes = map_node.get_children()
	if(select_name == ""):
		selected_index = 0
		bottom_index = 0
	update_list()

func update_list():
	var index = bottom_index
	var tab = 0
	for node in door_nodes:
		node.set_active(false)
	while(index < index + tabs.size() && tab < tabs.size()):
		if(index < door_nodes.size()):
			var door_node = door_nodes[index]
			var tab_name = door_node.get_tab_name()
			var tab_state = ""
			if(index == selected_index):
				tab_state = "selected"
				selected_door_node = door_node
				door_node.set_active(true)
			else:
				tab_state = "used"
			var has_link = false
			if(door_node.get_linked_map() != ""):
				var player_ref = get_tree().get_first_node_in_group("player")
				if(player_ref.get_owned_maps().has(door_node.get_linked_map())):
					has_link = true
			var lock_state = ""
			var lock_group = door_node.get_lock_group()
			if(lock_group != ""):
				var actual_door_node = get_tree().get_first_node_in_group(lock_group)
				lock_state = "unlocked"
				if(actual_door_node.locked):
					lock_state = "locked"
			tabs[tab].set_tab(tab_name,tab_state, has_link, lock_state)
		else:
			tabs[tab].set_tab("","unused",false)
		tab = tab + 1
		index = index + 1

func get_selected_index():
	return selected_index

func increment_selected():
	if(selected_index + 1 < door_nodes.size()):
		selected_index = selected_index + 1
		if(selected_index > bottom_index + (tabs.size()-1) &&
		bottom_index + (tabs.size()-1) <= door_nodes.size()):
			bottom_index = bottom_index + 1
			#dial.position = dial.position + Vector2(0,dial_step)
	update_list()

func decrement_selected():
	if(selected_index > 0):
		selected_index = selected_index - 1
		if(selected_index < bottom_index &&
		bottom_index > 0):
			bottom_index = bottom_index - 1
			#dial.position = dial.position - Vector2(0,dial_step)
	update_list()
