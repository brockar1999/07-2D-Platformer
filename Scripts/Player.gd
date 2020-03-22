extends KinematicBody2D

signal health_updated(health)
signal killed()

const UP = Vector2(0,-1)
const GRAV = 20
const MAX_SPEED = 200
const JUMP = -600
const ACCEL = 50
const BOUNCE_VELOCITY = -500

var velocity = Vector2()
export var score = 0

export (float) var max_health = 100

onready var health = max_health setget _set_health
onready var invulnerability_timer = $Invulnerability

func _physics_process(delta):
	velocity.y += GRAV
	var friction = false
	
	if Input.is_action_pressed("right"):
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.play("run")
		velocity.x = min(velocity.x+ACCEL, MAX_SPEED)
	elif Input.is_action_pressed("left"):
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.play("run")
		velocity.x = max(velocity.x-ACCEL, -MAX_SPEED)
	elif Input.is_action_pressed("duck"):
		$AnimatedSprite.play("duck")
		velocity.x = lerp(velocity.x, 0, 0.2)
	elif Input.is_action_pressed("cheer"):
		$AnimatedSprite.play("cheer")
		velocity.x = lerp(velocity.x, 0, 0.2)
	else:
		$AnimatedSprite.play("default")
		friction = true
		
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP
		if friction == true:
			velocity.x = lerp(velocity.x, 0, 0.2)
	else:
		if velocity.y < 0: #we are going UP
			$AnimatedSprite.play("jump")
		else:
			$AnimatedSprite.play("fall")
		if friction == true:
			velocity.x = lerp(velocity.x, 0, 0.0005)
	
	_check_bounce(delta)
	velocity = move_and_slide(velocity, UP)
	for i in range(get_slide_count()-1):
		var body = get_slide_collision(i).collider
		if body.is_in_group("enemies"):
			damage(body.DAMAGE)

func damage(amount):
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		_set_health(health-amount)
		$AnimatedSprite.play("damage")
	

func kill():
	pass

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health <= 0:
			kill()
			emit_signal("killed")

func _on_Invulnerability_timeout():
	$AnimatedSprite.play("default")

func _check_bounce(delta):
	if velocity.y > 0:
		for ray in $BounceCasts.get_children():
			ray.cast_to = Vector2.DOWN * velocity * delta + Vector2.DOWN
			ray.force_raycast_update()
			if ray.is_colliding() && ray.get_collision_normal() == Vector2.UP:
				velocity.y = (ray.get_collision_point() - ray.global_position - Vector2.DOWN).y / delta
				ray.get_collider().call_deferred("bounce", self)
				score += 100
				print(score)
				break
			

func bounce(bounce_velocity = BOUNCE_VELOCITY):
	velocity.y = bounce_velocity

func _get_score():
	return score
	
func save(save_game : Resource):
	save_game.data["PLAYER"] = score

func load(save_game : Resource):
	score = save_game.data["PLAYER"]
