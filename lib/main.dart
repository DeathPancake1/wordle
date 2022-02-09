import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/services.dart';

String wordle = '';
String guess = '';
int trial = 0;
bool solved = false;
bool done = false;
List<String>? results = []..length = 0;
Map<String, Color> keyboardMap = {
  'q': Colors.transparent,
  'w': Colors.transparent,
  'e': Colors.transparent,
  'r': Colors.transparent,
  't': Colors.transparent,
  'y': Colors.transparent,
  'u': Colors.transparent,
  'i': Colors.transparent,
  'a': Colors.transparent,
  's': Colors.transparent,
  'd': Colors.transparent,
  'f': Colors.transparent,
  'g': Colors.transparent,
  'h': Colors.transparent,
  'j': Colors.transparent,
  'k': Colors.transparent,
  'z': Colors.transparent,
  'x': Colors.transparent,
  'c': Colors.transparent,
  'v': Colors.transparent,
  'b': Colors.transparent,
  'n': Colors.transparent,
  'm': Colors.transparent,
  'p': Colors.transparent,
  'l': Colors.transparent,
  'o': Colors.transparent,
};

Future<bool> saveResultsPreference(List<String> res) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList('results', res);
  return prefs.commit();
}

Future<List<String>?> getResultsPreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? res = prefs.getStringList('results');
  return res;
}

