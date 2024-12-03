import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

enum Difficulty { easy, medium, hard }

void main() {
  runApp(MaterialApp(home: TicTacToeGame()));
}

class TicTacToeGame extends StatefulWidget {
  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<List<int>> board = List.generate(3, (_) => List.filled(3, 0));
  bool isPlayerTurn = true; // Player is X (1), Computer is O (2)
  bool gameOver = false;
  String message = '';
  final random = Random();
  Difficulty difficulty = Difficulty.medium; // Default difficulty
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    message = 'Your turn (X)';
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String soundName) async {
    await audioPlayer.stop();
    await audioPlayer.play(AssetSource('sounds/$soundName.mp3'));
  }

  void _handlePlayerMove(int row, int col) {
    if (board[row][col] != 0 || gameOver || !isPlayerTurn) return;

    _playSound('click');
    setState(() {
      // Player's move
      board[row][col] = 1;
      if (_checkWinner(row, col)) {
        gameOver = true;
        message = 'Game over: You won!';
        _playSound('win');
        return;
      }

      if (_isBoardFull()) {
        gameOver = true;
        message = 'Game over: Draw!';
        _playSound('draw');
        return;
      }

      // Computer's turn
      isPlayerTurn = false;
      message = "Computer's turn (O)";
    });

    // Add a small delay before computer moves
    Future.delayed(Duration(milliseconds: 500), () {
      if (!gameOver) _makeComputerMove();
    });
  }

  void _makeComputerMove() {
    if (gameOver) return;

    int row, col;
    switch (difficulty) {
      case Difficulty.easy:
        (row, col) = _makeEasyMove();
        break;
      case Difficulty.medium:
        (row, col) = _makeMediumMove();
        break;
      case Difficulty.hard:
        (row, col) = _makeHardMove();
        break;
    }

    _playSound('click');
    setState(() {
      board[row][col] = 2;
      if (_checkWinner(row, col)) {
        gameOver = true;
        message = 'Game over: Computer won!';
        _playSound('lose');
        return;
      }

      if (_isBoardFull()) {
        gameOver = true;
        message = 'Game over: Draw!';
        _playSound('draw');
        return;
      }

      isPlayerTurn = true;
      message = 'Your turn (X)';
    });
  }

  // Easy: Random empty cell
  (int, int) _makeEasyMove() {
    List<(int, int)> emptyCells = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == 0) emptyCells.add((i, j));
      }
    }
    final move = emptyCells[random.nextInt(emptyCells.length)];
    return move;
  }

  // Medium: Block player's winning move or take winning move if available, otherwise random
  (int, int) _makeMediumMove() {
    // Check for winning move
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == 0) {
          board[i][j] = 2;
          if (_checkWinner(i, j)) {
            board[i][j] = 0;
            return (i, j);
          }
          board[i][j] = 0;
        }
      }
    }

    // Check for blocking move
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == 0) {
          board[i][j] = 1;
          if (_checkWinner(i, j)) {
            board[i][j] = 0;
            return (i, j);
          }
          board[i][j] = 0;
        }
      }
    }

    // If no winning or blocking move, make a random move
    return _makeEasyMove();
  }

  // Hard: Use minimax algorithm for perfect play
  (int, int) _makeHardMove() {
    int bestScore = -1000;
    int bestRow = -1;
    int bestCol = -1;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == 0) {
          board[i][j] = 2;
          int score = _minimax(board, 0, false);
          board[i][j] = 0;

          if (score > bestScore) {
            bestScore = score;
            bestRow = i;
            bestCol = j;
          }
        }
      }
    }

    return (bestRow, bestCol);
  }

  int _minimax(List<List<int>> board, int depth, bool isMaximizing) {
    // Check terminal states
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] != 0) {
          if (_checkWinner(i, j)) {
            return board[i][j] == 2 ? 10 - depth : depth - 10;
          }
        }
      }
    }

    if (_isBoardFull()) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j] == 0) {
            board[i][j] = 2;
            bestScore = max(bestScore, _minimax(board, depth + 1, false));
            board[i][j] = 0;
          }
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j] == 0) {
            board[i][j] = 1;
            bestScore = min(bestScore, _minimax(board, depth + 1, true));
            board[i][j] = 0;
          }
        }
      }
      return bestScore;
    }
  }

  bool _checkWinner(int row, int col) {
    int player = board[row][col];
    if (board[row].every((cell) => cell == player)) return true;
    if (board.every((row) => row[col] == player)) return true;
    if (row == col &&
        board[0][0] == player &&
        board[1][1] == player &&
        board[2][2] == player) return true;
    if (row + col == 2 &&
        board[0][2] == player &&
        board[1][1] == player &&
        board[2][0] == player) return true;
    return false;
  }

  bool _isBoardFull() {
    return board.every((row) => row.every((cell) => cell != 0));
  }

  void _resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, 0));
      isPlayerTurn = true;
      gameOver = false;
      message = 'Your turn (X)';
    });
  }

  Widget _buildCell(int value, double size) {
    if (value == 0) return Container();

    return Image.asset(
      value == 1 ? 'assets/images/x.png' : 'assets/images/o.png',
      width: size * 0.8, // Make image slightly smaller than cell
      height: size * 0.8,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double gameboardSize = screenSize.width > screenSize.height
        ? screenSize.height * 0.7
        : screenSize.width * 0.9;
    final double messageFontSize = screenSize.width * 0.06;
    final double cellSize = (gameboardSize * 0.9) / 3; // Account for padding

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(gameboardSize * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Difficulty: ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: messageFontSize * 0.7,
                        ),
                      ),
                      DropdownButton<Difficulty>(
                        value: difficulty,
                        dropdownColor: Colors.grey[800],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: messageFontSize * 0.7,
                        ),
                        onChanged: (Difficulty? newValue) {
                          if (newValue != null) {
                            setState(() {
                              difficulty = newValue;
                              _resetGame();
                            });
                          }
                        },
                        items: Difficulty.values.map((Difficulty difficulty) {
                          return DropdownMenuItem<Difficulty>(
                            value: difficulty,
                            child: Text(difficulty.name.toUpperCase()),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(gameboardSize * 0.05),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: messageFontSize,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: gameboardSize,
                  height: gameboardSize,
                  padding: EdgeInsets.all(gameboardSize * 0.05),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: gameboardSize * 0.02,
                      mainAxisSpacing: gameboardSize * 0.02,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final row = index ~/ 3;
                      final col = index % 3;
                      return GestureDetector(
                        onTap: () => _handlePlayerMove(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius:
                                BorderRadius.circular(gameboardSize * 0.02),
                          ),
                          child: Center(
                            child: _buildCell(board[row][col], cellSize),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (gameOver)
                  Padding(
                    padding: EdgeInsets.only(top: gameboardSize * 0.05),
                    child: ElevatedButton(
                      onPressed: _resetGame,
                      child: Text(
                        'Play Again',
                        style: TextStyle(fontSize: messageFontSize * 0.7),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          horizontal: gameboardSize * 0.1,
                          vertical: gameboardSize * 0.03,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(gameboardSize * 0.02),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
