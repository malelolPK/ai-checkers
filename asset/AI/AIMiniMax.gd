extends Node

var main_script = load("res://main.gd").new()
var PawnMovement = load("res://asset/FUNKCJE LOGIKI GRY/PawnMovement.gd").new()
var AttackMoves

var how_much_is_search: int
var search: int
var possible_move_black: Dictionary = {}
var what_pawn_was: String
var old_grid_pos: Vector2i
var new_grid_pos: Vector2i
var possible_move_king: Array
var possible_move: Array
var who_win: String
var isPlayerTurn: bool = false
var isAITurn: bool = true
var previousTurnWasAttack: bool = false
var previousTurn: String
var currect_turn_attack: bool
var TYPE_PAWNS: String = ""

var number_white_king: int = 0
var number_black_king: int = 0
var previousPawnAttack = "nic"
var previousPawnAttackFullName

func find_pawn_position(pawn,game_state):
	for i in range(8):
		for j in range(8):
			if main_script.get_pawn_info(game_state.board[i][j],false,true) == pawn:
				return Vector2i(j, i)
	return null

func return_random_move(_pawns_moves):
	var selected_pawn = select_random(_pawns_moves.keys())
	var selected_move = select_random(_pawns_moves[selected_pawn])
	return [selected_pawn,selected_move]
func select_random(lista):
	return lista[randi() % lista.size()]

var previousPawnAttackInFindBest
var first_move = true

func findBestMove(_board,targetDepth, TYPE: String,_previousTurnWasAttack, _previousPawnAttack):
	TYPE_PAWNS = TYPE
	how_much_is_search = 0;
	var bestScore
	AttackMoves = load("res://asset/FUNKCJE LOGIKI GRY/AttackMoves.gd").new()
	AttackMoves.is_attack_move_available_for_type(TYPE_PAWNS,_board)
	if TYPE_PAWNS == "black":
		bestScore = 100000
	else: # jeżeli jest biały
		bestScore = -100000
	var curDepth = 0
	var bestMove_Panw = []
	var pawns_moves = {}
	pawns_moves.merge(PawnMovement.all_possible_move_types_pawn(TYPE_PAWNS,_board))
	if first_move:
		var random_move_pawn = return_random_move(pawns_moves)
		first_move = false
		return random_move_pawn
	if _previousTurnWasAttack and main_script.get_pawn_info(_previousPawnAttack,true,false).begins_with(TYPE_PAWNS):
		pawns_moves = {}
		if main_script.get_pawn_info(_previousPawnAttack,true,false).ends_with("King"):
			pawns_moves.merge({_previousPawnAttack: PawnMovement.possible_move_pawn_king(_previousPawnAttack,_board)})
		else:
			pawns_moves.merge({_previousPawnAttack: PawnMovement.posibble_move_pawn(_previousPawnAttack,_board)})

	for pawn in pawns_moves:
		var moves = pawns_moves[pawn]
		for move in moves:
			var new_board = _board.duplicate(true)
			var game_state = load("res://asset/Board/GameState.gd").new(_board,_previousTurnWasAttack,_previousPawnAttack)
			what_pawn_was = main_script.get_pawn_info(pawn, true, false)
			ai_make_move(pawn,move,game_state)
			game_turn(game_state)
			if TYPE_PAWNS == "black":
				var score = Minimax(game_state, curDepth, targetDepth, is_currect_turn_attack(false))
				if (score < bestScore):
					bestScore = score
					bestMove_Panw.append([pawn,move])
				print("score ",score)
			else:
				var score = Minimax(game_state, curDepth, targetDepth, is_currect_turn_attack(true))
				if (score > bestScore):
					bestScore = score
					bestMove_Panw.append([pawn,move])
					
	if bestMove_Panw.size() > 1:
		return select_random(bestMove_Panw)
	else:
		return bestMove_Panw[0]

func ai_make_move(pawn, move,game_state):
	var target_position = Vector2i(move[1], move[0])
	old_grid_pos = find_pawn_position(main_script.get_pawn_info(pawn,false,true),game_state)
	new_grid_pos = target_position
	var pawn_name = main_script.get_pawn_info(pawn, true, false)
	if pawn_name.ends_with("King"):
		possible_move_king.append(move)
		make_move_ai(pawn,game_state)
	else:
		possible_move.append(move)
		make_move_ai(pawn,game_state)
		if GlobalVariables.is_attack:
			previousPawnAttack = pawn

