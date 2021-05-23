extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

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

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match (state):
		CHASE:
			var player = playerDetectionZone.player
			if (player != null):
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
			sprite.flip_h = velocity.x < 0
			
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
	
	velocity = move_and_slide(velocity)
			
func seek_player():
	if (playerDetectionZone.can_see_player()):
		state = CHASE

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
