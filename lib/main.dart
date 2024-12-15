// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'dart:math';

// void main() {
//   runApp(MaterialApp(home: TicTacToeGame()));
// }

// class TicTacToeGame extends StatefulWidget {
//   @override
//   _TicTacToeGameState createState() => _TicTacToeGameState();
// }

// class _TicTacToeGameState extends State<TicTacToeGame> {
//   static const String PLAYER_SCORE_KEY = 'player_score';
//   static const String COMPUTER_SCORE_KEY = 'computer_score';
//   static const String DRAWS_KEY = 'draws';

//   // Add method to load scores
//   Future<void> _loadScores() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       playerScore = prefs.getInt(PLAYER_SCORE_KEY) ?? 0;
//       computerScore = prefs.getInt(COMPUTER_SCORE_KEY) ?? 0;
//       draws = prefs.getInt(DRAWS_KEY) ?? 0;
//     });
//   }

//   // Add method to save scores
//   Future<void> _saveScores() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(PLAYER_SCORE_KEY, playerScore);
//     await prefs.setInt(COMPUTER_SCORE_KEY, computerScore);
//     await prefs.setInt(DRAWS_KEY, draws);
//   }

//   List<List<int>> board = List.generate(3, (_) => List.filled(3, 0));
//   bool isPlayerTurn = true;
//   bool gameOver = false;
//   String message = '';
//   final random = Random();
//   Difficulty difficulty = Difficulty.medium;
//   final AudioPlayer audioPlayer = AudioPlayer();

//   // Score tracking
//   int playerScore = 0;
//   int computerScore = 0;
//   int draws = 0;

//   @override
//   void initState() {
//     super.initState();
//     message = 'Your turn (X)';
//     _loadScores();
//   }

//   @override
//   void dispose() {
//     audioPlayer.dispose();
//     super.dispose();
//   }

//   Future<void> _playSound(String soundName) async {
//     await audioPlayer.stop();
//     await audioPlayer.play(AssetSource('sounds/$soundName.mp3'));
//   }

//   // Easy: Random empty cell
//   (int, int) _makeEasyMove() {
//     List<(int, int)> emptyCells = [];
//     for (int i = 0; i < 3; i++) {
//       for (int j = 0; j < 3; j++) {
//         if (board[i][j] == 0) emptyCells.add((i, j));
//       }
//     }
//     final move = emptyCells[random.nextInt(emptyCells.length)];
//     return move;
//   }

//   // Medium: Block player's winning move or take winning move if available, otherwise random
//   (int, int) _makeMediumMove() {
//     // Check for winning move
//     for (int i = 0; i < 3; i++) {
//       for (int j = 0; j < 3; j++) {
//         if (board[i][j] == 0) {
//           board[i][j] = 2;
//           if (_checkWinner(i, j)) {
//             board[i][j] = 0;
//             return (i, j);
//           }
//           board[i][j] = 0;
//         }
//       }
//     }

//     // Check for blocking move
//     for (int i = 0; i < 3; i++) {
//       for (int j = 0; j < 3; j++) {
//         if (board[i][j] == 0) {
//           board[i][j] = 1;
//           if (_checkWinner(i, j)) {
//             board[i][j] = 0;
//             return (i, j);
//           }
//           board[i][j] = 0;
//         }
//       }
//     }

//     // If no winning or blocking move, make a random move
//     return _makeEasyMove();
//   }

//   // Hard: Use minimax algorithm for perfect play
//   (int, int) _makeHardMove() {
//     int bestScore = -1000;
//     int bestRow = -1;
//     int bestCol = -1;

//     for (int i = 0; i < 3; i++) {
//       for (int j = 0; j < 3; j++) {
//         if (board[i][j] == 0) {
//           board[i][j] = 2;
//           int score = _minimax(board, 0, false);
//           board[i][j] = 0;

//           if (score > bestScore) {
//             bestScore = score;
//             bestRow = i;
//             bestCol = j;
//           }
//         }
//       }
//     }

//     return (bestRow, bestCol);
//   }

//   int _minimax(List<List<int>> board, int depth, bool isMaximizing) {
//     // Check terminal states
//     for (int i = 0; i < 3; i++) {
//       for (int j = 0; j < 3; j++) {
//         if (board[i][j] != 0) {
//           if (_checkWinner(i, j)) {
//             return board[i][j] == 2 ? 10 - depth : depth - 10;
//           }
//         }
//       }
//     }

