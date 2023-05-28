import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';

class DetectorCameraScreen extends StatefulWidget {
  const DetectorCameraScreen(
      {super.key,
      required this.labelsPath,
      required this.modelPath,
      required this.entrance,
      required this.floor});

  final String labelsPath;
  final String modelPath;
  final int? entrance;
  final int? floor;

  @override
  State<DetectorCameraScreen> createState() => _DetectorCameraScreenState();
}

class _DetectorCameraScreenState extends State<DetectorCameraScreen> {
  late CameraController controller;
  late FlutterVision vision;
  late List<Map<String, dynamic>> yoloResults;
  CameraImage? cameraImage;
  bool isLoaded = false;
  bool isDetecting = false;
  late List<CameraDescription> cameras;
  late List<dynamic> bath = [];
  late double bathPercent = 0;
  late List<dynamic> ceil0 = [];
  late double ceil0Percent = 0;
  late List<dynamic> ceil1 = [];
  late double ceil1Percent = 0;
  late List<dynamic> door = [];
  late double doorPercent = 0;
  late List<dynamic> floor0 = [];
  late double floor0Percent = 0;
  late List<dynamic> floor1 = [];
  late double floor1Percent = 0;
  late List<dynamic> floor2 = [];
  late double floor2Percent = 0;
  late List<dynamic> garbage = [];
  late double garbagePercent = 0;
  late List<dynamic> kitchen = [];
  late double kitchenPercent = 0;
  late List<dynamic> podokonnik0 = [];
  late double podokonnik0Percent = 0;
  late List<dynamic> podokonnik1 = [];
  late double podolonnik1Percent = 0;
  late List<dynamic> radiator = [];
  late double radiatorPercent = 0;
  late List<dynamic> shower = [];
  late double showerPercent = 0;
  late List<dynamic> sink = [];
  late double sinkPercent = 0;
  late List<dynamic> socket0 = [];
  late double socket0Percent = 0;
  late List<dynamic> socket = [];
  late double socketPercent = 0;
  late List<dynamic> toilet = [];
  late double toiletPercent = 0;
  late List<dynamic> wall0 = [];
  late double wall0Percent = 0;
  late List<dynamic> wall1 = [];
  late double wall1Percent = 0;
  late List<dynamic> wall2 = [];
  late double wall2Percent = 0;
  double itemsCountBath = 0.0;
  double itemsCountRadiator = 0.0;
  double itemsCountShower = 0.0;
  double itemsCountSink = 0.0;
  double itemsCountToilet = 0.0;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    cameras = await availableCameras();
    vision = FlutterVision();
    controller = CameraController(cameras[0], ResolutionPreset.low);
    controller.initialize().then((value) {
      loadYoloModel().then((value) {
        setState(() {
          isLoaded = true;
          isDetecting = false;
          yoloResults = [];
        });
      });
    });
  }

  @override
  void dispose() async {
    super.dispose();
    controller.dispose();
    await vision.closeYoloModel();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(
                    controller,
                  ),
                ),
                ...displayBoxesAroundRecognizedObjects(size),
                Positioned(
                  bottom: 25,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 5,
                          color: Colors.white,
                          style: BorderStyle.solid),
                    ),
                    child: isDetecting
                        ? IconButton(
                            onPressed: () async {
                              stopDetection();
                              countPercentsForLabels();
                            },
                            icon: const Icon(
                              Icons.stop,
                              color: Colors.red,
                            ),
                            iconSize: 25,
                          )
                        : IconButton(
                            onPressed: () async {
                              await startDetection();
                            },
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            iconSize: 25,
                          ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() => Scrollbar(
        controller: scrollController,
        trackVisibility: true,
        showTrackOnHover: true,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Потолок без отделки",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ceil0Percent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$ceil0Percent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Потолок c отделкой",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ceil1Percent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$ceil1Percent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Пол без отделки",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: floor0Percent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$floor0Percent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Пол черновой",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: floor1Percent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$floor1Percent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Пол готовый",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: floor2Percent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$floor2Percent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Подоконник без отделки",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: podokonnik0Percent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$podokonnik0Percent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Подоконник c отделкой",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: podolonnik1Percent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$podolonnik1Percent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Нет Розетки",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: socketPercent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$socketPercent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Наличие Розеток",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: socket0Percent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$socket0Percent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Стена без отделки",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: wall0Percent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$wall0Percent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Стена черновая",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: wall1Percent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$wall1Percent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Стена чистовая",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: wall2Percent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$wall2Percent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Кухня",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: kitchenPercent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$kitchenPercent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Мусор",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: garbagePercent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$garbagePercent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Батарея",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: radiatorPercent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$radiatorPercent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Ванная",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: bathPercent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$bathPercent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Туалет",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: toiletPercent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$toiletPercent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Раковина",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: sinkPercent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$sinkPercent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "Душ",
                      style: TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  Expanded(
                    child: showerPercent.isNaN
                        ? const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            "$showerPercent",
                            style: const TextStyle(
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
        labels: widget.labelsPath,
        modelPath: widget.modelPath,
        modelVersion: "yolov8",
        numThreads: 4,
        useGpu: true);
    setState(() {
      isLoaded = true;
    });
  }

  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await vision.yoloOnFrame(
      bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
      imageHeight: cameraImage.height,
      imageWidth: cameraImage.width,
    );
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
    }
  }

  Future<void> startDetection() async {
    setState(() {
      isDetecting = true;
    });
    if (controller.value.isStreamingImages) {
      return;
    }
    await controller.startImageStream((image) async {
      if (isDetecting) {
        cameraImage = image;
        yoloOnFrame(image);
      }
    });
  }

  Future<void> stopDetection() async {
    setState(() {
      isDetecting = false;
      yoloResults.clear();
    });
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];
    double factorX = screen.width / (cameraImage?.height ?? 1);
    double factorY = screen.height / (cameraImage?.width ?? 1);

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return yoloResults.map((result) {
      if (result.containsValue('wall 2') && result.containsValue('bath') ||
          result.containsValue('floor2') && result.containsValue('bath')) {
        itemsCountBath++;
      } else if (result.containsValue('wall 1') &&
              result.containsValue('bath') ||
          result.containsValue('floor 1') && result.containsValue('bath')) {
        itemsCountBath += 0.5;
      }
      if (result.containsValue('wall 2') && result.containsValue('radiator') ||
          result.containsValue('floor2') && result.containsValue('radiator')) {
        itemsCountRadiator++;
      } else if (result.containsValue('wall 1') &&
              result.containsValue('radiator') ||
          result.containsValue('floor 1') && result.containsValue('radiator')) {
        itemsCountRadiator += 0.5;
      }
      if (result.containsValue('wall 2') && result.containsValue('shower') ||
          result.containsValue('floor2') && result.containsValue('shower')) {
        itemsCountShower++;
      } else if (result.containsValue('wall 1') &&
              result.containsValue('shower') ||
          result.containsValue('floor 1') && result.containsValue('shower')) {
        itemsCountShower += 0.5;
      }
      if (result.containsValue('wall 2') && result.containsValue('sink') ||
          result.containsValue('floor2') && result.containsValue('sink')) {
        itemsCountSink++;
      } else if (result.containsValue('wall 1') &&
              result.containsValue('sink') ||
          result.containsValue('floor 1') && result.containsValue('sink')) {
        itemsCountSink += 0.5;
      }
      if (result.containsValue('wall 2') && result.containsValue('toilet') ||
          result.containsValue('floor2') && result.containsValue('toilet')) {
        itemsCountToilet++;
      } else if (result.containsValue('wall 1') &&
              result.containsValue('toilet') ||
          result.containsValue('floor 1') && result.containsValue('toilet')) {
        itemsCountToilet += 0.5;
      }
      fillLists();
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  void fillLists() {
    log("fillingLists is working");

    for (var yResult in yoloResults) {
      switch (yResult["tag"]) {
        case 'bath':
          bath.add(yResult["box"][4]);
          break;
        case 'ceil 0':
          ceil0.add(yResult["box"][4]);
          break;
        case 'ceil 1':
          ceil1.add(yResult["box"][4]);
          break;
        case 'door':
          door.add(yResult["box"][4]);
          break;
        case 'floor 0':
          floor0.add(yResult["box"][4]);
          break;
        case 'floor 1':
          floor1.add(yResult["box"][4]);
          break;
        case 'floor2':
          floor2.add(yResult["box"][4]);
          break;
        case 'garbage':
          garbage.add(yResult["box"][4]);
          break;
        case 'kitchen':
          kitchen.add(yResult["box"][4]);
          break;
        case 'podokonnik 0':
          podokonnik0.add(yResult["box"][4]);
          break;
        case 'podokonnik 1':
          podokonnik1.add(yResult["box"][4]);
          break;
        case 'radiator':
          radiator.add(yResult["box"][4]);
          break;
        case 'shower':
          shower.add(yResult["box"][4]);
          break;
        case 'sink':
          sink.add(yResult["box"][4]);
          break;
        case 'socket 0':
          socket0.add(yResult["box"][4]);
          break;
        case 'socket':
          socket.add(yResult["box"][4]);
          break;
        case 'toilet':
          toilet.add(yResult["box"][4]);
          break;
        case 'wall 0':
          wall0.add(yResult["box"][4]);
          break;
        case 'wall 1':
          wall1.add(yResult["box"][4]);
          break;
        case 'wall 2':
          wall2.add(yResult["box"][4]);
          break;
      }
    }
  }

  void countPercentsForLabels() {
    kitchenPercent = ((10 * kitchen.length) / wall2.length) * 100;
    if (kitchenPercent > 100) {
      kitchenPercent = 100;
    }
    doorPercent = ((10 * door.length) / wall2.length) * 100;
    if (doorPercent > 100) {
      doorPercent = 100;
    }
    garbagePercent = ((10 * garbage.length) /
            (floor0.length + floor1.length + floor2.length)) *
        100;
    if (garbagePercent > 100) {
      garbagePercent = 100;
    }
    socket0Percent = ((10 * socket.length) / socket0.length) * 100;
    if (socket0Percent > 100) {
      socket0Percent = 100;
    }
    socketPercent =
        ((10 * socket0.length) / (socket0.length + socket.length)) * 100;
    if (socketPercent > 100) {
      socketPercent = 100;
    }
    podokonnik0Percent = ((10 * podokonnik0.length) /
            (podokonnik1.length + podokonnik0.length)) *
        100;
    if (podokonnik0Percent > 100) {
      podokonnik0Percent = 100;
    }
    podolonnik1Percent = ((10 * podokonnik1.length) /
            (podokonnik1.length + podokonnik0.length)) *
        100;
    if (podolonnik1Percent > 100) {
      podolonnik1Percent = 100;
    }
    ceil0Percent = (ceil0.length / (ceil0.length + ceil1.length) * 100);
    ceil1Percent = (ceil1.length / (ceil1.length + ceil0.length) * 100);
    floor0Percent =
        (floor0.length / (floor1.length + floor0.length + floor2.length) * 100);
    floor1Percent =
        (floor1.length / (floor1.length + floor0.length + floor2.length) * 100);
    floor2Percent =
        (floor2.length / (floor1.length + floor0.length + floor2.length) * 100);
    wall0Percent =
        (wall0.length / (wall1.length + wall0.length + wall2.length) * 100);
    wall1Percent =
        (wall1.length / (wall1.length + wall0.length + wall2.length) * 100);
    wall2Percent =
        (wall2.length / (wall1.length + wall0.length + wall2.length) * 100);
    bathPercent = (itemsCountBath / bath.length) * 100;
    radiatorPercent = (itemsCountRadiator / radiator.length) * 100;
    showerPercent = (itemsCountShower / shower.length) * 100;
    sinkPercent = (itemsCountSink / sink.length) * 100;
    toiletPercent = (itemsCountToilet / toilet.length) * 100;
  }
}
