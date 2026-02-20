import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/datasources/sync_server_datasource.dart';

class SyncServerPage extends StatefulWidget {
  const SyncServerPage({super.key});

  @override
  State<SyncServerPage> createState() => _SyncServerPageState();
}

class _SyncServerPageState extends State<SyncServerPage> {
  final SyncServerDatasource _server = SyncServerDatasource();
  String? _serverUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _server.stopServer();
    super.dispose();
  }

  Future<void> _toggleServer() async {
    setState(() => _isLoading = true);

    try {
      if (_server.isRunning) {
        await _server.stopServer();
        setState(() => _serverUrl = null);
      } else {
        final url = await _server.startServer();
        setState(() => _serverUrl = url);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Sync Server')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_serverUrl != null) ...[
              const Text(
                'Mobile App Sync Active',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Scan this QR code with the Mobile App'),
              const SizedBox(height: 24),

              // QR Code
              QrImageView(
                data: _serverUrl!,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
              ),

              const SizedBox(height: 16),
              SelectableText(
                _serverUrl!,
                style: const TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ] else
              const Text(
                'Server is Offline',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),

            const SizedBox(height: 48),

            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _toggleServer,
                icon: Icon(_server.isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(_server.isRunning ? 'STOP SERVER' : 'START SERVER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _server.isRunning
                      ? Colors.red
                      : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
