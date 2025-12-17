class_name Perceptions

var target_pos = Vector2(0,0) #last point where the target was seen
var target_obj : Node #reference to the target itself
var has_line_of_sight_to_target = false
var position = Vector2(0,0)
var global_position : Vector2 = Vector2(0,0)
var current_v = Vector2(0,0) #force applied this physics frame
var linear_velocity = Vector2(0,0)
var speed = 0
var nav_target_reached = false
var animation_running = false
var facing_dir = "left"
var one_shot_animating = false
var colliding_nodes: Array[Node] = []
var nodes_in_vision: Array[Node] = []
var nodes_in_hearing: Array[Node] = []
var holding_object = false
