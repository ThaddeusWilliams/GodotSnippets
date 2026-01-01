class_name Actor2D
extends CharacterBody2D

@export var stats = {max_hp = 8, hp = 8, mp = 8, max_mp = 8}

@export var team : Team = 0

enum Team {
	NEUTRAL, PLAYER, ENEMY_A, ENEMY_B, ENEMY_C
}

@export var movement_speed: float = 54.0
@onready var navigation_agent := NavigationAgent2D.new()

@export var texture : Texture2D

var impact = Vector2() #Vector that moves us when hit
var velocity_last = Vector2.DOWN
signal move_finish
signal point_move_finish


enum State {
	DEFAULT, JUMP, ATTACK_CHARGE, ATTACK, HURT, SPEAK, CAST_SPELL, USE_ITEM, DEAD,
	AI_FOLLOW, AI_RETURN, AI_POINT_RANDOM, AI_PATH
}
@export var state : State = State.DEFAULT
var state_last : State = State.DEFAULT

func _ready() -> void:
	add_child(navigation_agent)
	navigation_agent.radius = 5
	navigation_agent.avoidance_enabled = true
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func _draw():
	$Sprite.texture = texture

func move_to(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)
	#print_debug("Path: ", navigation_agent.get_current_navigation_path())

func states_process(delta):
	z_index = global_position.y / 10
	if !Engine.is_editor_hint():
		match state:
			State.DEFAULT, State.AI_POINT_RANDOM, State.AI_FOLLOW, State.AI_RETURN:
				if velocity.length() != 0:
					if get_real_velocity().y > 0:
						$AnimationPlayer.play("walk_down")
					elif get_real_velocity().y < 0:
						$AnimationPlayer.play("walk_up")
					elif get_real_velocity().x > 0:
						$AnimationPlayer.play("walk_right")
					elif get_real_velocity().x < 0:
						$AnimationPlayer.play("walk_left")
					velocity_last = get_real_velocity()
				else:
					$AnimationPlayer.stop()
				if stats["hp"] <= 0:
					state = State.DEAD
			State.ATTACK:
				velocity = Vector2()
				if velocity_last.y > 0:
					$AnimationPlayer.play("attack_down")
				elif velocity_last.y < 0:
					$AnimationPlayer.play("attack_up")
				elif velocity_last.x > 0:
					$AnimationPlayer.play("attack_right")
				elif velocity_last.x < 0:
					$AnimationPlayer.play("attack_left")
				await $AnimationPlayer.animation_finished
				$AnimationPlayer.stop(true)
				state = State.DEFAULT
			State.HURT:
				velocity.x = -clamp(velocity_last.x, -8, 8)
				velocity.y = -clamp(velocity_last.y, -8, 8)
				$Sprite.modulate = Color.RED
				var t = create_tween()
				t.tween_property($Sprite, "modulate", Color.WHITE, .3)
				await t.finished
				reset()
				velocity = Vector2()
				state = State.DEFAULT
			State.JUMP:
				#$AnimationPlayer.active = false
				if $Sprite.position.y == -6:
					velocity = Vector2()
					if velocity_last.y > 0:
						$Sprite.frame = 20
					elif velocity_last.y < 0:
						$Sprite.frame = 21
					elif velocity_last.x > 0:
						$Sprite.frame = 23
					elif velocity_last.x < 0:
						$Sprite.frame = 22
					var t = create_tween()
					t.tween_property($Sprite, "position:y", -32, 0.24)
					await t.finished
					var t2 = create_tween()
					t2.tween_property($Sprite, "position:y", -6, .19)
					
					state = State.DEFAULT
					#velocity = velocity_last
			State.DEAD:
				navigation_agent.avoidance_enabled = false
				collision_layer = 0
				$AnimationPlayer.play("dead")
		$InteractBox.rotation = velocity_last.angle()

func _physics_process(delta):
	states_process(delta)
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
	if state == State.DEAD:
		velocity = Vector2()

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()

var slash_scale_last = 1
func attack():
	state_last = state
	if state == State.DEFAULT:
		state = State.ATTACK

func hurt(_damage = 1):
	if not state in [State.JUMP, State.HURT]:
		stats['hp'] -= _damage
		state_last = state
		state = State.HURT

func reset():
	state = state_last
	
func jump():
	state_last = state
	state = State.JUMP

func hurt_box_create(offset: Vector2, angle: float):
	var with = Game.scene_spawn(global_position + offset, preload("res://effects/weapon_effects/sword_slash.tscn"), velocity_last.angle())
	with.play("default")
	with.team = team
	with.scale.y = slash_scale_last
	slash_scale_last = -slash_scale_last
