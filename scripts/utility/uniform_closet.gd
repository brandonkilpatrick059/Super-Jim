extends Node

var clothes_stored : bool = false

var hat_spriteframes : SpriteFrames
var top_spriteframes : SpriteFrames

var uniform_top_spriteframes = preload("res://sprites/spritesheets/spriteframes/characters/top/full_sheet/shirt_0.tres") 
var uniform_hat_spriteframes = preload("res://sprites/spritesheets/spriteframes/characters/hat/full_sheet/cap_0.tres")

func _on_area_2d_body_entered(body):
	if(body.is_in_group("player") && clothes_stored == false):
		var player_ref = body
		hat_spriteframes = player_ref.get_hat_spriteframes()
		top_spriteframes = player_ref.get_top_spriteframes()
		player_ref.set_top_spriteframes(uniform_top_spriteframes)
		player_ref.set_hat_spriteframes(uniform_hat_spriteframes)
		clothes_stored = true
		player_ref.add_to_group("uniformed")
		var cook_ref = get_tree().get_first_node_in_group("cook")
		cook_ref.set_schedules_index(1)
	elif(body.is_in_group("player") && clothes_stored == true):
		var player_ref = body
		player_ref.set_top_spriteframes(hat_spriteframes)
		player_ref.set_hat_spriteframes(top_spriteframes)
		clothes_stored = false
		player_ref.remove_from_group("uniformed")
		var cook_ref = get_tree().get_first_node_in_group("cook")
		cook_ref.set_schedules_index(0)
