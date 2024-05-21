// Flutter imports:
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:multiple_search_selection/createable/create_options.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/util/providers/detection_notifier.dart';
import 'package:binsight_ai/util/providers/annotation_notifier.dart';
import 'package:binsight_ai/util/shared_preferences.dart';
import 'package:binsight_ai/widgets/free_draw.dart';
import 'package:binsight_ai/widgets/heading.dart';
import 'package:binsight_ai/util/styles.dart';

/// Page used for annotating an individual detection image
class AnnotationPage extends StatefulWidget {
  /// The detection id of the image being annotated
  final String detectionId;

  const AnnotationPage({super.key, required this.detectionId});

  @override
  State<AnnotationPage> createState() => _AnnotationPageState();
}

class _AnnotationPageState extends State<AnnotationPage> {
  /// User's decision to show annotation tutorial upon opening annotation screen
  bool? dontShowAgain = false;

  Directory? appDocDir;

  late final Detection detection;

  /// The link for the image to be annotated
  late final Future<String> imageLink;

  @override
  void initState() {
    super.initState();
    getDirectory();
    imageLink = Future(() async {
      debug(
          "AnnotationPage: Getting image link for detection ${widget.detectionId}");
      final Detection d = (await Detection.find(widget.detectionId))!;
      detection = d;
      if (mounted) {
        final notifier =
            Provider.of<AnnotationNotifier>(context, listen: false);
        List<dynamic> annotations = jsonDecode(detection.boxes ?? "[]");
        for (var annotation in annotations) {
          notifier.label = annotation['object_name'];
          notifier.currentAnnotation.add(DrawingSegment(
              offsets: (annotation['xy_coord_list'] as List<dynamic>)
                  .map((e) => Offset(e[0], e[1]))
                  .toList()));
          notifier.addToAllAnnotations();
        }
        notifier.clearCurrentAnnotation();
        notifier.label = null;
      }
      debug(
          "AnnotationPage: Image link for detection ${widget.detectionId} is ${d.postDetectImgLink}");
      return d.postDetectImgLink!;
    });
    initPreferences();
  }

  /// Gets the application directory to store images and app data
  Future<void> getDirectory() async {
    Directory dir = await getApplicationDocumentsDirectory();
    setState(() {
      appDocDir = dir;
    });
  }

  /// Recalls user's decision of whether to show the annotation guide or not
  void initPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      dontShowAgain =
          preferences.getBool(SharedPreferencesKeys.dontShowAgain) ?? false;
    });
    if (dontShowAgain == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAnnotationPopup();
      });
    }
  }

  /// Renders the popup that educates the user on how to properly annotate their composted items
  void _showAnnotationPopup() {
    final textTheme = Theme.of(context).textTheme;
    showDialog(
        context: context,
        // Don't allow the user to dismiss the dialog to ensure the preference is set
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            surfaceTintColor: const Color.fromARGB(0, 147, 147, 147),
            title: Center(
                child: Text('How to Annotate', style: textTheme.headlineLarge)),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display annotation gif with border
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.0)),
                  child: Image.asset('assets/images/annotation.gif'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      "Outline the newly composted item with your finger as accurately as possible.",
                      style: Theme.of(context).textTheme.labelLarge),
                ),
                Row(
                  children: [
                    // Gives dialog's context the ability to update state (for checkbox)
                    StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return Checkbox(
                        checkColor: Colors.black,
                        value: dontShowAgain,
                        onChanged: (value) {
                          setState(() => dontShowAgain = value!);
                        },
                      );
                    }),
                    Expanded(
                      child: Text(
                        "Don't show this screen again",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.setBool(
                      SharedPreferencesKeys.dontShowAgain, dontShowAgain!);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              ),
            ],
          );
        });
  }

  //// The main build method for the AnnotationPage
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    AnnotationNotifier annotationNotifier = context.read<AnnotationNotifier>();
    if (annotationNotifier.currentDetection != widget.detectionId) {
      annotationNotifier.reset();
      annotationNotifier.setDetection(widget.detectionId);
    }
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LayoutBuilder(builder: (context, constraints) {
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_back_ios),
                                  Text("Back to detection",
                                      style: textTheme.labelLarge),
                                ],
                              ),
                              onTap: () => GoRouter.of(context).pop(),
                            ),
                            const Heading(text: "Annotate Your Image"),
                            // const SizedBox(height: 16),   // ?? this one
                          ],
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              appDocDir != null
                                  ? _DrawingArea(
                                      baseDir: appDocDir!,
                                      imageLink: imageLink,
                                      constraints: constraints)
                                  : Container(),
                              _DrawingControlArea(
                                  detectionId: widget.detectionId,
                                  constraints: constraints),
                              // const SizedBox(height: 16),  // ??
                            ],
                          ),
                        ),
                      ),
                      const Expanded(child: Column()),
                      _BottomControlArea(detectionId: widget.detectionId),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _DrawingControlArea extends StatefulWidget {
  _DrawingControlArea({
    required this.detectionId,
    required this.constraints,
  });

  /// Controller for the MultipleSearchSelection widget
  final MultipleSearchController controller = MultipleSearchController();

  /// The constraints for the drawing control area
  final BoxConstraints constraints;

  /// The detection id of the image being annotated
  final String detectionId;

  @override
  State<_DrawingControlArea> createState() => _DrawingControlAreaState();
}

