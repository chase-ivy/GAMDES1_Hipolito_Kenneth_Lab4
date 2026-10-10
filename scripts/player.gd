
extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -900.0

var is_attacking: bool = false
var health: int = 100
var attack_damage: int = 25

var enemy: CharacterBody2D = null


func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	
	# Check attack input (Left Click)
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		animated_sprite_2d.play("attacking")
		
		# Find the enemy
		enemy = get_tree().get_first_node_in_group("enemy")
		
		# Deal damage if the enemy is nearby
		if enemy and is_instance_valid(enemy):
			var distance_to_enemy = global_position.distance_to(enemy.global_position)
			if distance_to_enemy <= 100.0:
				enemy.take_damage(attack_damage)
				print("You hit the enemy! Enemy HP: ", enemy.health)
			else:
				print("Enemy is too far away!")
		else:
			print("Enemy not found! Check the enemy group.")

	# Add animation
	if is_attacking:
		pass
	elif velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "walking"
	else:
		animated_sprite_2d.animation = "idle"
		
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not is_attacking:
			animated_sprite_2d.animation = "jumping"

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true


func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "attacking":
		is_attacking = false


func take_damage(amount: int) -> void:
	health -= amount
	print("Player HP: ", health)
	if health <= 0:
		queue_free()