func make_move_ai(pawn, game_state):
	var pawn_info = main_script.get_pawn_info(pawn, true, false)
	var is_king = pawn_info == "whiteKing" or pawn_info == "blackKing"
	if is_king:
		if not GlobalVariables.is_attack:
			pass
			make_move_diagonal_king(pawn,game_state)
		else:
			pass
			make_jump_diagonal_king(pawn,game_state)
	else:
		if not GlobalVariables.is_attack:
			make_move_diagonal(pawn,game_state)
		else:
			pass
			make_jump_diagonal(pawn,game_state)
			
func make_move_diagonal(pawn, game_state):
	game_state.board[old_grid_pos.y][old_grid_pos.x] = null
	game_state.board[new_grid_pos.y][new_grid_pos.x] = pawn
	
func make_jump_diagonal(pawn, game_state):
	var mid_x = (new_grid_pos.x + old_grid_pos.x) / 2
	var mid_y = (new_grid_pos.y + old_grid_pos.y) / 2
	game_state.board[mid_y][mid_x] = null
	game_state.board[old_grid_pos.y][old_grid_pos.x] = null
	game_state.board[new_grid_pos.y][new_grid_pos.x] = pawn
	GlobalVariables.is_attack = false
	previousTurnWasAttack = true

func make_move_diagonal_king(pawn, game_state):
	game_state.board[old_grid_pos.y][old_grid_pos.x] = null
	game_state.board[new_grid_pos.y][new_grid_pos.x] = pawn

func make_jump_diagonal_king(pawn, game_state):
	# direction (1,1) (1,-1) (-1,1) (-1,-1)
	var direction = Vector2i(0, 0)
	var difference:Vector2i = new_grid_pos - old_grid_pos
	var max_abs: int = max(abs(difference.x), abs(difference.y))
	direction = Vector2i(difference.x / max_abs, difference.y / max_abs)
	var current_position = old_grid_pos + direction
	while current_position != new_grid_pos:
		if current_position.y >= 0 and current_position.y < game_state.board.size() and current_position.x >= 0 and current_position.x < game_state.board[0].size():
			if game_state.board[current_position.y][current_position.x] != null and main_script.get_pawn_info(game_state.board[current_position.y][current_position.x], true, false) != main_script.get_pawn_info(pawn, true, false): # main_script.get_pawn_info(pawn, true, false)
				game_state.board[current_position.y][current_position.x] = null
		current_position += direction
	game_state.board[old_grid_pos.y][old_grid_pos.x] = null
	game_state.board[new_grid_pos.y][new_grid_pos.x] = pawn
	GlobalVariables.is_attack = false

# func sprawdzająca ilość pionków konretnego typa
func isNoLeftPawns(_type_pawn: String, game_state):
	var number_of_white = 0
	var number_of_black = 0
	for i in (8):
		for j in (8):
			if main_script.get_pawn_info(game_state.board[i][j], true, false).begins_with("white"):
				number_of_white += 1
			elif main_script.get_pawn_info(game_state.board[i][j], true, false).begins_with("black"):
				number_of_black += 1
	if _type_pawn == "white":
		return (number_of_white == 0)
	if _type_pawn == "black":
		return (number_of_black == 0)
	return false

func isInPossibleToMove(_type_pawn: String, game_state):
	if _type_pawn == "white":
		if PawnMovement.all_possible_moves("white", game_state.board) and PawnMovement.all_possible_moves("whiteKing", game_state.board):
			return true
	if _type_pawn == "black":
		if PawnMovement.all_possible_moves("black", game_state.board) and PawnMovement.all_possible_moves("blackKing", game_state.board):
			return true
	return false

func game_end(game_state):
	if isInPossibleToMove("white",game_state) or isNoLeftPawns("white",game_state):
		who_win = "black"
		return true
	elif isInPossibleToMove("black",game_state) or isNoLeftPawns("black",game_state):
		who_win = "white"
		return true
	else:
		who_win = "nikt"
	return false

