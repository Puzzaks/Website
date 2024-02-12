import 'dart:convert';
import 'dart:core';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_website/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const WebMain());
}

class WebMain extends StatefulWidget {
  const WebMain({super.key});
  @override
  WebMainState createState() => WebMainState();
}

class WebMainState extends State<WebMain> {
  @override
  void initState() {
    super.initState();
  }
  static final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal, brightness: Brightness.dark);
  @override
  Widget build(BuildContext topContext) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double scaffoldHeight = constraints.maxHeight;
                double scaffoldWidth = constraints.maxWidth;
                double smallestSize = scaffoldWidth < scaffoldHeight ? scaffoldWidth : scaffoldHeight;
                bool isAlbum = scaffoldWidth > scaffoldHeight;
                return SafeArea(
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Card(
                                clipBehavior: Clip.hardEdge,
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Yo, I am Puzzak!",
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                Text(
                                                  "${(DateTime.now().difference(DateTime.utc(2002, 3, 18)).inDays / 365.25).toStringAsFixed(2)} y.o., ukrainian",
                                                  style: const TextStyle(
                                                      fontSize: 16
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  linkCard(
                                    "Threads",
                                    "Development blog",
                                    "https://threads.net/@puzzaks",
                                    Icon(Icons.format_list_bulleted_rounded),
                                  ),
                                  linkCard(
                                    "GitHub",
                                    "Source code",
                                    "https://github.com/Puzzak",
                                    Icon(Icons.code_rounded),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  linkCard(
                                    "Play Store",
                                    "Published apps",
                                    "https://play.google.com/store/apps/dev?id=8304874346039659820",
                                    Icon(Icons.android_rounded),
                                  ),
                                  linkCard(
                                    "Telegram",
                                    "Personal Blog",
                                    "https://t.me/Puzzaks",
                                    Icon(Icons.mark_unread_chat_alt_rounded),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  linkCard(
                                    "LinkedIn",
                                    "My network",
                                    "https://linkedin.com/in/puzzak",
                                    Icon(Icons.people_outline_rounded),
                                  ),
                                  linkCard(
                                    "Twitter/X",
                                    "Abandoned blog :)",
                                    "https://x.com/puzzaks",
                                    Icon(Icons.rss_feed_rounded),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  linkCard(
                                    "Reddit",
                                    "Follow me",
                                    "https://reddit.com/u/Puzzak",
                                    Icon(Icons.contact_page_rounded),
                                  ),
                                  linkCard(
                                    "Instagram",
                                    "My pics",
                                    "https://instagram.com/puzzaks/",
                                    Icon(Icons.camera_alt_rounded),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  linkCard(
                                    "YouTube",
                                    "Watch me",
                                    "https://youtube.com/@puzzak",
                                    Icon(Icons.video_library_rounded),
                                  ),
                                  linkCard(
                                    "Twitch",
                                    "My streams",
                                    "https://twitch.tv/puzzak",
                                    Icon(Icons.videogame_asset_rounded),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: scaffoldWidth,
                        height: scaffoldHeight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                                padding: EdgeInsets.all(15),
                                child: FutureBuilder(
                                    future: rootBundle.loadString('data/authors.json'),
                                    builder: (BuildContext context, AsyncSnapshot authorsRaw) {
                                      if (authorsRaw.hasData) {
                                        Map authors = jsonDecode(authorsRaw.data);
                                        return Wrap(
                                          spacing: 10.0,
                                          runSpacing: 10.0,
                                          alignment: WrapAlignment.start,
                                          runAlignment: WrapAlignment.start,
                                          verticalDirection: VerticalDirection.up,
                                          children: authors["Authors"][0]["Links"]
                                              .map((option) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    launchUrl(Uri.parse(option["Link"]), mode: LaunchMode.externalApplication);
                                                  },
                                                  child: Chip(
                                                    shadowColor: Colors.transparent,
                                                    // avatar: Icon(
                                                    //     Icons.alternate_email_rounded,
                                                    //     color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black
                                                    // ),
                                                    label: Text(
                                                      option["Title"],
                                                      style: const TextStyle(
                                                        fontFamily: 'Comfortaa',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF040707) : Colors.transparent,
                                                    elevation: 5.0,
                                                    shape: RoundedRectangleBorder(
                                                      side: const BorderSide(
                                                        color: Colors.white, // Border color
                                                        width: 2.0, // Border width
                                                      ),
                                                      borderRadius: BorderRadius.circular(16.0),
                                                    ),
                                                  ),
                                                );
                                              })
                                              .toList()
                                              .cast<Widget>(),
                                        );
                                      }
                                      return Text("Loading");
                                    }))
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}
