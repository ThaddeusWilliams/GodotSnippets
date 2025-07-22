class_name Actor2D
extends CharacterBody2D


@export var stats = {max_hp = 8, hp = 8, mp = 8, max_mp = 8}

@export_enum("Neutral", "Player", "Enemy A", "Enemy B", "Enemy C") var team = "Neutral"

@export var movement_speed: float = 54.0
@onready var navigation_agent: NavigationAgent2D = get_node("Agent")

var impact = Vector2() #Vector that moves us when hit

var direction = Vector2()
var movement = Vector2()

signal move_finish
signal point_move_finish


func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func _process(delta):
	body_parts.all(func(body_part: Game.BodyPart):body_part.update())

func move_to(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	#
	if velocity.length() > 0:
		$Sprite.play()
	else:
		$Sprite.stop()
		$Sprite.frame = 1
	
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()