func evaluate(game_state):
	var score = 0
	for i in range(8) :
		for j in range(8) :
			if game_state.board[i][j] != null:
				var pawn_info = main_script.get_pawn_info(game_state.board[i][j], true, false)
				if pawn_info.begins_with("white"):
					if pawn_info.ends_with("King"):
						score += 5
					if i >= 2 and i < 1:
						score += 2
					if j == 0 or j == 7:
						score += 2
					if (j >= 3 and j <= 5) and (i >= 3 and i <= 5):
						score += 2
					else:
						score += 1
				elif pawn_info.begins_with("black"):
					if pawn_info.ends_with("King"):
						score -= 5
					if i >= 7 and i < 8:
						score -= 2
					if j == 0 or j == 7:
						score -= 2
					if (j >= 3 and j <= 5) and (i >= 3 and i <= 5):
						score -= 2
					else:
						score -= 1
	return score
	
func Minimax(game_state, curDepth, targetDepth, isMax):
	var result = evaluate(game_state)
	
	if targetDepth == 0 or game_end(game_state):
		how_much_is_search += 1
		if who_win == "black":
			return -100
		elif who_win == "white":
			return 100
		else:
			return result
	if targetDepth > 0:
		targetDepth -= 1
		# Ruch MAX
		if(isMax):
			var bestScore = -1000
			AttackMoves.is_attack_move_available_for_type("black",game_state.board)
			var pawns_moves = {}
			pawns_moves.merge(PawnMovement.all_possible_move_types_pawn("black",game_state.board))
			if game_state.previousTurnWasAttackGameState and main_script.get_pawn_info(game_state.previousPawnAttackGameState,true,false).begins_with("black"):
				pawns_moves = {}
				if previousPawnAttack.ends_with("King"):
					pawns_moves.merge({game_state.previousPawnAttackGameState: PawnMovement.possible_move_pawn_king(game_state.previousPawnAttackGameState,game_state.board)})
				else:
					pawns_moves.merge({game_state.previousPawnAttackGameState: PawnMovement.posibble_move_pawn(game_state.previousPawnAttackGameState,game_state.board)})
			for pawn in pawns_moves:
				var moves = pawns_moves[pawn]
				for move in moves:
					var new_board = game_state.board.duplicate(true)
					var game_state_two = load("res://asset/Board/GameState.gd").new(new_board,game_state.previousTurnWasAttackGameState,game_state.previousPawnAttackGameState)
					
					what_pawn_was = main_script.get_pawn_info(pawn, true, false)
					ai_make_move(pawn,move,game_state_two)
					game_turn(game_state_two)
					var score = Minimax(game_state_two, curDepth + 1,targetDepth, is_currect_turn_attack(false))
					bestScore = max(score, bestScore) # wybiera Max z dzieci
			return bestScore
		# Ruch MIN
		else:
			var bestScore = 1000
			AttackMoves.is_attack_move_available_for_type("white",game_state.board)
			var pawns_moves = {}
			pawns_moves.merge(PawnMovement.all_possible_move_types_pawn("white",game_state.board))
			if game_state.previousTurnWasAttackGameState and main_script.get_pawn_info(game_state.previousPawnAttackGameState,true,false).begins_with("white"):
				pawns_moves = {}
				if previousPawnAttack.ends_with("King"):
					pawns_moves.merge({game_state.previousPawnAttackGameState: PawnMovement.possible_move_pawn_king(game_state.previousPawnAttackGameState,game_state.board)})
				else:
					pawns_moves.merge({game_state.previousPawnAttackGameState: PawnMovement.posibble_move_pawn(game_state.previousPawnAttackGameState,game_state.board)})
			for pawn in pawns_moves:
				var moves = pawns_moves[pawn]
				for move in moves:
					var new_board = game_state.board.duplicate(true)
					var game_state_two = load("res://asset/Board/GameState.gd").new(new_board,game_state.previousTurnWasAttackGameState,game_state.previousPawnAttackGameState)
					
					what_pawn_was = main_script.get_pawn_info(pawn, true, false)
					ai_make_move(pawn,move,game_state_two)
					game_turn(game_state_two)
					var score = Minimax(game_state_two, curDepth + 1,targetDepth , is_currect_turn_attack(true))
					bestScore = min(score, bestScore) # wybiera Min z dzieci
			return bestScore

