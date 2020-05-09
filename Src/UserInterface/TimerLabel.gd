extends Label

var ms := 0
var s := 0
var m := 0

func _process(delta: float) -> void:
	if ms > 9 :
		s += 1
		ms = 0
		
	if s > 59:
		m += 1
		s = 0
		
	self.text = str(str(m) if m > 9 else "0" + str(m)) + ":" +  str(str(s) if s > 9 else "0" + str(s)) +  ":" + str(str(ms) if ms > 9 else "0" + str(ms))


func _on_ms_timeout() -> void:
	ms += 1
