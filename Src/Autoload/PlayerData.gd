extends Node

signal health_updated
signal boss_health_updated
signal dragon_crusher_updated

var health: = 100 setget set_health
var boss_health: = 500 setget set_boss_health
var crusher_ready := false setget set_dragon_crusher

func set_health(value: int) -> void:
	health = value
	emit_signal("health_updated")

func set_boss_health(value: int) -> void:
	boss_health = value
	emit_signal("boss_health_updated")
	
func set_dragon_crusher(value: bool) -> void:
	crusher_ready = value
	emit_signal("dragon_crusher_updated")

func reset() -> void:
	health = 100
	boss_health = 500
	crusher_ready = false
	emit_signal("reset")