class _DrawingControlAreaState extends State<_DrawingControlArea> {
  /// List of labels user can choose from
  List labels = [];

  @override
  void initState() {
    super.initState();
    loadLabels();
  }

  /// Reads json file containing the possible labels
  Future<void> loadLabels() async {
    final String response =
        await rootBundle.loadString('assets/data/labels.json');
    final data = await json.decode(response);
    setState(() {
      labels = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Consumer<AnnotationNotifier>(
        builder: (context, annotationNotifier, child) {
      return SizedBox(
        width: widget.constraints.maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filled(
                          disabledColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(150),
                          onPressed: annotationNotifier.canUndo()
                              ? () {
                                  annotationNotifier.undo();
                                }
                              : null,
                          icon: const Icon(Icons.undo)),
                      IconButton.filled(
                          disabledColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(150),
                          onPressed: annotationNotifier.canRedo()
                              ? () {
                                  annotationNotifier.redo();
                                }
                              : null,
                          icon: const Icon(Icons.redo)),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      annotationNotifier.label == null
                          ? 'Please Select a Label'
                          : 'Selected Label: ${annotationNotifier.label}',
                      style: textTheme.labelLarge,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                ElevatedButton(
                  child: Text(
                    "Select Label",
                    style: textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  // If the labels json loaded in from assets/data is not empty, show the dialog popup, otherwise don't
                  onPressed: () {
                    labels.isNotEmpty
                        ? showDialog(
                            context: context,
                            builder: (context) {
                              return MyAlertDialog(
                                labels: labels,
                                controller: widget.controller,
                              );
                            },
                          )
                        : const Padding(padding: EdgeInsets.zero);
                  },
                ),
                const SizedBox(width: 8),
                Consumer<DetectionNotifier>(
                    builder: (context, notifier, child) {
                  return ElevatedButton(
                    style: !annotationNotifier.isCompleteAnnotation()
                        ? Theme.of(context).elevatedButtonTheme.style!.copyWith(
                              backgroundColor: WidgetStateProperty.all(
                                Theme.of(context).colorScheme.surface,
                              ),
                            )
                        : null,
                    onPressed: () {
                      if (annotationNotifier.isCompleteAnnotation()) {
                        annotationNotifier.addToAllAnnotations();
                        annotationNotifier.clearCurrentAnnotation();
                        annotationNotifier.label = null;
                      } else {
                        String message;
                        if (annotationNotifier.label == null) {
                          message =
                              "Please Enter a Label for Current Annotation";
                        } else {
                          message = "Please Draw Your Annotation";
                        }
                        debug(message);
                      }
                    },
                    child: Text(
                      "Save",
                      style: textTheme.labelLarge!.copyWith(
                        color: annotationNotifier.isCompleteAnnotation()
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(150),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      );
    });
  }
}

class _BottomControlArea extends StatelessWidget {
  const _BottomControlArea({required this.detectionId});

  /// The detection id of the image being annotated
  final String detectionId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Builder(builder: (context) {
              final AnnotationNotifier annotationNotifier =
                  context.read<AnnotationNotifier>();
              return ElevatedButton(
                onPressed: () {
                  annotationNotifier.clearCurrentAnnotation();
                  annotationNotifier.reset();

                  Future.delayed(const Duration(milliseconds: 100), () {
                    annotationNotifier.reset();
                    GoRouter.of(context).pop();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColorScheme.error,
                ),
                child: Text(
                  "Clear Image",
                  style: textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
            Consumer<DetectionNotifier>(
              builder: (context, notifier, child) {
                AnnotationNotifier annotationNotifier =
                    context.read<AnnotationNotifier>();
                return ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                  onPressed: () {
                    annotationNotifier.clearCurrentAnnotation();
                    notifier.updateDetection(
                        detectionId, annotationNotifier.allAnnotations);

                    Future.delayed(const Duration(milliseconds: 100), () {
                      annotationNotifier.reset();
                      GoRouter.of(context).pop();
                    });
                  },
                  child: child,
                );
              },
              child: Text(
                "Save & Exit",
                style: textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawingArea extends StatefulWidget {
  _DrawingArea(
      {required this.imageLink,
      required this.baseDir,
      required this.constraints});

  /// The link for the image to be annotated
  final Future<String> imageLink;

  final Directory baseDir;

  /// The constraints for the drawing area
  final BoxConstraints constraints;

  /// Key for the RepaintBoundary that captures the drawing area
  final GlobalKey<State<StatefulWidget>> captureKey = GlobalKey();

  @override
  State<_DrawingArea> createState() => _DrawingAreaState();
}

class _DrawingAreaState extends State<_DrawingArea> {
  /// Whether the user has started drawing on the image
  bool drawStarted = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = widget.constraints.maxWidth;

    return FutureBuilder(
      future: widget.imageLink,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: RepaintBoundary(
                  key: widget.captureKey,
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: FreeDraw(
                        imageLink: snapshot.data as String,
                        baseDir: widget.baseDir,
                        size: size,
                      ),
                    ),
                  ),
                ),
              ),
              if (!drawStarted)
                Positioned(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      drawStarted = true;
                    }),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                          ),
                          child: Center(
                              child: Text(
                            "Tap to start",
                            style: textTheme.displaySmall!.copyWith(
                              color: Colors.white,
                            ),
                          ))),
                    ),
                  ),
                ),
            ],
          );
        }
      },
    );
  }
}

/// Custom alert dialog that prompts the user to search and select for a label
class MyAlertDialog extends StatefulWidget {
  const MyAlertDialog(
      {super.key, required this.labels, required this.controller});

  /// List of labels the dialog will provide as options
  final List labels;

  /// Controller for the text input associated with searching
  final MultipleSearchController controller;

  @override
  State<MyAlertDialog> createState() => _MyAlertDialogState();
}

class _MyAlertDialogState extends State<MyAlertDialog> {
  /// The label the user has selected
  String? selectedLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Select A Label",
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Create MultipleSearchSelection widget with the ability to create new items
              MultipleSearchSelection.creatable(
                controller: widget.controller,
                onTapClearAll: () {
                  setState(() {
                    selectedLabel = null;
                  });
                },
                maxSelectedItems: 1,
                searchField: TextField(
                  decoration: InputDecoration(
                    hintText: selectedLabel == null
                        ? "Select A Label"
                        : selectedLabel!,
                    hintStyle: selectedLabel == null
                        ? const TextStyle(color: Colors.grey)
                        : const TextStyle(color: Colors.black),
                  ),
                ),
                showClearAllButton: false,
                items: widget.labels,
                onItemAdded: (item) {
                  setState(() {
                    selectedLabel = item["Label"]["name"];
                  });
                },
                pickedItemBuilder: (label) {
                  return const Text("");
                },
                //Each label has a category, we want to search the Labels
                fieldToCheck: (label) {
                  return label["Label"]["name"];
                },
                itemBuilder: (label, index) {
                  return Text(label["Label"]["name"]);
                },
                pickedItemsContainerBuilder: (pickedItems) {
                  return pickedItems.isNotEmpty
                      ? Center(child: pickedItems[0])
                      : const Padding(padding: EdgeInsets.zero);
                },
                // Options associated with creating a new item when searched item isn't found
                createOptions: CreateOptions(
                  pickCreated: true,
                  create: (text) => {
                    "Label": {"name": text, "category": "Undefined"}
                  },
                  createBuilder: (text) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Create "$text"'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 2,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextButton(
                        onPressed: () {
                          // Only pop out of the dialog when pressing submit if you've selected a label
                          if (widget.controller.getPickedItems().isNotEmpty) {
                            context.read<AnnotationNotifier>().setLabel(
                                widget.controller.getPickedItems()[0]["Label"]
                                    ["name"]);
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Submit"),
                      ),
                    ),
                    if (selectedLabel != null)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.red)),
                          onPressed: () => setState(
                            () {
                              selectedLabel = null;
                              widget.controller.clearAllPickedItems();
                            },
                          ),
                          child: const Text(
                            "Clear",
                          ),
                        ),
                      ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all<Color>(Colors.grey)),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "Cancel",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
