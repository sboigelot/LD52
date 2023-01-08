extends Node2D

export var fuse_duration: float = 3.0
export var fuse_start_on_ready: bool = false
export var fuse_start_on_body_entered: bool = false
export var attack_damage: int = 10

var fuse_started = false
var fuse_timer = 0.0

var cattle_nearby: Array

func _ready():
	fuse_started = fuse_start_on_ready
	
func _process(delta):
	if not fuse_started:
		return
		
	fuse_timer += delta
	visible = int(fuse_timer*10) % 2 == 0 #todo improve
	if fuse_timer >= fuse_duration:
		explode()
		
func explode():
	for cattle in cattle_nearby:
		cattle.take_damage(attack_damage)
	queue_free()
	
func _on_EplosionArea2D_body_entered(body):
	if body is Cattle:
		cattle_nearby.append(body)
		if fuse_start_on_body_entered:
			fuse_started = true

func _on_EplosionArea2D_body_exited(body):
	if body is Cattle:
		if cattle_nearby.has(body):
			cattle_nearby.erase(body)
