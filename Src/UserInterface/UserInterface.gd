extends Control

var crusher_ready := load("res://Assets/Sprites/sSkillIconDragonCrusher/19067cf0-3542-4738-83ec-f49021761d83.png")
var crusher_off := load("res://Assets/Sprites/sSkillIconDragonCrusher/94ae6bf9-1462-492f-8511-f27b3b96eef5.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerData.connect("dragon_crusher_updated", self, "dragon_crusher_updated")
	pass # Replace with function body.

func dragon_crusher_updated():
	if PlayerData.crusher_ready:
		$HBoxContainer/DragonCrusher.texture = crusher_ready
	else:
		$HBoxContainer/DragonCrusher.texture = crusher_off

func _process(delta: float) -> void:
	if PlayerData.health <= 0:
		$TextureRect.visible = true
	else:
		$TextureRect.visible = false
