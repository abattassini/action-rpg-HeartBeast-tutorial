extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4

enum {
	CHASE,
	IDLE,
	WANDER	
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO


var state = CHASE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wandererController = $WandererController

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match (state):
		CHASE:
			var player = playerDetectionZone.player
			if (player != null):
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
			
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			if (wandererController.get_time_left() == 0):
				update_wander()
		WANDER:
			seek_player()
			if (wandererController.get_time_left() == 0):
				update_wander()
			
			accelerate_towards_point(wandererController.target_position, delta)
			
			if (global_position.distance_to(wandererController.target_position) <= WANDER_TARGET_RANGE):
				update_wander()
	
	if (softCollision.is_colliding()):
		velocity+= softCollision.get_push_vector() * delta * 1500
	velocity = move_and_slide(velocity)

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wandererController.start_wander_timer(rand_range(0.5, 1))

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0
			
func seek_player():
	if (playerDetectionZone.can_see_player()):
		state = CHASE

func pick_random_state(states):
	states.shuffle()
	return states.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	
	var swordPosition = area.playerSpritePosition
	swordPosition.y += 10
	
	knockback = swordPosition.direction_to(global_position) * 150
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
