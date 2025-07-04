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
var previousPawnAttackInFindBest
var first_move = true
var targetDepth
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


func find_best_move(_board,_targetDepth, TYPE: String,_previousTurnWasAttack, _previousPawnAttack):
	var alpha = 10000
	var beta = -10000
	
	TYPE_PAWNS = TYPE
	var bestScore
	AttackMoves = load("res://asset/FUNKCJE LOGIKI GRY/AttackMoves.gd").new()
	print("TYPE_PAWNS ",TYPE_PAWNS)
	AttackMoves.is_attack_move_available_for_type(TYPE_PAWNS,_board)
	if TYPE_PAWNS == "black":
		bestScore = 100000
	else: # jeżeli jest biały
		bestScore = -100000
	var curDepth = _targetDepth
	var bestMove_Panw = []
	var pawns_moves = {}

	pawns_moves.merge(PawnMovement.all_possible_move_types_pawn(TYPE_PAWNS,_board))
#	if first_move:
#		var random_move_pawn = return_random_move(pawns_moves)
#		first_move = false
#		return random_move_pawn
	if _previousTurnWasAttack and main_script.get_pawn_info(_previousPawnAttack,true,false).begins_with(TYPE_PAWNS):
		pawns_moves = {}
		if main_script.get_pawn_info(_previousPawnAttack,true,false).ends_with("King"):
			pawns_moves.merge({_previousPawnAttack: PawnMovement.possible_move_pawn_king(_previousPawnAttack,_board)})
		else:
			pawns_moves.merge({_previousPawnAttack: PawnMovement.posibble_move_pawn(_previousPawnAttack,_board)})
	for pawn in pawns_moves:
		var moves = pawns_moves[pawn]
		for move in moves:
			var game_state = load("res://asset/Board/GameState.gd").new(_board,_previousTurnWasAttack,_previousPawnAttack,curDepth)
			what_pawn_was = main_script.get_pawn_info(pawn, true, false)
			game_state.nonCaptureMoveCount = 0
			ai_make_move(pawn,move,game_state)
			game_turn(game_state)
			if TYPE_PAWNS == "black":
				var score = AlphaBeta(game_state,curDepth-1, is_currect_turn_attack(false), alpha, beta)
				if (score < bestScore):
					bestScore = score
					bestMove_Panw.append([pawn,move])
			else:
				var score = AlphaBeta(game_state,curDepth-1, is_currect_turn_attack(true), alpha, beta)
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
		make_move_ai_on_board(pawn,game_state)
	else:
		possible_move.append(move)
		make_move_ai_on_board(pawn,game_state)

func make_move_ai_on_board(pawn, game_state):
	var pawn_info = main_script.get_pawn_info(pawn, true, false)
	var is_king = pawn_info == "whiteKing" or pawn_info == "blackKing"
	if is_king:
		if not GlobalVariables.is_attack:
			make_move_diagonal_king(pawn,game_state)
			game_state.nonCaptureMoveCount += 1
		else:
			make_jump_diagonal_king(pawn,game_state)
			game_state.nonCaptureMoveCount = 0
	else:
		if not GlobalVariables.is_attack:
			make_move_diagonal(pawn,game_state)
			game_state.nonCaptureMoveCount = 0
		else:
			make_jump_diagonal(pawn,game_state)
			game_state.nonCaptureMoveCount += 1

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
func is_no_left_pawns(_type_pawn: String, game_state):
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

func is_inPossible_to_move(_type_pawn: String, game_state):
	if _type_pawn == "white":
		if PawnMovement.all_possible_moves("white", game_state.board) and PawnMovement.all_possible_moves("whiteKing", game_state.board):
			return true
	if _type_pawn == "black":
		if PawnMovement.all_possible_moves("black", game_state.board) and PawnMovement.all_possible_moves("blackKing", game_state.board):
			return true
	return false

func game_end(game_state):
	if is_inPossible_to_move("white",game_state) or is_no_left_pawns("white",game_state):
		who_win = "black"
		game_state.is_game_over = true
		return true
	elif is_inPossible_to_move("black",game_state) or is_no_left_pawns("black",game_state):
		who_win = "white"
		game_state.is_game_over = true
		return true
	else:
		who_win = "nikt"
		game_state.is_game_over = true
	return false