//     if (_isBoardFull()) return 0;

//     if (isMaximizing) {
//       int bestScore = -1000;
//       for (int i = 0; i < 3; i++) {
//         for (int j = 0; j < 3; j++) {
//           if (board[i][j] == 0) {
//             board[i][j] = 2;
//             bestScore = max(bestScore, _minimax(board, depth + 1, false));
//             board[i][j] = 0;
//           }
//         }
//       }
//       return bestScore;
//     } else {
//       int bestScore = 1000;
//       for (int i = 0; i < 3; i++) {
//         for (int j = 0; j < 3; j++) {
//           if (board[i][j] == 0) {
//             board[i][j] = 1;
//             bestScore = min(bestScore, _minimax(board, depth + 1, true));
//             board[i][j] = 0;
//           }
//         }
//       }
//       return bestScore;
//     }
//   }

//   bool _checkWinner(int row, int col) {
//     int player = board[row][col];
//     if (board[row].every((cell) => cell == player)) return true;
//     if (board.every((row) => row[col] == player)) return true;
//     if (row == col &&
//         board[0][0] == player &&
//         board[1][1] == player &&
//         board[2][2] == player) return true;
//     if (row + col == 2 &&
//         board[0][2] == player &&
//         board[1][1] == player &&
//         board[2][0] == player) return true;
//     return false;
//   }

//   bool _isBoardFull() {
//     return board.every((row) => row.every((cell) => cell != 0));
//   }

//   void _resetGame() {
//     setState(() {
//       board = List.generate(3, (_) => List.filled(3, 0));
//       isPlayerTurn = true;
//       gameOver = false;
//       message = 'Your turn (X)';
//     });
//   }

//   Widget _buildCell(int value, double size) {
//     if (value == 0) return Container();

//     return Image.asset(
//       value == 1 ? 'assets/images/x.png' : 'assets/images/o.png',
//       width: size * 0.8, // Make image slightly smaller than cell
//       height: size * 0.8,
//       fit: BoxFit.contain,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Size screenSize = MediaQuery.of(context).size;
//     final bool isLandscape = screenSize.width > screenSize.height;

//     // Calculate sizes based on orientation
//     final double gameboardSize = isLandscape
//         ? screenSize.height * 0.8 // Smaller in landscape
//         : screenSize.width * 0.9; // Larger in portrait

//     final double messageFontSize =
//         isLandscape ? screenSize.height * 0.04 : screenSize.width * 0.06;

//     return Scaffold(
//       backgroundColor: Colors.black87,
//       body: SafeArea(
//         child: isLandscape
//             ? _buildLandscapeLayout(gameboardSize, messageFontSize, screenSize)
//             : _buildPortraitLayout(gameboardSize, messageFontSize),
//       ),
//     );
//   }

//   Widget _buildLandscapeLayout(
//       double gameboardSize, double messageFontSize, Size screenSize) {
//     return Row(
//       children: [
//         // Game Board Section (Left)
//         Expanded(
//           flex: 2,
//           child: Center(
//             child: SingleChildScrollView(
//                 child: _buildGameBoard(gameboardSize, messageFontSize)),
//           ),
//         ),

