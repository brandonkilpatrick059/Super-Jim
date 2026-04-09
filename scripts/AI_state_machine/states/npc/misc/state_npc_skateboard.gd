class_name NPC_Skateboard
extends State

var wait_timer := Timer.new()
var waiting_to_transit = false
var animated_sprite : AnimatedSprite2D

func _ready():
	wait_timer.one_shot = true
	add_child(wait_timer)

func physics_process(_delta: float) -> void:
	if(is_instance_valid(ai_state_machine.get_perceptions().current_stage_mark)):
		if(ai_state_machine.get_perceptions().global_position == ai_state_machine.get_perceptions().current_stage_mark.global_position):
				pass
		else:
			if(not waiting_to_transit):
				waiting_to_transit = true
				var wait_time = ai_state_machine.get_perceptions().current_stage_mark.get_wait_time()
				var rand_wait = randf_range(0.0, wait_time)
				wait_timer.start(rand_wait)
			else:
				if(wait_timer.is_stopped()):
					if(!ai_state_machine.get_perceptions().in_dialog):
						ai_state_machine.transition_to(npc_states.transit)

func enter(_msg := {}) -> void:
	waiting_to_transit = false
	var npc = get_parent().get_parent()
	animated_sprite = AnimatedSprite2D.new()
	animated_sprite.sprite_frames = load("res://sprites/spritesheets/spriteframes/item/skateboard.tres")
	animated_sprite.animation = "right"
	animated_sprite.speed_scale = 0.0
	npc.add_child(animated_sprite)
	animated_sprite.position = Vector2(0,4)
	animated_sprite.z_index = -2

func exit() -> void:
	animated_sprite.queue_free()
