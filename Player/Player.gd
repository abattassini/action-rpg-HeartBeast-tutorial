extends KinematicBody2D

const ACCELERATION = 12 * 60
const MAX_SPEED = 80
const ROLL_SPEED = 100
const FRICTION = 20 * 60

enum PlayerStates {
	ATTACK,
	MOVE,
	ROLL
}

var state = PlayerStates.MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get('parameters/playback')

func _ready():
	animationTree.active = true

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

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func roll_state(delta):
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

