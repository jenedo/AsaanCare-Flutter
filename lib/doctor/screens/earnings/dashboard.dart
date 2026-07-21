
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const AsaanCareApp());
}

// ═══════════════════════════════════════════════════════════
//  COLORS
// ═══════════════════════════════════════════════════════════
class AppColors {
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color border = Color(0xFFE2E8F0);
  static const Color mutedBg = Color(0xFFF0FDFA);
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color greenLight = Color(0xFFF0FDF4);
}

// ═══════════════════════════════════════════════════════════
//  CUSTOM PAGE TRANSITION
// ═══════════════════════════════════════════════════════════
class EarningsStartupState {
  static const String zeroAmount = 'PKR 0';
  static const String noChange = 'No earnings yet';
  static const List<double> emptyChart = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  static const List<Map<String, dynamic>> transactions = [];
  static const List<Map<String, String>> payouts = [];
}
class AppRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  AppRoute({required this.page})
      : super(
          pageBuilder: (_, _, _) => page,
          transitionsBuilder: (_, animation, _, child) {
            const curve = Curves.easeInOutCubic;
            final slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .chain(CurveTween(curve: curve));
            final fade = Tween<double>(begin: 0, end: 1);
            return FadeTransition(
              opacity: animation.drive(fade),
              child: SlideTransition(
                position: animation.drive(slide),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

// ═══════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════
class AnimatedEntry extends StatelessWidget {
  final Widget child;
  final int delayMs;
  const AnimatedEntry({super.key, required this.child, this.delayMs = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (_, value, c) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final double radius;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  const AppHeader({super.key, required this.title, this.onBack, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: onBack != null
          ? IconButton(
              onPressed: onBack,
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textPrimary),
              ),
            )
          : null,
      title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      actions: actions ?? [const SizedBox(width: 56)],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isSecondary;
  final Color? color;
  const PrimaryButton({super.key, required this.text, required this.onTap, this.isSecondary = false, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSecondary ? AppColors.mutedBg : (color ?? AppColors.primary),
          borderRadius: BorderRadius.circular(12),
          border: isSecondary ? Border.all(color: AppColors.primary, width: 1.5) : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSecondary ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}

class TabBarWidget extends StatefulWidget {
  final List<String> tabs;
  final Function(int) onChanged;
  const TabBarWidget({super.key, required this.tabs, required this.onChanged});

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: List.generate(widget.tabs.length, (i) {
          final isActive = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => selected = i);
                widget.onChanged(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ANIMATED LINE CHART
// ═══════════════════════════════════════════════════════════
class AnimatedLineChart extends StatefulWidget {
  final List<double> data;
  final Color lineColor;
  final bool showDots;
  final bool showGrid;
  final bool showFill;
  const AnimatedLineChart({
    super.key,
    required this.data,
    this.lineColor = Colors.white,
    this.showDots = true,
    this.showGrid = false,
    this.showFill = true,
  });

  @override
  State<AnimatedLineChart> createState() => _AnimatedLineChartState();
}

class _AnimatedLineChartState extends State<AnimatedLineChart> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    Future.delayed(const Duration(milliseconds: 200), () => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(
        size: Size.infinite,
        painter: _LinePainter(widget.data, _ctrl.value, widget.lineColor, widget.showDots, widget.showGrid, widget.showFill),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final Color color;
  final bool showDots;
  final bool showGrid;
  final bool showFill;
  _LinePainter(this.data, this.progress, this.color, this.showDots, this.showGrid, this.showFill);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxV = data.reduce(math.max);
    final minV = data.reduce(math.min);
    final range = (maxV - minV) == 0 ? 1 : maxV - minV;

    if (showGrid) {
      final gridPaint = Paint()
        ..color = AppColors.border
        ..strokeWidth = 1;
      for (int i = 1; i <= 3; i++) {
        final y = size.height * (i / 4);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    List<Offset> pts = [];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minV) / range) * (size.height * 0.75) - size.height * 0.12;
      pts.add(Offset(x, y));
    }

    final path = Path();
    if (pts.isNotEmpty) {
      path.moveTo(pts.first.dx, pts.first.dy);
      for (int i = 1; i < pts.length; i++) {
        final p0 = pts[i - 1];
        final p1 = pts[i];
        final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
        path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
      }
      if (pts.length > 1) path.lineTo(pts.last.dx, pts.last.dy);
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      final extract = m.extractPath(0, m.length * progress);
      canvas.drawPath(extract, linePaint);
    }

    if (showFill && progress > 0.3) {
      final fillPath = Path.from(path);
      fillPath.lineTo(pts.last.dx, size.height);
      fillPath.lineTo(pts.first.dx, size.height);
      fillPath.close();
      final fillPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height),
          [color.withValues(alpha: 0.25 * progress), color.withValues(alpha: 0)],
        );
      canvas.drawPath(fillPath, fillPaint);
    }

    if (showDots && progress > 0.95 && pts.isNotEmpty) {
      for (int i = 0; i < pts.length; i++) {
        final p = pts[i];
        canvas.drawCircle(p, 3, Paint()..color = color.withValues(alpha: 0.6));
      }
      final last = pts.last;
      canvas.drawCircle(last, 5, Paint()..color = Colors.white);
      canvas.drawCircle(last, 5, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════
//  APP ROOT
// ═══════════════════════════════════════════════════════════
class AsaanCareApp extends StatelessWidget {
  const AsaanCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AsaanCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SCREEN 1: DASHBOARD
// ═══════════════════════════════════════════════════════════
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  void _go(Widget page) => Navigator.push(context, AppRoute(page: page));

  final List<double> chartData = EarningsStartupState.emptyChart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Good Morning,', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const Text('Dr. Ali Raza', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(50)),
                    child: const Icon(Icons.notifications_outlined, size: 20, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(50)),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedEntry(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total Earnings', style: TextStyle(fontSize: 13, color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    const Text(EarningsStartupState.zeroAmount, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                                  child: const Text('This Month', style: TextStyle(fontSize: 12, color: Colors.white)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(EarningsStartupState.noChange, style: TextStyle(fontSize: 13, color: Colors.white70)),
                            const SizedBox(height: 12),
                            SizedBox(height: 100, child: AnimatedLineChart(data: chartData)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _actionCard(Icons.bar_chart, 'Earnings\nOverview', () => _go(const EarningsOverviewScreen())),
                        _actionCard(Icons.account_balance_wallet, 'Wallet\nBalance', () => _go(const WalletBalanceScreen())),
                        _actionCard(Icons.receipt_long, 'Transactions\nHistory', () => _go(const TransactionsScreen())),
                        _actionCard(Icons.request_page, 'Payout\nRequest', () => _go(const WithdrawOptionsScreen())),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Quick Stats', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Row(
                        children: [
                          _statColumn('0', 'Consultations'),
                          _statColumn('0', 'Completed'),
                          _statColumn('0', 'Pending'),
                          _statColumn('-', 'Rating'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.home_rounded, 'Home', 0),
                  _navItem(Icons.calendar_today_rounded, 'Appointments', 1),
                  _navItem(Icons.payments_rounded, 'Earnings', 2, onTap: () => _go(const EarningsOverviewScreen())),
                  _navItem(Icons.person_outline, 'Profile', 3, onTap: () => _go(const WalletSettingsScreen())),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedEntry(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(height: 8),
                Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500, height: 1.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, {VoidCallback? onTap}) {
    final isActive = _navIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _navIndex = index);
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: isActive ? AppColors.mutedBg : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? AppColors.primary : AppColors.textTertiary),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: isActive ? AppColors.primary : AppColors.textTertiary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SCREEN 2: EARNINGS OVERVIEW
// ═══════════════════════════════════════════════════════════
class EarningsOverviewScreen extends StatefulWidget {
  const EarningsOverviewScreen({super.key});

  @override
  State<EarningsOverviewScreen> createState() => _EarningsOverviewScreenState();
}

class _EarningsOverviewScreenState extends State<EarningsOverviewScreen> {
  final List<double> monthlyData = EarningsStartupState.emptyChart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: 'Earnings Overview', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBarWidget(tabs: const ['This Month', 'Last Month', 'This Year'], onChanged: (_) {}),
            AnimatedEntry(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Earnings', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    const Text(EarningsStartupState.zeroAmount, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text(EarningsStartupState.noChange, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: AnimatedLineChart(
                        data: monthlyData,
                        lineColor: AppColors.primary,
                        showGrid: true,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('1', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                        Text('8', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                        Text('15', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                        Text('22', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                        Text('30', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Earnings Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _breakdownItem(Icons.chat_bubble_outline, 'Consultation Fees', EarningsStartupState.zeroAmount, '-', AppColors.mutedBg),
            _breakdownItem(Icons.videocam_outlined, 'Video Consultations', EarningsStartupState.zeroAmount, '-', AppColors.blueLight),
            _breakdownItem(Icons.card_giftcard_outlined, 'Other Earnings', EarningsStartupState.zeroAmount, '-', AppColors.warningLight),
          ],
        ),
      ),
    );
  }

  Widget _breakdownItem(IconData icon, String title, String amount, String change, Color bg) {
    return AnimatedEntry(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(amount, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text(change, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SCREEN 3: WALLET BALANCE
// ═══════════════════════════════════════════════════════════
class WalletBalanceScreen extends StatelessWidget {
  const WalletBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: 'Wallet Balance', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedEntry(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Balance', style: TextStyle(fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 4),
                    const Text(EarningsStartupState.zeroAmount, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Balance', style: TextStyle(fontSize: 12, color: Colors.white70)),
                              const SizedBox(height: 2),
                              const Text(EarningsStartupState.zeroAmount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pending Amount', style: TextStyle(fontSize: 12, color: Colors.white70)),
                              const SizedBox(height: 2),
                              const Text(EarningsStartupState.zeroAmount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'Withdraw',
                            onTap: () => Navigator.push(context, AppRoute(page: const WithdrawOptionsScreen())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            text: 'View History',
                            onTap: () => Navigator.push(context, AppRoute(page: const PayoutHistoryScreen())),
                            isSecondary: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Balance Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _breakdownRow(Icons.water_drop_outlined, 'Available for Withdrawal', EarningsStartupState.zeroAmount, AppColors.mutedBg),
            _breakdownRow(Icons.pause_circle_filled_outlined, 'On Hold', EarningsStartupState.zeroAmount, AppColors.warningLight),
            _breakdownRow(Icons.sync, 'Processing', EarningsStartupState.zeroAmount, AppColors.blueLight),
            _breakdownRow(Icons.diamond_outlined, 'Total Earned', EarningsStartupState.zeroAmount, AppColors.greenLight),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Withdrawals are processed within 1-2 business days.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _breakdownRow(IconData icon, String title, String amount, Color bg) {
    return AnimatedEntry(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SCREEN 4: TRANSACTIONS HISTORY
// ═══════════════════════════════════════════════════════════
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String activeTab = 'All';

  final List<Map<String, dynamic>> transactions = EarningsStartupState.transactions;

  @override
  Widget build(BuildContext context) {
    final filtered = activeTab == 'All'
        ? transactions
        : transactions.where((t) {
            if (activeTab == 'Earnings') return t['isPositive'] == true;
            if (activeTab == 'Payouts') return t['title'].toString().contains('Payout');
            if (activeTab == 'Adjustments') return t['title'].toString().contains('Adjustment');
            return true;
          }).toList();

    final groups = <String, List<Map<String, dynamic>>>{};
    for (final t in filtered) {
      groups.putIfAbsent(t['group'] as String, () => []).add(t);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: 'Transactions', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBarWidget(
              tabs: const ['All', 'Earnings', 'Payouts', 'Adjustments'],
              onChanged: (i) => setState(() => activeTab = ['All', 'Earnings', 'Payouts', 'Adjustments'][i]),
            ),
            if (groups.isEmpty)
              const AppCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('No transactions yet', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              ),
            ...groups.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ),
                  AppCard(
                    child: Column(
                      children: entry.value.asMap().entries.map((e) {
                        final t = e.value;
                        final isPos = t['isPositive'] as bool;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: t['bg'] as Color,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      t['icon'] as IconData,
                                      color: (t['iconColor'] as Color?) ?? AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t['title'] as String,
                                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          t['subtitle'] as String,
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    t['amount'] as String,
                                    style: TextStyle(
                                      color: isPos ? AppColors.primary : AppColors.danger,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (e.key < entry.value.length - 1)
                              const Divider(height: 1, color: AppColors.border),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),
            const SizedBox(height: 8),
            if (filtered.isNotEmpty) PrimaryButton(text: 'Load More', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SCREEN 5: WITHDRAW OPTIONS
// ═══════════════════════════════════════════════════════════
class WithdrawOptionsScreen extends StatefulWidget {
  const WithdrawOptionsScreen({super.key});

  @override
  State<WithdrawOptionsScreen> createState() => _WithdrawOptionsScreenState();
}

class _WithdrawOptionsScreenState extends State<WithdrawOptionsScreen> {
  int selected = 0;
  final methods = [
    {'title': 'Bank Transfer', 'subtitle': 'Direct transfer to your bank account', 'icon': Icons.account_balance},
    {'title': 'JazzCash', 'subtitle': 'Withdraw to your JazzCash account', 'icon': Icons.phone_android},
    {'title': 'EasyPaisa', 'subtitle': 'Withdraw to your EasyPaisa account', 'icon': Icons.credit_card},
    {'title': 'Raast', 'subtitle': 'Instant transfer via Raast', 'icon': Icons.flash_on},
    {'title': 'IBAN Transfer', 'subtitle': 'International bank transfer', 'icon': Icons.public},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: 'Withdraw', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Choose a withdrawal method',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ...methods.asMap().entries.map((e) {
              final isSel = e.key == selected;
              return GestureDetector(
                onTap: () => setState(() => selected = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.mutedBg : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSel ? AppColors.primary : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: isSel
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.value['title'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              e.value['subtitle'] as String,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(e.value['icon'] as IconData, color: AppColors.primary, size: 24),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Minimum withdrawal amount is PKR 2,000. Withdrawals are processed within 1-2 business days.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Continue',
              onTap: () => Navigator.push(context, AppRoute(page: const BankDetailsScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SCREEN 6: BANK DETAILS
// ═══════════════════════════════════════════════════════════
class BankDetailsScreen extends StatelessWidget {
  const BankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: 'Bank Details', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: AppColors.mutedBg, borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.account_balance, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 12),
            const Text('Add Bank Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Enter your bank details to receive payments', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                children: [
                  _field('Account Holder Name', 'Dr. Ali Raza'),
                  _field('Bank Name', 'Meezan Bank'),
                  _field('Account Number', '1234 5678 9012 3456'),
                  _field('IBAN (Optional)', 'PK18 MEZN 0012 3456 7890 1234'),
                  _field('Branch Code (Optional)', '1234'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Save Bank Details',
              onTap: () => Navigator.push(context, AppRoute(page: const WithdrawAmountScreen())),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 14, color: AppColors.textTertiary),
                SizedBox(width: 6),
                Text('Your bank details are 100% secure', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SCREEN 7: WITHDRAW AMOUNT
// ═══════════════════════════════════════════════════════════
class WithdrawAmountScreen extends StatefulWidget {
  const WithdrawAmountScreen({super.key});

  @override
  State<WithdrawAmountScreen> createState() => _WithdrawAmountScreenState();
}

class _WithdrawAmountScreenState extends State<WithdrawAmountScreen> {
  int selectedAmount = 0;
  final amounts = [0, 2000, 5000, 10000];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: 'Withdraw Amount', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Balance', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 4),
                  const Text(EarningsStartupState.zeroAmount, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Enter Amount', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PKR', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  TextField(
                    controller: TextEditingController(text: '0'),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: amounts.map((a) {
                final isSel = selectedAmount == a;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedAmount = a),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSel ? AppColors.primary : AppColors.border, width: 1.5),
                      ),
                      child: Text(
                        a.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSel ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Withdrawal Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  _summaryRow('Available Balance', EarningsStartupState.zeroAmount),
                  _summaryRow('Withdrawal Amount', EarningsStartupState.zeroAmount),
                  _summaryRow('Processing Fee', 'PKR 0'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('You Will Receive', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text(EarningsStartupState.zeroAmount, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Continue',
              onTap: () => Navigator.push(context, AppRoute(page: const ReviewWithdrawalScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SCREEN 8: REVIEW & CONFIRM
// ═══════════════════════════════════════════════════════════
class ReviewWithdrawalScreen extends StatelessWidget {
  const ReviewWithdrawalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: 'Review Withdrawal', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Withdrawal Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  _detailRow('Amount', EarningsStartupState.zeroAmount),
                  _detailRow('Processing Fee', 'PKR 0'),
                  _detailRow('You Will Receive', EarningsStartupState.zeroAmount, isHighlight: true),
                  _detailRow('Method', 'Bank Transfer'),
                  _detailRow('Bank Account', 'Meezan Bank •••• 3456'),
                  _detailRow('Estimated Time', '1-2 Business Days'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFF92400E)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please review your details carefully before confirming the withdrawal.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Confirm Withdrawal',
              onTap: () => Navigator.push(context, AppRoute(page: const WithdrawalSuccessScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SCREEN 9: WITHDRAWAL SUCCESS
// ═══════════════════════════════════════════════════════════
class WithdrawalSuccessScreen extends StatefulWidget {
  const WithdrawalSuccessScreen({super.key});

  @override
  State<WithdrawalSuccessScreen> createState() => _WithdrawalSuccessScreenState();
}

class _WithdrawalSuccessScreenState extends State<WithdrawalSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    Future.delayed(const Duration(milliseconds: 200), () => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              ScaleTransition(
                scale: CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(50)),
                  child: const Icon(Icons.check, color: AppColors.success, size: 48),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Withdrawal Request Submitted!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Your withdrawal request has been submitted successfully.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Request Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    _detailRow('Amount', EarningsStartupState.zeroAmount),
                    _detailRow('Method', 'Bank Transfer'),
                    _detailRow('Reference ID', 'Not generated', isMono: true),
                    _detailRow('Date', 'Not submitted'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'View History',
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  AppRoute(page: const PayoutHistoryScreen()),
                  (route) => route.isFirst,
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                text: 'Back to Earnings',
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  AppRoute(page: const DashboardScreen()),
                  (route) => route.isFirst,
                ),
                isSecondary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isMono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: isMono ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SCREEN 10: PAYOUT HISTORY
// ═══════════════════════════════════════════════════════════
class PayoutHistoryScreen extends StatefulWidget {
  const PayoutHistoryScreen({super.key});

  @override
  State<PayoutHistoryScreen> createState() => _PayoutHistoryScreenState();
}

class _PayoutHistoryScreenState extends State<PayoutHistoryScreen> {
  String activeTab = 'All';
  final List<Map<String, String>> payouts = EarningsStartupState.payouts;

  @override
  Widget build(BuildContext context) {
    final filtered = activeTab == 'All'
        ? payouts
        : payouts.where((p) => p['status'] == activeTab.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: 'Payout History', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TabBarWidget(
              tabs: const ['All', 'Completed', 'Processing', 'Failed'],
              onChanged: (i) => setState(() => activeTab = ['All', 'Completed', 'Processing', 'Failed'][i]),
            ),
            if (filtered.isEmpty)
              const AppCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('No payout history yet', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              ),
            ...filtered.asMap().entries.map((e) {
              final p = e.value;
              Color badgeColor = AppColors.successLight;
              Color badgeText = const Color(0xFF166534);
              if (p['status'] == 'processing') {
                badgeColor = AppColors.warningLight;
                badgeText = const Color(0xFF92400E);
              } else if (p['status'] == 'failed') {
                badgeColor = AppColors.dangerLight;
                badgeText = const Color(0xFF991B1B);
              }
              return AnimatedEntry(
                delayMs: e.key * 80,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p['amount'] as String, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(p['method'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text(p['reference'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontFamily: 'monospace')),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(p['date'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                (p['status'] as String)[0].toUpperCase() + (p['status'] as String).substring(1),
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: badgeText),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            if (filtered.isNotEmpty) PrimaryButton(text: 'Load More', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SCREEN 11: WALLET SETTINGS
// ═══════════════════════════════════════════════════════════
class WalletSettingsScreen extends StatefulWidget {
  const WalletSettingsScreen({super.key});

  @override
  State<WalletSettingsScreen> createState() => _WalletSettingsScreenState();
}

class _WalletSettingsScreenState extends State<WalletSettingsScreen> {
  bool notificationsOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: 'Wallet Settings', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  _settingItem(Icons.account_balance, 'Bank Accounts', 'Manage your bank accounts', AppColors.mutedBg, () => Navigator.push(context, AppRoute(page: const BankDetailsScreen()))),
                  _settingItem(Icons.credit_card, 'Payout Methods', 'Manage withdrawal methods', AppColors.blueLight, () {}),
                  _settingItem(Icons.settings, 'Payout Preferences', 'Set your payout preferences', AppColors.warningLight, () {}),
                  _settingItem(Icons.description, 'Tax Information', 'Manage tax details', AppColors.greenLight, () {}),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  _settingItem(Icons.notifications, 'Notification Settings', 'Payout & transaction alerts', AppColors.dangerLight, () {}, trailing: _toggle()),
                  _settingItem(Icons.help_outline, 'Help & Support', 'Get help with payments', AppColors.blueLight, () => Navigator.push(context, AppRoute(page: const HelpSupportScreen()))),
                  _settingItem(Icons.article_outlined, 'Terms & Conditions', 'Wallet terms and conditions', const Color(0xFFF8FAFC), () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingItem(IconData icon, String title, String subtitle, Color bg, VoidCallback onTap, {Widget? trailing}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _toggle() {
    return GestureDetector(
      onTap: () => setState(() => notificationsOn = !notificationsOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: notificationsOn ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: notificationsOn ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SCREEN 12: HELP & SUPPORT
// ═══════════════════════════════════════════════════════════
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      'How withdrawals work',
      'Payout processing time',
      'Minimum withdrawal amount',
      'Transaction fees',
      'Supported banks & wallets',
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: 'Help & Support', onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('How can we help you?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Find answers to common questions', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.search, size: 18, color: Colors.white70),
                        SizedBox(width: 8),
                        Text('Search help articles...', style: TextStyle(fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Quick Help', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: items.asMap().entries.map((e) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                          ],
                        ),
                      ),
                      if (e.key < items.length - 1) const Divider(height: 1, color: AppColors.border),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              color: AppColors.mutedBg,
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.support_agent, size: 24, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Still need help?', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            SizedBox(height: 2),
                            Text('Our support team is here for you.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(text: 'Contact Support', onTap: () {}, isSecondary: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
