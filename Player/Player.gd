extends KinematicBody2D

export var ACCELERATION = 12 * 60
export var MAX_SPEED = 80
export var ROLL_SPEED = 100
export var FRICTION = 20 * 60

enum PlayerStates {
	ATTACK,
	MOVE,
	ROLL
}

var state = PlayerStates.MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get('parameters/playback')
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var sprite = $Sprite
onready var hurtbox = $Hurtbox

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

## This function gets called every frame
func _physics_process(delta):
	match (state):
		PlayerStates.ATTACK:
			attack_state(delta)
			
		PlayerStates.MOVE:
			move_state(delta)
			
		PlayerStates.ROLL:
			roll_state(delta)
			
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
	input_vector.y = Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up')
	input_vector = input_vector.normalized()
	
	if (input_vector != Vector2.ZERO):
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		swordHitbox.playerSpritePosition = sprite.global_position
		animationTree.set('parameters/Idle/blend_position', input_vector)
		animationTree.set('parameters/Run/blend_position', input_vector)
		animationTree.set('parameters/Attack/blend_position', input_vector)
		animationTree.set('parameters/Roll/blend_position', input_vector)
		animationState.travel('Run')
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel('Idle')
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if (Input.is_action_just_pressed("attack")):
		state = PlayerStates.ATTACK
	if (Input.is_action_just_pressed("roll")):
		state = PlayerStates.ROLL

func attack_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func roll_state(_delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func move():
	velocity = move_and_slide(velocity)
	
func roll_animation_finished():
	velocity = velocity / 3
	state = PlayerStates.MOVE

func attack_animation_finished():
	state = PlayerStates.MOVE

func _on_Hurtbox_area_entered(area):
	stats.health -= 1
	hurtbox.start_invincibility(1)
	hurtbox.create_hit_effect()
