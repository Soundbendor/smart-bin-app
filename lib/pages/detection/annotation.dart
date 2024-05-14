// Flutter imports:
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:multiple_search_selection/createable/create_options.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';
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

/// Page used for annotating an individual detection image
class AnnotationPage extends StatefulWidget {
  /// The link for the image to be annotated
  late final Future<String> imageLink;
  final String detectionId;
  AnnotationPage({super.key, required this.detectionId}) {
    imageLink = Future(() async {
      return Detection.find(detectionId)
          .then((detection) => detection!.preDetectImgLink);
    });
  }
  @override
  State<AnnotationPage> createState() => _AnnotationPageState();
}

class _AnnotationPageState extends State<AnnotationPage> {
  /// List of labels user can choose from
  List labels = [];

  /// Whether the user has started drawing on the image
  bool drawStarted = false;

  /// Key for the RepaintBoundary widget that's used to capture the annotated image
  final GlobalKey _captureKey = GlobalKey();

  /// User's decision to show annotation tutorial upon opening annotation screen
  bool? dontShowAgain = false;

  @override
  void initState() {
    super.initState();
    loadLabels();
    initPreferences();
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
            surfaceTintColor: Colors.transparent,
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
                      border: Border.all(color: Colors.black, width: 2.0)),
                  child: Image.asset('assets/images/annotation.gif'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      "Trace the composted item with your finger as accurately as possible.",
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
                        style: Theme.of(context).textTheme.labelLarge,
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

  final MultipleSearchController controller = MultipleSearchController();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    AnnotationNotifier annotationNotifier = context.read<AnnotationNotifier>();
    if (annotationNotifier.currentDetection != widget.detectionId) {
      annotationNotifier.reset();
      annotationNotifier.setDetection(widget.detectionId);
    }
    return Consumer<DetectionNotifier>(
      builder: (context, notifier, child) {
        return Scaffold(
          body: Center(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      heading(textTheme, context),
                      drawingArea(textTheme),
                      drawingControlArea(textTheme, notifier),
                      const SizedBox(height: 16),
                      bottomControlArea(
                          context, annotationNotifier, notifier, textTheme),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget bottomControlArea(
      BuildContext context,
      AnnotationNotifier annotationNotifier,
      DetectionNotifier notifier,
      TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
              onPressed: () {
                annotationNotifier.clearCurrentAnnotation();
                notifier.updateDetection(widget.detectionId);

                Future.delayed(const Duration(milliseconds: 100), () {
                  annotationNotifier.reset();
                });
              },
              child: Text(
                "Done",
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

  Widget drawingControlArea(TextTheme textTheme, DetectionNotifier notifier) {
    return Consumer<AnnotationNotifier>(
        builder: (context, annotationNotifier, child) {
      return SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                Text(
                  annotationNotifier.label == null
                      ? 'No label selected yet'
                      : 'Selected Label: ${annotationNotifier.label}',
                  style: textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                                controller: controller,
                              );
                            },
                          )
                        : const Padding(padding: EdgeInsets.zero);
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: !annotationNotifier.isCompleteAnnotation()
                      ? Theme.of(context).elevatedButtonTheme.style!.copyWith(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.surface,
                            ),
                          )
                      : null,
                  onPressed: () {
                    if (annotationNotifier.isCompleteAnnotation()) {
                      annotationNotifier.addToAllAnnotations();
                      annotationNotifier.clearCurrentAnnotation();
                      annotationNotifier.label = null;
                      notifier.updateDetection(widget.detectionId);
                    } else {
                      String message;
                      if (annotationNotifier.label == null) {
                        message = "Please Enter a Label for Current Annotation";
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
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget drawingArea(TextTheme textTheme) {
    return FutureBuilder(
      future: widget.imageLink,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return Stack(
            children: [
              RepaintBoundary(
                key: _captureKey,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: FreeDraw(
                      imageLink: snapshot.data as String,
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
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Center(
                        child: Text(
                          "Tap to start",
                          style: textTheme.displaySmall!.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
      },
    );
  }

  Widget heading(TextTheme textTheme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios),
                Text("Back to detection", style: textTheme.labelLarge),
              ],
            ),
            onTap: () => GoRouter.of(context).pop(),
          ),
          const Heading(text: "Annotate Your Image"),
          const SizedBox(height: 16),
        ],
      ),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
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
                    selectedLabel != null
                        ? TextButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red)),
                            onPressed: () => setState(
                              () {
                                selectedLabel = null;
                                widget.controller.clearAllPickedItems();
                              },
                            ),
                            child: const Text(
                              "Clear",
                            ),
                          )
                        : const Text(""),
                    TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.grey)),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "Cancel",
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
