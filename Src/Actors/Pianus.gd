extends KinematicBody2D

onready var animPlayer := $AnimationPlayer
onready var animPlayer2 := $AnimationPlayer2

var floaty_text_scene :=  preload("res://Src/UserInterface/FloatingText.tscn")

var hit_sound := load("res://Assets/Sounds/soHit0/soHit0.wav")
var charge_sound := load("res://Assets/Sounds/soBeamCharge/soBeamCharge.wav")
var beam_start := load("res://Assets/Sounds/soBeamStart/soBeamStart.wav")
var beam_shooting := load("res://Assets/Sounds/soBeamShooting/soBeamShooting.wav")
var beam_end := load("res://Assets/Sounds/soBeamEnd/soBeamEnd.wav")

var last_attack: = 0
var attacking := false

var dead := false

func _ready() -> void:
	last_attack = OS.get_ticks_msec()
	animPlayer.play("idle") 

func _on_WeaponHit_area_entered(area: Area2D) -> void:
	if dead:
		return
	
	var floaty_text = floaty_text_scene.instance()
	 
	floaty_text.position = Vector2(0,0)
	floaty_text.velocity = Vector2(rand_range(-50,50), -100)
	floaty_text.modulate = Color(rand_range(0.7, 1), rand_range(0.7,1), rand_range(0.7,1), 1.0)
	
	var ammount = randi() % 3 + 1
	
	floaty_text.text = ammount
	
	add_child(floaty_text)
		
	animPlayer2.play("hit")
	AudioManager.play_sfx(hit_sound)
	PlayerData.boss_health -= ammount #1
	Signals.signal_hit()
	

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void: 
	if anim_name == "laser_charge":
		animPlayer.play("laser_shot") 
		Signals.signal_release_laser()
	if anim_name == "laser_shot":
		attacking = false
		last_attack = OS.get_ticks_msec()
		animPlayer.play("idle")

func _process(delta: float) -> void:
	if dead:
		return
	
	if PlayerData.boss_health <= 0 and !dead:
		animPlayer.play("death")
		dead = true
		self.set_collision_layer_bit(2, false)
		
	if (OS.get_ticks_msec() - last_attack) > 7000 and !attacking:
		attack()
		
func attack() -> void:
	attacking = true 
	animPlayer.play("laser_charge")
	Signals.signal_charge()

func signal_death() -> void:
	Signals.signal_boss_death()

func signal_death_stomp() -> void:
	Signals.signal_boss_death_stomp()
