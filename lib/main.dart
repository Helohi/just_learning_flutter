import 'dart:io';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: const ReadWriteFileExample(),
    );
  }
}

class ReadWriteFileExample extends StatefulWidget {
  const ReadWriteFileExample({super.key});

  @override
  State<ReadWriteFileExample> createState() => _ReadWriteFileExampleState();
}

class _ReadWriteFileExampleState extends State<ReadWriteFileExample> {
  late final TextEditingController _textController;
  late final FocusNode textFieldFocusNode;
  static const kLocalFileName = 'demo_localfile.txt';
  String _localFileContent = '';
  String _localFilePath = kLocalFileName;

  @override
  void initState() {
    textFieldFocusNode = FocusNode();
    _textController = TextEditingController();
    _readTextFromLocalFile();
    _getLocalFile.then((file) => setState(() => _localFilePath = file.path));
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local file read/write Demo'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Write to local file:'),
          TextField(
            focusNode: textFieldFocusNode,
            controller: _textController,
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () async {
                  _readTextFromLocalFile();
                  _textController.text = _localFileContent;
                  FocusScope.of(context).requestFocus(textFieldFocusNode);
                  log('Text from file was successfully loaded');
                },
                child: const Text('Load'),
              ),
              TextButton(
                onPressed: () async {
                  await _writeTextToLocalFile(_textController.text);
                  _textController.clear();
                  await _readTextFromLocalFile();
                  log('Text was saved to file successfully');
                },
                child: const Text('Save'),
              ),
            ],
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: const Text('Local file path:'),
            subtitle: Text(_localFilePath),
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: const Text('Local file content:'),
            subtitle: Text(_localFileContent),
          ),
        ],
      ),
    );
  }

  Future<String> get _getLocalPath async {
    final derictory = await getApplicationDocumentsDirectory();
    return derictory.path;
  }

  Future<File> get _getLocalFile async {
    final path = await _getLocalPath;
    return File('$path/$kLocalFileName');
  }

  Future<File> _writeTextToLocalFile(String text) async {
    final file = await _getLocalFile;
    return file.writeAsString(text);
  }

  Future _readTextFromLocalFile() async {
    String content;
    try {
      final file = await _getLocalFile;
      content = await file.readAsString();
    } catch (e) {
      content = 'Error loading local file: $e';
    }

    setState(() {
      _localFileContent = content;
    });
  }
}
