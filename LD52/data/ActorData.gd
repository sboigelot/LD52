extends Resource

class_name ActorData

export var max_health:int = 5
export var health:float = 5
export var health_regen_per_second:float = 0

export var max_stamina:float = 0
export var stamina_regen_per_second:float = 0.2
export var stamina:float = 0

export var boost_stamina_cost_per_second:float = 1
export var boost_speed_multiplier = 1.5

var invincible:bool = false
export var speed: int = 50
export var can_move: bool = true
export var auto_boost: bool
export var auto_boost_threshold: float

export var sigth_range: float = 300.0
export var move_threshold: float = 20.0
export var attack_damage: int = 0
export var attack_range: float = 60.0
export var attack_is_melee: bool = true
export var range_attack_projectile_scene: PackedScene
export var range_attack_projectle_speed:float = 200

export var suffer_knockback_on_attacks: bool = false
export var take_damage_sfx_name: String = ""
export var attack_sfx_name: String = ""
