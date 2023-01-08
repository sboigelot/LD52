extends KinematicBody2D

class_name Actor

export(NodePath) var np_sprite
onready var sprite = get_node(np_sprite) as Sprite

export(NodePath) var np_animated_sprite
onready var animated_sprite = get_node(np_animated_sprite) as AnimatedSprite

export(NodePath) var np_move_animation_player
onready var move_animation_player = get_node_or_null(np_move_animation_player) as AnimationPlayer

export(NodePath) var np_boost_particule
onready var boost_particule = get_node_or_null(np_boost_particule) as Particles2D

export(NodePath) var fsm_np
onready var fsm = get_node(fsm_np) as StateMachinePlayer

signal took_damage
signal died

var knockback:Vector2
var knockback_timer:float
var time_in_state: float = 0.0
var idle_time: float = 1.0
var destination: Vector2
var paused: bool = false

export(Resource) var data

func _process(delta):
	if paused:
		return
		
	if knockback_timer > 0:
		move_and_slide(knockback)
		knockback_timer -= delta
		
	if data == null:
		return
		
	regen_stamina(delta)
	regen_health(delta)

func regen_stamina(delta):
	if paused:
		return
		
	if data.stamina < data.max_stamina:
		data.stamina += data.stamina_regen_per_second * delta
		data.stamina = min(data.stamina, data.max_stamina)
		
func regen_health(delta):
	if paused:
		return
		
	if data.health_regen_per_second == 0:
		return
		
	if data.health < data.max_health:
		data.health += data.health_regen_per_second * delta
		data.health = min(data.health, data.max_health)
		
func boost(direction, delta)->bool:
	if paused:
		return false
		
	if not data.can_move:
		return false
		
	if boost_particule != null:
		boost_particule.emitting = true
		
	if knockback_timer > 0:
		return false
		
	if direction == Vector2(0,0):
		return false
	
	var stamina_cost = data.boost_stamina_cost_per_second * delta
	if data.stamina < stamina_cost:
		move(direction)
		return false
		
	data.stamina -= stamina_cost
	var boost_velocity = direction * data.speed * data.boost_speed_multiplier
	move_and_slide (boost_velocity)
	return true

func move(direction):
	if paused:
		return
		
	if not data.can_move:
		return
		
	if boost_particule != null:
		boost_particule.emitting = false
		
#	modulate= Color.white
	if knockback_timer > 0:
		return
		
	# We don't need to multiply velocity by delta because "move_and_slide" already takes delta time into account.
	# The second parameter of "move_and_slide" is the normal pointing up.
	# In the case of a 2D platformer, in Godot, upward is negative y, which translates to -1 as a normal.
	var velocity = direction * data.speed
	move_and_slide(velocity)

func flip_and_animate(direction):
	if paused:
		return
		
	if direction == Vector2():
		return
		
	if sprite != null:
		sprite.flip_h = direction.x < 0
	
	if animated_sprite != null:
		animated_sprite.flip_h = direction.x < 0
	
	if move_animation_player != null and not move_animation_player.is_playing():
		move_animation_player.play("Walk")

func knockback(origin:Vector2, force:float, time:float):
	var direction = origin.direction_to(global_position)
	knockback = direction * force
	knockback_timer = time
	
func take_damage(damage):
	if data.invincible:
		return
	
#	SfxManager.play(data.take_damage_sfx_name)
	data.health -= damage
	if data.health <= 0:
		die()
	else:
		blink(Color.red)
	
	emit_signal("took_damage", self)
	data.invincible = true
	yield(get_tree().create_timer(0.3), "timeout")
	data.invincible = false
		
func die():
	data.can_move = false
	modulate = Color.red
	yield(get_tree().create_timer(0.3), "timeout")

	on_death()
	
	emit_signal("died",self)
	queue_free()

func on_death():
	pass

func blink(color:Color, time:float = 0.3):
	modulate = color
	yield(get_tree().create_timer(time), "timeout")
	modulate = Color.white
