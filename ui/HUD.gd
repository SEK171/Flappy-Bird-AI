extends CanvasLayer

# the score label refrence
onready var score_label: Node = $Score


# function to update the score
func update_score_label(new_score: int) -> void:
	score_label.text = str(new_score)

