extends Node

class_name CountryData

export var display_name:String
export var initial_population: int
export var remaining_population: int
export var max_cattle_per_harvest: int
export var security_level: int
export var panic_level: int

export var mission_time: float
export(PackedScene) var cattle_scene