//         // Dashboard Section (Right)
//         Expanded(
//           flex: 1,
//           child: Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.grey[900],
//               border: Border(
//                 left: BorderSide(
//                   color: Colors.grey[800]!,
//                   width: 2,
//                 ),
//               ),
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'SCOREBOARD',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: messageFontSize * 1.2,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 30),
//                   _buildScoreCard('Player (X)', playerScore, Colors.green),
//                   SizedBox(height: 20),
//                   _buildScoreCard('Computer (O)', computerScore, Colors.red),
//                   SizedBox(height: 20),
//                   _buildScoreCard('Draws', draws, Colors.grey),
//                   SizedBox(height: 40),
//                   // Difficulty Selector
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Difficulty: ',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: messageFontSize * 0.7,
//                         ),
//                       ),
//                       DropdownButton<Difficulty>(
//                         value: difficulty,
//                         dropdownColor: Colors.grey[800],
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: messageFontSize * 0.7,
//                         ),
//                         onChanged: (Difficulty? newValue) {
//                           if (newValue != null) {
//                             setState(() {
//                               difficulty = newValue;
//                               _resetGame();
//                             });
//                           }
//                         },
//                         items: Difficulty.values.map((Difficulty difficulty) {
//                           return DropdownMenuItem<Difficulty>(
//                             value: difficulty,
//                             child: Text(difficulty.name.toUpperCase()),
//                           );
//                         }).toList(),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   // Reset Scores Button
//                   ElevatedButton(
//                     onPressed: _resetScores,
//                     child: Text(
//                       'Reset Scores',
//                       style: TextStyle(fontSize: messageFontSize * 0.7),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).primaryColor,
//                       foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 30,
//                         vertical: 15,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPortraitLayout(double gameboardSize, double messageFontSize) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Score summary in portrait mode
//           Padding(
//             padding: EdgeInsets.all(10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildCompactScore('Player', playerScore, Colors.green),
//                 _buildCompactScore('Draws', draws, Colors.grey),
//                 _buildCompactScore('Computer', computerScore, Colors.red),
//               ],
//             ),
//           ),
//           // Difficulty selector
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Difficulty: ',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: messageFontSize * 0.7,
//                 ),
//               ),
//               DropdownButton<Difficulty>(
//                 value: difficulty,
//                 dropdownColor: Colors.grey[800],
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: messageFontSize * 0.7,
//                 ),
//                 onChanged: (Difficulty? newValue) {
//                   if (newValue != null) {
//                     setState(() {
//                       difficulty = newValue;
//                       _resetGame();
//                     });
//                   }
//                 },
//                 items: Difficulty.values.map((Difficulty difficulty) {
//                   return DropdownMenuItem<Difficulty>(
//                     value: difficulty,
//                     child: Text(difficulty.name.toUpperCase()),
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//           _buildGameBoard(gameboardSize, messageFontSize),
//         ],
//       ),
//     );
//   }

//   Widget _buildGameBoard(double gameboardSize, double messageFontSize) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Padding(
//           padding: EdgeInsets.all(gameboardSize * 0.05),
//           child: Text(
//             message,
//             style: TextStyle(
//               fontSize: messageFontSize,
//               color: Colors.white,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         Container(
//           width: gameboardSize,
//           height: gameboardSize,
//           padding: EdgeInsets.all(gameboardSize * 0.05),
//           child: GridView.builder(
//             physics: NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: gameboardSize * 0.02,
//               mainAxisSpacing: gameboardSize * 0.02,
//             ),
//             itemCount: 9,
//             itemBuilder: (context, index) {
//               final row = index ~/ 3;
//               final col = index % 3;
//               return GestureDetector(
//                 onTap: () => _handlePlayerMove(row, col),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[800],
//                     borderRadius: BorderRadius.circular(gameboardSize * 0.02),
//                   ),
//                   child: Center(
//                     child: _buildCell(board[row][col], gameboardSize / 3),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         if (gameOver)
//           Padding(
//             padding: EdgeInsets.only(top: gameboardSize * 0.05),
//             child: ElevatedButton(
//               onPressed: _resetGame,
//               child: Text(
//                 'Play Again',
//                 style: TextStyle(fontSize: messageFontSize * 0.7),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).primaryColor,
//                 foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: gameboardSize * 0.1,
//                   vertical: gameboardSize * 0.03,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(gameboardSize * 0.02),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildScoreCard(String title, int score, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
//       decoration: BoxDecoration(
//         color: Colors.grey[850],
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: color.withOpacity(0.5), width: 2),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//             ),
//           ),
//           Text(
//             score.toString(),
//             style: TextStyle(
//               color: color,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactScore(String title, int score, Color color) {
//     return Column(
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 14,
//           ),
//         ),
//         Text(
//           score.toString(),
//           style: TextStyle(
//             color: color,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   void _resetScores() {
//     setState(() {
//       playerScore = 0;
//       computerScore = 0;
//       draws = 0;
//       _saveScores();
//       _resetGame();
//     });
//   }

//   // Update your _handlePlayerMove to update scores
//   void _handlePlayerMove(int row, int col) {
//     if (board[row][col] != 0 || gameOver || !isPlayerTurn) return;

//     _playSound('click');

//     setState(() {
//       board[row][col] = 1;
//       if (_checkWinner(row, col)) {
//         gameOver = true;
//         message = 'Game over: You won!';
//         playerScore++; // Update player score
//         _saveScores();
//         _playSound('win');
//         return;
//       }

//       if (_isBoardFull()) {
//         gameOver = true;
//         message = 'Game over: Draw!';
//         draws++; // Update draws
//         _saveScores();
//         _playSound('draw');
//         return;
//       }

//       isPlayerTurn = false;
//       message = "Computer's turn (O)";
//     });

