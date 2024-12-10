import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:math';

void main() {
  runApp(MaterialApp(home: TicTacToeGame()));
}

class TicTacToeGame extends StatefulWidget {
  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  static const String PLAYER_SCORE_KEY = 'player_score';
  static const String COMPUTER_SCORE_KEY = 'computer_score';
  static const String DRAWS_KEY = 'draws';

  // Add method to load scores
  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      playerScore = prefs.getInt(PLAYER_SCORE_KEY) ?? 0;
      computerScore = prefs.getInt(COMPUTER_SCORE_KEY) ?? 0;
      draws = prefs.getInt(DRAWS_KEY) ?? 0;
    });
  }

  // Add method to save scores
  Future<void> _saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PLAYER_SCORE_KEY, playerScore);
    await prefs.setInt(COMPUTER_SCORE_KEY, computerScore);
    await prefs.setInt(DRAWS_KEY, draws);
  }

  List<List<int>> board = List.generate(3, (_) => List.filled(3, 0));
  bool isPlayerTurn = true;
  bool gameOver = false;
  String message = '';
  final random = Random();
  Difficulty difficulty = Difficulty.medium;
  final AudioPlayer audioPlayer = AudioPlayer();

  // Score tracking
  int playerScore = 0;
  int computerScore = 0;
  int draws = 0;

  @override
  void initState() {
    super.initState();
    message = 'Your turn (X)';
    _loadScores();
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
    final bool isLandscape = screenSize.width > screenSize.height;

    // Calculate sizes based on orientation
    final double gameboardSize = isLandscape
        ? screenSize.height * 0.8 // Smaller in landscape
        : screenSize.width * 0.9; // Larger in portrait

    final double messageFontSize =
        isLandscape ? screenSize.height * 0.04 : screenSize.width * 0.06;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout(gameboardSize, messageFontSize, screenSize)
            : _buildPortraitLayout(gameboardSize, messageFontSize),
      ),
    );
  }

  Widget _buildLandscapeLayout(
      double gameboardSize, double messageFontSize, Size screenSize) {
    return Row(
      children: [
        // Game Board Section (Left)
        Expanded(
          flex: 2,
          child: Center(
            child: SingleChildScrollView(
                child: _buildGameBoard(gameboardSize, messageFontSize)),
          ),
        ),

        // Dashboard Section (Right)
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(
                left: BorderSide(
                  color: Colors.grey[800]!,
                  width: 2,
                ),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SCOREBOARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: messageFontSize * 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildScoreCard('Player (X)', playerScore, Colors.green),
                  SizedBox(height: 20),
                  _buildScoreCard('Computer (O)', computerScore, Colors.red),
                  SizedBox(height: 20),
                  _buildScoreCard('Draws', draws, Colors.grey),
                  SizedBox(height: 40),
                  // Difficulty Selector
                  Row(
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
                  SizedBox(height: 20),
                  // Reset Scores Button
                  ElevatedButton(
                    onPressed: _resetScores,
                    child: Text(
                      'Reset Scores',
                      style: TextStyle(fontSize: messageFontSize * 0.7),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(double gameboardSize, double messageFontSize) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Score summary in portrait mode
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCompactScore('Player', playerScore, Colors.green),
                _buildCompactScore('Draws', draws, Colors.grey),
                _buildCompactScore('Computer', computerScore, Colors.red),
              ],
            ),
          ),
          // Difficulty selector
          Row(
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
          _buildGameBoard(gameboardSize, messageFontSize),
        ],
      ),
    );
  }

  Widget _buildGameBoard(double gameboardSize, double messageFontSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
                    borderRadius: BorderRadius.circular(gameboardSize * 0.02),
                  ),
                  child: Center(
                    child: _buildCell(board[row][col], gameboardSize / 3),
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
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: gameboardSize * 0.1,
                  vertical: gameboardSize * 0.03,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(gameboardSize * 0.02),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScoreCard(String title, int score, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            score.toString(),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactScore(String title, int score, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        Text(
          score.toString(),
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _resetScores() {
    setState(() {
      playerScore = 0;
      computerScore = 0;
      draws = 0;
      _saveScores();
      _resetGame();
    });
  }

  // Update your _handlePlayerMove to update scores
  void _handlePlayerMove(int row, int col) {
    if (board[row][col] != 0 || gameOver || !isPlayerTurn) return;

    _playSound('click');

    setState(() {
      board[row][col] = 1;
      if (_checkWinner(row, col)) {
        gameOver = true;
        message = 'Game over: You won!';
        playerScore++; // Update player score
        _saveScores();
        _playSound('win');
        return;
      }

      if (_isBoardFull()) {
        gameOver = true;
        message = 'Game over: Draw!';
        draws++; // Update draws
        _saveScores();
        _playSound('draw');
        return;
      }

      isPlayerTurn = false;
      message = "Computer's turn (O)";
    });

    Future.delayed(Duration(milliseconds: 500), () {
      if (!gameOver) _makeComputerMove();
    });
  }

  // Update computer move to handle scoring
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
        computerScore++; // Update computer score
        _saveScores();
        _playSound('win');
        return;
      }

      if (_isBoardFull()) {
        gameOver = true;
        message = 'Game over: Draw!';
        draws++; // Update draws
        _saveScores();
        _playSound('draw');
        return;
      }

      isPlayerTurn = true;
      message = 'Your turn (X)';
    });
  }

  // [Keep all your existing helper methods like _makeEasyMove, _makeMediumMove, etc.]
}

enum Difficulty { easy, medium, hard }
