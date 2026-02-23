extends CharacterBody2D

# --- CONFIGURATION ---
@export var speed: float = 150.0
@export var glide_speed: float = 300.0
@export var gravity: float = 1200.0
@export var glide_gravity: float = 150.0
@export var wall_slide_speed: float = 50.0
@export var max_jump_force: float = -800.0
@export var jump_charge_speed: float = 700.0
@export var trajectory_visible: bool = true

# --- STATE VARIABLES ---
var charge_power: float = 0.0
var is_charging: bool = false
var is_gliding: bool = false
var is_on_wall_latch: bool = false
var locked_direction: float = 0.0

@onready var trajectory_line = $Line2D


func _physics_process(delta: float):
	# 1. GRAVITY & LEDGE LOGIC
	if not is_on_floor():
		# Check for Wall Latch (only if moving downward or neutral)
		#if is_on_wall_only() and velocity.y > -10.0:
		#	is_on_wall_latch = true
		#	is_gliding = false
		#	var friction = get_wall_friction()
		#	velocity.y = wall_slide_speed * friction
			#velocity.y = wall_slide_speed # The "dragged down" effect
		# Check for Gliding
		if Input.is_action_pressed("ui_jump") and velocity.y > 0.0 and not is_on_wall_latch:
			is_gliding = true
			velocity.y = move_toward(velocity.y, glide_gravity, gravity * delta)
		# Normal Gravity
		else:
			is_on_wall_latch = false
			is_gliding = false
			velocity.y += gravity * delta
	else:
		# Reset air states on floor
		is_on_wall_latch = false
		is_gliding = false
		velocity.x = move_toward(velocity.x, 0.0, speed * delta * 10.0)

	# 2. INPUT HANDLING
	if is_on_floor():
		handle_ground_input(delta)
	else:
		handle_air_input(delta)
	
	# 3. TRAJECTORY VISUAL
	if is_charging:
		update_trajectory(delta)
		if trajectory_visible:
			trajectory_line.modulate.a = 1.0
		else:
			trajectory_line.modulate.a=0.0
	
	move_and_slide()
	update_animations()



func get_wall_friction() -> float:
	if not is_on_wall():
		return 1.0 # Default friction
		
	# Get the collision information
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check if we hit a TileMap
		if collider is TileMap:
			var tile_pos = collider.local_to_map(collider.to_local(collision.get_position() - collision.get_normal()))
			var data = collider.get_cell_tile_data(0, tile_pos) # 0 is the layer index
			if data:
				return data.get_custom_data("wall_friction")
				
	return 1.0 # Fallback



func handle_ground_input(delta: float):
	if Input.is_action_pressed("ui_jump"):
		is_charging = true
		velocity.x = 0.0
		var current_input = Input.get_axis("ui_left", "ui_right")
		if current_input != 0:
			locked_direction = current_input
		charge_power = move_toward(charge_power, max_jump_force, jump_charge_speed * delta)
	elif Input.is_action_just_released("ui_jump") and is_charging:
		execute_jump()
	elif not is_charging:
		var direction = Input.get_axis("ui_left", "ui_right")
		velocity.x = direction * speed
		if direction != 0:
			locked_direction = direction

func handle_air_input(delta: float):
	# Charge a jump while latched to the wall
	if is_on_wall_latch:
		if Input.is_action_pressed("ui_jump"):
			is_charging = true
			locked_direction = get_wall_normal().x # Automatically jump AWAY from wall
			charge_power = move_toward(charge_power, max_jump_force, jump_charge_speed * delta)
		elif Input.is_action_just_released("ui_jump") and is_charging:
			execute_jump()
		else:
			is_charging = false
			charge_power = 0.0
			
	# Glide drift logic
	elif is_gliding:
		var direction = Input.get_axis("ui_left", "ui_right")
		if sign(direction) == sign(locked_direction) and direction != 0:
			velocity.x = move_toward(velocity.x, direction * glide_speed, speed * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, speed * delta * 0.5)

func execute_jump():
	velocity.y = charge_power
	$JumpSound.play()
	if locked_direction != 0:
		velocity.x = locked_direction * (speed * 1.5)
		# The "Launch Snap" to clear collision
		position.y -= 3.0
		position.x += locked_direction * 2.0
	
	var tween = create_tween()
	tween.tween_property(trajectory_line, "modulate:a", 0.0, 0.3)
	
	is_charging = false
	charge_power = 0.0
	is_on_wall_latch = false

func update_trajectory(delta: float):
	trajectory_line.clear_points()
	var temp_pos = Vector2.ZERO
	var temp_vel = Vector2(locked_direction * (speed * 1.5), charge_power)
	for i in range(30):
		trajectory_line.add_point(temp_pos)
		temp_vel.y += gravity * delta
		temp_pos += temp_vel * delta

func update_animations():
	# Flip Logic
	if is_on_wall_latch and not is_charging:
		$AnimatedSprite2D.flip_h = (get_wall_normal().x > 0) # Face wall while sliding
	elif locked_direction != 0:
		$AnimatedSprite2D.flip_h = (locked_direction < 0) # Face jump direction
		
	# Animation Choice
	if is_on_wall_latch:
		$AnimatedSprite2D.play("run") # Or a "wall_slide" animation
		$AnimatedSprite2D.rotation = 0
	elif is_gliding:
		$AnimatedSprite2D.play("glide")
		$AnimatedSprite2D.rotation = lerp_angle($AnimatedSprite2D.rotation, deg_to_rad(locked_direction * 15), 0.1)
	elif not is_on_floor():
		$AnimatedSprite2D.play("jump")
		$AnimatedSprite2D.rotation = lerp_angle($AnimatedSprite2D.rotation, 0, 0.1)
	elif is_charging:
		$AnimatedSprite2D.play("idle")
		$AnimatedSprite2D.rotation = 0
	elif velocity.x != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")