func evaluate_complicated(game_state):
	# algorytm alpha beta opisać bardziej skupić się na samym 
	var score = 0
	var sum_piece = 0
	var sum_kings = 0
	var sum_central_control = 0
	var sum_close_to_be_king = 0
	var sum_control_edge_left_right = 0
	var sum_mobility_pawns = 0
	
	for i in range(8) :
		for j in range(8) :
			if game_state.board[i][j] != null:
				var pawn_info = main_script.get_pawn_info(game_state.board[i][j], true, false)
				if pawn_info.begins_with("white"):
					if pawn_info.ends_with("King"):
						sum_kings += 10
					if pawn_info.ends_with("King"):
						sum_mobility_pawns += len(PawnMovement.possible_move_pawn_king(game_state.board[i][j],game_state.board))
					if !pawn_info.ends_with("King"):
						sum_mobility_pawns += len(PawnMovement.posibble_move_pawn(game_state.board[i][j],game_state.board))
					if i >= 2 and i < 1:
						sum_close_to_be_king += 2
					if j == 0 or j == 7:
						sum_control_edge_left_right += 2
					if (j >= 3 and j <= 5) and (i >= 3 and i <= 5):
						sum_central_control += 2
					else:
						sum_piece += 1
				elif pawn_info.begins_with("black"):
					if pawn_info.ends_with("King"):
						sum_kings -= 10
					if pawn_info.ends_with("King"):
						sum_mobility_pawns -= len(PawnMovement.possible_move_pawn_king(game_state.board[i][j],game_state.board))
					if !pawn_info.ends_with("King"):
						sum_mobility_pawns -= len(PawnMovement.posibble_move_pawn(game_state.board[i][j],game_state.board))
					if i >= 7 and i < 8:
						sum_close_to_be_king -= 2
					if j == 0 or j == 7:
						sum_control_edge_left_right -= 2
					if (j >= 3 and j <= 5) and (i >= 3 and i <= 5):
						sum_central_control -= 2
					else:
						sum_piece -= 1
	score = (sum_piece * 2  + (3 * sum_kings)) * 10 + sum_central_control * 2 + sum_close_to_be_king * 2 + sum_control_edge_left_right * 2 + sum_mobility_pawns/4
	return score
	
func AlphaBeta(game_state,depth, isMax, alpha, beta):
	var result = evaluate_complicated(game_state)
	if game_state.curretDepth == 0 or game_end(game_state):
		if who_win == "black":
			return -10000
		elif who_win == "white":
			return 10000
		else:
			return result

	if game_state.curretDepth > 0:
		# Ruch MAX
		if(isMax):
			var bestScore = -1000
			AttackMoves.is_attack_move_available_for_type("black",game_state.board)
			var pawns_moves = {}
			pawns_moves.merge(PawnMovement.all_possible_move_types_pawn("black",game_state.board))
			for pawn in pawns_moves.keys():
				var moves = pawns_moves[pawn]
				for move in moves:
					var game_state_two = load("res://asset/Board/GameState.gd").new(game_state.board,game_state.previousTurnWasAttackGameState,game_state.previousPawnAttackGameState,depth)
					what_pawn_was = main_script.get_pawn_info(pawn, true, false)
					# jeżeli jest to sekwencja wielu ataków, wtedy wykonaj ją tyle razy dopóki nie zakończy się
					if game_state_two.previousTurnWasAttackGameState and main_script.get_pawn_info(game_state_two.previousPawnAttackGameState,true,false).begins_with("black"):
						while main_script.get_pawn_info(game_state_two.previousPawnAttackGameState,true,false).begins_with("black") and game_state_two.previousTurnWasAttackGameState and game_state.currect_turn_attack and !game_state.is_game_over:
							if !game_state_two.created_king:
								var pawns_moves_two = {}
								if main_script.get_pawn_info(game_state_two.previousPawnAttackGameState,true,false).ends_with("King"):
									pawns_moves_two.merge({game_state_two.previousPawnAttackGameState: PawnMovement.possible_move_pawn_king(game_state_two.previousPawnAttackGameState,game_state_two.board)})
								else:
									pawns_moves_two.merge({game_state_two.previousPawnAttackGameState: PawnMovement.posibble_move_pawn(game_state_two.previousPawnAttackGameState,game_state_two.board)})
								var pawns_moves_only = pawns_moves_two[game_state_two.previousPawnAttackGameState]
								if pawns_moves_only.size() == 1:
									ai_make_move(game_state_two.previousPawnAttackGameState,pawns_moves_only[0],game_state_two)
									game_turn(game_state_two)
								elif pawns_moves_only.size() > 1:
									var best_move = find_best_move(game_state_two.board,2,"black",game_state_two.previousTurnWasAttackGameState,game_state_two.previousPawnAttackGameState)
									ai_make_move(game_state_two.previousPawnAttackGameState,best_move[1],game_state_two)
									game_turn(game_state_two)
								else:
									break
							else:
								break
					else:
						if !game_state_two.created_king:
							ai_make_move(pawn,move,game_state_two)
							game_turn(game_state_two)
						else:
							game_turn(game_state_two)
					var score = AlphaBeta(game_state_two,depth - 1, is_currect_turn_attack(false), alpha, beta)
					bestScore = max(score, bestScore) # wybiera Max z dzieci
					alpha = max(alpha, bestScore)
					if beta <= alpha:
						break
			return bestScore
		# Ruch MIN
		else:
			var bestScore = 1000
			AttackMoves.is_attack_move_available_for_type("white",game_state.board)
			var pawns_moves = {}
			pawns_moves.merge(PawnMovement.all_possible_move_types_pawn("white",game_state.board))
			for pawn in pawns_moves.keys():
				var moves = pawns_moves[pawn]
				for move in moves:
					var game_state_two = load("res://asset/Board/GameState.gd").new(game_state.board,game_state.previousTurnWasAttackGameState,game_state.previousPawnAttackGameState,depth)
					what_pawn_was = main_script.get_pawn_info(pawn, true, false)
					# jeżeli jest to sekwencja wielu ataków, wtedy wykonaj ją tyle razy dopóki nie zakończy się
					if game_state_two.previousTurnWasAttackGameState and main_script.get_pawn_info(game_state_two.previousPawnAttackGameState,true,false).begins_with("white"):
						while main_script.get_pawn_info(game_state_two.previousPawnAttackGameState,true,false).begins_with("white") and game_state_two.previousTurnWasAttackGameState and game_state.currect_turn_attack and !game_state.is_game_over:
							if !game_state_two.created_king:
								var pawns_moves_two = {}
								if main_script.get_pawn_info(game_state_two.previousPawnAttackGameState,true,false).ends_with("King") and !game_state_two.created_king:
									pawns_moves_two.merge({game_state_two.previousPawnAttackGameState: PawnMovement.possible_move_pawn_king(game_state_two.previousPawnAttackGameState,game_state_two.board)})
								else:
									pawns_moves_two.merge({game_state_two.previousPawnAttackGameState: PawnMovement.posibble_move_pawn(game_state_two.previousPawnAttackGameState,game_state_two.board)})
								var pawns_moves_only = pawns_moves_two[game_state_two.previousPawnAttackGameState]
								if pawns_moves_only.size() == 1:
									ai_make_move(game_state_two.previousPawnAttackGameState,pawns_moves_only[0],game_state_two)
									game_turn(game_state_two)
								elif pawns_moves_only.size() > 1:
									var best_move = find_best_move(game_state_two.board,2,"white",game_state_two.previousTurnWasAttackGameState,game_state_two.previousPawnAttackGameState)
									ai_make_move(game_state_two.previousPawnAttackGameState,best_move[1],game_state_two)
									game_turn(game_state_two)
								else:
									break
							else:
								break
					else:
						if !game_state_two.created_king:
							ai_make_move(pawn,move,game_state_two)
							game_turn(game_state_two)
						else:
							game_turn(game_state_two)
					var score = AlphaBeta(game_state_two ,depth - 1 , is_currect_turn_attack(true), alpha, beta)
					bestScore = min(score, bestScore) # wybiera Min z dzieci
					beta = min( beta, bestScore)
					if beta <= alpha:
						break
			return bestScore

