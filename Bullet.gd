extends Area

export var speed : float = 30.0
var damage : int = 1

func _process (delta):
	# move the bullet forwards
	translation += global_transform.basis.z * speed * delta


#when bullet hits something
func _on_Bullet_body_entered(body):
	
	#does damage if the body can take damage
	if body.has_method("take_damage"):
		body.take_damage(damage)
		destroy()

#destroys the bullet		
func destroy():
	queue_free()
	
