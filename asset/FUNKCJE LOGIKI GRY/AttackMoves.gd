extends Node

var main_script = load("res://main.gd").new()


var old_grid_pos
func find_pawn_position(pawn,_board: Array):
	for i in range(8):
		for j in range(8):
			if main_script.get_pawn_info(_board[i][j],false,true) == pawn:
				return Vector2i(j, i)
	return null

# ============================================================ IS ATTACK MOVE PLAYER MOVE ====================================================	

func search_if_is_attack(Pawn_type: String, _board: Array):
	is_attack_move_available(Pawn_type, _board) # sprawdź czy jest atak dla pionków
	is_attack_move_available_king(Pawn_type,_board)

func is_attack_move_available(PAWN_TYPE: String, _board: Array):
	if PAWN_TYPE.ends_with("King"):
		return
	else:
		GlobalVariables.is_attack = false
	
	for i in range(8):
		for j in range(8):
			if main_script.get_pawn_info(_board[i][j],true,false) == PAWN_TYPE:
				var pionek = main_script.get_pawn_info(_board[i][j],true,false)
				var directionRow = null
				var directionColLeft = -1
				var directionColright = 1
				var left_col = j - 1
				var right_col = j + 1
				var row = i
				
				if pionek == "white":
					directionRow = -1
				elif pionek == "black":
					directionRow = 1
				row += directionRow

				if check_attack_move(row , left_col, directionRow, directionColLeft, pionek, _board) == true:
					GlobalVariables.is_attack = true
				if check_attack_move(row , right_col, directionRow, directionColright, pionek, _board) == true:
					GlobalVariables.is_attack = true
				
				# sprawdzanie ataku do tyłu
				row -= 2*directionRow
				if check_attack_move(row , left_col, -directionRow, directionColLeft, pionek, _board) == true:
					GlobalVariables.is_attack = true
				if check_attack_move(row , right_col, -directionRow, directionColright, pionek, _board) == true:
					GlobalVariables.is_attack = true

func is_attack_move_available_pawn(PAWN, _board: Array):
	if main_script.get_pawn_info(PAWN,true,false).ends_with("King") or PAWN == null:
		return false
	var is_attack_for_pawn = false
	old_grid_pos = find_pawn_position(main_script.get_pawn_info(PAWN,false,true),_board)
	var pionek = main_script.get_pawn_info(PAWN,true,false)
	var directionRow = null
	var directionColLeft = -1
	var directionColright = 1

	var left_col = old_grid_pos.x - 1
	var right_col = old_grid_pos.x + 1
	var row = old_grid_pos.y
	if pionek == "white":
		directionRow = -1
	elif pionek == "black":
		directionRow = 1
	row += directionRow
	
	if check_attack_move(row, left_col, directionRow, directionColLeft, pionek, _board) == true:
		is_attack_for_pawn = true
	if check_attack_move(row, right_col, directionRow, directionColright, pionek, _board) == true:
		is_attack_for_pawn = true
	# sprawdzanie ataku do tyłu
	row -= 2*directionRow
	if check_attack_move(row , left_col, -directionRow, directionColLeft, pionek, _board) == true:
		is_attack_for_pawn = true
	if check_attack_move(row , right_col, -directionRow, directionColright, pionek, _board) == true:
		is_attack_for_pawn = true
	return is_attack_for_pawn


func check_attack_move(row: int, col: int, directionRow: int, directionCol: int, pionek: String, _board: Array):
	var isInBoard: bool = col >= 0 and col < 8 and row >= 0 and row < 8
	var same
	if isInBoard and main_script.get_pawn_info(_board[row][col],true,false) == "whiteKing":
		same = "white"
	elif isInBoard and main_script.get_pawn_info(_board[row][col],true,false) == "blackKing":
		same = "black"
	
	var isOpponentColor: bool = isInBoard and main_script.get_pawn_info(_board[row][col],true,false) != pionek and  _board[row][col] != null
	var isJumpInBoard: bool = row+directionRow >= 0 and row+directionRow < 8 and col + directionCol >= 0 and col + directionCol < 8
	var isJumpPossible: bool = isJumpInBoard and _board[row + directionRow][col + directionCol] == null

	if pionek == same:
		return false
	if isInBoard and isOpponentColor and isJumpInBoard and isJumpPossible:
		return true
	return false

# ============================================================ IS ATTACK KING ====================================================

func is_attack_move_available_king(PAWN_TYPE: String, _board: Array):
	if PAWN_TYPE.ends_with("King"):
		GlobalVariables.is_attack = false
	else:
		return
	
	for i in range(8):
		for j in range(8):
			if main_script.get_pawn_info(_board[i][j],true,false) == PAWN_TYPE:
				var pionek = main_script.get_pawn_info(_board[i][j],true,false)
				var directionRow = null
				var directionColLeft = -1
				var directionColRight = 1

				var left_col = j - 1
				var right_col = j + 1
				var row = i
				if pionek == "whiteKing":
					directionRow = -1
				elif pionek == "blackKing":
					directionRow = 1
				
				var moves = check_diagonal_move_king(row + directionRow, left_col , directionRow, directionColLeft, pionek,_board)
				if moves != []:
					GlobalVariables.is_attack = true
				moves = check_diagonal_move_king(row + directionRow, right_col , directionRow, directionColRight, pionek,_board)
				if moves != []:
					GlobalVariables.is_attack = true
				# sprawdź ataki do tyłu
				moves = check_diagonal_move_king(row - directionRow, left_col , -directionRow, directionColLeft, pionek,_board)
				if moves != []:
					GlobalVariables.is_attack = true
				moves = check_diagonal_move_king(row - directionRow, right_col, -directionRow, directionColRight, pionek,_board)
				if moves != []:
					GlobalVariables.is_attack = true

