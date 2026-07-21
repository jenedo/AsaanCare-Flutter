import 'package:flutter/material.dart';

import '../theme/doctor_tokens.dart';
import '../utils/doctor_time_format.dart';

/// Circular patient/doctor avatar.
///
/// - Picks a deterministic accent color from [DoctorColors.avatarPalette] based
///   on [id] (never random per rebuild).
/// - Falls back to initials if [imageAsset]/[imageUrl] is missing or fails to
///   load, so it can never get stuck showing a broken-image glyph.
class PatientAvatar extends StatelessWidget {
  const PatientAvatar({
    super.key,
    required this.id,
    required this.name,
    this.imageAsset,
    this.imageUrl,
    this.radius = 22,
    this.onTap,
  });

  final String id;
  final String name;
  final String? imageAsset;
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;

  Color get _accent {
    final palette = DoctorColors.avatarPalette;
    final index = id.isEmpty ? 0 : id.hashCode.abs() % palette.length;
    return palette[index];
  }

  @override
  Widget build(BuildContext context) {
    final initials = initialsFor(name);
    final fallback = Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      color: _accent,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.7,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );

    Widget child = fallback;
    final asset = imageAsset;
    final url = imageUrl;
    if (asset != null && asset.isNotEmpty) {
      child = Image.asset(
        asset,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    } else if (url != null && url.isNotEmpty) {
      child = Image.network(
        url,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
        loadingBuilder: (context, widget, progress) {
          if (progress == null) return widget;
          return Container(
            width: radius * 2,
            height: radius * 2,
            alignment: Alignment.center,
            color: _accent.withValues(alpha: 0.25),
            child: SizedBox.square(
              dimension: radius * 0.7,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }

    final avatar = Semantics(
      image: true,
      label: name.isEmpty ? 'Patient avatar' : '$name avatar',
      child: ClipOval(
        child: SizedBox(width: radius * 2, height: radius * 2, child: child),
      ),
    );

    if (onTap == null) return avatar;
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: avatar,
    );
  }
}