func is_turn_attack_over(game_state, type):
	return AttackMoves.is_attack_move_available_for_type(type, game_state.board)

func is_currect_turn_attack(isMax: bool):
	if currect_turn_attack and !isMax:
		return true
	elif currect_turn_attack and isMax:
		return false
	else:
		return isMax

func game_turn(game_state):
	create_king(game_state)
	if game_end(game_state) or game_state.nonCaptureMoveCount >= 50:
		return
	
	if game_state.created_king == true:
		handle_normal_turn(game_state)
		game_state.created_king = false
		return
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
			game_state.currect_turn_attack = true
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
			game_state.currect_turn_attack = true
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
		game_state.currect_turn_attack = false
	elif isAITurn:
		isAITurn = false
		isPlayerTurn = true
		previousTurn = "AI"
		currect_turn_attack = false
		previousPawnAttack = "nic"
		game_state.previousTurnWasAttackGameState = false
		game_state.previousPawnAttackGameState = null
		game_state.currect_turn_attack = false

func create_king(game_state):
	for i in range(8):
		var pawn_info_king = main_script.get_pawn_info(game_state.board[0][i],true,false)
		if pawn_info_king.begins_with("white") and !pawn_info_king.ends_with("King"):
			game_state.created_king = true
			var grid_pos = Vector2i(i,0)
			var position = grid_pos * 100 + Vector2i(100 / 2, 100 / 2)
			number_white_king += 1
			game_state.board[0][i] = "whiteKing " + str(number_white_king)
		elif pawn_info_king.begins_with("black") and !pawn_info_king.ends_with("King"):
			game_state.created_king = true
			var grid_pos = Vector2i(i,7)
			var position = grid_pos * 100 + Vector2i(100 / 2, 100 / 2)
			number_black_king += 1
			game_state.board[0][i] = "whiteKing " + str(number_black_king)
