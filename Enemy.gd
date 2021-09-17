extends KinematicBody

#stats
var health : int = 7
var moveSpeed : float = 1

#attacking
var damage : int = 2
var attackRate : float = 1.0
var attackDist : float  = 2.0

var scoreToGive : int = 200

# components
onready var player : Node = get_node("/root/MainScene/Player")
onready var timer : Timer = get_node("Timer")

func _ready():
	
	#set up the attack timer
	timer.set_wait_time(attackRate)
	timer.start()
	

#attack the player
func _physics_process(delta):
	
	#calculate direction to the player
	var dir = (player.translation - translation).normalized()
	dir.y = 0
	
	# move the enemy towards the player
	move_and_slide(dir * moveSpeed, Vector3.UP)
	
#when the enemy takes damage
func take_damage(damage):
	health -= damage
	
	if health <= 0 :
		die()
		
#when health reaches 0
func die():
	player.add_score(scoreToGive)
	queue_free()
	
#attack
func attack():
	player.take_damage(damage)
	
#called every attack rate second
func _on_Timer_timeout():
	#if at the right direction
	if translation.distance_to(player.translation) <= attackDist:
		attack()
