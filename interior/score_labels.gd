extends RichTextLabel

var default_text = "Score: "


func _process(delta: float) -> void:
	var text = str(default_text, str(Global.current_score))
	self.text = (text)