func is_currect_turn_attack(isMax: bool):
	if currect_turn_attack and !isMax:
		return true
	elif currect_turn_attack and isMax:
		return false
	else:
		return isMax

func game_turn(game_state):
	create_king(game_state)	
	AttackMoves.search_if_is_attack(what_pawn_was,game_state.board)
	if GlobalVariables.is_attack:
		handle_attack_turn(game_state)
	else:
		handle_normal_turn(game_state)

func handle_attack_turn(game_state):
	if isPlayerTurn: 
		handle_player_attack_turn(game_state)
	elif isAITurn:
		handle_ai_attack_turn(game_state)

func handle_normal_turn(game_state):
	previousTurnWasAttack = false
	switch_turn(game_state)
	
func handle_player_attack_turn(game_state):
	if AttackMoves.is_attack_move_available_pawn(game_state.board[new_grid_pos.y][new_grid_pos.x],game_state.board) or AttackMoves.is_attack_move_available_pawn_king(game_state.board[new_grid_pos.y][new_grid_pos.x],game_state.board):
		if previousTurnWasAttack:
			isPlayerTurn = true
			isAITurn = false
			previousTurnWasAttack = true
			previousTurn = "Player"
			currect_turn_attack = true
			previousPawnAttack = main_script.get_pawn_info(game_state.board[new_grid_pos.y][new_grid_pos.x], true, false)
			previousPawnAttackFullName = game_state.board[new_grid_pos.y][new_grid_pos.x]
			game_state.previousTurnWasAttackGameState = true
			game_state.previousPawnAttackGameState = game_state.board[new_grid_pos.y][new_grid_pos.x]
		else:
			switch_turn(game_state)  
	else:
		switch_turn(game_state)  

func handle_ai_attack_turn(game_state):
	if AttackMoves.is_attack_move_available_pawn(game_state.board[new_grid_pos.y][new_grid_pos.x],game_state.board) or AttackMoves.is_attack_move_available_pawn_king(game_state.board[new_grid_pos.y][new_grid_pos.x],game_state.board):
		if previousTurnWasAttack:
			isPlayerTurn = false
			isAITurn = true
			previousTurnWasAttack = true
			previousTurn = "AI"
			currect_turn_attack = true
			previousPawnAttack = main_script.get_pawn_info(game_state.board[new_grid_pos.y][new_grid_pos.x], true, false)
			previousPawnAttackFullName = game_state.board[new_grid_pos.y][new_grid_pos.x]
			game_state.previousTurnWasAttackGameState = true
			game_state.previousPawnAttackGameState = game_state.board[new_grid_pos.y][new_grid_pos.x]
		else:
			switch_turn(game_state) 
	else:
		switch_turn(game_state) 

func switch_turn(game_state):
	if isPlayerTurn:
		isPlayerTurn = false
		isAITurn = true
		previousTurn = "Player"
		currect_turn_attack = false
		previousPawnAttack = "nic"
		game_state.previousTurnWasAttackGameState = false
		game_state.previousPawnAttackGameState = null
		
	elif isAITurn:
		isAITurn = false
		isPlayerTurn = true
		previousTurn = "AI"
		currect_turn_attack = false
		previousPawnAttack = "nic"
		game_state.previousTurnWasAttackGameState = false
		game_state.previousPawnAttackGameState = null

func create_king(game_state):
	for i in range(8):
		if main_script.get_pawn_info(game_state.board[0][i],true,false) == "white":
			var grid_pos = Vector2i(i,0)
			var position = grid_pos * 100 + Vector2i(100 / 2, 100 / 2)
			number_white_king += 1
			game_state.board[0][i] = "whiteKing " + str(number_white_king)
			
		elif main_script.get_pawn_info(game_state.board[7][i],true,false) == "black":
			var grid_pos = Vector2i(i,7)
			var position = grid_pos * 100 + Vector2i(100 / 2, 100 / 2)
			number_black_king += 1
			game_state.board[0][i] = "whiteKing " + str(number_black_king)
