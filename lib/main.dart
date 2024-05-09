import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'IPTVChannelsScreen.dart';

void main() => runApp(IPTVApp());

class IPTVApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IPTV Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IPTVHome(),
    );
  }
}

class IPTVHome extends StatefulWidget {
  @override
  _IPTVHomeState createState() => _IPTVHomeState();
}

class _IPTVHomeState extends State<IPTVHome> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: "https://iptv-org.github.io/iptv/countries/es.m3u");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IPTV Player'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Give me a URL of iptv',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String? url = _urlController.text;
                  if (url != null && url.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IPTVChannelsScreen(url: url),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Error"),
                          content: Text("Need a valid URL."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Play'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
