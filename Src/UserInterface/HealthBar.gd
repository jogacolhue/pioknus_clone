extends Control

onready var health_bar = $HealthOver 
onready var health_under := $HealthUnder
onready var update_tween := $UpdateTween

func _ready() -> void:
	health_bar.value = PlayerData.health 
	health_under.value = PlayerData.health 
	_on_max_health_updated(PlayerData.health)
	PlayerData.connect("health_updated", self, "health_updated")

func health_updated():
	_on_health_updated(PlayerData.health,0)

func _on_health_updated(health :float , ammount):
	health_bar.value = health
	update_tween.interpolate_property(health_under, "value", health_under.value, health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT,0.4)
	update_tween.start()

func _on_max_health_updated(max_health:float):
	health_bar.max_value = max_health #max_health
	health_under.max_value = max_health
