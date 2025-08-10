import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_page.dart';
import 'settings_provider.dart';
import 'widgets.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage>
    with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _formattedTime = '00:00:00';
  bool _isRunning = false;
  final List<Map<String, String>> _laps = [];
  int _currentCycleIndex = 0;

  Duration _lastLapTime = Duration.zero;
  String _splitTime = '00:00:00';
  double _currentProgress = 0.0;
  bool _isResetting = false;

  late final AnimationController _gradientController;

  final ScrollController _scrollController = ScrollController();
  bool _showUpArrow = false;
  bool _showDownArrow = false;

  List<Color> _energyColors = [];

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _scrollController.addListener(_scrollListener);
  }

  bool _isInitialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _randomizeColors();
      _isInitialized = true;
    }
  }

  void _randomizeColors() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorList = isDarkMode
        ? settings.darkEnergyColors
        : settings.lightEnergyColors;
    _energyColors = List.from(colorList)..shuffle();
  }

  void _selectNextRandomColor(int currentMinute) {
    setState(() {
      _currentCycleIndex = currentMinute;
    });
  }

  void _scrollListener() {
    if (!mounted) return;
    bool canScrollUp =
        _scrollController.position.pixels >
        _scrollController.position.minScrollExtent;
    bool canScrollDown =
        _scrollController.position.pixels <
        _scrollController.position.maxScrollExtent;
    if (canScrollUp != _showUpArrow || canScrollDown != _showDownArrow) {
      setState(() {
        _showUpArrow = canScrollUp;
        _showDownArrow = canScrollDown;
      });
    }
  }

  void _updateScrollIndicator() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      bool isScrollable =
          _scrollController.position.maxScrollExtent >
          _scrollController.position.minScrollExtent;
      setState(() {
        _showDownArrow =
            isScrollable &&
            _scrollController.position.pixels <
                _scrollController.position.maxScrollExtent;
        if (_scrollController.position.pixels <=
            _scrollController.position.minScrollExtent) {
          _showUpArrow = false;
        }
      });
    });
  }

  void _handleStartStop() {
    if (!mounted) return;
    setState(() {
      if (_isRunning) {
        _stopwatch.stop();
        _timer?.cancel();
      } else {
        _stopwatch.start();
        _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
          if (!mounted) return;
          setState(() {
            _updateTime();
          });
        });
      }
      _isRunning = !_isRunning;
    });
  }

  String _formatDuration(Duration d) {
    return '${d.inMinutes.toString().padLeft(2, '0')}:'
        '${(d.inSeconds % 60).toString().padLeft(2, '0')}:'
        '${((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0')}';
  }

  void _updateTime() {
    final elapsed = _stopwatch.elapsed;
    if (elapsed.inMinutes != _currentCycleIndex) {
      _selectNextRandomColor(elapsed.inMinutes);
    }
    _formattedTime = _formatDuration(elapsed);
    _splitTime = _formatDuration(elapsed - _lastLapTime);
    _currentProgress = (_stopwatch.elapsedMilliseconds % 60000) / 60000;
  }

  void _addLap() {
    if (_isRunning) {
      final currentLapTime = _stopwatch.elapsed;
      final split = currentLapTime - _lastLapTime;
      _laps.insert(0, {
        "lap": _formatDuration(currentLapTime),
        "split": _formatDuration(split),
      });
      _lastLapTime = currentLapTime;
      _listKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 500),
      );
      _updateScrollIndicator();
    }
  }

  void _reset() {
    if (!mounted) return;
    if (_isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
    }
    setState(() {
      _isRunning = false;
      _isResetting = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gradientController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    if (_energyColors.isEmpty) _randomizeColors();

    final currentEnergyColor = settings.useDynamicColors
        ? _energyColors[_currentCycleIndex % _energyColors.length]
        : (isDarkMode
              ? settings.darkEnergyColors[settings.staticColorIndex]
              : settings.lightEnergyColors[settings.staticColorIndex]);

    final restingColor = colorScheme.surface;
    final runningColor = currentEnergyColor;

    final alignmentTween = AlignmentTween(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
    final rotationTween = Tween<double>(begin: -math.pi / 2, end: math.pi / 2);
    final animation = CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _gradientController,
            builder: (context, child) {
              return AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _isRunning ? runningColor.withOpacity(0.4) : restingColor,
                      theme.scaffoldBackgroundColor,
                    ],
                    begin: alignmentTween.evaluate(animation),
                    end: alignmentTween.transform(-1.0 * animation.value),
                    transform: GradientRotation(
                      rotationTween.evaluate(animation),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_isRunning && settings.showParticles)
            MovingParticles(baseColor: currentEnergyColor),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 320,
                          minHeight: 152,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: 2.1,
                                // ## FIX: This is the new, robust animation logic ##
                                child: TweenAnimationBuilder<double>(
                                  key: ValueKey(_isResetting),
                                  tween: Tween(
                                    begin: _currentProgress,
                                    end: _isResetting ? 0.0 : _currentProgress,
                                  ),
                                  duration: _isResetting
                                      ? const Duration(milliseconds: 500)
                                      : Duration.zero,
                                  curve: Curves.easeOut,
                                  builder: (context, progress, child) {
                                    return CustomPaint(
                                      painter: RelyRoundPainter(
                                        progress: progress,
                                        color: currentEnergyColor,
                                        backgroundColor: colorScheme
                                            .surfaceVariant
                                            .withOpacity(0.3),
                                      ),
                                    );
                                  },
                                  onEnd: () {
                                    // This block now ONLY runs after the reset animation is complete
                                    if (_isResetting) {
                                      setState(() {
                                        _stopwatch.reset();
                                        _formattedTime = '00:00:00';
                                        _splitTime = '00:00:00';
                                        _lastLapTime = Duration.zero;
                                        _currentCycleIndex = 0;
                                        _currentProgress = 0.0;
                                        _randomizeColors();
                                        _isResetting = false;

                                        final lapCount = _laps.length;
                                        if (lapCount > 0) {
                                          _laps.clear();
                                          for (var i = 0; i < lapCount; i++) {
                                            _listKey.currentState?.removeItem(
                                              0,
                                              (context, animation) =>
                                                  const SizedBox.shrink(),
                                              duration: Duration.zero,
                                            );
                                          }
                                          _updateScrollIndicator();
                                        }
                                      });
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            color: _isRunning
                                                ? currentEnergyColor
                                                : colorScheme.onSurface,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: _formattedTime.substring(
                                                0,
                                                _formattedTime.length - 3,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 80,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -2,
                                              ),
                                            ),
                                            TextSpan(
                                              text: _formattedTime.substring(
                                                _formattedTime.length - 3,
                                              ),
                                              style: TextStyle(
                                                fontSize: 40,
                                                color:
                                                    (_isRunning
                                                            ? currentEnergyColor
                                                            : colorScheme
                                                                  .onSurface)
                                                        .withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (_laps.isNotEmpty || _isRunning)
                                      Text(
                                        _splitTime,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontFamily: 'monospace',
                                          color: _isRunning
                                              ? currentEnergyColor.withOpacity(
                                                  0.8,
                                                )
                                              : colorScheme.onSurface
                                                    .withOpacity(0.6),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Stack(
                      children: [
                        AnimatedList(
                          controller: _scrollController,
                          key: _listKey,
                          initialItemCount: _laps.length,
                          itemBuilder: (context, index, animation) {
                            return SizeTransition(
                              sizeFactor: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ),
                              child: FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOut,
                                ),
                                child: _buildLapItem(
                                  index,
                                  colorScheme,
                                  currentEnergyColor,
                                ),
                              ),
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: AnimatedOpacity(
                            opacity: _showUpArrow ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: ScrollIndicator(
                              icon: Icons.keyboard_arrow_up,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedOpacity(
                            opacity: _showDownArrow ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: ScrollIndicator(
                              icon: Icons.keyboard_arrow_down,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildControls(colorScheme, currentEnergyColor),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 0,
            child: SafeArea(
              child: IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                  setState(() {
                    _randomizeColors();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLapItem(int index, ColorScheme colorScheme, Color energyColor) {
    final isDarkMode = colorScheme.brightness == Brightness.dark;
    final lapData = _laps.length > index ? _laps[index] : null;
    if (lapData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      height: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : colorScheme.surfaceVariant.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDarkMode ? Colors.white : colorScheme.surfaceVariant)
                    .withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Lap ${_laps.length - index}',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "+${lapData['split']!}",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'monospace',
                    color: energyColor.withOpacity(0.9),
                  ),
                ),
                const Spacer(),
                Text(
                  lapData['lap']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'monospace',
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(ColorScheme colorScheme, Color energyColor) {
    // ## FIX: Corrected button logic ##
    // The `isPaused` check now includes the `_isResetting` flag.
    final bool isPaused =
        !_isRunning && _stopwatch.elapsedMilliseconds > 0 && !_isResetting;
    final String startButtonLabel = isPaused ? 'Resume' : 'Start';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Reset',
            onPressed: isPaused ? _reset : null,
            colorScheme: colorScheme,
          ),
          _buildControlButton(
            icon: _isRunning ? Icons.stop : Icons.play_arrow,
            label: _isRunning ? 'Stop' : startButtonLabel,
            onPressed: _handleStartStop,
            isPrimary: true,
            colorScheme: colorScheme,
            energyColor: energyColor,
          ),
          _buildControlButton(
            icon: Icons.flag,
            label: 'Lap',
            onPressed: _isRunning ? _addLap : null,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isPrimary = false,
    required ColorScheme colorScheme,
    Color? energyColor,
  }) {
    final activeColor = isPrimary
        ? (energyColor ?? colorScheme.primary)
        : colorScheme.surfaceVariant;
    final iconColor = isPrimary
        ? (colorScheme.brightness == Brightness.dark
              ? Colors.black
              : Colors.white)
        : colorScheme.onSurface;
    final isDarkMode = colorScheme.brightness == Brightness.dark;

    return Column(
      children: [
        ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: CircleAvatar(
              radius: isPrimary ? 38 : 30,
              backgroundColor: onPressed == null
                  ? colorScheme.surfaceVariant.withOpacity(0.3)
                  : (isDarkMode
                        ? activeColor.withOpacity(0.8)
                        : activeColor.withOpacity(0.7)),
              child: IconButton(
                icon: Icon(icon),
                iconSize: isPrimary ? 36 : 24,
                color: onPressed == null
                    ? colorScheme.onSurface.withOpacity(0.3)
                    : iconColor,
                onPressed: onPressed,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: onPressed == null
                ? colorScheme.onSurface.withOpacity(0.3)
                : colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
