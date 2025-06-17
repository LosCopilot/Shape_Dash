extends CanvasLayer

func update_score(value: int):
	$ScoreLabel.text = "Score: %d" % value
