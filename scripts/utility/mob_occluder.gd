extends Node

var update_timer : Timer = Timer.new()
var update_timer_step = 0.5
var occlusion_distance_player = 800
var occlusion_distance_mob = 500

var dormant_mobs : Array[Node] = []
var dummy_mobs : Array[Node] = []
var removed_dummy_mobs : Array[int] = []

func _ready():
	update_timer.one_shot = true
	add_child(update_timer)
	update_timer.start(update_timer_step)

func make_dormant(mobster : Node):
	mobster.paused = true
	#var parent = mobster.get_parent()
	#var dummy = Node2D.new()
	#dummy.global_position = mobster.global_position
	#dummy.add_to_group("mobster")
	#if(mobster.is_in_group("blu")):
		#dummy.add_to_group("blu")
	#else:
		#dummy.add_to_group("red")
	#parent.add_child(dummy)
	#dummy_mobs.append(dummy)
	#parent.remove_child(mobster)
	#dormant_mobs.append(mobster)

func revive(mobster : Node):
	mobster.paused = false
	#var index = dummy_mobs.find(dummy)
	#var mobster = dormant_mobs[index]
	#removed_dummy_mobs.append(index)
	#var ysort = get_tree().get_first_node_in_group("daylight_affected_ysort")
	#ysort.add_child(mobster)

func _process(delta):
		var mobsters : Array[Node] = get_tree().get_nodes_in_group("mobster")
		var bandits : Array[Node] = get_tree().get_nodes_in_group("bandit")
		var player = get_tree().get_first_node_in_group("player")

		for mobster in mobsters:
			var dormant = true
			if(mobster.global_position.distance_to(player.global_position) < occlusion_distance_player):
				dormant = false
			if(dormant):
				for bandit in bandits:
					if(mobster.global_position.distance_to(bandit.global_position) < occlusion_distance_mob):
						dormant = false
			if(dormant):
				make_dormant(mobster)
			else:
				revive(mobster)
		#for dummy in dummy_mobs:
			#if(dummy.global_position.distance_to(player.global_position) < occlusion_distance_player):
				#revive(dummy)
			#else:
				#for bandit in bandits:
					#if(dummy.global_position.distance_to(bandit.global_position) < occlusion_distance_mob):
						#revive(dummy)
						#break
				
		#for index in removed_dummy_mobs:
			#var dummy = dummy_mobs[index]
			#dummy_mobs.remove_at(index)
			#dormant_mobs.remove_at(index)
			#dummy.queue_free()
		#removed_dummy_mobs = []
