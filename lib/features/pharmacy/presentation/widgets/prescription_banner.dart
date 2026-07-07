import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class PrescriptionBanner extends StatelessWidget {
  const PrescriptionBanner({
    super.key,
    required this.onUploadTap,
    this.assetPath = 'assets/images/medicine_records.png',
  });

  final VoidCallback onUploadTap;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Semantics(
      container: true,
      button: true,
      label: 'Upload prescription banner',
      child: Material(
        color: const Color(0xFFE6F7F5),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onUploadTap,
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 172,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;
                final imageHeight = isCompact ? 126.0 : 148.0;
                final textMaxWidth = isCompact ? 190.0 : 235.0;

                return Stack(
                  children: [
                    Positioned(
                      right: isCompact ? -38 : -14,
                      bottom: -4,
                      child: ExcludeSemantics(
                        child: Image.asset(
                          assetPath,
                          height: imageHeight,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 16, 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: textMaxWidth),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload Prescription',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textScaler: textScaler.clamp(
                                    minScaleFactor: 1,
                                    maxScaleFactor: 1.06,
                                  ),
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "We'll deliver your medicines\nat your door.",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textScaler: textScaler.clamp(
                                    minScaleFactor: 1,
                                    maxScaleFactor: 1.04,
                                  ),
                                  style: const TextStyle(
                                    color: AppTheme.primaryDark,
                                    fontSize: 14.5,
                                    height: 1.28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _UploadButton(onTap: onUploadTap),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Upload prescription now',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        child: Ink(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryLight, AppTheme.primary],
            ),
            borderRadius: BorderRadius.circular(99),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(99),
            child: const Center(
              child: Text(
                'Upload Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
