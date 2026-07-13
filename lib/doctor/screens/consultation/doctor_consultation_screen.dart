import 'dart:async';

import 'package:flutter/material.dart';

import 'write_prescription_screen.dart';

class DoctorConsultationScreen extends StatefulWidget {
  const DoctorConsultationScreen({
    super.key,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.appointmentId,
    required this.isVideo,
  });

  final String patientName;
  final int patientAge;
  final String patientGender;
  final String appointmentId;
  final bool isVideo;

  @override
  State<DoctorConsultationScreen> createState() =>
      _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  static const _teal = Color(0xFF078D83);
  late final Timer _timer;
  int _elapsedSeconds = 0;
  bool _muted = false;
  bool _cameraEnabled = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _endConsultation() async {
    final end = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End consultation?'),
        content: const Text(
          'The consultation will end and the prescription editor will open.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Continue call'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Consultation'),
          ),
        ],
      ),
    );
    if (end != true || !mounted) return;

    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => WritePrescriptionScreen(
          patientName: widget.patientName,
          patientAge: widget.patientAge,
          patientGender: widget.patientGender,
          appointmentId: widget.appointmentId,
        ),
      ),
    );
    if (sent == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071719),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          widget.isVideo ? 'Video Consultation' : 'Clinic Consultation',
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              const Spacer(),
              CircleAvatar(
                radius: 72,
                backgroundColor: const Color(0xFFDCF4F0),
                child: Text(
                  widget.patientName.characters.first,
                  style: const TextStyle(
                    color: _teal,
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                widget.patientName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _durationLabel(_elapsedSeconds),
                style: const TextStyle(
                  color: Color(0xFFA8C6C4),
                  fontSize: 16,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CallControl(
                    icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: _muted ? 'Unmute' : 'Mute',
                    active: _muted,
                    onTap: () => setState(() => _muted = !_muted),
                  ),
                  if (widget.isVideo) ...[
                    const SizedBox(width: 20),
                    _CallControl(
                      icon: _cameraEnabled
                          ? Icons.videocam_rounded
                          : Icons.videocam_off_rounded,
                      label: 'Camera',
                      active: !_cameraEnabled,
                      onTap: () =>
                          setState(() => _cameraEnabled = !_cameraEnabled),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _endConsultation,
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.call_end_rounded),
                  label: const Text('End Consultation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallControl extends StatelessWidget {
  const _CallControl({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onTap,
          style: IconButton.styleFrom(
            backgroundColor: active ? Colors.white : const Color(0xFF173638),
            foregroundColor: active ? const Color(0xFF071719) : Colors.white,
            minimumSize: const Size(58, 58),
          ),
          icon: Icon(icon),
        ),
        const SizedBox(height: 7),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

String _durationLabel(int seconds) {
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final remaining = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$remaining';
}
