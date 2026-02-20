// Hien Dao. Mobile App Development

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;

  Timer? _hungerTimer;
  DateTime? happinessStartTime;
  bool hasWon = false;

  TextEditingController textController = TextEditingController();
  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    _hungerTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _updateHunger();
    });
    confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    textController.dispose();
    confettiController.dispose();
    super.dispose();
  }

  Color _moodColor(int happinessLevel) {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel < 30) {
      return Colors.red;
    } else {
      return Colors.yellow;
    }
  }

  IconData petMoodIndicator() {
    if (happinessLevel > 70) {
      return Icons.sentiment_satisfied_alt;
    } else if (happinessLevel < 30) {
      return Icons.sentiment_dissatisfied;
    } else {
      return Icons.sentiment_neutral;
    }
  }

  void _setPetName() {
    setState(() {
      petName = textController.text;
    });
  }

  void _checkWinCondition() {
    if (happinessLevel > 80) {
      happinessStartTime ??= DateTime.now();

      final elapsed = DateTime.now().difference(happinessStartTime!);
      if (elapsed.inMinutes >= 1 && !hasWon) {
        hasWon = true;
        _showWin();
      }
    } else {
      happinessStartTime = null;
    }
  }

  void _checkLossCondition() {
  if (hungerLevel >= 100 && happinessLevel <= 10) {
    _showLoss();
  }
}


  void _playWithPet() {
    setState(() {
      happinessLevel += 10;
      _updateHunger();
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel -= 10;
      _updateHappiness();
    });
  }

  void _updateHappiness() {
    setState(() {
      if (hungerLevel < 30) {
        happinessLevel -= 20;
      } else {
        happinessLevel += 10;
      }
      _checkWinCondition();
      _checkLossCondition();
    });
  }

  void _updateHunger() {
    setState(() {
      hungerLevel += 5;
      if (hungerLevel >= 100) {
        hungerLevel = 100;
        happinessLevel -= 20;
      }
      _checkWinCondition();
      _checkLossCondition();
    });
  }

  void _showWin() {
    confettiController.play();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('YOU WON!'),
        content: Text('Congratulation! $petName is very happy!!!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),

          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }
    
  void _showLoss() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('YOU LOST!'),
        content: Text('$petName is very upset and it might eat you!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),

          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      happinessLevel = 50;
      hungerLevel = 50;
      hasWon = false;
      happinessStartTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              // Display pet name and image with mood color
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$petName is feeling ${happinessLevel > 70 ? "Happy" : happinessLevel < 30 ? "Sad" : "Okay"}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: _moodColor(happinessLevel)
                    )
                  ),
                  SizedBox(width: 8.0),
                  Icon(petMoodIndicator(), size: 40.0, color: _moodColor(happinessLevel)),
                ]
              ),
              SizedBox(height: 8.0),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _moodColor(happinessLevel),
                  BlendMode.modulate,
                ),
                child: Container(
                  width: 150.0,
                  height: 150.0,
                  child: Image.asset('assets/pet_image2.jpg'),
                )
              ),

              // Display happiness and hunger levels
              SizedBox(height: 16.0),
              Text('Happiness Level: $happinessLevel', style: TextStyle(fontSize: 20.0)),
              SizedBox(height: 16.0),
              Text('Hunger Level: $hungerLevel', style: TextStyle(fontSize: 20.0)),
              SizedBox(height: 32.0),

              // Input field to set pet name and buttons to play and feed the pet
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300.0,
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        labelText: 'Enter Your Pet Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _setPetName();
                    },
                    child: Text('Set Name'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _playWithPet,
                child: Text('Play with Your Pet'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _feedPet,
                child: Text('Feed Your Pet'),
              ),
            ],
          ),


          // Confetti
          ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
          ),
        ]
      ) 
    );
  }
}
