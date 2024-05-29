// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:binsight_ai/widgets/heading.dart';

/// Displays the User Guide
class UserGuide extends StatelessWidget {
  const UserGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyLarge;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            // User Guide Heading
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 5),
              child: Heading(text: "User Guide"),
            ),
            // User Guide Content
            _buildUserGuideSections(
              [
                {
                  "subheading": "Overview",
                  "content": [
                    "Welcome to the binsight.ai app, developed by Soundbendor Lab.",
                    "This guide will help you set up and use your Smart Compost Bin—enabling you to track household food waste, annotate detection images, and monitor your compost data trends over time.",
                  ],
                },
                {
                  "subheading": "Getting Started",
                  "content": [
                    "Unbox your Smart Compost Bin and place it on your kitchen countertop.",
                    "Connect the bin to a power source and wait for the bin to boot up.",
                    "Note: this step may take a minute or so, but the bin will give audio feedback when it is ready to connect to your phone.",
                  ],
                },
                {
                  "subheading": "Connecting to Wi-Fi",
                  "content": [
                    "Open the binsight.ai app and follow the on-screen instructions to connect your bin to your local Wi-Fi network.",
                    "During this connection process, your Wi-Fi credentials will be shared with the bin via a Bluetooth connection.",
                    "Keep in mind that the Bluetooth pairing mode automatically shuts down within five minutes of powering on the bin, so have your Wi-Fi credentials ready.",
                    "Once the bin is connected to Wi-Fi, you can start using the app to track your food waste.",
                  ],
                },
                {
                  "subheading": "Annotating The Images",
                  "content": [
                    "Your annotations are an essential part of building a new visual dataset of food waste, which will be used to train our AI model.",
                    "To annotate an image, select the image from your gallery list and use the annotation tools to outline and label items.",
                    "Use your finger to draw an outline around the newly composted item in the image, and then tap 'Select Label' to search for the appropriate label.",
                    "Once you have selected the label, tap 'Submit' and note that the label now appears on the item you have outlined.",
                    "Continue this process for all newly composted items in the image.",
                    "When you are finished outlining items and labeling them, save your annotations with the 'Save & Exit' button.",
                    "Note: You can also use the 'Undo/Redo' buttons to adjust your outlines, or 'Clear Image' to start over.",
                  ],
                },
                {
                  "subheading": "Inspecting Your Data",
                  "content": [
                    "Once you have annotated your images, you can inspect your data.",
                    "Go to the 'Home' section in the app to view a breakdown of all of the food you have composted.",
                  ],
                },
                // Add more sections as needed
              ],
              textTheme!,
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build User Guide sections with subheadings and dropdown content
  Widget _buildUserGuideSections(
      List<Map<String, dynamic>> sections, TextStyle textTheme) {
    return Column(
      children: sections
          .map((section) => ExpansionTile(
                shape: Border.all(color: Colors.transparent),
                title: Text(
                  section["subheading"],
                  style: textTheme.copyWith(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                children: section["content"]
                    .map<Widget>((content) => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 16),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(content, style: textTheme)),
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }
}
