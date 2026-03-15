import 'package:flutter/material.dart';
import 'package:new_website/widgets/elements.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets.dart'; // for headerLine and linkCard
import '../../widgets/dashboard_cards.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Cards cards = Cards(context: context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double maxWidth = constraints.maxWidth;

        // The standard card block width
        double elementWidth = 350;
        double padding = 20; // Generic safe area side-spacing

        // If screen is wider than two elements + spacing, use 2-column center layout (approx 720px)
        double maxContentWidth = (elementWidth * 2) + padding;

        // True content container width
        double contentWidth =
            maxWidth > maxContentWidth ? maxContentWidth : maxWidth;

        // Single column cards stretch full width on mobile, set to 350 on desktop
        double cardWidth =
            maxWidth < maxContentWidth ? contentWidth - padding : elementWidth;
        double fullCardWidth = maxWidth < maxContentWidth
            ? contentWidth - padding
            : maxContentWidth - padding;
        bool doubleColumns = cardWidth == elementWidth;

        return SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: Column(
                children: [
                  headerLine("About", 3, contentWidth),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 0,
                    runSpacing: 0,
                    children: [
                      ProfileCard(width: cardWidth, columns: doubleColumns, trueColor: Theme.of(context).colorScheme.primary, realColor: Theme.of(context).colorScheme.surfaceContainer,),
                      AgeCard(width: cardWidth, columns: doubleColumns, trueColor: Theme.of(context).colorScheme.primary, realColor: Theme.of(context).colorScheme.surfaceContainer,),
                      ThemeSwitchCard(width: fullCardWidth, trueColor: Theme.of(context).colorScheme.primary, realColor: Theme.of(context).colorScheme.surfaceContainer,),
                    ],
                  ),

                  // Links Section
                  headerLine("Links", 11, contentWidth),
                  cards.cardGroup(
                      doubleColumns,
                      cardWidth,
                    [
                      CardContents.tap(
                        width: cardWidth,
                        title: "Threads",
                        subtitle: "Follow my apps development",
                        action: () async {
                          await launchUrl(
                              Uri.parse("https://threads.net/@puzzaks"),
                              mode: LaunchMode.externalApplication
                          );
                        },
                      ),
                      CardContents.tap(
                        width: cardWidth,
                        title: "GitHub",
                        subtitle: "Check out my source code",
                        action: () async {
                          await launchUrl(
                              Uri.parse("https://github.com/Puzzak"),
                              mode: LaunchMode.externalApplication
                          );
                        },
                      ),
                      CardContents.tap(
                        width: cardWidth,
                        title: "Play Store",
                        subtitle: "Try out my apps",
                        action: () async {
                          await launchUrl(
                              Uri.parse("https://play.google.com/store/apps/dev?id=8304874346039659820"),
                              mode: LaunchMode.externalApplication
                          );
                        },
                      ),
                      CardContents.tap(
                        width: cardWidth,
                        title: "Telegram",
                        subtitle: "Read my personal blog",
                        action: () async {
                          await launchUrl(
                              Uri.parse("https://t.me/Puzzaks"),
                              mode: LaunchMode.externalApplication
                          );
                        },
                      ),
                      CardContents.tap(
                        width: cardWidth,
                        title: "LinkedIn",
                        subtitle: "Connect with my network",
                        action: () async {
                          await launchUrl(
                              Uri.parse("https://linkedin.com/in/puzzak"),
                              mode: LaunchMode.externalApplication
                          );
                        },
                      ),
                      CardContents.tap(
                        width: cardWidth,
                        title: "Twitter/X",
                        subtitle: "Abandoned blog, nevermind",
                        action: () async {
                          await launchUrl(
                              Uri.parse("https://x.com/puzzaks"),
                              mode: LaunchMode.externalApplication
                          );
                        },
                      ),
                      CardContents.tap(
                        width: cardWidth,
                        title: "Reddit",
                        subtitle: "Upvote my posts",
                        action: () async {
                          await launchUrl(
                              Uri.parse("https://reddit.com/u/Puzzak"),
                              mode: LaunchMode.externalApplication
                          );
                        },
                      ),
                      CardContents.tap(
                        width: cardWidth,
                        title: "Instagram",
                        subtitle: "Look at my photography",
                        action: () async {
                          await launchUrl(
                              Uri.parse("https://instagram.com/puzzaks"),
                              mode: LaunchMode.externalApplication
                          );
                        },
                      ),
                      CardContents.tap(
                        width: cardWidth,
                        title: "YouTube",
                        subtitle: "Watch my videos",
                        action: () async {
                          await launchUrl(
                              Uri.parse("https://youtube.com/@puzzak"),
                              mode: LaunchMode.externalApplication
                          );
                        },
                      ),
                      CardContents.tap(
                        width: cardWidth,
                        title: "Twitch",
                        subtitle: "Join my streams",
                        action: () async {
                          await launchUrl(
                              Uri.parse("https://twitch.tv/puzzak"),
                              mode: LaunchMode.externalApplication
                          );
                        },
                      ),
                    ]
                  ),
                  cards.cardGroup(
                      false,
                      fullCardWidth,
                      [
                        CardContents.tap(
                          width: fullCardWidth,
                          title: "Privacy policy",
                          subtitle: "Read how we handle your data",
                          action: () async {
                            await launchUrl(
                                Uri.parse("https://stories.puzzak.page/privacy-policy"),
                                mode: LaunchMode.externalApplication
                            );
                          },
                        ),
                      ]
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
