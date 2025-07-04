extends Node


var board: Array = []
var ai_board: Array = []

var help_current_array: Array = []
var is_attack: bool = false
var previousPawn: String = ""
var loop_count: int = 0

func set_board(new_board: Array):
	board = new_board
	
