import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
          onSurface: Colors.black,
          onBackground: Colors.black,
          background: Colors.grey.shade100,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
          onSurface: Colors.white,
          onBackground: Colors.white,
          background: Colors.black,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // --- State Variables ---
  String _inputExpression = "";
  String _output = "0";
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- Helper to clear all state ---
  void _clearAll() {
    _inputExpression = "";
    _output = "0";
  }

  // --- Helper to check if a character is an operator (without '=') ---
  bool _isOperator(String char) {
    return char == '+' ||
        char == '-' ||
        char == 'x' ||
        char == '÷' ||
        char == '%';
  }

  // --- Helper to handle number and decimal point input ---
  void _handleNumberInput(String buttonText) {
    // If output is '0' or 'Error', or if the last input was an operator, start a new number
    if (_output == "0" || _output == "Error") {
      _inputExpression = buttonText;
    } else {
      _inputExpression += buttonText;
    }
  }

  void _handleLastDot() {
    if ((_inputExpression.lastIndexOf(RegExp(r'\.')) ==
        _inputExpression.length - 1)) {
      _inputExpression = "${_inputExpression}0";
      _output = _inputExpression;
    }
  }

  // --- Main button press handler ---
  void _onButtonPressed(String buttonText) {
    setState(() {
      switch (buttonText) {
        case "C":
          _clearAll();
          break;

        case "⌫":
          if (_inputExpression.isNotEmpty) {
            _inputExpression = _inputExpression.substring(
              0,
              _inputExpression.length - 1,
            );
            if (_inputExpression.isEmpty) {
              _output = "0";
            }
          }
          break;

        case "=":
          if (_inputExpression.isNotEmpty &&
              !_isOperator(_inputExpression[_inputExpression.length - 1])) {
            _handleLastDot();
            try {
              String finalExpression = _inputExpression.replaceAll('x', '*');
              finalExpression = finalExpression.replaceAll('÷', '/');
              finalExpression = finalExpression.replaceAll('%', '/100');

              GrammarParser p = GrammarParser();
              Expression exp = p.parse(finalExpression);
              ContextModel cm = ContextModel();
              double evalResult = exp.evaluate(EvaluationType.REAL, cm);

              String formattedResult;
              if (evalResult == evalResult.toInt().toDouble()) {
                formattedResult = evalResult.toInt().toString();
              } else {
                formattedResult = evalResult.toStringAsFixed(8);
                formattedResult = formattedResult.replaceAll(
                  RegExp(r'\.?0+$'),
                  '',
                );
              }
              _output = formattedResult;
              _inputExpression = formattedResult;
            } catch (e) {
              _output = "Error";
              _inputExpression = "";
            }
          }
          break;

        case ".":
          // Check if a decimal already exists in the current number segment
          bool hasDecimal = false;
          int lastOperatorIndex = _inputExpression.lastIndexOf(
            RegExp(r'[\+\-\x\÷\%]'),
          );
          if (lastOperatorIndex != -1) {
            String currentNumber = _inputExpression.substring(
              lastOperatorIndex + 1,
            );
            if (currentNumber.contains('.')) {
              hasDecimal = true;
            }
          } else if (_inputExpression.contains('.')) {
            hasDecimal = true;
          }

          if (!hasDecimal) {
            if (_inputExpression.isEmpty ||
                _isOperator(_inputExpression[_inputExpression.length - 1])) {
              _inputExpression += "0.";
            } else {
              _inputExpression += ".";
            }
          }
          break;

        case '+':
        case '-':
        case 'x':
        case '÷':
        case '%':
          // Handle the starting symbole of number
          if (_inputExpression.isEmpty) {
            if (!(buttonText == '%' ||
                buttonText == 'x' ||
                buttonText == '÷')) {
              // } else {
              _handleNumberInput(buttonText);
            }
            break;
          }

          // Operator replacement logic
          if (_inputExpression.isNotEmpty &&
              _isOperator(_inputExpression[_inputExpression.length - 1])) {
            _inputExpression = _inputExpression.substring(
              0,
              _inputExpression.length - 1,
            );
          }
          _handleLastDot();
          _inputExpression += buttonText;
          break;

        default: // For all number buttons (0-9)
          _handleNumberInput(buttonText);
      }

      // A single place to update the output for non-error states
      if (_output != "Error") {
        _output = _inputExpression.isEmpty ? "0" : _inputExpression;
      }

      // --- Add this block to auto-scroll ---
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).colorScheme.background;
    final Color dynamicTextColor = Theme.of(context).colorScheme.onBackground;
    // final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Calculator',
          style: TextStyle(color: dynamicTextColor, fontSize: 30.0),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 50.0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: backgroundColor,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          // statusBarBrightness: Theme.light.brightness
          systemNavigationBarColor: backgroundColor,
          systemNavigationBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.0)),
                  // This makes the display vertically scrollable
                  child: SingleChildScrollView(
                    controller: _scrollController, // Attach the controller
                    child: Text(
                      _output,
                      style: TextStyle(
                        color: dynamicTextColor, // Use your existing variable
                        fontSize: 48.0, // A clear, fixed font size
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end, // Align text to the right
                    ),
                  ),
                ),
              ),
            ),

            const Divider(height: 15.0, color: Colors.grey),

            Row(
              children: <Widget>[
                Expanded(
                  child: CalculatorButton(
                    text: 'C',
                    backgroundColor: Colors.red.shade700,
                    onPressed: () => _onButtonPressed('C'),
                  ),
                ),
                Expanded(
                  child: CalculatorButton(
                    text: '⌫',
                    backgroundColor: Colors.grey.shade700,
                    onPressed: () => _onButtonPressed('⌫'),
                  ),
                ),
                Expanded(
                  child: CalculatorButton(
                    text: '%',
                    backgroundColor: Colors.grey.shade700,
                    onPressed: () => _onButtonPressed('%'),
                  ),
                ),
                Expanded(
                  child: CalculatorButton(
                    text: '÷',
                    backgroundColor: Colors.blue.shade800,
                    onPressed: () => _onButtonPressed('÷'),
                  ),
                ),
              ],
            ),

            Row(
              children: <Widget>[
                Expanded(
                  child: CalculatorButton(
                    text: '7',
                    backgroundColor: Colors.grey.shade900,
                    onPressed: () {
                      _onButtonPressed('7');
                    },
                  ),
                ),
                Expanded(
                  child: CalculatorButton(
                    text: '8',
                    backgroundColor: Colors.grey.shade900,
                    onPressed: () {
                      _onButtonPressed('8');
                    },
                  ),
                ),
                Expanded(
                  child: CalculatorButton(
                    text: '9',
                    backgroundColor: Colors.grey.shade900,
                    onPressed: () {
                      _onButtonPressed('9');
                    },
                  ),
                ),
                Expanded(
                  child: CalculatorButton(
                    text: 'x',
                    backgroundColor: Colors.blue.shade800,
                    onPressed: () => _onButtonPressed('x'),
                  ),
                ),
              ],
            ),

            Row(
              children: <Widget>[
                Expanded(
                  child: CalculatorButton(
                    text: '4',
                    backgroundColor: Colors.grey.shade900,
                    onPressed: () => _onButtonPressed('4'),
                  ),
                ),
                Expanded(
                  child: CalculatorButton(
                    text: '5',
                    backgroundColor: Colors.grey.shade900,
                    onPressed: () => _onButtonPressed('5'),
                  ),
                ),
                Expanded(
                  child: CalculatorButton(
                    text: '6',
                    backgroundColor: Colors.grey.shade900,
                    onPressed: () => _onButtonPressed('6'),
                  ),
                ),
                Expanded(
                  child: CalculatorButton(
                    text: '-',
                    fontSize: 36.0,
                    backgroundColor: Colors.blue.shade800,
                    onPressed: () => _onButtonPressed('-'),
                  ),
                ),
              ],
            ),

            Row(
              children: <Widget>[
                Expanded(
                  child: CalculatorButton(
                    text: '1',
                    backgroundColor: Colors.grey.shade900,
                    onPressed: () => _onButtonPressed('1'),
                  ),
                ),
                Expanded(
                  child: CalculatorButton(
                    text: '2',
                    backgroundColor: Colors.grey.shade900,
                    onPressed: () => _onButtonPressed('2'),
                  ),
                ),
                Expanded(
                  child: CalculatorButton(
                    text: '3',
                    backgroundColor: Colors.grey.shade900,
                    onPressed: () => _onButtonPressed('3'),
                  ),
                ),
                Expanded(
                  child: CalculatorButton(
                    text: '+',
                    backgroundColor: Colors.blue.shade800,
                    onPressed: () => _onButtonPressed('+'),
                  ),
                ),
              ],
            ),

            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: CalculatorButton(
                    text: '0',
                    backgroundColor: Colors.grey.shade900,
                    // onPressed: _useDot ? () => _onButtonPressed('.') : () {},
                    onPressed: () => _onButtonPressed('0'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CalculatorButton(
                    text: '.',
                    backgroundColor: Colors.grey.shade900,
                    onPressed: () => _onButtonPressed('.'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CalculatorButton(
                    text: '=',
                    backgroundColor: Colors.green.shade800,
                    onPressed: () => _onButtonPressed('='),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final VoidCallback onPressed;

  const CalculatorButton({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.fontSize = 32.0,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color shadowColorToUse = backgroundColor != Colors.grey.shade900
        ? backgroundColor!.withOpacity(1)
        : (isDarkMode
              ? Colors.white.withOpacity(0.2)
              : Colors.grey.withOpacity(1));
    return Container(
      margin: const EdgeInsets.all(4.0),
      height: 70.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(10.0),
          ),
          elevation: 10.0,
          // shadowColor: isDarkMode
          //     ? Colors.white.withOpacity(0.5)
          //     : Colors.black.withOpacity(1),
          // surfaceTintColor: isDarkMode
          //     ? Colors.white.withOpacity(0.1)
          //     : Colors.transparent,
          shadowColor: shadowColorToUse,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Center(
            child: Text(
              text,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
