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
      title: 'Simple Calculator',
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
  String _inputExpression = "";
  String _output = "0";
  bool _useDot = true;

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _inputExpression = "";
        _output = "0";
        _useDot = true;
      } else if (buttonText == "⌫") {
        if (_inputExpression.isNotEmpty) {
          _useDot = _inputExpression[_inputExpression.length - 1] == '.'
              ? true
              : _useDot;
          _inputExpression = _inputExpression.substring(
            0,
            _inputExpression.length - 1,
          );
          if (_inputExpression.isEmpty) {
            _output = "0";
          } else {
            _output = _inputExpression;
          }
        }
      } else if (buttonText == "=") {
        if (_inputExpression.isNotEmpty &&
            !_isOperator(_inputExpression[_inputExpression.length - 1])) {
          try {
            String finalExpression = _inputExpression.replaceAll('x', '*');
            finalExpression = finalExpression.replaceAll('÷', '/');
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
              _useDot = true;
            }

            _output = formattedResult;
            _inputExpression = formattedResult;
          } catch (e) {
            _output = "Error";
            _inputExpression = "";
          }
        }
      } else if (buttonText == ".") {
        if (_output == "Error" ||
            (_inputExpression.isEmpty && _output != "0")) {
          _inputExpression = "0.";
          _output = _inputExpression;
          _useDot = false;
          return;
        }
        if (_useDot) {
          _inputExpression = _inputExpression + buttonText;
          _useDot = false;
        }
        _output = _inputExpression;
      } else {
        if (_isOperator(buttonText) &&
            _inputExpression.isNotEmpty &&
            _isOperator(_inputExpression[_inputExpression.length - 1])) {
          _inputExpression = _inputExpression.substring(
            0,
            _inputExpression.length - 1,
          );
        }

        _useDot = _isOperator(buttonText) ? true : _useDot;

        if (_output == "0" && !_isOperator(buttonText) && buttonText != '.') {
          _inputExpression = buttonText;
        } else {
          _inputExpression += buttonText;
        }

        _output = _inputExpression;
      }
    });
  }

  bool _isOperator(String char) {
    return char == '+' ||
        char == '-' ||
        char == 'x' ||
        char == '÷' ||
        char == '%' ||
        char == '=';
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
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          // statusBarBrightness: Theme.light.brightness
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.bottomRight,
                child: Text(
                  _output,
                  style: TextStyle(
                    color: dynamicTextColor,
                    fontSize: 72.0,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            const Divider(height: 1.0, color: Colors.grey),

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
                  flex: 1,
                  child: CalculatorButton(
                    text: '.',
                    backgroundColor: Colors.grey.shade900,
                    onPressed: _useDot ? () => _onButtonPressed('.') : () {},
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: CalculatorButton(
                    text: '0',
                    backgroundColor: Colors.grey.shade900,
                    onPressed: () => _onButtonPressed('0'),
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
    this.fontSize = 28.0,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
          elevation: 5.0,
          shadowColor: isDarkMode
              ? Colors.white.withOpacity(0.5)
              : Colors.black.withOpacity(1),
          // surfaceTintColor: isDarkMode
          //     ? Colors.white.withOpacity(0.1)
          //     : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Center(
            child: Text(
              text,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ),
    );
  }
}
