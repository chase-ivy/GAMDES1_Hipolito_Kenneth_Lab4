
extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var detection_range: float = 300.0
@export var attack_range: float = 70.0
@export var health: int = 100
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0

var player: CharacterBody2D = null
var is_attacking: bool = false
var can_attack: bool = true


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Find player again if necessary
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

	var direction: float = 0.0

	if player and not is_attacking:
		var distance_to_player = global_position.distance_to(player.global_position)

		if distance_to_player <= detection_range:
			direction = sign(player.global_position.x - global_position.x)

			if direction > 0:
				animated_sprite_2d.flip_h = false
			elif direction < 0:
				animated_sprite_2d.flip_h = true

			if distance_to_player > attack_range:
				velocity.x = direction * SPEED
				animated_sprite_2d.play("walking")
			else:
				velocity.x = 0
				animated_sprite_2d.play("idle")

				# Attack repeatedly when cooldown permits
				if can_attack:
					is_attacking = true
					can_attack = false
					animated_sprite_2d.play("attacking")

					player.take_damage(attack_damage)
					print("Enemy hit you! Player HP: ", player.health)

					start_attack_cooldown()
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animated_sprite_2d.play("idle")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_attacking:
			animated_sprite_2d.play("idle")

	move_and_slide()


func start_attack_cooldown() -> void:
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "attacking":
		is_attacking = false


func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy HP: ", health)
	if health <= 0:
		queue_free()
