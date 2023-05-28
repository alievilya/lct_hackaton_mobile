import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/detector_screen.dart';

//TODO константы путей для лейблов и моделей
const String labels = 'assets/labels/labels.txt';
const String clsLabels = 'assets/labels/clslabels.txt';
const String detModel32 = 'assets/mlmodels/best_float32.tflite';
const String clsModel16 = 'mlmodels/cls_best_float16.tflite';
const String clsModel32 = 'mlmodels/cls_best_float32.tflite';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RealTime',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'RealTime'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final entranceController = TextEditingController();
    final floorController = TextEditingController();
    final FocusNode entranceFocusNode = FocusNode();
    final FocusNode floorFocusNode = FocusNode();

    return GestureDetector(
      onTap: () {
        entranceFocusNode.unfocus();
        floorFocusNode.unfocus();
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  TextField(
                    controller: entranceController,
                    focusNode: entranceFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Введите номер cекции(подъезда)',
                    ),
                  ),
                  TextField(
                    controller: floorController,
                    focusNode: floorFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Введите номер этажа',
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size?>(
                      const Size(150, 150),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.yellow),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  child: const Text(
                    "Открыть реалтайм камеру для детектора",
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => (entranceController.text.isNotEmpty &&
                          floorController.text.isNotEmpty)
                      ? Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetectorCameraScreen(
                              labelsPath: labels,
                              modelPath: detModel32,
                              entrance: int.tryParse(entranceController.text),
                              floor: int.tryParse(floorController.text),
                            ),
                          ),
                        )
                      : null),
            ],
          ),
        ),
      ),
    );
  }
}
