@tool
extends Actor2D
@export var sight_range = 128
@export var states_enabled = true
@export var state_follow = State.AI_FOLLOW
@export var state_low_health = State.DEFAULT
@export var target : Actor2D
@export var point_distance := 12
@export var follow_distance := 7
@export var point_randoms := PackedVector2Array([Vector2()])
@export var point_random_interval := 120
var _point_randoms_global : Array[Vector2] = []
@onready var position_start = global_position

func _ready() -> void:
	super()
	if !Engine.is_editor_hint():
		state = State.AI_POINT_RANDOM
		for p in point_randoms:
			_point_randoms_global.append(to_global(p))
		$SightArea/CollisionShape2D.shape.radius = sight_range

func _physics_process(delta):
	super(delta)
	if states_enabled == true:
		match state:
			State.AI_POINT_RANDOM:
				if randi_range(0, point_random_interval) == 1:
					if point_randoms.size() > 0:
						#await get_tree().create_timer(.3).timeout
						move_to(_point_randoms_global.pick_random())
			State.AI_RETURN:
				move_to(position_start)
			State.AI_FOLLOW:
				move_to(target.global_position)
			State.ATTACK:
				pass
	if target != null:
		if target.global_position.distance_to(global_position) > follow_distance:
			move_to(target.global_position)
		else:
			velocity = global_position.direction_to(target.global_position)
			state = State.ATTACK
		if target.stats['hp'] <= 0:
			move_to(position_start)
	#

func _on_sight_area_body_entered(body):
	if body is Actor2D:
		if Game.team_opposed(body.team, team) and body.stats['hp'] > 0:
			target = body
