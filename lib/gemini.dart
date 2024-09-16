import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

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

  bool _isLoading = false;

  void send() async {
    var inputText = _controller.text.trim();
    if (inputText.isEmpty) return;

    setState(() {
      convo.add(Chat(inputText, true));
      _isLoading = true;
    });

    try {
      var response = await gemini.text(inputText);
      if (response != null && response.output != null) {
        setState(() {
          convo.add(Chat(response.output?.toString().trim() ?? '', false));
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        convo.add(Chat("Error occurred: $e", false));
      });
    }

    setState(() {
      _isLoading = false;
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        message.text,
                        style: const TextStyle(color: Colors.white),
                        maxLines: null, // Allow text to wrap to multiple lines
                        overflow: TextOverflow.visible, // Show overflow text
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
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