func is_attack_move_available_pawn_king(PAWN,_board):
	
	if !main_script.get_pawn_info(PAWN,true,false).ends_with("King") or PAWN == null:
		return false
	
	var is_attack_for_pawn = false
	old_grid_pos = find_pawn_position(main_script.get_pawn_info(PAWN,false,true),_board)
	var pionek = main_script.get_pawn_info(PAWN,true,false)
	var directionRow = null
	var directionColLeft = -1
	var directionColright = 1

	var left_col = old_grid_pos.x - 1
	var right_col = old_grid_pos.x + 1
	var row = old_grid_pos.y
	if pionek == "whiteKing":
		directionRow = -1
	elif pionek == "blackKing":
		directionRow = 1
	
	var moves = check_diagonal_move_king(row + directionRow, left_col , directionRow, directionColLeft, pionek,_board)
	if moves != []:
		is_attack_for_pawn = true
	moves = check_diagonal_move_king(row + directionRow, right_col , directionRow, directionColright, pionek,_board)
	if moves != []:
		is_attack_for_pawn = true
	# sprawdź ataki do tyłu
	moves = check_diagonal_move_king(row - directionRow, left_col , -directionRow, directionColLeft, pionek,_board)
	if moves != []:
		is_attack_for_pawn = true
	moves = check_diagonal_move_king(row - directionRow, right_col, -directionRow, directionColright, pionek,_board)
	if moves != []:
		is_attack_for_pawn = true
	return is_attack_for_pawn

# HELP func
func check_diagonal_move_king(_row: int, _col: int, row_step: int, col_step: int, pawn_type: String,_board):
	var empty_cells = []
	var consecutiveEnemies: int = 0 
	var isEnemy: bool = false
	var kingEnemyAttack = []
	var check_pawn_type = []
	var check_pawn_type_white = ["white","whiteKing"]
	var check_pawn_type_black = ["black","blackKing"]
	
	if pawn_type == "whiteKing":
		check_pawn_type = check_pawn_type_white
	elif pawn_type == "blackKing":
		check_pawn_type = check_pawn_type_black

	while _row >= 0 and _row < 8 and _col >= 0 and _col < 8:
		var cell_info = main_script.get_pawn_info(_board[_row][_col],true,false)
		if cell_info in check_pawn_type:
			break
		if cell_info in check_pawn_type_white or cell_info in check_pawn_type_black:
			consecutiveEnemies += 1
			if _row + row_step >= 0 and _row + row_step < 8 and _col + col_step >= 0 and _col + col_step < 8 and _board[_row + row_step][_col + col_step] == null:
				isEnemy = true
		elif _board[_row][_col] == null and isEnemy and consecutiveEnemies < 2:
			if _row - row_step >= 0 and _row - row_step < 8 and _col - col_step >= 0 and _col - col_step < 8 and (_board[_row - row_step][_col - col_step] in check_pawn_type_white or _board[_row - row_step][_col - col_step] in check_pawn_type_black):
				break
			kingEnemyAttack.append([_row, _col])
		_row += row_step
		_col += col_step
	return kingEnemyAttack


func is_attack_move_available_for_type(PAWN_TYPE: String, _board: Array):
	GlobalVariables.is_attack = false

	for i in range(8):
		for j in range(8):
			if main_script.get_pawn_info(_board[i][j],true,false).begins_with(PAWN_TYPE):
				var pionek = main_script.get_pawn_info(_board[i][j],true,false)
				var isKing = pionek.ends_with("King")

				var directionRow = null
				var directionColLeft = -1
				var directionColRight = 1

				var left_col = j - 1
				var right_col = j + 1
				var row = i
				if pionek.begins_with("white"):
					directionRow = -1
				elif pionek.begins_with("black"):
					directionRow = 1
				
				if isKing:
					var moves = check_diagonal_move_king(row + directionRow, left_col , directionRow, directionColLeft, pionek,_board)
					if moves != []:
						GlobalVariables.is_attack = true
					moves = check_diagonal_move_king(row + directionRow, right_col , directionRow, directionColRight, pionek,_board)
					if moves != []:
						GlobalVariables.is_attack = true
					# sprawdź ataki do tyłu
					moves = check_diagonal_move_king(row - directionRow, left_col , -directionRow, directionColLeft, pionek,_board)
					if moves != []:
						GlobalVariables.is_attack = true
					moves = check_diagonal_move_king(row - directionRow, right_col, -directionRow, directionColRight, pionek,_board)
					if moves != []:
						GlobalVariables.is_attack = true
				else:
					row += directionRow
					if check_attack_move(row, left_col, directionRow, directionColLeft, pionek, _board) == true:
						GlobalVariables.is_attack = true
					if check_attack_move(row, right_col, directionRow, directionColRight, pionek, _board) == true:
						GlobalVariables.is_attack = true
					# sprawdzanie ataku do tyłu
					row -= 2*directionRow
					if check_attack_move(row , left_col, -directionRow, directionColLeft, pionek, _board) == true:
						GlobalVariables.is_attack = true
					if check_attack_move(row , right_col, -directionRow, directionColRight, pionek, _board) == true:
						GlobalVariables.is_attack = true
