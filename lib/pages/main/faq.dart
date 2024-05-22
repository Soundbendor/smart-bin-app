// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:binsight_ai/widgets/heading.dart';

/// Displays the FAQ page with dropdown section for content
class FAQ extends StatelessWidget {
  const FAQ({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyLarge;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            // FAQ Heading
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 5),
              child: Heading(text: "FAQ"),
            ),
            // FAQ Content
            _buildFaqSections(
              [
                {
                  "subheading": "What can I put in my Smart Compost Bin?",
                  "content": [
                    "As a general rule of thumb, if it comes from your cutting board or plate, you can compost it!",
                    "Here are some examples:",
                    "- Fruit and vegetable scraps",
                    "- Rinds, peels, pits",
                    "- Meat, dairy, eggs",
                    "- Leftover prepared foods",
                    "- Grass clippings",
                    "- Coffee grounds and filters",
                    "- Tea bags",
                    "- Nut shells",
                  ],
                },
                {
                  "subheading": "What things don't belong in the bin?",
                  "content": [
                    "- Large bones (like beef, lamb, or pork)",
                    "- Large amounts of grease or oil",
                    "- Drugs or medications",
                    "- Compostable plastics, packaging",
                    "- Take-out containers, paper plates",
                  ],
                },
                {
                  "subheading": "How will the saved annotations be used?",
                  "content": [
                    "The annotations saved from the images will be used to train the AI model to recognize objects in the images.",
                    "The more annotations we have, the better the model will be at recognizing objects in the images.",
                  ],
                },
                {
                  "subheading":
                      "How do I know if my bin is connected to the internet?",
                  "content": [
                    "You can check the Wi-Fi status of your bin in the app by pulling down to refresh the Detections page.",
                    "If you see new detections, your bin is connected to the internet.",
                    "If you don't see any new detections, your bin may be offline and you can click the pop-up to check your Wi-Fi connection.",
                  ],
                },
              ],
              textTheme!,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget to build FAQ sections
Widget _buildFaqSections(
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
                        padding: 
                          const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(content, style: textTheme)),
                      ))
                  .toList(),
            ))
        .toList(),
  );
}