void main() => {
      WidgetsFlutterBinding.ensureInitialized(),
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]),
      runApp(const MyApp())
    };

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wordle Clone',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      routes: {
        '/': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    getResultsPreference().then((value) => {
          results = value,
        });
  }

  void createWord() {
    wordle = '';
    done = false;
    solved = false;
    trial = 0;
    Random random = Random();
    while (wordle.length != 5) {
      int rnd = random.nextInt(4333);
      wordle = all[rnd].toLowerCase();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _getScores() {
    List<Widget> scores = [const Divider()];
    IconData tempIcon;
    MaterialColor tempIconCol;
    if (results != null) {
      results?.forEach((element) {
        String tempTF = element.substring(element.length - 4, element.length);
        if (tempTF == 'true') {
          tempIcon = Icons.done;
          tempIconCol = Colors.green;
        } else {
          tempIcon = Icons.close;
          tempIconCol = Colors.red;
        }
        scores.add(Card(
          child: ListTile(
            leading: Icon(
              tempIcon,
              color: tempIconCol,
            ),
            title: Text(
              element.substring(0, element.length - 5),
              textAlign: TextAlign.center,
            ),
          ),
        ));
      });
    }
    return scores;
  }

  Center _activePage(int index) {
    if (index == 0) {
      return Center(
        child: CupertinoButton.filled(
            child: const Text('Start'),
            onPressed: () {
              createWord();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const GameScreen()));
            }),
      );
    } else {
      return Center(
        child: ListView(
          children: _getScores(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Wordle Clone'),
      ),
      body: _activePage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.watch_later), label: 'Scores'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const row = 6;
  static const col = 5;
  var table = List.generate(row, (i) => List.filled(col, '', growable: false),
      growable: false);
  var colorTable = List.generate(
      row, (i) => List.filled(col, Colors.grey[300], growable: false),
      growable: false);
  @override
  void initState() {
    super.initState();
    keyboardMap = {
      'q': Colors.transparent,
      'w': Colors.transparent,
      'e': Colors.transparent,
      'r': Colors.transparent,
      't': Colors.transparent,
      'y': Colors.transparent,
      'u': Colors.transparent,
      'i': Colors.transparent,
      'a': Colors.transparent,
      's': Colors.transparent,
      'd': Colors.transparent,
      'f': Colors.transparent,
      'g': Colors.transparent,
      'h': Colors.transparent,
      'j': Colors.transparent,
      'k': Colors.transparent,
      'z': Colors.transparent,
      'x': Colors.transparent,
      'c': Colors.transparent,
      'v': Colors.transparent,
      'b': Colors.transparent,
      'n': Colors.transparent,
      'm': Colors.transparent,
      'p': Colors.transparent,
      'l': Colors.transparent,
      'o': Colors.transparent,
    };
    guess = '';
    trial = 0;
    solved = false;
    done = false;
  }

  void deleteLetter() {
    setState(() {
      if (!done) {
        if (guess.isNotEmpty) {
          guess = guess.substring(0, guess.length - 1);
        }
        if (trial < 6) {
          int i = 0;
          while (i < 5) {
            if (i >= guess.length) {
              table[trial][i] = '';
            } else {
              table[trial][i] = guess.characters.elementAt(i);
            }
            i++;
          }
        }
      }
    });
  }

  void appendLetter(String x) {
    setState(() {
      if (!done) {
        if (guess.length < 5) {
          guess = guess + x;
        }
        if (trial < 6) {
          int i = 0;
          while (i < 5) {
            if (i >= guess.length) {
              table[trial][i] = '';
            } else {
              table[trial][i] = guess.characters.elementAt(i);
            }
            i++;
          }
        }
        return;
      }
    });
  }

  void endGame() {
    results ??= []..length = 0;
    results?.add('Tries: ' +
        (trial).toString() +
        '/6 The word: ' +
        wordle +
        ' ' +
        solved.toString());
    saveResultsPreference(results!);
  }

  void checkGuess() {
    setState(() {
      if (trial < 6 && !done) {
        if (guess.length == 5) {
          for (var element in all) {
            if (element.toLowerCase() == guess) {
              if (guess == wordle) {
                for (int i = 0; i < 5; i++) {
                  colorTable[trial][i] = Colors.green;
                  keyboardMap[guess.characters.elementAt(i)] = Colors.green;
                }
                done = true;
                solved = true;
              } else {
                for (int i = 0; i < 5; i++) {
                  if (wordle.characters
                      .contains(guess.characters.elementAt(i))) {
                    colorTable[trial][i] = Colors.amber;
                    if (keyboardMap[guess.characters.elementAt(i)] !=
                        Colors.green) {
                      keyboardMap[guess.characters.elementAt(i)] = Colors.amber;
                    }
                  } else {
                    colorTable[trial][i] = Colors.grey;
                    keyboardMap[guess.characters.elementAt(i)] = Colors.grey;
                  }
                }
                for (int i = 0; i < 5; i++) {
                  if (guess.characters.elementAt(i) ==
                      wordle.characters.elementAt(i)) {
                    colorTable[trial][i] = Colors.green;
                    keyboardMap[guess.characters.elementAt(i)] = Colors.green;
                  }
                }
              }
              trial++;
              guess = '';
            }
          }
        }
        if (trial == 6 || done == true) {
          done = true;
          endGame();
        }
      }
    });
  }

  var _pressed = 'kosom el sisi';

  void _onPointerDown(String letter) {
    setState(() {
      _pressed = letter;
    });
  }

  void _onPointerUp(String letter) {
    setState(() {
      appendLetter(letter);
      _pressed = 'kosom el sisi';
    });
  }

  Listener letterButton(String letter) {
    return Listener(
      onPointerDown: (p) {
        _onPointerDown(letter);
      },
      onPointerUp: (p) {
        setState(() {
          _onPointerUp(letter);
        });
      },
      child: Container(
        width: 30,
        height: 50,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 100),
            style: TextStyle(
                color: _pressed != letter
                    ? Colors.black
                    : Colors.black.withOpacity(0.25)),
            child: Text(
              letter.toUpperCase(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.transparent,
          ),
          color: keyboardMap[letter],
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(0),
        margin: const EdgeInsets.all(3),
      ),
    );
  }

  SizedBox letterBox(int x, y) {
    return SizedBox.square(
      dimension: 50,
      child: Container(
        margin: const EdgeInsets.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 3,
          ),
          color: colorTable[x][y],
        ),
        child: Text(
          table[x][y],
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wordle Clone'),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Center(
        child: Container(
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  letterBox(0, 0),
                  letterBox(0, 1),
                  letterBox(0, 2),
                  letterBox(0, 3),
                  letterBox(0, 4),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  letterBox(1, 0),
                  letterBox(1, 1),
                  letterBox(1, 2),
                  letterBox(1, 3),
                  letterBox(1, 4),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  letterBox(2, 0),
                  letterBox(2, 1),
                  letterBox(2, 2),
                  letterBox(2, 3),
                  letterBox(2, 4),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  letterBox(3, 0),
                  letterBox(3, 1),
                  letterBox(3, 2),
                  letterBox(3, 3),
                  letterBox(3, 4),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  letterBox(4, 0),
                  letterBox(4, 1),
                  letterBox(4, 2),
                  letterBox(4, 3),
                  letterBox(4, 4),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  letterBox(5, 0),
                  letterBox(5, 1),
                  letterBox(5, 2),
                  letterBox(5, 3),
                  letterBox(5, 4),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  letterButton('q'),
                  letterButton('w'),
                  letterButton('e'),
                  letterButton('r'),
                  letterButton('t'),
                  letterButton('y'),
                  letterButton('u'),
                  letterButton('i'),
                  letterButton('o'),
                  letterButton('p'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  letterButton('a'),
                  letterButton('s'),
                  letterButton('d'),
                  letterButton('f'),
                  letterButton('g'),
                  letterButton('h'),
                  letterButton('j'),
                  letterButton('k'),
                  letterButton('l'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    child: const Text('Enter'),
                    onPressed: () {
                      var oldTrial = trial;
                      checkGuess();
                      if (trial == oldTrial && !done) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Word not in Library'),
                            action: SnackBarAction(
                              label: 'OK',
                              onPressed: () {
                                // Code to execute.
                              },
                            ),
                          ),
                        );
                      }
                      if (done) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('The Word is ' + wordle),
                            action: SnackBarAction(
                              label: 'OK',
                              onPressed: () {
                                // Code to execute.
                              },
                            ),
                          ),
                        );
                      }
                    },
                    padding: const EdgeInsets.all(0),
                  ),
                  letterButton('z'),
                  letterButton('x'),
                  letterButton('c'),
                  letterButton('v'),
                  letterButton('b'),
                  letterButton('n'),
                  letterButton('m'),
                  CupertinoButton(
                    child: const Icon(Icons.backspace_outlined),
                    onPressed: deleteLetter,
                    padding: const EdgeInsets.all(0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
