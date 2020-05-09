extends Actor

var floaty_text_scene :=  preload("res://Src/UserInterface/FloatingText.tscn")

onready var animPlayer := $AnimationPlayer
onready var animInv := $AnimationInvulnerable
onready var sprite := $Sprite
onready var dust := $Dust

var state_machine
var anim = "idle"
var attack = false
var normal_attack_count = 0
var last_position = "right"
var in_air = false

var hitstun: = 0
var hitdirection: = 0
var damage_zone := false
var damage_area := false

var invulnerable: = false
var invulnerability_start: = 0

var dead := false

var jump_sound := load("res://Assets/Sounds/soPlayerJump/soPlayerJump.wav")
var swing_sound := load("res://Assets/Sounds/soSwing/soSwing.wav")
var death_sound := load("res://Assets/Sounds/soDeath/soDeath.wav")
var land_sounds := [load("res://Assets/Sounds/soLand0/soLand0.wav"),
					load("res://Assets/Sounds/soLand1/soLand1.wav"),
					load("res://Assets/Sounds/soLand2/soLand2.wav")]


func _ready() -> void:  
	animPlayer.play(anim)
	Signals.connect("hit", self, "hit")
	Signals.connect("charge", self, "charge")
	Signals.connect("release_laser", self, "release_laser")
	Signals.connect("boss_death", self, "boss_death")
	Signals.connect("boss_death_stomp", self, "boss_death_stomp")

func hit():
	if !PlayerData.crusher_ready:
		normal_attack_count+=1;
	$Camera2D/ScreenShake.start()

func charge():
	$Camera2D/ScreenShake.start(3, 20, 16, 1)
	
func release_laser():
	$Camera2D/ScreenShake.start(5, 30, 16, 1)

func boss_death():
	$Camera2D/ScreenShake.start(2.5, 30, 16, 1)

func boss_death_stomp():
	$Camera2D/ScreenShake.start(0.5, 30, 16, 1)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "strong_attack":
		PlayerData.crusher_ready = false
		normal_attack_count = 0 
		
	if anim_name == "weak_attack" or anim_name == "strong_attack":
		attack = false
	if anim_name == "death":
		animPlayer.play("death_idle")

func _on_PlatformDetecter_body_exited(body: Node) -> void:
	set_collision_mask_bit(3,true)

func _on_EnemyDetector_body_entered(body: Node) -> void:
	damage_zone = true
	if invulnerable or dead:
		return 
		 
	var collision_point = global_position - body.global_position
	hitdirection = sign(collision_point.x)
#	PlayerData.health -= 5
#	hitstun = 20
#	invulnerable = true
#	invulnerability_start = OS.get_ticks_msec()
#	animInv.play("invulnerable")  
	_decrease_healt()

func _on_EnemyDetector_body_exited(body: Node) -> void:
	damage_zone = false

func _on_EnemyDetector_area_entered(area: Area2D) -> void:
	damage_area = true
	if invulnerable or dead:
		return 
		 
	var collision_point = global_position - area.global_position
	hitdirection = sign(collision_point.x)
#	PlayerData.health -= 5
#	hitstun = 20
#	invulnerable = true
#	invulnerability_start = OS.get_ticks_msec()
#	animInv.play("invulnerable")  
	_decrease_healt()

func _on_EnemyDetector_area_exited(area: Area2D) -> void:
	print(area.name)
	damage_area = false

func _physics_process(delta: float) -> void:
	var is_jump_interrupted: = Input.is_action_just_released("jump") and _velocity.y < 0.0 
	var direction: = get_direction()
	_velocity = calculate_move_velocity(_velocity,direction,speed, is_jump_interrupted) 
	
	check_damage_zone()
	check_hitstun()
	
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)  
		
	asign_animation()
	
	if in_air and _velocity.y == 0 and is_on_floor():
		in_air = false
		AudioManager.play_sfx(land_sounds[randi() % 2])
	
	check_invulnerability()
		
