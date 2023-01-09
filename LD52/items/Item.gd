extends Node2D

export var friendly_fire:bool = true
export var fuse_duration: float = 3.0
export var fuse_start_on_ready: bool = false
export var fuse_start_on_body_entered: bool = false
export var attack_damage: int = 10

var fuse_started = false
var fuse_timer = 0.0
var exploded = false

var cattle_nearby: Array
var alien_nearby: Array

func _ready():
	fuse_started = fuse_start_on_ready
	
func _process(delta):
	if not fuse_started:
		return
		
	if exploded:
		return
		
	fuse_timer += delta
	if(int(fuse_timer*10) % 6 == 0):
		$EplosionArea2D.visible = !$EplosionArea2D.visible
	if fuse_timer >= fuse_duration:
		exploded = true
		explode()
		
func explode():
	for cattle in cattle_nearby:
		cattle.take_damage(attack_damage)
	for alien in alien_nearby:
		alien.take_damage(attack_damage)
	SfxManager.play("bomb")
	if $ExplosionAnimatedSprite != null:
		$ExplosionAnimatedSprite.visible = true
		$ExplosionAnimatedSprite.play("default")
		yield(get_tree().create_timer(0.5),"timeout")
	queue_free()
	
func _on_EplosionArea2D_body_entered(body):
	if body is Cattle:
		cattle_nearby.append(body)
		if fuse_start_on_body_entered:
			fuse_started = true
	if body is Unit:
		alien_nearby.append(body)

func _on_EplosionArea2D_body_exited(body):
	if body is Cattle:
		if cattle_nearby.has(body):
			cattle_nearby.erase(body)
	if body is Unit:
		if alien_nearby.has(body):
			alien_nearby.erase(body)
