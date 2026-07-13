import 'dart:async';

import 'package:flutter/material.dart';

import 'video_call_screen.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({
    super.key,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImageAsset,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  final String doctorName;
  final String doctorSpecialty;
  final String doctorImageAsset;
  final DateTime appointmentDate;
  final String appointmentTime;

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _connected = false;
  bool _muted = false;
  bool _speaker = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 850), () {
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

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FCFC),
      appBar: AppBar(
        toolbarHeight: 76,
        backgroundColor: const Color(0xFF087A78),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Audio Consultation',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 34, 22, 20),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 152,
                          width: 152,
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE7F2F1)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14007168),
                                blurRadius: 25,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              widget.doctorImageAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.person,
                                color: Color(0xFF00796B),
                                size: 70,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: 9,
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF087A78),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.graphic_eq_rounded,
                              color: Colors.white,
                              size: 29,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.doctorName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF102A36),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.doctorSpecialty,
                      style: const TextStyle(
                        color: Color(0xFF647780),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _connected
                            ? const Color(0xFFE5F8EB)
                            : const Color(0xFFFFF4DE),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              color: _connected
                                  ? const Color(0xFF25B862)
                                  : const Color(0xFFF0A229),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _connected ? 'Connected' : 'Connecting…',
                            style: TextStyle(
                              color: _connected
                                  ? const Color(0xFF159149)
                                  : const Color(0xFFAD741D),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 19),
                    Text(
                      _duration,
                      style: const TextStyle(
                        color: Color(0xFF087A78),
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _Waveform(active: _connected && !_muted),
                    const SizedBox(height: 25),
                    _AppointmentInfo(
                      date: widget.appointmentDate,
                      time: widget.appointmentTime,
                    ),
                    const SizedBox(height: 19),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.security_rounded,
                          color: Color(0xFF087A78),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Secure audio consultation in progress',
                          style: TextStyle(
                            color: Color(0xFF344D58),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (context) => VideoCallScreen(
                            doctorName: widget.doctorName,
                            doctorImageAsset: widget.doctorImageAsset,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.videocam_outlined),
                      label: const Text('Switch to Video'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF087A78),
                        side: const BorderSide(color: Color(0xFF087A78)),
                        minimumSize: const Size(240, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _AudioControls(
              muted: _muted,
              speaker: _speaker,
              onMute: () => setState(() => _muted = !_muted),
              onSpeaker: () => setState(() => _speaker = !_speaker),
              onNotes: () => _message('Consultation notes opened'),
              onEnd: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    const heights = [
      8,
      12,
      20,
      31,
      43,
      28,
      18,
      24,
      38,
      22,
      34,
      56,
      72,
      48,
      29,
      42,
      59,
      37,
      25,
      34,
      49,
      61,
      47,
      32,
      25,
      18,
      13,
      9,
    ];
    return SizedBox(
      height: 82,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: heights.map((height) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 4,
            height: active ? height.toDouble() : 5,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: const Color(
                0xFF43B9B0,
              ).withValues(alpha: active ? .8 : .25),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AppointmentInfo extends StatelessWidget {
  const _AppointmentInfo({required this.date, required this.time});
  final DateTime date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const _InfoIcon(icon: Icons.calendar_month_outlined),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateLabel(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _weekday(date.weekday),
                  style: const TextStyle(
                    color: Color(0xFF718087),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 48, color: const Color(0xFFDCE5E5)),
          const SizedBox(width: 14),
          const _InfoIcon(icon: Icons.access_time_rounded),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '30 min',
                style: TextStyle(color: Color(0xFF718087), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoIcon extends StatelessWidget {
  const _InfoIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    height: 45,
    width: 45,
    decoration: BoxDecoration(
      color: const Color(0xFFE8F6F4),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Icon(icon, color: const Color(0xFF087A78)),
  );
}

class _AudioControls extends StatelessWidget {
  const _AudioControls({
    required this.muted,
    required this.speaker,
    required this.onMute,
    required this.onSpeaker,
    required this.onNotes,
    required this.onEnd,
  });

  final bool muted;
  final bool speaker;
  final VoidCallback onMute;
  final VoidCallback onSpeaker;
  final VoidCallback onNotes;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _AudioControl(
            icon: muted ? Icons.mic_off : Icons.mic,
            label: muted ? 'Unmute' : 'Mute',
            active: muted,
            onTap: onMute,
          ),
          _AudioControl(
            icon: speaker ? Icons.volume_up : Icons.volume_off,
            label: 'Speaker',
            active: speaker,
            onTap: onSpeaker,
          ),
          _AudioControl(
            icon: Icons.description_outlined,
            label: 'Notes',
            onTap: onNotes,
          ),
          Container(width: 1, height: 55, color: const Color(0xFFE0E6E7)),
          _AudioControl(
            icon: Icons.call_end_rounded,
            label: 'End Call',
            danger: true,
            onTap: onEnd,
          ),
        ],
      ),
    );
  }
}

class _AudioControl extends StatelessWidget {
  const _AudioControl({
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
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: danger
                ? const Color(0xFFF04444)
                : active
                ? const Color(0xFFE0F2F1)
                : const Color(0xFFF7F9F9),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Color(0x10000000), blurRadius: 8),
            ],
          ),
          child: Icon(
            icon,
            color: danger ? Colors.white : const Color(0xFF124D53),
            size: 23,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: danger ? const Color(0xFFE52F2F) : const Color(0xFF344D58),
            fontSize: 10.5,
          ),
        ),
      ],
    ),
  );
}

String _dateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _weekday(int weekday) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return days[weekday - 1];
}