//     Future.delayed(Duration(milliseconds: 500), () {
//       if (!gameOver) _makeComputerMove();
//     });
//   }

//   // Update computer move to handle scoring
//   void _makeComputerMove() {
//     if (gameOver) return;

//     int row, col;
//     switch (difficulty) {
//       case Difficulty.easy:
//         (row, col) = _makeEasyMove();
//         break;
//       case Difficulty.medium:
//         (row, col) = _makeMediumMove();
//         break;
//       case Difficulty.hard:
//         (row, col) = _makeHardMove();
//         break;
//     }

//     _playSound('click');

//     setState(() {
//       board[row][col] = 2;
//       if (_checkWinner(row, col)) {
//         gameOver = true;
//         message = 'Game over: Computer won!';
//         computerScore++; // Update computer score
//         _saveScores();
//         _playSound('win');
//         return;
//       }

//       if (_isBoardFull()) {
//         gameOver = true;
//         message = 'Game over: Draw!';
//         draws++; // Update draws
//         _saveScores();
//         _playSound('draw');
//         return;
//       }

//       isPlayerTurn = true;
//       message = 'Your turn (X)';
//     });
//   }

//   // [Keep all your existing helper methods like _makeEasyMove, _makeMediumMove, etc.]
// }

// enum Difficulty { easy, medium, hard }
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This will be auto-generated

// Data model for Game
class Game {
  final String id;
  final String creator;
  final String? opponent;
  final List<List<int>> board;
  final bool isComplete;
  final String? winner;
  final String currentTurn;

