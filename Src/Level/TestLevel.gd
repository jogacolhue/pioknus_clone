extends Node2D

var music_clip : AudioStream = load("res://Assets/Sounds/soPianusIntro/soPianusIntro.ogg")
var music_loop : AudioStream = load("res://Assets/Sounds/soPianusLoop/soPianusLoop.ogg")

func _ready() -> void:
	AudioManager.connect("music_end", self, "change_music")
	AudioManager.play_music(music_clip)
	pass
func change_music() -> void:
	AudioManager.play_music(music_loop)
	pass
