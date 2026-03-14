extends CollisionObject2D

@export var repel: bool = false
@export var push_vect : Vector2 = Vector2(0,0)
@export var push_secs : float = 0.0

func _on_body_entered(body : Node2D):
	if(body.is_in_group("player")):
		if(repel):
			var vect : Vector2 = body.get_current_v()
			body.push(-vect,0.35)
		else:
			body.push(push_vect,push_secs)
