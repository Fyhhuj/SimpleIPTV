import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'ChannelPlay.dart';

class IPTVChannelsScreen extends StatefulWidget {
  final String url;

  IPTVChannelsScreen({required this.url});

  @override
  _IPTVChannelsScreenState createState() => _IPTVChannelsScreenState();
}

class _IPTVChannelsScreenState extends State<IPTVChannelsScreen> {
  late Future<List<Channel>> _futureChannels;
  String _searchText = "";
  late List<Channel> _filteredChannels;

  @override
  void initState() {
    super.initState();
    _futureChannels = fetchChannels(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Canales IPTV'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSearchDialog(context);
        },
        child: Icon(Icons.search),
      ),
      body: FutureBuilder<List<Channel>>(
        future: _futureChannels,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Channel> channels = snapshot.data!;
            _filteredChannels = _searchText.isEmpty
                ? channels
                : channels
                .where((channel) => channel.name
                .toLowerCase()
                .contains(_searchText.toLowerCase()))
                .toList();
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              itemCount: _filteredChannels.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Channel selectedChannel = _filteredChannels[index];
                    print(selectedChannel.url);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayerScreen(videoUrl: selectedChannel.url),
                      ),
                    );
                  },
                  child: Card(
                    child: Center(
                      child: Text(
                            () {
                          try {
                            return utf8.decode(_filteredChannels[index].name.runes.toList());
                          } catch (e) {
                            return _filteredChannels[index].name;
                          }
                        }(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text('No se encontraron canales'),
            );
          }
        },
      ),
    );
  }

  Future<List<Channel>> fetchChannels(String url) async {
    List<Channel> channels = [];
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<String> lines = response.body.split('\n');
        String? name;
        String? streamUrl;
        for (String line in lines) {
          if (line.startsWith('#EXTINF:')) {
            name = line.split(',')[1].trim();
          } else if (line.isNotEmpty) {
            streamUrl = line.trim();
            if (streamUrl.endsWith('.m3u8')) {
              // Filter out only m3u8 URLs
              channels.add(Channel(name: name!, url: streamUrl));
            }
          }
        }
      } else {
        throw Exception('Error al cargar los canales');
      }
    } catch (e) {
      throw Exception('Error al cargar los canales: $e');
    }
    return channels;
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Buscar"),
          content: TextField(
            onChanged: (text) {
              setState(() {
                _searchText = text;
              });
            },
            decoration: InputDecoration(hintText: "Ingrese un nombre"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class Channel {
  final String name;
  final String url;

  Channel({required this.name, required this.url});
}
