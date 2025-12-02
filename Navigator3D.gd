extends CharacterBody3D

@export var ai_movement_speed: float = 4.0
@onready var navigation_agent: NavigationAgent3D = $Agent

var ai_destination : Vector3

func _ready() -> void:
	move_to(ai_destination)

func move_to(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * ai_movement_speed * delta
	velocity = new_velocity
	move_and_slide()
