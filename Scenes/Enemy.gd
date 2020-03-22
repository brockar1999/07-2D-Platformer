extends KinematicBody2D


const GRAV = 20
const SPEED = 200
const FLOOR = Vector2(0,-1)
const DAMAGE = 40

var velocity = Vector2()

var direction = 1 #right

var dead = false

func _physics_process(delta):
	if dead == false:
		velocity.x = SPEED * direction
		
		if direction == 1:
			$AnimatedSprite.flip_h = false
		else:
			$AnimatedSprite.flip_h = true
		
		$AnimatedSprite.play("move")
		velocity.y += GRAV
		velocity = move_and_slide(velocity, FLOOR)
		
	if is_on_wall():
		direction = direction * -1
		$RayCast2D.position.x *= -1
		
	if $RayCast2D.is_colliding() == false:
		direction = direction * -1
		$RayCast2D.position.x *= -1

func die():
	dead = true
	velocity = Vector2(0,0)
	$AnimatedSprite.play("death")
	$CollisionShape2D.disabled = true
	$DeathTime.start()


func _on_DeathTime_timeout():
	queue_free()

func bounce(bouncer):
	if bouncer.has_method("bounce"):
		bouncer.bounce()
		die()
		
func save(save_game : Resource):
	save_game.data[name] = dead #keeping track of whether or not an enemy is already dead
	
func load(save_game : Resource):
	dead = save_game.data[name]
