extends Node

class LoadTouple:
	var load_node : Node
	var load_parent : Node

#nodes which are removed from the tree when the player exits this zone,
#and re-added when they enter the zone
var nodes : Array[Node]

var player_ref : Node = null
var camera_ref : Node = null

var loadTouples : Array[LoadTouple]
var deadIndexes : Array[int]

var load_distance : float = 800

var setup_ready = false

var process_timer : Timer = Timer.new()
var process_step_range : float = 0.25

var index = 0
var rel_index = 0
var max_nodes_per = 24

func _ready() -> void:
	process_timer.one_shot = true
	add_child(process_timer)

func setup():
	nodes = get_tree().get_nodes_in_group("prunable")
	for node in nodes:
		var parent_node = node.get_parent()
		var load_node = node
		var new_touple : LoadTouple = LoadTouple.new()
		new_touple.load_node = load_node
		new_touple.load_parent = parent_node
		loadTouples.append(new_touple)
	setup_ready = true

func remove_dead_indexes():
	for dead_index in deadIndexes:
		loadTouples.remove_at(dead_index)
	deadIndexes = []

func prune_tree():
	rel_index = 0
	while(rel_index < max_nodes_per):
		var loadTouple = loadTouples[index]
		if(loadTouple.load_parent != null && loadTouple.load_node != null):
			var node_pos : Vector2 = loadTouple.load_node.global_position
			#prune distant objects
			if(node_pos.distance_to(player_ref.global_position) > load_distance &&
			node_pos.distance_to(camera_ref.global_position) > load_distance):
				if(loadTouple.load_node.get_parent() == loadTouple.load_parent):
					loadTouple.load_parent.remove_child(loadTouple.load_node)
			#re-add near objects
			elif(node_pos.distance_to(player_ref.global_position) <= load_distance ||
			node_pos.distance_to(camera_ref.global_position) <= load_distance):
					if(loadTouple.load_parent != null && loadTouple.load_node != null):
						if(loadTouple.load_node.get_parent() != loadTouple.load_parent):
							loadTouple.load_parent.add_child(loadTouple.load_node)
					#else:
						#deadIndexes.append(index)
		#else:
			#deadIndexes.append(index)
		rel_index = rel_index + 1
		if(index + 1 >= loadTouples.size()):
			index = 0
			#remove_dead_indexes()
		else:
			index = index + 1

func _process(delta: float) -> void:
	if(!setup_ready):
		setup()
	else:
		if(player_ref == null):
			player_ref = get_tree().get_first_node_in_group("player")
		if(camera_ref == null):
			camera_ref = get_tree().get_first_node_in_group("camera")
		else:
			prune_tree()
			#if(process_timer.is_stopped()):
				#prune_thread.wait_to_finish()
				#prune_thread.start(prune_tree)
				#process_timer.start(process_step_range)
			
	
