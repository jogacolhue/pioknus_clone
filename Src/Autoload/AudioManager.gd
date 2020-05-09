extends Node

var dic: Dictionary = {}
signal music_end

func play_sfx(audio_clip: AudioStream, priority : int = 0) -> void:
	for child in $Sfx.get_children():
		if !child.playing:
			child.stream = audio_clip
			child.play()
#			dic[child.name] = priority
			break
		
#		if child.get_index() == $Sfx.get_child_count() -1:
#			var priority_player = check_priority(dic, priority)
#			if priority_player != null:
#				$Sfx.get_node(priority_player).stream = audio_clip
#				$Sfx.get_node(priority_player).play()
#				dic[priority_player] = priority

		if child.get_index() == $Sfx.get_child_count() -1:
			var priority_player = find_oldest_player()
			if priority_player != null:
				priority_player.stream = audio_clip
				priority_player.play() 

func check_priority(_dic: Dictionary, _priority):
	var prio_list : Array = []
	
	for key in _dic:
		if _priority > _dic[key]:
			prio_list.append(key)
	
	var last_prio = null
	for key in prio_list:
		if last_prio == null:
			last_prio = key
			continue
		if _dic[key] < _dic[last_prio]:
			last_prio = key
	return last_prio

func find_oldest_player():
	var last_child = null
	
	for child in $Sfx.get_children():
		if last_child == null:
			last_child = child
			continue
		if child.get_playback_position() > last_child.get_playback_position():
			last_child = child
	
	return last_child

func play_music(music_clip:AudioStream) -> void:
	$Music/MusicPlayer.stream = music_clip
	$Music/MusicPlayer.play()
	
func _on_MusicPlayer_finished() -> void:
	emit_signal("music_end")
