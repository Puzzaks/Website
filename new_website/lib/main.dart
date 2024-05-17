import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:new_website/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(const WebMain());
}

class WebMain extends StatefulWidget {
  const WebMain({super.key});
  @override
  WebMainState createState() => WebMainState();
}

class WebMainState extends State<WebMain> {
  int startingTimestamp = DateTime.now().millisecondsSinceEpoch.toInt();
  int currentTimestamp = DateTime.now().millisecondsSinceEpoch.toInt();
  Duration ping = Duration(milliseconds: 0);
  Map telemetry = jsonDecode('{"netspd":{"in":0,"out":0},"time":0.0,"temp":0,"util":0,"memo":{"total":"0","avail":"0"},"uptime":0}');
  getTelemetry(){
    Timer.periodic(Duration(seconds: 1), (timer) async {
      startingTimestamp = DateTime.now().millisecondsSinceEpoch.toInt();
      String endpoint = "api.puzzak.page";
      String method = "AIO.php";
      try {
        final response = await http.get(
          Uri.https(
              endpoint, method
          ),
        );
        currentTimestamp = DateTime.now().millisecondsSinceEpoch.toInt();
        ping = Duration(milliseconds: currentTimestamp - startingTimestamp);
        setState(() {
          telemetry = jsonDecode(response.body);
        });
      } catch (_) {
        jsonDecode('{"netspd":{"in":0,"out":0},"time":0.0,"temp":0,"util":0,"memo":{"total":"0","avail":"0"},"uptime":0}');
      }
    });
  }
  String formatNetworkSpeed(int speed) {
    if (speed < 1024) {
      return '$speed B/s';
    } else if (speed < 10240) {
      double speedKb = speed / 1024;
      return '${speedKb.toStringAsFixed(2)} KB/s';
    } else if (speed < 1048576) {
      double speedKb = speed / 1024;
      return '${speedKb.toStringAsFixed(1)} KB/s';
    } else if (speed < 10485760) {
      double speedMb = speed / 1048576;
      return '${speedMb.toStringAsFixed(2)} MB/s';
    } else if (speed < 104857600) {
      double speedMb = speed / 1048576;
      return '${speedMb.toStringAsFixed(1)} MB/s';
    } else {
      double speedMb = speed / 1048576;
      return '${speedMb.toInt()} MB/s';
    }
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTelemetry();
    });
    super.initState();
  }
  static final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal);
  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.teal, brightness: Brightness.dark);
  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Color.fromRGBO(15, 15, 15, 1),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double scaffoldHeight = constraints.maxHeight;
                double scaffoldWidth = constraints.maxWidth;
                DateTime now = DateTime.now();
                final DateTime birthday = DateTime(2002, 3, 18);
                DateTime nextBirthday = DateTime(now.year, birthday.month, birthday.day);
                int uptimeMilliseconds =
                (currentTimestamp - telemetry["uptime"] * 1000).toInt();
                Duration uptimeDuration = Duration(milliseconds: uptimeMilliseconds);
                DateTime startDate = DateTime.fromMillisecondsSinceEpoch(telemetry["uptime"] * 1000);
                String formatDuration(Duration duration) {
                  String twoDigits(int n) => n.toString().padLeft(2, '0');
                  final days = duration.inDays;
                  final hours = twoDigits(duration.inHours - (days * 24));
                  final minutes = twoDigits(duration.inMinutes.remainder(60));
                  final seconds = twoDigits(duration.inSeconds.remainder(60));

                  return '${DateFormat.yMMMEd().format(startDate)} ${DateFormat.jms().format(startDate)}\n(${days==0?"":"$days days, "}${hours==0?"":"$hours hrs, "}${minutes==0?"":"$minutes min, "}$seconds sec ago)';
                }
                String formattedUptime = formatDuration(uptimeDuration);
                double mempercent = 100 -
                    (int.parse(telemetry["memo"]["avail"]) /
                        int.parse(telemetry["memo"]["total"])) *
                        100;
                int memtotal = int.parse(telemetry["memo"]["total"]);
                int memfree = int.parse(telemetry["memo"]["avail"]);
                int memused = memtotal - memfree;
                if (nextBirthday.isBefore(now) || nextBirthday.isAtSameMomentAs(now)) {
                  nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
                }
                int daysLeft = nextBirthday.difference(now).inDays;
                int age = (now.difference(birthday).inDays / 365.25).floor();

                if(scaffoldWidth < 715){
                  return SafeArea(
                    child: SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              headerLine("About", 2, scaffoldWidth-30),
                              Container(
                                width: scaffoldWidth,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Card(
                                    color: Color.fromRGBO(29, 27, 32, 1),
                                    clipBehavior: Clip.hardEdge,
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 15, right: 20),
                                            child: Icon(Icons.person_outline_rounded),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Yo, I am Puzzak!",
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              Text(
                                                "Welcome to my website!",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: scaffoldWidth,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Card(
                                    color: Color.fromRGBO(29, 27, 32, 1),
                                    clipBehavior: Clip.hardEdge,
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 15, right: 20),
                                            child: Icon(Icons.cake_rounded),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "I'm ${(DateTime.now().difference(DateTime.utc(2002, 3, 18)).inDays / 365.25).toStringAsFixed(2)} y.o.",
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              Text(
                                                "$daysLeft days left till I'm ${age + 1}.",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              headerLine("Telemetry", 2, scaffoldWidth-30),
                              Container(
                                width: scaffoldWidth,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Card(
                                    color: Color.fromRGBO(29, 27, 32, 1),
                                    clipBehavior: Clip.hardEdge,
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 15, right: 20),
                                            child: Icon(Icons.timer_outlined),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Booted ${formattedUptime.split("\n(")[1].split(")")[0]}",
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              Text(
                                                "Since ${formattedUptime.split("\n")[0]}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: scaffoldWidth,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Card(
                                    color: Color.fromRGBO(29, 27, 32, 1),
                                    clipBehavior: Clip.hardEdge,
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 15, right: 20),
                                            child: Icon(Icons.network_check_rounded),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Network speed",
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              Container(
                                                width: scaffoldWidth-107,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: (scaffoldWidth-107)/3,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Icon(Icons.download_rounded),
                                                          Text(
                                                            formatNetworkSpeed(telemetry["netspd"]["in"]),
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                        width: (scaffoldWidth-107)/3,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Icon(Icons.upload_rounded),
                                                            Text(
                                                              formatNetworkSpeed(telemetry["netspd"]["out"]),
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                    ),
                                                    Container(
                                                        width: (scaffoldWidth-107)/3,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Icon(Icons.network_ping_rounded),
                                                            Text(
                                                              "${ping.inMilliseconds.toInt()} ms",
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: scaffoldWidth/2,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 10, right: 0),
                                      child: Card(
                                        color: Color.fromRGBO(29, 27, 32, 1),
                                        clipBehavior: Clip.hardEdge,
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(left: 15, right: 20),
                                                child: Icon(Icons.developer_board),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "CPU load",
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  Text(
                                                    "${telemetry["util"].toStringAsFixed(2)}%",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: scaffoldWidth/2,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 0, right: 10),
                                      child: Card(
                                        color: Color.fromRGBO(29, 27, 32, 1),
                                        clipBehavior: Clip.hardEdge,
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(left: 15, right: 20),
                                                child: Icon(Icons.thermostat_rounded),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "CPU temp",
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  Text(
                                                    "${telemetry["temp"].toStringAsFixed(2)}°",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              headerLine("Links", 11, scaffoldWidth-30),
                              linkCard(
                                  "Threads",
                                  "Follow my apps development",
                                  "https://threads.net/@puzzaks",
                                  Icon(Icons.format_list_bulleted_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "GitHub",
                                  "Check out my source code",
                                  "https://github.com/Puzzak",
                                  Icon(Icons.code_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Play Store",
                                  "Try out my apps",
                                  "https://play.google.com/store/apps/dev?id=8304874346039659820",
                                  Icon(Icons.android_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Telegram",
                                  "Read my personal blog",
                                  "https://t.me/Puzzaks",
                                  Icon(Icons.mark_unread_chat_alt_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "LinkedIn",
                                  "Connect with my network",
                                  "https://linkedin.com/in/puzzak",
                                  Icon(Icons.people_outline_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Twitter/X",
                                  "Abandoned blog, nevermind",
                                  "https://x.com/puzzaks",
                                  Icon(Icons.rss_feed_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Reddit",
                                  "Upvote my posts",
                                  "https://reddit.com/u/Puzzak",
                                  Icon(Icons.contact_page_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Instagram",
                                  "Look at my photography",
                                  "https://instagram.com/puzzaks/",
                                  Icon(Icons.camera_alt_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "YouTube",
                                  "Watch my videos",
                                  "https://youtube.com/@puzzak",
                                  Icon(Icons.video_library_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Twitch",
                                  "Join my streams  ",
                                  "https://twitch.tv/puzzak",
                                  Icon(Icons.videogame_asset_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Privacy policy",
                                  "Read how we handle your data",
                                  "https://stories.puzzak.page/privacy_policy.html",
                                  Icon(Icons.privacy_tip_outlined),
                                  scaffoldWidth
                              ),
                              headerLine("Projects", 3, scaffoldWidth-30),
                              Container(
                                width: scaffoldWidth,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(left:15),
                                          child: projectCard(
                                              Image.asset(
                                                  "assets/autostream-project.png",
                                                  width:350
                                              ),
                                              "Autostreaming project",
                                              "Real-time software-generated videofeed, using FFMPEG on Raspberry Pi with 96.66% uptime.",
                                              "https://stories.puzzak.page/autostream.html"
                                          )),
                                      projectCard(
                                          Image.asset(
                                              "assets/dashboard-project.png",
                                              width:350
                                          ),
                                          "Dashboard",
                                          "Statuses, telemetry, data I use and a bit more - open to the world, free to use.",
                                          "https://link.puzzak.page/?dashboard"
                                      ),
                                      projectCard(
                                          Image.asset(
                                              "assets/links-project.png",
                                              width:350
                                          ),
                                          "Link shortener",
                                          "Simple link shortener with statistics. Yes, available for everyone.",
                                          "https://link.puzzak.page/?dashboard"
                                      ),
                                    ],
                                  ),
                                ),
                              )

                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }else if(scaffoldWidth < 1075){
                  return SafeArea(
                    child: SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              headerLine("About", 2),
                              Row(
                                children: [
                                  Container(
                                    width: 350,
                                    child: Card(
                                      color: Color.fromRGBO(29, 27, 32, 1),
                                      clipBehavior: Clip.hardEdge,
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 15, right: 20),
                                              child: Icon(Icons.person_outline_rounded),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Yo, I am Puzzak!",
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                Text(
                                                  "Welcome to my website!",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 350,
                                    child: Card(
                                      color: Color.fromRGBO(29, 27, 32, 1),
                                      clipBehavior: Clip.hardEdge,
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 15, right: 20),
                                              child: Icon(Icons.cake_rounded),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${(DateTime.now().difference(DateTime.utc(2002, 3, 18)).inDays / 365.25).toStringAsFixed(2)} y.o.",
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                Text(
                                                  "$daysLeft days left till I'm ${age + 1}.",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              headerLine("Links", 11),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  linkCard(
                                    "Threads",
                                    "Follow my apps development",
                                    "https://threads.net/@puzzaks",
                                    Icon(Icons.format_list_bulleted_rounded),
                                  ),
                                  linkCard(
                                    "GitHub",
                                    "Check out my source code",
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
                                    "Try out my apps",
                                    "https://play.google.com/store/apps/dev?id=8304874346039659820",
                                    Icon(Icons.android_rounded),
                                  ),
                                  linkCard(
                                    "Telegram",
                                    "Read my personal blog",
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
                                    "Connect with my network",
                                    "https://linkedin.com/in/puzzak",
                                    Icon(Icons.people_outline_rounded),
                                  ),
                                  linkCard(
                                    "Twitter/X",
                                    "Abandoned blog, nevermind",
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
                                    "Upvote my posts",
                                    "https://reddit.com/u/Puzzak",
                                    Icon(Icons.contact_page_rounded),
                                  ),
                                  linkCard(
                                    "Instagram",
                                    "Look at my photography",
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
                                    "Watch my videos",
                                    "https://youtube.com/@puzzak",
                                    Icon(Icons.video_library_rounded),
                                  ),
                                  linkCard(
                                    "Twitch",
                                    "Join my streams  ",
                                    "https://twitch.tv/puzzak",
                                    Icon(Icons.videogame_asset_rounded),
                                  ),
                                ],
                              ),
                              linkCard(
                                  "Privacy policy",
                                  "Read how we handle your data",
                                  "https://stories.puzzak.page/privacy_policy.html",
                                  Icon(Icons.privacy_tip_outlined),
                                  700
                              ),
                              headerLine("Projects", 3),
                              Container(
                                width: 700,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      projectCard(
                                          Image.asset(
                                              "assets/autostream-project.png",
                                              width:350
                                          ),
                                          "Autostreaming project",
                                          "Real-time software-generated videofeed, using FFMPEG on Raspberry Pi with 96.66% uptime.",
                                          "https://stories.puzzak.page/autostream.html"
                                      ),
                                      projectCard(
                                          Image.asset(
                                              "assets/dashboard-project.png",
                                              width:350
                                          ),
                                          "Dashboard",
                                          "Statuses, telemetry, data I use and a bit more - open to the world, free to use.",
                                          "https://link.puzzak.page/?dashboard"
                                      ),
                                      projectCard(
                                          Image.asset(
                                              "assets/links-project.png",
                                              width:350
                                          ),
                                          "Link shortener",
                                          "Simple link shortener with statistics. Yes, available for everyone.",
                                          "https://link.puzzak.page/?dashboard"
                                      ),
                                    ],
                                  ),
                                ),
                              )

                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SafeArea(
                  child: SingleChildScrollView(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: scaffoldHeight,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                headerLine("About", 2),
                                Row(
                                  children: [
                                    Container(
                                      width: 350,
                                      child: Card(
                                        color: Color.fromRGBO(29, 27, 32, 1),
                                        clipBehavior: Clip.hardEdge,
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(left: 15, right: 20),
                                                child: Icon(Icons.person_outline_rounded),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Yo, I am Puzzak!",
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  Text(
                                                    "Welcome to my website!",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 350,
                                      child: Card(
                                        color: Color.fromRGBO(29, 27, 32, 1),
                                        clipBehavior: Clip.hardEdge,
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(left: 15, right: 20),
                                                child: Icon(Icons.cake_rounded),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${(DateTime.now().difference(DateTime.utc(2002, 3, 18)).inDays / 365.25).toStringAsFixed(2)} y.o.",
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  Text(
                                                    "$daysLeft days left till I'm ${age + 1}.",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                headerLine("Links", 11),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    linkCard(
                                      "Threads",
                                      "Follow my apps development",
                                      "https://threads.net/@puzzaks",
                                      Icon(Icons.format_list_bulleted_rounded),
                                    ),
                                    linkCard(
                                      "GitHub",
                                      "Check out my source code",
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
                                      "Try out my apps",
                                      "https://play.google.com/store/apps/dev?id=8304874346039659820",
                                      Icon(Icons.android_rounded),
                                    ),
                                    linkCard(
                                      "Telegram",
                                      "Read my personal blog",
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
                                      "Connect with my network",
                                      "https://linkedin.com/in/puzzak",
                                      Icon(Icons.people_outline_rounded),
                                    ),
                                    linkCard(
                                      "Twitter/X",
                                      "Abandoned blog, nevermind",
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
                                      "Upvote my posts",
                                      "https://reddit.com/u/Puzzak",
                                      Icon(Icons.contact_page_rounded),
                                    ),
                                    linkCard(
                                      "Instagram",
                                      "Look at my photography",
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
                                      "Watch my videos",
                                      "https://youtube.com/@puzzak",
                                      Icon(Icons.video_library_rounded),
                                    ),
                                    linkCard(
                                      "Twitch",
                                      "Join my streams  ",
                                      "https://twitch.tv/puzzak",
                                      Icon(Icons.videogame_asset_rounded),
                                    ),
                                  ],
                                ),
                                linkCard(
                                    "Privacy policy",
                                    "Read how we handle your data",
                                    "https://stories.puzzak.page/privacy_policy.html",
                                    Icon(Icons.privacy_tip_outlined),
                                    700
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 350,
                          height: scaffoldHeight,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                headerLine("Projects", 3),
                                projectCard(
                                    Image.asset(
                                        "assets/autostream-project.png",
                                        width:350
                                    ),
                                    "Autostreaming project",
                                    "Real-time software-generated videofeed, using FFMPEG on Raspberry Pi with 96.66% uptime.",
                                    "https://stories.puzzak.page/autostream.html"
                                ),
                                projectCard(
                                    Image.asset(
                                        "assets/dashboard-project.png",
                                        width:350
                                    ),
                                    "Dashboard",
                                    "Statuses, telemetry, data I use and a bit more - open to the world, free to use.",
                                    "https://link.puzzak.page/?dashboard"
                                ),
                                projectCard(
                                    Image.asset(
                                        "assets/links-project.png",
                                        width:350
                                    ),
                                    "Link shortener",
                                    "Simple link shortener with statistics. Yes, available for everyone.",
                                    "https://link.puzzak.page/?dashboard"
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
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
