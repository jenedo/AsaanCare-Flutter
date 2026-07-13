import 'dart:async';

import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({
    super.key,
    required this.doctorName,
    required this.doctorImageAsset,
  });

  final String doctorName;
  final String doctorImageAsset;

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _connected = false;
  bool _muted = false;
  bool _cameraOff = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _connected = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds++);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _duration =>
      '${(_seconds ~/ 60).toString().padLeft(2, '0')}:'
      '${(_seconds % 60).toString().padLeft(2, '0')}';

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF123D43),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF315B61), Color(0xFF102F35)],
                ),
              ),
            ),
            Positioned.fill(
              top: 70,
              child: Image.asset(
                widget.doctorImageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.person, color: Colors.white54, size: 180),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x66000000),
                      Colors.transparent,
                      Color(0xB3000000),
                    ],
                    stops: [0, .55, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(widget.doctorImageAsset),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _connected ? _duration : 'Connecting…',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _message('More call options'),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white12,
                    ),
                    icon: const Icon(Icons.more_horiz, color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 118,
              child: Container(
                height: 150,
                width: 112,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF263D41),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white70, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 18),
                  ],
                ),
                child: _cameraOff
                    ? const Icon(Icons.videocam_off, color: Colors.white70)
                    : Image.asset(
                        'assets/images/user_avatar.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 54,
                        ),
                      ),
              ),
            ),
            if (!_connected)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Connecting both participants…',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xE61A262A),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Control(
                      icon: _muted ? Icons.mic_off : Icons.mic,
                      label: _muted ? 'Unmute' : 'Mute',
                      active: _muted,
                      onTap: () => setState(() => _muted = !_muted),
                    ),
                    _Control(
                      icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
                      label: 'Camera',
                      active: _cameraOff,
                      onTap: () => setState(() => _cameraOff = !_cameraOff),
                    ),
                    _Control(
                      icon: Icons.chat_bubble,
                      label: 'Chat',
                      onTap: () => _message('Call chat opened'),
                    ),
                    _Control(
                      icon: Icons.more_horiz,
                      label: 'More',
                      onTap: () => _message('More call options'),
                    ),
                    _Control(
                      icon: Icons.call_end,
                      label: 'End',
                      danger: true,
                      onTap: () => Navigator.of(context).pop(),
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

class _Control extends StatelessWidget {
  const _Control({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: danger
                  ? const Color(0xFFEF4056)
                  : active
                  ? Colors.white
                  : const Color(0xFF344247),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: active && !danger ? Colors.black87 : Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 9)),
        ],
      ),
    );
  }
}
