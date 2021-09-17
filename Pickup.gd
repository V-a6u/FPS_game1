extends Area

enum PickupType{
	Health,
	Ammo
}

#stats
export (PickupType) var type = PickupType.Health
export var amount : int = 10

#bobbing animation
onready var startPos : float = translation.y
var bobHeight : float = 1.0
var bobSpeed : float = 1.0 
var bobbingUp : bool = true

#code for movving up and down
func _process(delta):
	
	#move up or down
	translation.y += (bobSpeed if bobbingUp else -bobSpeed) * delta
	
	#if we are at the top
	if bobbingUp and translation.y > startPos + bobHeight:
		bobbingUp = false
		
	#if at the bottom
	elif !bobbingUp and translation.y < startPos:
		bobbingUp = true
	
func pickup(player):
	if type == PickupType.Health:
		player.add_health(amount)
	elif type == PickupType.Ammo:
		player.add_ammo(amount)

func _on_Pickup_body_entered(body):
	if body.name == "Player":
		pickup(body)
		queue_free()
