class_name  GameState

var board
var previousPawn
var previousTurnWasAttackGameState
var previousPawnAttackGameState
var targetDepth: int
var curretDepth: int
var nonCaptureMoveCount: int
var created_king = false
var currect_turn_attack = false
var is_game_over: bool = false

func _init(_board,_previousTurnWasAttack,_previousPawnAttack,_curretDepth):
	board = _board.duplicate(true)
	previousTurnWasAttackGameState = _previousTurnWasAttack
	previousPawnAttackGameState = _previousPawnAttack
	curretDepth = _curretDepth
