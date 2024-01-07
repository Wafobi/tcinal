class_name LevelStats extends Control

func getHealthBar() -> ProgressBar :
	return  $VBoxContainer/healthBar

func getLabel() -> Label :
	return $VBoxContainer/HBoxContainer/LevelLabel