func check_invulnerability(): 
	if (OS.get_ticks_msec() - invulnerability_start) > 2000:
		invulnerability_start = 0
		invulnerable = false  
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and dead:
		get_tree().reload_current_scene()
		dead = false
		PlayerData.reset()
	
	if dead:
		return
	
	if event.is_action_pressed("move_left") and last_position != "left":
		last_position = "left"
		self.scale.x = -1
	
	if event.is_action_pressed("move_right") and last_position != "right":
		last_position = "right"
		self.scale.x = -1
		
	if event.is_action_pressed("jump"):
		if Input.is_action_pressed("move_down") and is_on_floor():
			set_collision_mask_bit(3,false)

func asign_animation() -> void:
	if dead:
		return
	
	if PlayerData.health <= 0 and !dead:
		dead = true
		AudioManager.play_sfx(death_sound)
		animPlayer.play("death")
		return
	
	if Input.is_action_just_pressed("weak_attack") and !attack: 
		attack = true
		AudioManager.play_sfx(swing_sound)
		animPlayer.play("weak_attack")
		if normal_attack_count >= 3 and !PlayerData.crusher_ready:
			normal_attack_count = 0
			PlayerData.crusher_ready = true
		return
		
	if Input.is_action_just_pressed("strong_attack") and !attack and PlayerData.crusher_ready:
		attack = true
		AudioManager.play_sfx(swing_sound)
		animPlayer.play("strong_attack")
		return
		
	if !attack: 
		if _velocity.y != 0:
			anim = "jump"
			animPlayer.play(anim)
			return  
		
		if _velocity.x == 0 and is_on_floor() and Input.is_action_pressed("move_down"):
			anim = "crouch"
		elif _velocity.x == 0 and is_on_floor():
			anim = "idle" 
		elif is_on_floor():
			anim = "run"
			
		animPlayer.play(anim) 

func get_direction() -> Vector2:
	if dead:
		return Vector2()
		
	return Vector2(
		Input.get_action_strength("move_right") - 
		Input.get_action_strength("move_left"),
		-1.0 if Input.get_action_strength("jump") and is_on_floor() and !Input.is_action_pressed("move_down") else 1.0
	)

func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var out = linear_velocity
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time() 
	if direction.y == -1.0:
		out.y = speed.y * direction.y
		AudioManager.play_sfx(jump_sound)
	if is_jump_interrupted:
		out.y = 0 
	
	if out.y != 0 and !is_on_floor():
		in_air = true
	
	if attack and is_on_floor():
		out.x = 0
	
	return out
 

func check_hitstun(): 
	if hitstun > 0:
		if hitstun == 19:
			_velocity.y = -600 
		hitstun -= 1
		_velocity.x = hitdirection * hitstun * 3500 * get_physics_process_delta_time()

func check_damage_zone():
	if dead:
		return
		
	if (damage_zone or damage_area) and !invulnerable:
		_decrease_healt()


func _decrease_healt():
	
	var floaty_text = floaty_text_scene.instance()
	 
	floaty_text.position = self.position #Vector2(0,0)
	floaty_text.position.x -= 50
	floaty_text.position.y -= 200
	floaty_text.velocity = Vector2(rand_range(-50,50), -100)
	floaty_text.modulate = Color(rand_range(0.7, 1), rand_range(0.7,1), rand_range(0.7,1), 1.0)
 
	var ammount = randi() % 10 + 5
	
	floaty_text.text = ammount
	
	get_parent().add_child(floaty_text)
	
#
#	if last_position == "left":
#		floaty_text.scale.x = -1
#
#	if last_position == "right" and floaty_text.scale.x == -1:
#		floaty_text.scale.x = -1
	
	PlayerData.health -= ammount #5
	hitstun = 20
	invulnerable = true
	invulnerability_start = OS.get_ticks_msec()
	animInv.play("invulnerable")  
	



