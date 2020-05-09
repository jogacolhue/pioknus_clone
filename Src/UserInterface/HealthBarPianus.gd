extends Control

onready var boss_health_bar = $HealthOver 
onready var boss_health_under := $HealthUnder
onready var update_tween := $UpdateTween

func _ready() -> void:
	boss_health_bar.value = PlayerData.boss_health 
	boss_health_under.value = PlayerData.boss_health 
	_on_max_boss_health_updated(PlayerData.boss_health)
	PlayerData.connect("boss_health_updated", self, "boss_health_updated")

func boss_health_updated():
	_on_boss_health_updated(PlayerData.boss_health,0)

func _on_boss_health_updated(boss_health :float , ammount):
	boss_health_bar.value = boss_health
	update_tween.interpolate_property(boss_health_under, "value", boss_health_under.value, boss_health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT,0.4)
	update_tween.start()

func _on_max_boss_health_updated(max_boss_health:float):
	boss_health_bar.max_value = max_boss_health
	boss_health_under.max_value = max_boss_health
