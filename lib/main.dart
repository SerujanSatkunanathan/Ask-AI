import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  Gemini.init(apiKey: 'AIzaSyD4sct6oXarl6MRqiyqXwpzYMfzhRlEjgQ');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Chat> convo = [];
  final TextEditingController _controller = TextEditingController();
  final gemini = Gemini.instance;
  final FlutterTts flutterTts = FlutterTts();

  bool _isLoading = false;
  TtsState ttsState = TtsState.stopped;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(1.0);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      print("TTS Initialized Successfully");
    } catch (e) {
      print("Error initializing TTS: $e");
    }
  }

  Future<void> _speak(String text) async {
    try {
      var result = await flutterTts.speak(text);
      if (result == 1) setState(() => ttsState = TtsState.playing);
    } catch (e) {
      print("Error speaking text: $e");
    }
  }

  Future<void> _stop() async {
    try {
      var result = await flutterTts.stop();
      if (result == 1) setState(() => ttsState = TtsState.stopped);
    } catch (e) {
      print("Error stopping speech: $e");
    }
  }

  void send() async {
    var inputText = _controller.text.trim();
    if (inputText.isEmpty) return;

    setState(() {
      convo.add(Chat(inputText, true));
      _isLoading = true;
    });
    var outputText;
    try {
      var response = await gemini.text(inputText);
      if (response != null && response.output != null) {
        outputText = response.output?.toString().trim() ?? '';
        setState(() {
          convo.add(Chat(outputText, false));
        });

        _controller.clear();
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        convo.add(Chat("Error occurred: $e", false));
      });
      await _speak(outputText.toString());
    }

    setState(() {
      _isLoading = false;
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Center(
              child: const Text(
            'Ask AI',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          )),
          backgroundColor: const Color.fromARGB(255, 0, 59, 66),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: convo.length,
                itemBuilder: (context, index) {
                  var message = convo[index];
                  return Align(
                    alignment: message.sender
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: message.sender
                            ? const Color.fromARGB(255, 0, 100, 107)
                            : const Color.fromARGB(255, 0, 58, 10),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: Text(
                        message.text,
                        style: const TextStyle(color: Colors.white),
                        maxLines: null,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Colors.cyanAccent,
                ),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Your Prompt',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: send,
                      icon: const Icon(
                        Icons.send,
                        color: Color.fromARGB(255, 0, 100, 107),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Chat {
  String text;
  bool sender;

  Chat(this.text, this.sender);
}

enum TtsState { playing, stopped }
