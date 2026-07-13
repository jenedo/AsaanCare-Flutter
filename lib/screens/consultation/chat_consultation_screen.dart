import 'dart:async';

import 'package:flutter/material.dart';

class ChatConsultationScreen extends StatefulWidget {
  const ChatConsultationScreen({
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
  State<ChatConsultationScreen> createState() => _ChatConsultationScreenState();
}

class _ChatConsultationScreenState extends State<ChatConsultationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _doctorTyping = false;
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      _ChatMessage(
        text: 'Hello Doctor, I would like to discuss my symptoms.',
        time: widget.appointmentTime,
        sentByPatient: true,
      ),
      const _ChatMessage(
        text:
            'Hello! I’m here to help. Please describe how you are feeling today.',
        time: 'Now',
        sentByPatient: false,
      ),
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(text: text, time: _currentTime(), sentByPatient: true),
      );
      _doctorTyping = true;
      _messageController.clear();
    });
    _scrollToBottom();
    Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        _doctorTyping = false;
        _messages.add(
          _ChatMessage(
            text:
                'Thank you for sharing that. I’ve noted it. Please tell me when the symptoms started and whether you have taken any medicine.',
            time: _currentTime(),
            sentByPatient: false,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _showAction(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFB),
      appBar: AppBar(
        toolbarHeight: 82,
        backgroundColor: const Color(0xFF087A78),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFE0F2F1),
              backgroundImage: AssetImage(widget.doctorImageAsset),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.doctorSpecialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF3EE27C), size: 9),
                      SizedBox(width: 5),
                      Text('Online', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Secure consultation information',
            onPressed: () => _showAction('Messages are end-to-end encrypted.'),
            icon: const Icon(Icons.security_rounded),
          ),
          IconButton(
            onPressed: () => _showAction('More chat options'),
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _SecurityBanner(
              onInfo: () => _showAction('This chat is private and encrypted.'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F4),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'Consultation Started',
                      style: TextStyle(
                        color: Color(0xFF087A78),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_dateLabel(widget.appointmentDate)} • ${widget.appointmentTime}',
                    style: const TextStyle(
                      color: Color(0xFF839094),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(14, 5, 14, 12),
                itemCount: _messages.length + (_doctorTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _TypingBubble(imageAsset: widget.doctorImageAsset);
                  }
                  return _MessageBubble(
                    message: _messages[index],
                    doctorImageAsset: widget.doctorImageAsset,
                  );
                },
              ),
            ),
            _QuickActions(onAction: _showAction),
            _MessageComposer(
              controller: _messageController,
              onAttach: () => _showAction('Choose a report or image to attach'),
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityBanner extends StatelessWidget {
  const _SecurityBanner({required this.onInfo});
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF1FAF9),
      border: Border.all(color: const Color(0xFFCBE6E3)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(Icons.shield_rounded, color: Color(0xFF087A78), size: 34),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Secure chat consultation',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 3),
              Text(
                'Your messages are end-to-end encrypted',
                style: TextStyle(color: Color(0xFF687A81), fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onInfo,
          icon: const Icon(Icons.info_outline, color: Color(0xFF087A78)),
        ),
      ],
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.doctorImageAsset});
  final _ChatMessage message;
  final String doctorImageAsset;

  @override
  Widget build(BuildContext context) {
    final patient = message.sentByPatient;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: patient
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!patient) ...[
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(doctorImageAsset),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 430),
              padding: const EdgeInsets.fromLTRB(14, 11, 12, 8),
              decoration: BoxDecoration(
                color: patient ? const Color(0xFFE4F5F3) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(patient ? 18 : 4),
                  bottomRight: Radius.circular(patient ? 4 : 18),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      message.text,
                      style: const TextStyle(
                        color: Color(0xFF152A34),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.time,
                        style: const TextStyle(
                          color: Color(0xFF879498),
                          fontSize: 10,
                        ),
                      ),
                      if (patient) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all_rounded,
                          color: Color(0xFF087A78),
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble({required this.imageAsset});
  final String imageAsset;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        CircleAvatar(radius: 18, backgroundImage: AssetImage(imageAsset)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'Doctor is typing…',
            style: TextStyle(color: Color(0xFF718087), fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onAction});
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(12, 5, 12, 8),
    child: Row(
      children: [
        _QuickAction(
          icon: Icons.upload_file_rounded,
          label: 'Upload Report',
          onTap: () => onAction('Choose a report to upload'),
        ),
        _QuickAction(
          icon: Icons.medication_outlined,
          label: 'Prescription',
          onTap: () => onAction('Prescription request sent'),
        ),
        _QuickAction(
          icon: Icons.mic_none_rounded,
          label: 'Voice Note',
          onTap: () => onAction('Hold to record a voice note'),
        ),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 19),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF13535A),
        side: const BorderSide(color: Color(0xFFE2E9EA)),
        backgroundColor: Colors.white,
        minimumSize: const Size(0, 44),
      ),
    ),
  );
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.onAttach,
    required this.onSend,
  });
  final TextEditingController controller;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.fromLTRB(4, 3, 5, 3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE5E6)),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 12)],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onAttach,
            icon: const Icon(
              Icons.attach_file_rounded,
              color: Color(0xFF607B85),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(
                hintText: 'Type your message',
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          ),
          IconButton.filled(
            onPressed: onSend,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF087A78),
            ),
            icon: const Icon(Icons.send_rounded, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.time,
    required this.sentByPatient,
  });
  final String text;
  final String time;
  final bool sentByPatient;
}

String _currentTime() {
  final now = DateTime.now();
  final hour = now.hour == 0
      ? 12
      : now.hour > 12
      ? now.hour - 12
      : now.hour;
  return '$hour:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
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