  Game({
    required this.id,
    required this.creator,
    this.opponent,
    required this.board,
    required this.isComplete,
    this.winner,
    required this.currentTurn,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'creator': creator,
        'opponent': opponent,
        'board': board.map((row) => row.map((cell) => cell).toList()).toList(),
        'isComplete': isComplete,
        'winner': winner,
        'currentTurn': currentTurn,
      };

  factory Game.fromJson(Map<String, dynamic> json) {
    var boardData = (json['board'] as List)
        .map((row) => (row as List).map((cell) => cell as int).toList())
        .toList();

    return Game(
      id: json['id'],
      creator: json['creator'],
      opponent: json['opponent'],
      board: List<List<int>>.from(boardData),
      isComplete: json['isComplete'],
      winner: json['winner'],
      currentTurn: json['currentTurn'],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(OnlineTicTacToe());
}

class OnlineTicTacToe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _usernameController = TextEditingController();

  Future<void> _anonymousLogin() async {
    try {
      await _auth.signInAnonymously();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GameLobbyScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging in: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tic Tac Toe Online')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Enter your username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _anonymousLogin,
                child: Text('Enter Game Lobby'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Game Lobby Screen
class GameLobbyScreen extends StatefulWidget {
  @override
  _GameLobbyScreenState createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends State<GameLobbyScreen> {
  final DatabaseReference _gamesRef =
      FirebaseDatabase.instance.ref().child('games');
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _createGame() async {
    try {
      // Create a new game reference
      final newGameRef = _gamesRef.push(); // This generates a unique key

      final newGame = {
        'id': newGameRef.key,
        'creator': userId,
        'opponent': null,
        'board': List.generate(3, (_) => List.filled(3, 0)).toList(),
        'isComplete': false,
        'winner': null,
        'currentTurn': userId,
        'createdAt': ServerValue.timestamp,
      };

      // Save the game to Firebase
      await newGameRef.set(newGame);

      // Navigate to the game screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OnlineGameScreen(gameId: newGameRef.key!),
        ),
      );
    } catch (e) {
      print('Error creating game: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating game: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Lobby'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _gamesRef.orderByChild('createdAt').onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Center(child: Text('No games available'));
          }

          // Convert the data to a list of games
          Map<dynamic, dynamic>? gamesMap =
              snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

          if (gamesMap == null) {
            return Center(child: Text('No games available'));
          }

          List<MapEntry<dynamic, dynamic>> games =
              gamesMap.entries.where((entry) {
            final game = entry.value as Map<dynamic, dynamic>;
            return game['isComplete'] == false &&
                game['opponent'] == null &&
                game['creator'] != userId;
          }).toList();

          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index].value as Map<dynamic, dynamic>;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Game ${index + 1}'),
                  subtitle: Text('Created by: ${game['creator']}'),
                  trailing: ElevatedButton(
                    onPressed: () => _joinGame(games[index].key, game),
                    child: Text('Join Game'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGame,
        child: Icon(Icons.add),
        tooltip: 'Create New Game',
      ),
    );
  }

  void _joinGame(String gameId, Map<dynamic, dynamic> game) async {
    try {
      await _gamesRef.child(gameId).update({
        'opponent': userId,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OnlineGameScreen(gameId: gameId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining game: $e')),
      );
    }
  }
}

// Online Game Screen
class OnlineGameScreen extends StatefulWidget {
  final String gameId;

  OnlineGameScreen({required this.gameId});

  @override
  _OnlineGameScreenState createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  final DatabaseReference _gameRef =
      FirebaseDatabase.instance.ref().child('games');
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  late final Stream<DatabaseEvent> _gameStream =
      _gameRef.child(widget.gameId).onValue;

  // Remove initState since we're initializing the stream directly above
  // If you need other initialization logic, you can keep initState:
  @override
  void initState() {
    super.initState();
    // Any other initialization code can go here
  }

  bool _isBoardFull(List<List<dynamic>> board) {
    return board.every((row) => row.every((cell) => cell != 0));
  }

  Future<void> _makeMove(
      Map<dynamic, dynamic> gameData, int row, int col) async {
    try {
      // Check if game is already complete
      if (gameData['isComplete'] == true) return;

      // Check if it's user's turn and cell is empty
      if (gameData['currentTurn'] != userId ||
          (gameData['board'] as List)[row][col] != 0) {
        return;
      }

      // Create a new board with the move
      List<List<dynamic>> newBoard =
          List.from((gameData['board'] as List).map((row) => List.from(row)));

      // Update the board (1 for creator, 2 for opponent)
      int playerMark = gameData['creator'] == userId ? 1 : 2;
      newBoard[row][col] = playerMark;

      // Check for winner or draw
      bool isWinner = _checkWinner(newBoard, row, col, playerMark);
      bool isDraw = _isBoardFull(newBoard);

      // Determine next turn
      String nextTurn = gameData['creator'] == userId
          ? gameData['opponent']
          : gameData['creator'];

      // Update game state
      Map<String, dynamic> updates = {
        'board': newBoard,
        'currentTurn': nextTurn,
      };

      // If game is over, update completion status
      if (isWinner || isDraw) {
        updates['isComplete'] = true;
        updates['winner'] = isWinner ? userId : null;
      }

      // Send updates to Firebase
      await _gameRef.child(widget.gameId).update(updates);

      // Show game result message
      if (isWinner || isDraw) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isWinner ? 'You won!' : 'Game ended in a draw!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error making move: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making move: $e')),
      );
    }
  }

  bool _checkWinner(List<List<dynamic>> board, int row, int col, int player) {
    // Check row
    if (board[row].every((cell) => cell == player)) return true;

    // Check column
    if (board.every((r) => r[col] == player)) return true;

    // Check diagonals
    bool mainDiagonal = true;
    bool antiDiagonal = true;

    for (int i = 0; i < 3; i++) {
      if (board[i][i] != player) mainDiagonal = false;
      if (board[i][2 - i] != player) antiDiagonal = false;
    }

    return mainDiagonal || antiDiagonal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Online Tic Tac Toe')),
      body: StreamBuilder<DatabaseEvent>(
        stream: _gameStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Center(child: CircularProgressIndicator());
          }

          final gameData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final bool isMyTurn = gameData['currentTurn'] == userId;
          final bool gameComplete = gameData['isComplete'] == true;

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game status
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isMyTurn
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    gameComplete
                        ? (gameData['winner'] == userId
                            ? 'You won!'
                            : gameData['winner'] == null
                                ? 'Draw!'
                                : 'Opponent won!')
                        : (isMyTurn ? 'Your turn' : "Opponent's turn"),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isMyTurn ? Colors.green : Colors.grey[700],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Game board
                AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final row = index ~/ 3;
                      final col = index % 3;
                      final cell = (gameData['board'] as List)[row][col];

                      return GestureDetector(
                        onTap: gameComplete
                            ? null
                            : () => _makeMove(gameData, row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isMyTurn
                                  ? Colors.blue.withOpacity(0.5)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cell == 0
                                  ? ''
                                  : cell == 1
                                      ? 'X'
                                      : 'O',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: cell == 1 ? Colors.blue : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                if (gameComplete)
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Return to lobby
                      },
                      child: Text('Return to Lobby'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
