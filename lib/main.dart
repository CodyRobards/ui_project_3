import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  ThemeData _buildTheme({required bool dark}) {
    final seedColor = dark ? const Color(0xFF76E4F7) : const Color(0xFF006494);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: dark ? Brightness.dark : Brightness.light,
    );

    final textTheme =
        ThemeData(brightness: dark ? Brightness.dark : Brightness.light)
            .textTheme
            .apply(
              fontFamily: 'RobotoMono',
              displayColor: colorScheme.onSurface,
              bodyColor: colorScheme.onSurface,
            );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF0A111F) : const Color(0xFFE9F0FA),
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary.withOpacity(dark ? 0.6 : 0.85),
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snazzy Calculator',
      theme: _buildTheme(dark: false),
      darkTheme: _buildTheme(dark: true),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: CalculatorPage(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final CalculatorController _controller = CalculatorController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradientColors = widget.isDarkMode
        ? const [Color(0xFF050912), Color(0xFF17213B)]
        : const [Color(0xFFDDE6F5), Color(0xFFF4F7FD)];
    final bool isDark = widget.isDarkMode;
    final Color shellColor =
        isDark ? const Color(0xFF111B2E) : const Color(0xFFF8FAFF);
    final Color deepShadow =
        isDark ? Colors.black.withOpacity(0.55) : const Color(0xFFB5C2D6);
    final Color highlightShadow =
        isDark ? const Color(0xFF1F2B40) : Colors.white;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 360,
              height: 620,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: shellColor,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: deepShadow,
                    offset: const Offset(24, 24),
                    blurRadius: 46,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: highlightShadow,
                    offset: const Offset(-20, -20),
                    blurRadius: 42,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_outlined, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Snazzy Calculator',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 8),
                      Switch(
                        value: widget.isDarkMode,
                        onChanged: (_) => widget.onToggleTheme(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _DisplayPanel(
                    history: _controller.history,
                    value: _controller.display,
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      clipBehavior: Clip.antiAlias,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: shellColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: _ButtonsGrid(
                            onButtonTap: _handleButtonPress,
                          ),
                        ),
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

  void _handleButtonPress(String label) {
    setState(() {
      switch (label) {
        case 'C':
          _controller.clear();
          break;
        case 'DEL':
          _controller.delete();
          break;
        case '.':
          _controller.inputDecimal();
          break;
        case '+':
        case '−':
        case '×':
        case '÷':
          _controller.inputOperation(label);
          break;
        case '=':
          _controller.evaluate();
          break;
        case 'Mode':
          widget.onToggleTheme();
          break;
        default:
          _controller.inputDigit(label);
      }
    });
  }
}

class _DisplayPanel extends StatelessWidget {
  const _DisplayPanel({
    required this.history,
    required this.value,
  });

  final String history;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color panelColor =
        isDark ? const Color(0xFF0E1728) : theme.colorScheme.surface;
    final Color shadowDark =
        isDark ? Colors.black.withOpacity(0.5) : const Color(0xFFCCD5E0);
    final Color shadowLight =
        isDark ? const Color(0xFF1E2B42) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: panelColor,
        boxShadow: [
          BoxShadow(
            color: shadowDark,
            blurRadius: 20,
            offset: const Offset(10, 10),
          ),
          BoxShadow(
            color: shadowLight,
            blurRadius: 20,
            offset: const Offset(-10, -10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            history,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonsGrid extends StatelessWidget {
  const _ButtonsGrid({
    required this.onButtonTap,
  });

  final ValueChanged<String> onButtonTap;

  static const List<List<String>> _layout = [
    ['C', 'DEL', 'Mode', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['0', '.', '=', ''],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: _layout.map((row) {
        return Expanded(
          child: Row(
            children: row.map((label) {
              if (label.isEmpty) {
                return const Expanded(child: SizedBox.shrink());
              }

              final bool isOperation =
                  ['÷', '×', '−', '+', '='].contains(label);
              final bool isUtility = ['C', 'DEL', 'Mode'].contains(label);
              final ColorScheme scheme = theme.colorScheme;
              Color background;
              Color foreground;

              if (isOperation) {
                background = scheme.primary;
                foreground = scheme.onPrimary;
              } else if (isUtility) {
                background = scheme.secondaryContainer;
                foreground = scheme.onSecondaryContainer;
              } else {
                background = scheme.surfaceVariant;
                foreground = scheme.onSurface;
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: _CalculatorButton(
                    label: label,
                    background: background,
                    foreground: foreground,
                    onTap: () => onButtonTap(label),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: foreground.withOpacity(0.25),
        highlightColor: foreground.withOpacity(0.12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: background,
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ) ??
                  TextStyle(
                    color: foreground,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class CalculatorController {
  String _display = '0';
  String _history = '';
  double? _firstOperand;
  String? _pendingOperation;
  bool _resetOnNextInput = false;

  String get display => _display;
  String get history => _history;

  void inputDigit(String digit) {
    if (_display == 'Error') {
      _display = '0';
    }

    if (_resetOnNextInput || _display == '0') {
      _display = digit;
      _resetOnNextInput = false;
    } else {
      _display += digit;
    }
  }

  void inputDecimal() {
    if (_display == 'Error') {
      _display = '0';
      _resetOnNextInput = false;
    }

    if (_resetOnNextInput) {
      _display = '0.';
      _resetOnNextInput = false;
      return;
    }

    if (!_display.contains('.')) {
      _display = _display.isEmpty ? '0.' : '${_display}.';
    }
  }

  void inputOperation(String symbol) {
    final currentValue = double.tryParse(_display);
    if (currentValue == null) {
      return;
    }

    if (_pendingOperation != null && !_resetOnNextInput) {
      _compute(currentValue);
    } else {
      _firstOperand = currentValue;
    }

    _pendingOperation = symbol;
    _history = '${_formatNumber(_firstOperand ?? currentValue)} $symbol';
    _resetOnNextInput = true;
  }

  void evaluate() {
    if (_pendingOperation == null || _firstOperand == null) {
      return;
    }

    final secondOperand = double.tryParse(_display);
    if (secondOperand == null) {
      return;
    }

    final result =
        _performOperation(_firstOperand!, secondOperand, _pendingOperation!);

    if (result == null) {
      _display = 'Error';
      _history = '';
    } else {
      _history =
          '${_formatNumber(_firstOperand!)} ${_pendingOperation!} ${_formatNumber(secondOperand)} =';
      _display = _formatNumber(result);
    }

    _firstOperand = null;
    _pendingOperation = null;
    _resetOnNextInput = true;
  }

  void delete() {
    if (_resetOnNextInput) {
      _display = '0';
      _resetOnNextInput = false;
      return;
    }

    if (_display.length <= 1) {
      _display = '0';
    } else {
      _display = _display.substring(0, _display.length - 1);
      if (_display.endsWith('.')) {
        _display = _display.substring(0, _display.length - 1);
      }
      if (_display.isEmpty) {
        _display = '0';
      }
    }
  }

  void clear() {
    _display = '0';
    _history = '';
    _firstOperand = null;
    _pendingOperation = null;
    _resetOnNextInput = false;
  }

  void _compute(double secondOperand) {
    final result =
        _performOperation(_firstOperand!, secondOperand, _pendingOperation!);
    if (result == null) {
      _display = 'Error';
      _history = '';
      _firstOperand = null;
      _pendingOperation = null;
      _resetOnNextInput = true;
      return;
    }

    _firstOperand = result;
    _display = _formatNumber(result);
  }

  double? _performOperation(double first, double second, String operation) {
    switch (operation) {
      case '+':
        return first + second;
      case '−':
        return first - second;
      case '×':
        return first * second;
      case '÷':
        if (second == 0) {
          return null;
        }
        return first / second;
      default:
        return null;
    }
  }

  String _formatNumber(num value) {
    if (value.isNaN || value.isInfinite) {
      return 'Error';
    }

    String text = value.toStringAsFixed(8);
    while (text.contains('.') && (text.endsWith('0') || text.endsWith('.'))) {
      text = text.substring(0, text.length - 1);
    }

    if (text.isEmpty) {
      return '0';
    }

    return text;
  }
}
