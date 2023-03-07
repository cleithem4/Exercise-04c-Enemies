extends KinematicBody2D

var player = null
onready var ray = $See
export var speed = 1500
export var looking_speed = 400
var line_of_sight = false

var mode = ""


var points = []
const margin = 1.5

func _ready():
	change_mode("move")
	
func _physics_process(delta):
	var velocity = Vector2.ZERO
	player = get_node_or_null("/root/Game/Player_Container/Player")
	if player != null and mode != "die":
		ray.cast_to = ray.to_local(player.global_position)
	velocity = move_and_slide(velocity,Vector2.ZERO)
	var c = ray.get_collider()
	line_of_sight = false
	if c and c.name == "Player":
		line_of_sight = true
	points = get_node("/root/Game/Navigation2D").get_simple_path(global_position, player.global_position, true)
	if points.size() > 1:
		var distance = points[1] - global_position
		var direction = distance.normalized()
		if distance.length() > margin or points.size() > 2:
			velocity = direction*speed
		else:
			velocity = Vector2.ZERO
		velocity = move_and_slide(velocity, Vector2.ZERO)
func change_mode(m):
	if mode != m and mode != "die":
		mode = m
		$AnimatedSprite.play(mode)
func damage():
	change_mode("die")
	collision_mask = 0
	collision_layer = 0


func _on_Attack_body_entered(body):
	if mode != "attack" and body.name == "Player":
		change_mode("attack")
	$Attack/Timer.start()


func _on_Timer_timeout():
	if mode=="attack":
		var bodies = $Attack.get_overlapping_bodies()
		for body in bodies:
			if body.name == "Player":
				body.die()
		change_mode("move")


func _on_Above_and_Below_body_entered(body):
	if body.name == "Player" and mode != "die":
		body.die()
		queue_free()


func _on_AnimatedSprite_animation_finished():
	if mode == "die":
		queue_free()
