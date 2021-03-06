import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, rootBundle;
import 'package:confetti/confetti.dart';
import 'package:url_launcher/url_launcher.dart';

List<String>? results = []..length = 0;
List<String>? allowedGuesses = []..length = 0;
List<String>? answers = []..length = 0;
List<String> randomWordsPhrases = []..length = 0;

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

Future<bool> saveGuessesPreference(List<String> guesses) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList('guesses', guesses);
  return prefs.commit();
}

Future<List<String>?> getGuessesPreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? guesses = prefs.getStringList('guesses');
  return guesses;
}

Future<bool> saveAnswersPreference(List<String> answers) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList('answers', answers);
  return prefs.commit();
}

Future<List<String>?> getAnswersPreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? answers = prefs.getStringList('answers');
  return answers;
}

Future<bool> saveVisitsPreference(int visits) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('visits', visits);
  return prefs.commit();
}

Future<int?> getVisitsPreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? visits = prefs.getInt('visits');
  return visits;
}


Future<void> readWords() async {
  if (answers?.length == 0) {
    try {
      await rootBundle
          .loadString('assets/allowed_guesses.txt')
          .then((value) => {
        for (String i in const LineSplitter().convert(value))
          {
            allowedGuesses?.add(i),
          },
        saveGuessesPreference(allowedGuesses!),
      });
      await rootBundle.loadString('assets/answers.txt').then((value) => {
        for (String i in const LineSplitter().convert(value))
          {
            answers?.add(i),
          },
        saveAnswersPreference(answers!),
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  } else {
    getAnswersPreference().then((value) => {
      answers = value,
    });
    getGuessesPreference().then((value) => {
      allowedGuesses = value,
    });
  }
  await rootBundle.loadString('assets/tyring_random_words.txt').then((value) => {
    for (String i in const LineSplitter().convert(value))
      {
        randomWordsPhrases.add(i),
      },
  });
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
      title: 'Daword',
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
    readWords();
    getResultsPreference().then((value) => {
      results = value,
    });
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

  Widget _activePage(int index) {
    if (index == 0) {
      return Column(
        children: [
          Center(
            child: CupertinoButton.filled(
                child: const Text('Start'),
                onPressed: () {
                  getVisitsPreference().then((value) => {
                    if (value != null)
                      {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const GameScreen())),
                      }
                    else
                      {
                        saveVisitsPreference(1),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const TutorialScreen())),
                      }
                  });
                }),
          ),
          const Divider(
            endIndent: 100,
            indent: 100,
          ),
          Center(
            child: CupertinoButton.filled(
                child: const Text('How to play'),
                padding: const EdgeInsets.all(14),
                onPressed: () {
                  saveVisitsPreference(1);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TutorialScreen()));
                }),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    } else if (index == 1) {
      return Center(
        child: ListView(
          children: _getScores(),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Made By\nYoussef Dawoud',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: CupertinoButton.filled(
                  child: const Text(
                    "Email\nyoussef.dawoud@hotmail.com",
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () async {
                    const url =
                        'mailto:youssef.dawoud@hotmail.com?subject=Daword app&body= ';
                    if (await canLaunch(url)) launch(url);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: CupertinoButton.filled(
                  child: const Text(
                    "Github: DeathPancake1",
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () async {
                    const url = 'https://github.com/DeathPancake1';
                    if (await canLaunch(url)) launch(url);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Daword'),
      ),
      body: _activePage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.watch_later), label: 'Scores'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info')
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  static const _textStyling = TextStyle(
    fontSize: 18,
  );
  SizedBox _letterBox(String letter, Color color) {
    return SizedBox.square(
      dimension: 60,
      child: Container(
        margin: const EdgeInsets.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[500]!,
            width: 3,
          ),
          color: color,
        ),
        child: Text(
          letter,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text('Daword Tutorial'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Guess the word in 6 tries.',
              style: _textStyling,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Each guess must be a valid 5 letter word.',
              style: _textStyling,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'After each guess, the color of the tiles will change to show how close your guess was to the word.',
              style: _textStyling,
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Examples',
              style: TextStyle(fontSize: 28),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _letterBox('S', Colors.green),
              _letterBox('H', Colors.transparent),
              _letterBox('I', Colors.transparent),
              _letterBox('N', Colors.transparent),
              _letterBox('E', Colors.transparent),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'The letter S is in the word and in the correct spot.',
              style: _textStyling,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _letterBox('B', Colors.transparent),
              _letterBox('L', Colors.transparent),
              _letterBox('I', Colors.transparent),
              _letterBox('N', Colors.amber),
              _letterBox('D', Colors.transparent),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'The letter N is in the word but in the wrong spot.',
              style: _textStyling,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _letterBox('S', Colors.transparent),
              _letterBox('P', Colors.grey),
              _letterBox('E', Colors.transparent),
              _letterBox('N', Colors.transparent),
              _letterBox('D', Colors.transparent),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'The letter P is not in the word in any spot.',
              style: _textStyling,
            ),
          ),
          Center(
            child: CupertinoButton.filled(
                child: const Text('Start'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GameScreen()));
                }),
          ),
        ],
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
  late ConfettiController _controllerRight;
  late ConfettiController _controllerLeft;
  static const row = 6;
  static const col = 5;
  String _daword = '';
  String _guess = '';
  int _trial = 0;
  bool _solved = false;
  bool _done = false;
  int _badGuess = 0;
  Map<String, Color> _keyboardMap = {};
  final _table = List.generate(row, (i) => List.filled(col, '', growable: false),
      growable: false);
  final _colorTable = List.generate(
      row, (i) => List.filled(col, Colors.grey[100], growable: false),
      growable: false);
  @override
  void initState() {
    super.initState();
    _keyboardMap = {
      'q': Colors.grey[300]!,
      'w': Colors.grey[300]!,
      'e': Colors.grey[300]!,
      'r': Colors.grey[300]!,
      't': Colors.grey[300]!,
      'y': Colors.grey[300]!,
      'u': Colors.grey[300]!,
      'i': Colors.grey[300]!,
      'a': Colors.grey[300]!,
      's': Colors.grey[300]!,
      'd': Colors.grey[300]!,
      'f': Colors.grey[300]!,
      'g': Colors.grey[300]!,
      'h': Colors.grey[300]!,
      'j': Colors.grey[300]!,
      'k': Colors.grey[300]!,
      'z': Colors.grey[300]!,
      'x': Colors.grey[300]!,
      'c': Colors.grey[300]!,
      'v': Colors.grey[300]!,
      'b': Colors.grey[300]!,
      'n': Colors.grey[300]!,
      'm': Colors.grey[300]!,
      'p': Colors.grey[300]!,
      'l': Colors.grey[300]!,
      'o': Colors.grey[300]!,
    };
    _createWord();
    _guess = '';
    _trial = 0;
    _solved = false;
    _done = false;
    _badGuess=0;
    _controllerRight = ConfettiController(duration: const Duration(seconds: 1));
    _controllerLeft = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controllerLeft.dispose();
    _controllerRight.dispose();
    super.dispose();
  }

  void _createWord() {
    _daword = '';
    _done = false;
    _solved = false;
    _trial = 0;
    Random random = Random();
    int rnd = random.nextInt(2315);
    _daword = answers![rnd];
  }

  void _deleteLetter() {
    setState(() {
      if (!_done) {
        if (_guess.isNotEmpty) {
          _guess = _guess.substring(0, _guess.length - 1);
        }
        if (_trial < 6) {
          int i = 0;
          while (i < 5) {
            if (i >= _guess.length) {
              _table[_trial][i] = '';
            } else {
              _table[_trial][i] = _guess.characters.elementAt(i);
            }
            i++;
          }
        }
      }
    });
  }

  void _appendLetter(String x) {
    setState(() {
      if (!_done) {
        if (_guess.length < 5) {
          _guess = _guess + x;
        }
        if (_trial < 6) {
          int i = 0;
          while (i < 5) {
            if (i >= _guess.length) {
              _table[_trial][i] = '';
            } else {
              _table[_trial][i] = _guess.characters.elementAt(i);
            }
            i++;
          }
        }
        return;
      }
    });
  }

  void _endGame() {
    results ??= []..length = 0;
    results?.add('Tries: ' +
        (_trial).toString() +
        '/6 The word: ' +
        _daword +
        ' ' +
        _solved.toString());
    saveResultsPreference(results!);
  }

  List<String> _dawordChars(){
    List<String> chars=[];
    for(int i=0;i<_daword.length;i++){
      chars.add(_daword[i]);
    }
    return chars;
  }

  void _checkGuess() {
    setState(() {
      List<String> chars=_dawordChars();
      if (_trial < 6 && !_done) {
        if (_daword == _guess) {
          _badGuess=0;
          for (int i = 0; i < _daword.length; i++) {
            _colorTable[_trial][i] = Colors.green;
            _keyboardMap[_guess.characters.elementAt(i)] = Colors.green;
          }
          _done = true;
          _solved = true;
          _trial++;
        } else if (allowedGuesses?.contains(_guess) ?? false) {
          _badGuess=0;
          for (int i = 0; i < _daword.length; i++) {
            if (_guess.characters.elementAt(i) ==
                _daword.characters.elementAt(i)) {
              _colorTable[_trial][i] = Colors.green;
              _keyboardMap[_guess.characters.elementAt(i)] = Colors.green;
              chars.remove(_guess.characters.elementAt(i));
            }
          }
          for (int i = 0; i < _daword.length; i++){
            if(_colorTable[_trial][i] != Colors.green){
              if (chars.contains(_guess.characters.elementAt(i))) {
                chars.remove(_guess.characters.elementAt(i));
                _colorTable[_trial][i] = Colors.amber;
                if (_keyboardMap[_guess.characters.elementAt(i)] !=
                    Colors.green) {
                  _keyboardMap[_guess.characters.elementAt(i)] = Colors.amber;
                }
              }else{
                _colorTable[_trial][i] = Colors.grey;
              }
            }
          }
          for (int i=0;i<_daword.length;i++){
            if (_keyboardMap[_guess.characters.elementAt(i)] !=
                Colors.green&&_keyboardMap[_guess.characters.elementAt(i)] !=
                Colors.amber){
              _keyboardMap[_guess.characters.elementAt(i)] = Colors.grey;
            }
          }
          _trial++;
          _guess = '';
        }
        else{
          _badGuess++;
        }
      }
      if (_trial == 6 || _done == true) {
        _done = true;
        _endGame();
      }
    });
  }

  var _pressed = '';

  void _onPointerDown(String letter) {
    setState(() {
      _pressed = letter;
    });
  }

  void _onPointerUp(String letter) {
    setState(() {
      _appendLetter(letter);
      _pressed = '';
    });
  }

  Listener _letterButton(String letter) {
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
        width: 32,
        height: 53,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 100),
            style: TextStyle(
                color: _pressed != letter
                    ? Colors.black
                    : Colors.black.withOpacity(0.25),
                fontSize: 18),
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
          color: _pressed==letter?_keyboardMap[letter]?.withOpacity(0.8):_keyboardMap[letter],
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(0),
        margin: const EdgeInsets.only(top: 5, bottom: 5),
      ),
    );
  }

  SizedBox _letterBox(int x, y) {
    return SizedBox.square(
      dimension: 60,
      child: Container(
        margin: const EdgeInsets.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[500]!,
            width: 3,
          ),
          color: _colorTable[x][y],
        ),
        child: Text(
          _table[x][y].toUpperCase(),
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daword'),
        leading: IconButton(
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            icon: const Icon(Icons.arrow_back)),
        actions: _done
            ? [
          CupertinoButton(
              child: const Text('Play Again'),
              onPressed: () {
                _createWord();
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                    const GameScreen(),
                    transitionDuration: const Duration(seconds: 0),
                  ),
                );
              }),
        ]
            : null,
      ),
      body: Center(
        child: Container(
          color: Colors.grey[100],
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _letterBox(0, 0),
                    _letterBox(0, 1),
                    _letterBox(0, 2),
                    _letterBox(0, 3),
                    _letterBox(0, 4),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _letterBox(1, 0),
                  _letterBox(1, 1),
                  _letterBox(1, 2),
                  _letterBox(1, 3),
                  _letterBox(1, 4),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _letterBox(2, 0),
                  _letterBox(2, 1),
                  _letterBox(2, 2),
                  _letterBox(2, 3),
                  _letterBox(2, 4),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _letterBox(3, 0),
                  _letterBox(3, 1),
                  _letterBox(3, 2),
                  _letterBox(3, 3),
                  _letterBox(3, 4),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _letterBox(4, 0),
                  _letterBox(4, 1),
                  _letterBox(4, 2),
                  _letterBox(4, 3),
                  _letterBox(4, 4),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _letterBox(5, 0),
                  _letterBox(5, 1),
                  _letterBox(5, 2),
                  _letterBox(5, 3),
                  _letterBox(5, 4),
                ],
              ),
              const Spacer(),
              Stack(
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _letterButton('q'),
                          _letterButton('w'),
                          _letterButton('e'),
                          _letterButton('r'),
                          _letterButton('t'),
                          _letterButton('y'),
                          _letterButton('u'),
                          _letterButton('i'),
                          _letterButton('o'),
                          _letterButton('p'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _letterButton('a'),
                          _letterButton('s'),
                          _letterButton('d'),
                          _letterButton('f'),
                          _letterButton('g'),
                          _letterButton('h'),
                          _letterButton('j'),
                          _letterButton('k'),
                          _letterButton('l'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CupertinoButton(
                            child: const Text('Enter'),
                            onPressed: () {
                              var oldTrial = _trial;
                              _checkGuess();
                              if (_trial == oldTrial && !_done && _badGuess<3) {
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
                              }else if(_trial == oldTrial && !_done && _badGuess>=3){
                                Random random = Random();
                                int rnd = random.nextInt(randomWordsPhrases.length);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:  Text(randomWordsPhrases[rnd]),
                                    action: SnackBarAction(
                                      label: 'OK',
                                      onPressed: () {
                                        // Code to execute.
                                      },
                                    ),
                                  ),
                                );
                              }
                              if (_done && _solved) {
                                _controllerRight.play();
                                _controllerLeft.play();
                              } else if (_done) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('The Word is ' + _daword),
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
                          _letterButton('z'),
                          _letterButton('x'),
                          _letterButton('c'),
                          _letterButton('v'),
                          _letterButton('b'),
                          _letterButton('n'),
                          _letterButton('m'),
                          CupertinoButton(
                            child: const Icon(Icons.backspace_outlined),
                            onPressed: _deleteLetter,
                            padding: const EdgeInsets.all(0),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ConfettiWidget(
                        confettiController: _controllerLeft,
                        blastDirection: pi / 4,
                        emissionFrequency: 0.3,
                        numberOfParticles: 10,
                        shouldLoop: false,
                        blastDirectionality: BlastDirectionality.explosive,
                      ),
                      ConfettiWidget(
                        confettiController: _controllerRight,
                        blastDirection: 3 * pi / 4,
                        emissionFrequency: 0.3,
                        numberOfParticles: 10,
                        shouldLoop: false,
                        blastDirectionality: BlastDirectionality.explosive,
                      ),
                    ],
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
