import 'package:flutter/material.dart';

import '../core/config.dart';
import '../pages/video_feed_page.dart';
import '../repositories/sync_repository.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final SyncRepository _repository = SyncRepository();

  ConnectionSnapshot? _snapshot;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final snapshot = await _repository.checkConnection();
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _snapshot = null;
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _openKalo() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const VideoFeedPage()),
    );
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final connected = snapshot != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo/logo.png',
                    width: 92,
                    height: 92,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.play_circle_fill_rounded,
                      size: 82,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Kalo Connect',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConfig.serverBaseUrl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 26),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isLoading
                        ? const _LoadingCard(key: ValueKey('loading'))
                        : connected
                            ? _SuccessCard(
                                key: const ValueKey('success'),
                                snapshot: snapshot,
                              )
                            : _ErrorCard(
                                key: const ValueKey('error'),
                                message: _error ?? 'Không rõ nguyên nhân.',
                              ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _checkServer,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('KIỂM TRA LẠI'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openKalo,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        connected ? 'VÀO KALO' : 'VÀO KALO OFFLINE',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StatusCard(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang kiểm tra /status và /manifest...'),
        ],
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({super.key, required this.snapshot});

  final ConnectionSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final status = snapshot.status;
    final manifest = snapshot.manifest;
    final countsMatch = status.videoCount == manifest.videoCount;

    return _StatusCard(
      borderColor: status.isReady ? Colors.green : Colors.orange,
      child: Column(
        children: [
          Icon(
            status.isReady
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
            color: status.isReady ? Colors.greenAccent : Colors.orangeAccent,
            size: 48,
          ),
          const SizedBox(height: 10),
          Text(
            status.isReady ? 'SERVER ONLINE' : 'SERVER ĐÃ KẾT NỐI',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          _InfoRow(label: 'Server', value: status.serverName),
          _InfoRow(label: 'Phiên bản', value: status.serverVersion),
          _InfoRow(
            label: 'Library',
            value: '${status.libraryVersion ?? manifest.libraryVersion ?? '?'}',
          ),
          _InfoRow(label: 'Số video', value: '${manifest.videoCount}'),
          _InfoRow(label: 'Manifest schema', value: '${manifest.schemaVersion}'),
          _InfoRow(
            label: 'Đối chiếu dữ liệu',
            value: countsMatch ? 'Khớp' : 'Chưa khớp',
          ),
          if (status.libraryError != null) ...[
            const SizedBox(height: 12),
            Text(
              status.libraryError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.orangeAccent),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      borderColor: Colors.red,
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 48),
          const SizedBox(height: 10),
          const Text(
            'CHƯA KẾT NỐI ĐƯỢC',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    super.key,
    required this.child,
    this.borderColor = Colors.white24,
  });

  final Widget child;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white60)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
