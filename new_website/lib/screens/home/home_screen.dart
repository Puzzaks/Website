import 'package:flutter/material.dart';
import '../../widgets.dart'; // for headerLine and linkCard
import '../../widgets/dashboard_cards.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

        return SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: Column(
                children: [
                  // About Section
                  headerLine("About", 3, contentWidth),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 0,
                    runSpacing: 0,
                    children: [
                      ProfileCard(width: cardWidth),
                      AgeCard(width: cardWidth),
                      ThemeSwitchCard(width: fullCardWidth),
                    ],
                  ),

                  // Links Section
                  headerLine("Links", 11, contentWidth),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 0,
                    runSpacing: 0,
                    children: [
                      linkCard(
                          "Threads",
                          "Follow my apps development",
                          "https://threads.net/@puzzaks",
                          const Icon(Icons.format_list_bulleted_rounded),
                          context,
                          cardWidth),
                      linkCard(
                          "GitHub",
                          "Check out my source code",
                          "https://github.com/Puzzak",
                          const Icon(Icons.code_rounded),
                          context,
                          cardWidth),
                      linkCard(
                          "Play Store",
                          "Try out my apps",
                          "https://play.google.com/store/apps/dev?id=8304874346039659820",
                          const Icon(Icons.android_rounded),
                          context,
                          cardWidth),
                      linkCard(
                          "Telegram",
                          "Read my personal blog",
                          "https://t.me/Puzzaks",
                          const Icon(Icons.mark_unread_chat_alt_rounded),
                          context,
                          cardWidth),
                      linkCard(
                          "LinkedIn",
                          "Connect with my network",
                          "https://linkedin.com/in/puzzak",
                          const Icon(Icons.people_outline_rounded),
                          context,
                          cardWidth),
                      linkCard(
                          "Twitter/X",
                          "Abandoned blog, nevermind",
                          "https://x.com/puzzaks",
                          const Icon(Icons.rss_feed_rounded),
                          context,
                          cardWidth),
                      linkCard(
                          "Reddit",
                          "Upvote my posts",
                          "https://reddit.com/u/Puzzak",
                          const Icon(Icons.contact_page_rounded),
                          context,
                          cardWidth),
                      linkCard(
                          "Instagram",
                          "Look at my photography",
                          "https://instagram.com/puzzaks/",
                          const Icon(Icons.camera_alt_rounded),
                          context,
                          cardWidth),
                      linkCard(
                          "YouTube",
                          "Watch my videos",
                          "https://youtube.com/@puzzak",
                          const Icon(Icons.video_library_rounded),
                          context,
                          cardWidth),
                      linkCard(
                          "Twitch",
                          "Join my streams",
                          "https://twitch.tv/puzzak",
                          const Icon(Icons.videogame_asset_rounded),
                          context,
                          cardWidth),
                      linkCard(
                          "Privacy policy",
                          "Read how we handle your data",
                          "https://stories.puzzak.page/privacy-policy",
                          const Icon(Icons.privacy_tip_outlined),
                          context,
                          fullCardWidth),
                    ],
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
