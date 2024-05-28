import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:new_website/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:system_theme/system_theme.dart';
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
  int startingTimestamp = DateTime.now().millisecondsSinceEpoch.toInt();
  int currentTimestamp = DateTime.now().millisecondsSinceEpoch.toInt();
  Duration ping = const Duration(milliseconds: 0);
  Map telemetry = jsonDecode('{"netspd":{"in":0,"out":0},"time":0.0,"temp":0,"util":0,"memo":{"total":"0","avail":"0"},"uptime":0}');
  Map rusnya = {};
  getTelemetryTimer(){
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      getTelemetry();
    });
  }
  getTelemetry() async {
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
        telemetry = jsonDecode('{"netspd":{"in":0,"out":0},"time":0.0,"temp":0,"util":0,"memo":{"total":"1","avail":"1"},"uptime":0}');
      }
  }
  getRusnyaTimer(){
    Timer.periodic(const Duration(minutes: 10), (timer) async {
      getRusnya();
    });
  }
  getRusnya() async {
      String endpoint = "russianwarship.rip";
      String method = "api/v2/statistics/latest";
      final response = await http.get(
        Uri.https(
            endpoint, method
        ),
      );
      setState(() {
        rusnya = jsonDecode(response.body)["data"]["stats"];
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
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTelemetry();
      getRusnya();
      getTelemetryTimer();
      getRusnyaTimer();
    });
  }
  static final _defaultLightColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.teal,
      backgroundColor: Colors.teal
  );
  ThemeMode mode = ThemeMode.system;
  final MaterialStateProperty<Icon?> thumbIcon = MaterialStateProperty.resolveWith<Icon?>(
        (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.dark_mode_rounded);
      }
      return const Icon(Icons.light_mode_rounded);
    },
  );
  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.teal,
      brightness: Brightness.dark,
      backgroundColor: Color.fromRGBO(29, 27, 32, 1),
  );
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: "Puzzak's",
        theme: ThemeData(
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
          useMaterial3: true,
        ),
        themeMode: mode,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double scaffoldHeight = constraints.maxHeight;
                double scaffoldWidth = constraints.maxWidth;
                DateTime now = DateTime.now();
                final DateTime birthday = DateTime(2002, 3, 18);
                DateTime nextBirthday = DateTime(now.year, birthday.month, birthday.day);
                DateTime remoteTime = DateTime.fromMillisecondsSinceEpoch((telemetry["time"] * 1000).toInt());
                DateTime startDate = DateTime.fromMillisecondsSinceEpoch((telemetry["uptime"] * 1000).toInt()).subtract(remoteTime.timeZoneOffset);
                Duration uptimeDuration = remoteTime.difference(startDate);
                String formatDuration(Duration duration) {
                  String twoDigits(int n) => n.toString().padLeft(2, '0');
                  final days = duration.inDays;
                  final hours = twoDigits(duration.inHours - (days * 24));
                  final minutes = twoDigits(duration.inMinutes.remainder(60));
                  final seconds = twoDigits(duration.inSeconds.remainder(60));

                  return '${DateFormat.yMMMEd().format(startDate)} ${DateFormat.jms().format(startDate)}\n(${days==0?"":"$days days, "}${hours=="00"?"":"$hours hrs, "}${minutes=="00"?"":"$minutes min, "}$seconds sec ago)';
                }
                String formattedUptime = formatDuration(uptimeDuration);
                double mempercent = 0;
                if(!(telemetry["memo"]["avail"]=="0" && telemetry["memo"]["total"]=="0")){
                  mempercent = 100 - (int.parse(telemetry["memo"]["avail"]) / int.parse(telemetry["memo"]["total"])) * 100;
                }
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
                              headerLine("About", 3, mode == ThemeMode.dark?Colors.teal:Colors.white, scaffoldWidth-30),
                              Container(
                                width: scaffoldWidth,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Card(
                                    clipBehavior: Clip.hardEdge,
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 15, right: 20),
                                            child: Icon(Icons.person_rounded),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Yo, I am Puzzak!",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              Text(
                                                "Welcome to my website!",
                                                style: TextStyle(
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
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Card(
                                    clipBehavior: Clip.hardEdge,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const Padding(
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
                              Container(
                                width: scaffoldWidth,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Card(
                                    clipBehavior: Clip.hardEdge,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(left: 15, right: 20),
                                                  child: Icon(Icons.contrast),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Enable Dark Mode",
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                    Text(
                                                      mode == ThemeMode.system?"Adjusted to your system now":mode == ThemeMode.light?"Switched to Light Mode now":"Switched to Dark Mode now",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ]
                                          ),
                                          Switch(
                                            thumbIcon: thumbIcon,
                                            value: mode == ThemeMode.dark,
                                            inactiveThumbColor: Colors.teal,
                                            activeColor: Colors.teal,
                                            inactiveTrackColor: Color.fromRGBO(29, 27, 32, 1),
                                            onChanged: (bool value) {
                                              setState(() {
                                                if(mode == ThemeMode.dark){
                                                  mode = ThemeMode.light;
                                                }else{
                                                  mode = ThemeMode.dark;
                                                }
                                              });
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              headerLine("Telemetry", telemetry["uptime"] == 0?1:7, mode == ThemeMode.dark?Colors.teal:Colors.white, scaffoldWidth-30),
                              telemetry["uptime"] == 0?Container(
                                width: scaffoldWidth,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Card(
                                      color: Theme.of(context).colorScheme.errorContainer,
                                      clipBehavior: Clip.hardEdge,
                                      child: ExpansionTileTheme(
                                          data: const ExpansionTileThemeData(tilePadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15)),
                                          child: Theme(
                                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                              child: ExpansionTile(
                                                leading: Icon(Icons.error_outline_rounded),
                                                iconColor: Theme.of(context).textTheme.bodyMedium?.color,
                                                title: Text(
                                                  "Disconnected from the server!",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "Server is offline, expand to read more.",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
                                                    child: Container(
                                                      width: scaffoldWidth,
                                                      child: Text(
                                                        "We're currently unable to connect to the server. This is likely due to recent russian terroristic bombardments on Ukraine's social infrastructure.\nYou can learn more about how YOU can help Ukraine or just check server status in Telegram using button below.",
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        TextButton(
                                                            onPressed: (){
                                                              launchUrl(Uri.parse("https://t.me/PuzzakServer"), mode: LaunchMode.externalApplication);
                                                            },
                                                            child: Text(
                                                              "Server Status",
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Theme.of(context).textTheme.bodyMedium?.color
                                                              ),
                                                            )
                                                        ),
                                                        TextButton(
                                                            onPressed: (){
                                                              launchUrl(Uri.parse("https://war.ukraine.ua/support-ukraine/"), mode: LaunchMode.externalApplication);
                                                            },
                                                            child: Text(
                                                              "Help Ukraine",
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Theme.of(context).textTheme.bodyMedium?.color
                                                              ),
                                                            )
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )))
                                  ),
                                ),
                              ):
                              Column(
                                children: [
                                  Container(
                                    width: scaffoldWidth,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Card(
                                        clipBehavior: Clip.hardEdge,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(left: 15, right: 20),
                                                child: Icon(Icons.timer_outlined),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Booted ${formattedUptime.split("\n(")[1].split(")")[0]}",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  Text(
                                                    "Since ${formattedUptime.split("\n")[0]}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: scaffoldWidth/2,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 0),
                                          child: Card(
                                            clipBehavior: Clip.hardEdge,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(2.5),
                                                        child: CircularProgressIndicator(
                                                          value: telemetry["netspd"]["in"]/125000000,
                                                          backgroundColor: Colors.transparent,
                                                          strokeCap: StrokeCap.round,
                                                          color: Theme.of(context).colorScheme.primary,
                                                        ),
                                                      ),
                                                      const Padding(
                                                        padding: EdgeInsets.all(8.5),
                                                        child: Icon(Icons.download_rounded),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(width: 10,),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        "Download",
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      Text(
                                                        formatNetworkSpeed(telemetry["netspd"]["in"]),
                                                        style: const TextStyle(
                                                          fontSize: 14,
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
                                          padding: const EdgeInsets.only(left: 0, right: 10),
                                          child: Card(
                                            clipBehavior: Clip.hardEdge,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(2.5),
                                                        child: CircularProgressIndicator(
                                                          value: telemetry["netspd"]["out"]/125000000,
                                                          backgroundColor: Colors.transparent,
                                                          strokeCap: StrokeCap.round,
                                                          color: Theme.of(context).colorScheme.primary,
                                                        ),
                                                      ),
                                                      const Padding(
                                                        padding: EdgeInsets.all(8.5),
                                                        child: Icon(Icons.upload_rounded),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(width: 10,),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        "Upload",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      Text(
                                                        formatNetworkSpeed(telemetry["netspd"]["out"]),
                                                        style: const TextStyle(
                                                          fontSize: 14,
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
                                  Row(
                                    children: [
                                      Container(
                                        width: scaffoldWidth/2,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 0),
                                          child: Card(
                                            clipBehavior: Clip.hardEdge,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(2.5),
                                                        child: CircularProgressIndicator(
                                                          value: telemetry["util"]/100,
                                                          backgroundColor: Colors.transparent,
                                                          strokeCap: StrokeCap.round,
                                                          color: Theme.of(context).colorScheme.primary,
                                                        ),
                                                      ),
                                                      const Padding(
                                                        padding: EdgeInsets.all(8.5),
                                                        child: Icon(Icons.developer_board),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(width: 10,),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        "CPU Load",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      Text(
                                                        "${telemetry["util"].toStringAsFixed(2)}%",
                                                        style: const TextStyle(
                                                          fontSize: 14,
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
                                          padding: const EdgeInsets.only(left: 0, right: 10),
                                          child: Card(
                                            clipBehavior: Clip.hardEdge,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(2),
                                                        child: CircularProgressIndicator(
                                                          value: (telemetry["temp"] - 20)/60,
                                                          backgroundColor: Colors.transparent,
                                                          strokeCap: StrokeCap.round,
                                                          color: Theme.of(context).colorScheme.primary,
                                                        ),
                                                      ),
                                                      const Padding(
                                                        padding: EdgeInsets.all(8.5),
                                                        child: Icon(Icons.thermostat_rounded),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(width: 10,),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        "CPU Temp",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      Text(
                                                        "${telemetry["temp"].toStringAsFixed(2)}°",
                                                        style: const TextStyle(
                                                          fontSize: 14,
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
                                  Row(
                                    children: [
                                      Container(
                                        width: (scaffoldWidth/5)*3,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Card(
                                            clipBehavior: Clip.hardEdge,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(2.5),
                                                        child: CircularProgressIndicator(
                                                          value: mempercent/100,
                                                          backgroundColor: Colors.transparent,
                                                          strokeCap: StrokeCap.round,
                                                          color: Theme.of(context).colorScheme.primary,
                                                        ),
                                                      ),
                                                      const Padding(
                                                        padding: EdgeInsets.all(8.5),
                                                        child: Icon(Icons.memory),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(width: 10,),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        "RAM Usage",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      Text(
                                                        "${((memtotal - memfree) / 1000000).toStringAsFixed(2)}/${(memtotal / 1000000).toStringAsFixed(2)}GB (${mempercent.toStringAsFixed(2)}%)",
                                                        style: const TextStyle(
                                                          fontSize: 14,
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
                                        width: (scaffoldWidth/5)*2,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 0, right: 10),
                                          child: Card(
                                            clipBehavior: Clip.hardEdge,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(2),
                                                        child: CircularProgressIndicator(
                                                          value: ping.inMilliseconds/1000,
                                                          backgroundColor: Colors.transparent,
                                                          strokeCap: StrokeCap.round,
                                                          color: Theme.of(context).colorScheme.primary,
                                                        ),
                                                      ),
                                                      const Padding(
                                                        padding: EdgeInsets.all(8.5),
                                                        child: Icon(Icons.network_ping_rounded),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(width: 10,),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        "Ping",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      Text(
                                                        "${ping.inMilliseconds.toInt()} ms",
                                                        style: const TextStyle(
                                                          fontSize: 14,
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
                                ],
                              ),
                              headerLine("Russian Casualties", rusnya.isEmpty?1:15, mode == ThemeMode.dark?Colors.teal:Colors.white, scaffoldWidth-30),
                              rusnya.isEmpty?Container(
                                width: scaffoldWidth,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Card(
                                      clipBehavior: Clip.hardEdge,
                                      child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child:Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.only(left:10, right:15),
                                                    child:Icon(Icons.cloud_download_rounded)
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Loading casualties",
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      Text(
                                                        "Hold on, loading russian casualties data.",
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ]
                                                )
                                              ]
                                          )
                                      )
                                  ),
                                ),
                              ):
                              Column(
                                children: [
                                  rusnyaCard(
                                      "Personnel",
                                      rusnya["personnel_units"],
                                      "Personnel",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "Tanks",
                                      rusnya["tanks"],
                                      "tanks",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "Armored",
                                      rusnya["armoured_fighting_vehicles"],
                                      "armored",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "Artillery",
                                      rusnya["artillery_systems"],
                                      "Cannons",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "MLRS",
                                      rusnya["mlrs"],
                                      "Mlrs",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "Anti-Air",
                                      rusnya["aa_warfare_systems"],
                                      "aa",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "Spec Vehicles",
                                      rusnya["special_military_equip"],
                                      "equipment",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "Planes",
                                      rusnya["planes"],
                                      "planes",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "Helicopters",
                                      rusnya["helicopters"],
                                      "helicopters",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "Fuel Tanks",
                                      rusnya["vehicles_fuel_tanks"],
                                      "cars",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "Ships",
                                      rusnya["warships_cutters"],
                                      "Ships",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "Missiles",
                                      rusnya["cruise_missiles"],
                                      "missiles",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "UAVs",
                                      rusnya["uav_systems"],
                                      "uav",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "ATGMs & SRBMs",
                                      rusnya["atgm_srbm_systems"],
                                      "atgms",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                  rusnyaCard(
                                      "Submarines",
                                      rusnya["submarines"],
                                      "submarine",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      scaffoldWidth
                                  ),
                                ],
                              ),
                              headerLine("Links", 11, mode == ThemeMode.dark?Colors.teal:Colors.white, scaffoldWidth-30),
                              linkCard(
                                  "Threads",
                                  "Follow my apps development",
                                  "https://threads.net/@puzzaks",
                                  const Icon(Icons.format_list_bulleted_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "GitHub",
                                  "Check out my source code",
                                  "https://github.com/Puzzak",
                                  const Icon(Icons.code_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Play Store",
                                  "Try out my apps",
                                  "https://play.google.com/store/apps/dev?id=8304874346039659820",
                                  const Icon(Icons.android_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Telegram",
                                  "Read my personal blog",
                                  "https://t.me/Puzzaks",
                                  const Icon(Icons.mark_unread_chat_alt_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "LinkedIn",
                                  "Connect with my network",
                                  "https://linkedin.com/in/puzzak",
                                  const Icon(Icons.people_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Twitter/X",
                                  "Abandoned blog, nevermind",
                                  "https://x.com/puzzaks",
                                  const Icon(Icons.rss_feed_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Reddit",
                                  "Upvote my posts",
                                  "https://reddit.com/u/Puzzak",
                                  const Icon(Icons.contact_page_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Instagram",
                                  "Look at my photography",
                                  "https://instagram.com/puzzaks/",
                                  const Icon(Icons.camera_alt_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "YouTube",
                                  "Watch my videos",
                                  "https://youtube.com/@puzzak",
                                  const Icon(Icons.video_library_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Twitch",
                                  "Join my streams  ",
                                  "https://twitch.tv/puzzak",
                                  const Icon(Icons.videogame_asset_rounded),
                                  scaffoldWidth
                              ),
                              linkCard(
                                  "Privacy policy",
                                  "Read how we handle your data",
                                  "https://stories.puzzak.page/privacy_policy.html",
                                  const Icon(Icons.privacy_tip_outlined),
                                  scaffoldWidth
                              ),
                              headerLine("Projects", 3, mode == ThemeMode.dark?Colors.teal:Colors.white, scaffoldWidth-30),
                              Container(
                                width: scaffoldWidth,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(left:15),
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
                              headerLine("About", 3, mode == ThemeMode.dark?Colors.teal:Colors.white),
                              Row(
                                children: [
                                  Container(
                                    width: 350,
                                    child: const Card(
                                      clipBehavior: Clip.hardEdge,
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 15, right: 20),
                                              child: Icon(Icons.person_rounded),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Yo, I am Puzzak!",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                Text(
                                                  "Welcome to my website!",
                                                  style: TextStyle(
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
                                      clipBehavior: Clip.hardEdge,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            const Padding(
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
                                  )
                                ],
                              ),
                              Container(
                                width: 700,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                  child: Card(
                                    clipBehavior: Clip.hardEdge,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(left: 15, right: 20),
                                                  child: Icon(Icons.contrast),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Enable Dark Mode",
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                    Text(
                                                      mode == ThemeMode.system?"Adjusted to your system now":mode == ThemeMode.light?"Switched to Light Mode now":"Switched to Dark Mode now",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ]
                                          ),
                                          Switch(
                                            thumbIcon: thumbIcon,
                                            value: mode == ThemeMode.dark,
                                            inactiveThumbColor: Colors.teal,
                                            activeColor: Colors.teal,
                                            inactiveTrackColor: Color.fromRGBO(29, 27, 32, 1),
                                            onChanged: (bool value) {
                                              setState(() {
                                                if(mode == ThemeMode.dark){
                                                  mode = ThemeMode.light;
                                                }else{
                                                  mode = ThemeMode.dark;
                                                }
                                              });
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              headerLine("Telemetry", telemetry["uptime"] == 0?1:7, mode == ThemeMode.dark?Colors.teal:Colors.white),
                              telemetry["uptime"] == 0?Container(
                                width: 700,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                  child: Card(
                                      color: Theme.of(context).colorScheme.errorContainer,
                                      clipBehavior: Clip.hardEdge,
                                      child: ExpansionTileTheme(
                                          data: const ExpansionTileThemeData(tilePadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15)),
                                          child: Theme(
                                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                              child: ExpansionTile(
                                                leading: Icon(Icons.error_outline_rounded),
                                                iconColor: Theme.of(context).textTheme.bodyMedium?.color,
                                                title: Text(
                                                  "Disconnected from the server!",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "Server is offline, expand to read more.",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
                                                    child: Container(
                                                      width: scaffoldWidth,
                                                      child: Text(
                                                        "We're currently unable to connect to the server. This is likely due to recent russian terroristic bombardments on Ukraine's social infrastructure.\nYou can learn more about how YOU can help Ukraine or just check server status in Telegram using button below.",
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        TextButton(
                                                            onPressed: (){
                                                              launchUrl(Uri.parse("https://t.me/PuzzakServer"), mode: LaunchMode.externalApplication);
                                                            },
                                                            child: Text(
                                                              "Server Status",
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Theme.of(context).textTheme.bodyMedium?.color
                                                              ),
                                                            )
                                                        ),
                                                        TextButton(
                                                            onPressed: (){
                                                              launchUrl(Uri.parse("https://war.ukraine.ua/support-ukraine/"), mode: LaunchMode.externalApplication);
                                                            },
                                                            child: Text(
                                                              "Help Ukraine",
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Theme.of(context).textTheme.bodyMedium?.color
                                                              ),
                                                            )
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )))
                                  ),
                                ),
                              ):
                                  Column(
                                      children: [
                                        Container(
                                          width: 700,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 0),
                                            child: Card(
                                              clipBehavior: Clip.hardEdge,
                                              child: Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    const Padding(
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
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 700/3,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 0, right: 0),
                                                child: Card(
                                                  clipBehavior: Clip.hardEdge,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.all(2.5),
                                                              child: CircularProgressIndicator(
                                                                value: telemetry["netspd"]["in"]/125000000,
                                                                backgroundColor: Colors.transparent,
                                                                strokeCap: StrokeCap.round,
                                                                color: Theme.of(context).colorScheme.primary,
                                                              ),
                                                            ),
                                                            const Padding(
                                                              padding: EdgeInsets.all(8.5),
                                                              child: Icon(Icons.download_rounded),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(width: 10,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                              "Download",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold
                                                              ),
                                                            ),
                                                            Text(
                                                              formatNetworkSpeed(telemetry["netspd"]["in"]),
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
                                              width: 700/3,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 0, right: 0),
                                                child: Card(
                                                  clipBehavior: Clip.hardEdge,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.all(2.5),
                                                              child: CircularProgressIndicator(
                                                                value: telemetry["netspd"]["out"]/125000000,
                                                                backgroundColor: Colors.transparent,
                                                                strokeCap: StrokeCap.round,
                                                                color: Theme.of(context).colorScheme.primary,
                                                              ),
                                                            ),
                                                            const Padding(
                                                              padding: EdgeInsets.all(8.5),
                                                              child: Icon(Icons.upload_rounded),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(width: 10,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                              "Upload",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold
                                                              ),
                                                            ),
                                                            Text(
                                                              formatNetworkSpeed(telemetry["netspd"]["out"]),
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
                                              width: 700/3,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 0, right: 0),
                                                child: Card(
                                                  clipBehavior: Clip.hardEdge,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.all(2),
                                                              child: CircularProgressIndicator(
                                                                value: ping.inMilliseconds/1000,
                                                                backgroundColor: Colors.transparent,
                                                                strokeCap: StrokeCap.round,
                                                                color: Theme.of(context).colorScheme.primary,
                                                              ),
                                                            ),
                                                            const Padding(
                                                              padding: EdgeInsets.all(8.5),
                                                              child: Icon(Icons.network_ping_rounded),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(width: 10,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                              "Ping",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold
                                                              ),
                                                            ),
                                                            Text(
                                                              "${ping.inMilliseconds.toInt()} ms",
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
                                        Row(
                                          children: [
                                            Container(
                                              width: 700/3,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 0, right: 0),
                                                child: Card(
                                                  clipBehavior: Clip.hardEdge,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.all(2.5),
                                                              child: CircularProgressIndicator(
                                                                value: telemetry["util"]/100,
                                                                backgroundColor: Colors.transparent,
                                                                strokeCap: StrokeCap.round,
                                                                color: Theme.of(context).colorScheme.primary,
                                                              ),
                                                            ),
                                                            const Padding(
                                                              padding: EdgeInsets.all(8.5),
                                                              child: Icon(Icons.developer_board),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(width: 10,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                              "CPU Load",
                                                              style: TextStyle(
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
                                              width: 700/3,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 0, right: 0),
                                                child: Card(
                                                  clipBehavior: Clip.hardEdge,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.all(2),
                                                              child: CircularProgressIndicator(
                                                                value: (telemetry["temp"] - 20)/60,
                                                                backgroundColor: Colors.transparent,
                                                                strokeCap: StrokeCap.round,
                                                                color: Theme.of(context).colorScheme.primary,
                                                              ),
                                                            ),
                                                            const Padding(
                                                              padding: EdgeInsets.all(8.5),
                                                              child: Icon(Icons.thermostat_rounded),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(width: 10,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                              "CPU Temperature",
                                                              style: TextStyle(
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
                                            Container(
                                              width: 700/3,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                                child: Card(
                                                  clipBehavior: Clip.hardEdge,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.all(2),
                                                              child: CircularProgressIndicator(
                                                                value: mempercent/100,
                                                                backgroundColor: Colors.transparent,
                                                                strokeCap: StrokeCap.round,
                                                                color: Theme.of(context).colorScheme.primary,
                                                              ),
                                                            ),
                                                            const Padding(
                                                              padding: EdgeInsets.all(8.5),
                                                              child: Icon(Icons.memory),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(width: 10,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            const Text(
                                                              "RAM Usage",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold
                                                              ),
                                                            ),
                                                            Text(
                                                                "${((memtotal - memfree) / 1000000).toStringAsFixed(2)}/${(memtotal / 1000000).toStringAsFixed(2)}GB (${mempercent.toStringAsFixed(2)}%)"
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                  ),
                              headerLine("Russian Casualties", rusnya.isEmpty?1:15, mode == ThemeMode.dark?Colors.teal:Colors.white),
                              rusnya.isEmpty?Container(
                                width: 700,
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Card(
                                      clipBehavior: Clip.hardEdge,
                                      child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child:Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.only(left:10, right:15),
                                                    child:Icon(Icons.cloud_download_rounded)
                                                ),
                                                Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Loading casualties",
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      Text(
                                                        "Hold on, loading russian casualties data.",
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ]
                                                )
                                              ]
                                          )
                                      )
                                  ),
                                ),
                              ):
                              Column(
                                children: [
                                  rusnyaCard(
                                      "Personnel",
                                      rusnya["personnel_units"],
                                      "Personnel",
                                      Theme.of(context).textTheme.bodyMedium?.color,
                                      700
                                  ),
                                  Row(
                                      children: [
                                        rusnyaCard(
                                            "Missiles",
                                            rusnya["cruise_missiles"],
                                            "missiles",
                                            Theme.of(context).textTheme.bodyMedium?.color,
                                            350
                                        ),
                                        rusnyaCard(
                                            "UAVs",
                                            rusnya["uav_systems"],
                                            "uav",
                                            Theme.of(context).textTheme.bodyMedium?.color,
                                            350
                                        ),
                                    ]
                                  ),
                                  Row(
                                      children: [
                                        rusnyaCard(
                                            "Tanks",
                                            rusnya["tanks"],
                                            "tanks",
                                            Theme.of(context).textTheme.bodyMedium?.color,
                                            350
                                        ),
                                        rusnyaCard(
                                            "Armored",
                                            rusnya["armoured_fighting_vehicles"],
                                            "armored",
                                            Theme.of(context).textTheme.bodyMedium?.color,
                                            350
                                        ),
                                      ]
                                  ),
                                  Row(
                                      children: [
                                        rusnyaCard(
                                            "MLRS",
                                            rusnya["mlrs"],
                                            "Mlrs",
                                            Theme.of(context).textTheme.bodyMedium?.color,
                                            350
                                        ),
                                        rusnyaCard(
                                            "Artillery",
                                            rusnya["artillery_systems"],
                                            "Cannons",
                                            Theme.of(context).textTheme.bodyMedium?.color,
                                            350
                                        ),
                                      ]
                                  ),
                                  Row(
                                      children: [
                                        rusnyaCard(
                                            "Anti-Air",
                                            rusnya["aa_warfare_systems"],
                                            "aa",
                                            Theme.of(context).textTheme.bodyMedium?.color,
                                            350
                                        ),
                                        rusnyaCard(
                                            "Spec Vehicles",
                                            rusnya["special_military_equip"],
                                            "equipment",
                                            Theme.of(context).textTheme.bodyMedium?.color,
                                            350
                                        ),
                                      ]
                                  ),
                                  Row(
                                      children: [
                                        rusnyaCard(
                                            "Planes",
                                            rusnya["planes"],
                                            "planes",
                                            Theme.of(context).textTheme.bodyMedium?.color,
                                            350
                                        ),
                                        rusnyaCard(
                                            "Helicopters",
                                            rusnya["helicopters"],
                                            "helicopters",
                                            Theme.of(context).textTheme.bodyMedium?.color,
                                            350
                                        ),
                                      ]
                                  ),
                                  Row(
                                    children: [
                                      rusnyaCard(
                                          "Submarines",
                                          rusnya["submarines"],
                                          "submarine",
                                          Theme.of(context).textTheme.bodyMedium?.color,
                                          350
                                      ),
                                      rusnyaCard(
                                          "Ships",
                                          rusnya["warships_cutters"],
                                          "Ships",
                                          Theme.of(context).textTheme.bodyMedium?.color,
                                          350
                                      ),
                                    ]
                                  ),
                                  Row(
                                      children:[
                                        rusnyaCard(
                                            "Fuel Tanks",
                                            rusnya["vehicles_fuel_tanks"],
                                            "cars",
                                            Theme.of(context).textTheme.bodyMedium?.color,
                                            350
                                        ),
                                        rusnyaCard(
                                            "ATGMs & SRBMs",
                                            rusnya["atgm_srbm_systems"],
                                            "atgms",
                                            Theme.of(context).textTheme.bodyMedium?.color,
                                            350
                                        ),
                                      ]
                                  ),
                                ],
                              ),
                              headerLine("Links", 11, mode == ThemeMode.dark?Colors.teal:Colors.white),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  linkCard(
                                    "Threads",
                                    "Follow my apps development",
                                    "https://threads.net/@puzzaks",
                                    const Icon(Icons.format_list_bulleted_rounded),
                                  ),
                                  linkCard(
                                    "GitHub",
                                    "Check out my source code",
                                    "https://github.com/Puzzak",
                                    const Icon(Icons.code_rounded),
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
                                    const Icon(Icons.android_rounded),
                                  ),
                                  linkCard(
                                    "Telegram",
                                    "Read my personal blog",
                                    "https://t.me/Puzzaks",
                                    const Icon(Icons.mark_unread_chat_alt_rounded),
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
                                    const Icon(Icons.people_outline_rounded),
                                  ),
                                  linkCard(
                                    "Twitter/X",
                                    "Abandoned blog, nevermind",
                                    "https://x.com/puzzaks",
                                    const Icon(Icons.rss_feed_rounded),
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
                                    const Icon(Icons.contact_page_rounded),
                                  ),
                                  linkCard(
                                    "Instagram",
                                    "Look at my photography",
                                    "https://instagram.com/puzzaks/",
                                    const Icon(Icons.camera_alt_rounded),
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
                                    const Icon(Icons.video_library_rounded),
                                  ),
                                  linkCard(
                                    "Twitch",
                                    "Join my streams  ",
                                    "https://twitch.tv/puzzak",
                                    const Icon(Icons.videogame_asset_rounded),
                                  ),
                                ],
                              ),
                              linkCard(
                                  "Privacy policy",
                                  "Read how we handle your data",
                                  "https://stories.puzzak.page/privacy_policy.html",
                                  const Icon(Icons.privacy_tip_outlined),
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
                                headerLine("About", 3, mode == ThemeMode.dark?Colors.teal:Colors.white),
                                Row(
                                  children: [
                                    Container(
                                      width: 350,
                                      child: const Card(
                                        clipBehavior: Clip.hardEdge,
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(left: 15, right: 20),
                                                child: Icon(Icons.person_rounded),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Yo, I am Puzzak!",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  Text(
                                                    "Welcome to my website!",
                                                    style: TextStyle(
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
                                        clipBehavior: Clip.hardEdge,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              const Padding(
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
                                    )
                                  ],
                                ),
                                Container(
                                  width: 700,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 0),
                                    child: Card(
                                      clipBehavior: Clip.hardEdge,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(left: 15, right: 20),
                                                    child: Icon(Icons.contrast),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Enable Dark Mode",
                                                        style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      Text(
                                                        mode == ThemeMode.system?"Adjusted to your system now":mode == ThemeMode.light?"Switched to Light Mode now":"Switched to Dark Mode now",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ]
                                            ),
                                            Switch(
                                              thumbIcon: thumbIcon,
                                              value: mode == ThemeMode.dark,
                                              inactiveThumbColor: Colors.teal,
                                              activeColor: Colors.teal,
                                              inactiveTrackColor: Color.fromRGBO(29, 27, 32, 1),
                                              onChanged: (bool value) {
                                                setState(() {
                                                  if(mode == ThemeMode.dark){
                                                    mode = ThemeMode.light;
                                                  }else{
                                                    mode = ThemeMode.dark;
                                                  }
                                                });
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                headerLine("Telemetry", telemetry["uptime"] == 0?1:7, mode == ThemeMode.dark?Colors.teal:Colors.white),
                                telemetry["uptime"] == 0?Container(
                                  width: 700,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 0),
                                    child: Card(
                                        color: Theme.of(context).colorScheme.errorContainer,
                                        clipBehavior: Clip.hardEdge,
                                        child: ExpansionTileTheme(
                                            data: const ExpansionTileThemeData(tilePadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15)),
                                            child: Theme(
                                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                                child: ExpansionTile(
                                                  leading: Icon(Icons.error_outline_rounded),
                                                  iconColor: Theme.of(context).textTheme.bodyMedium?.color,
                                                  title: Text(
                                                    "Disconnected from the server!",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    "Server is offline, expand to read more.",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
                                                      child: Container(
                                                        width: scaffoldWidth,
                                                        child: Text(
                                                          "We're currently unable to connect to the server. This is likely due to recent russian terroristic bombardments on Ukraine's social infrastructure.\nYou can learn more about how YOU can help Ukraine or just check server status in Telegram using button below.",
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          TextButton(
                                                              onPressed: (){
                                                                launchUrl(Uri.parse("https://t.me/PuzzakServer"), mode: LaunchMode.externalApplication);
                                                              },
                                                              child: Text(
                                                                "Server Status",
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Theme.of(context).textTheme.bodyMedium?.color
                                                                ),
                                                              )
                                                          ),
                                                          TextButton(
                                                              onPressed: (){
                                                                launchUrl(Uri.parse("https://war.ukraine.ua/support-ukraine/"), mode: LaunchMode.externalApplication);
                                                              },
                                                              child: Text(
                                                                "Help Ukraine",
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Theme.of(context).textTheme.bodyMedium?.color
                                                                ),
                                                              )
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )))
                                    ),
                                  ),
                                ):
                                Column(
                                    children: [
                                      Container(
                                        width: 700,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 0),
                                          child: Card(
                                            clipBehavior: Clip.hardEdge,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  const Padding(
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 700/3,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 0, right: 0),
                                              child: Card(
                                                clipBehavior: Clip.hardEdge,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.all(2.5),
                                                            child: CircularProgressIndicator(
                                                              value: telemetry["netspd"]["in"]/125000000,
                                                              backgroundColor: Colors.transparent,
                                                              strokeCap: StrokeCap.round,
                                                              color: Theme.of(context).colorScheme.primary,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding: EdgeInsets.all(8.5),
                                                            child: Icon(Icons.download_rounded),
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            "Download",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold
                                                            ),
                                                          ),
                                                          Text(
                                                            formatNetworkSpeed(telemetry["netspd"]["in"]),
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
                                            width: 700/3,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 0, right: 0),
                                              child: Card(
                                                clipBehavior: Clip.hardEdge,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.all(2.5),
                                                            child: CircularProgressIndicator(
                                                              value: telemetry["netspd"]["out"]/125000000,
                                                              backgroundColor: Colors.transparent,
                                                              strokeCap: StrokeCap.round,
                                                              color: Theme.of(context).colorScheme.primary,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding: EdgeInsets.all(8.5),
                                                            child: Icon(Icons.upload_rounded),
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            "Upload",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold
                                                            ),
                                                          ),
                                                          Text(
                                                            formatNetworkSpeed(telemetry["netspd"]["out"]),
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
                                            width: 700/3,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 0, right: 0),
                                              child: Card(
                                                clipBehavior: Clip.hardEdge,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.all(2),
                                                            child: CircularProgressIndicator(
                                                              value: ping.inMilliseconds/1000,
                                                              backgroundColor: Colors.transparent,
                                                              strokeCap: StrokeCap.round,
                                                              color: Theme.of(context).colorScheme.primary,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding: EdgeInsets.all(8.5),
                                                            child: Icon(Icons.network_ping_rounded),
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            "Ping",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold
                                                            ),
                                                          ),
                                                          Text(
                                                            "${ping.inMilliseconds.toInt()} ms",
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
                                      Row(
                                        children: [
                                          Container(
                                            width: 700/3,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 0, right: 0),
                                              child: Card(
                                                clipBehavior: Clip.hardEdge,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.all(2.5),
                                                            child: CircularProgressIndicator(
                                                              value: telemetry["util"]/100,
                                                              backgroundColor: Colors.transparent,
                                                              strokeCap: StrokeCap.round,
                                                              color: Theme.of(context).colorScheme.primary,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding: EdgeInsets.all(8.5),
                                                            child: Icon(Icons.developer_board),
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            "CPU Load",
                                                            style: TextStyle(
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
                                            width: 700/3,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 0, right: 0),
                                              child: Card(
                                                clipBehavior: Clip.hardEdge,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.all(2),
                                                            child: CircularProgressIndicator(
                                                              value: (telemetry["temp"] - 20)/60,
                                                              backgroundColor: Colors.transparent,
                                                              strokeCap: StrokeCap.round,
                                                              color: Theme.of(context).colorScheme.primary,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding: EdgeInsets.all(8.5),
                                                            child: Icon(Icons.thermostat_rounded),
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            "CPU Temperature",
                                                            style: TextStyle(
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
                                          Container(
                                            width: 700/3,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 0),
                                              child: Card(
                                                clipBehavior: Clip.hardEdge,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.all(2),
                                                            child: CircularProgressIndicator(
                                                              value: mempercent/100,
                                                              backgroundColor: Colors.transparent,
                                                              strokeCap: StrokeCap.round,
                                                              color: Theme.of(context).colorScheme.primary,
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding: EdgeInsets.all(8.5),
                                                            child: Icon(Icons.memory),
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            "RAM Usage",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold
                                                            ),
                                                          ),
                                                          Text(
                                                              "${((memtotal - memfree) / 1000000).toStringAsFixed(2)}/${(memtotal / 1000000).toStringAsFixed(2)}GB (${mempercent.toStringAsFixed(2)}%)"
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                ),
                                headerLine("Russian Casualties", rusnya.isEmpty?1:15, mode == ThemeMode.dark?Colors.teal:Colors.white),
                                rusnya.isEmpty?Container(
                                  width: 700,
                                  child: Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: Card(
                                        clipBehavior: Clip.hardEdge,
                                        child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child:Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                      padding: EdgeInsets.only(left:10, right:15),
                                                      child:Icon(Icons.cloud_download_rounded)
                                                  ),
                                                  Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "Loading casualties",
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold
                                                          ),
                                                        ),
                                                        Text(
                                                          "Hold on, loading russian casualties data.",
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ]
                                                  )
                                                ]
                                            )
                                        )
                                    ),
                                  ),
                                ):
                                Column(
                                  children: [
                                    rusnyaCard(
                                        "Personnel",
                                        rusnya["personnel_units"],
                                        "Personnel",
                                        Theme.of(context).textTheme.bodyMedium?.color,
                                        700
                                    ),
                                    Row(
                                        children: [
                                          rusnyaCard(
                                              "Missiles",
                                              rusnya["cruise_missiles"],
                                              "missiles",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                          rusnyaCard(
                                              "UAVs",
                                              rusnya["uav_systems"],
                                              "uav",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          rusnyaCard(
                                              "Tanks",
                                              rusnya["tanks"],
                                              "tanks",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                          rusnyaCard(
                                              "Armored",
                                              rusnya["armoured_fighting_vehicles"],
                                              "armored",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          rusnyaCard(
                                              "MLRS",
                                              rusnya["mlrs"],
                                              "Mlrs",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                          rusnyaCard(
                                              "Artillery",
                                              rusnya["artillery_systems"],
                                              "Cannons",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          rusnyaCard(
                                              "Anti-Air",
                                              rusnya["aa_warfare_systems"],
                                              "aa",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                          rusnyaCard(
                                              "Spec Vehicles",
                                              rusnya["special_military_equip"],
                                              "equipment",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          rusnyaCard(
                                              "Planes",
                                              rusnya["planes"],
                                              "planes",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                          rusnyaCard(
                                              "Helicopters",
                                              rusnya["helicopters"],
                                              "helicopters",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                        ]
                                    ),
                                    Row(
                                        children: [
                                          rusnyaCard(
                                              "Submarines",
                                              rusnya["submarines"],
                                              "submarine",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                          rusnyaCard(
                                              "Ships",
                                              rusnya["warships_cutters"],
                                              "Ships",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                        ]
                                    ),
                                    Row(
                                        children:[
                                          rusnyaCard(
                                              "Fuel Tanks",
                                              rusnya["vehicles_fuel_tanks"],
                                              "cars",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                          rusnyaCard(
                                              "ATGMs & SRBMs",
                                              rusnya["atgm_srbm_systems"],
                                              "atgms",
                                              Theme.of(context).textTheme.bodyMedium?.color,
                                              350
                                          ),
                                        ]
                                    ),
                                  ],
                                ),
                                headerLine("Links", 11, mode == ThemeMode.dark?Colors.teal:Colors.white),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    linkCard(
                                      "Threads",
                                      "Follow my apps development",
                                      "https://threads.net/@puzzaks",
                                      const Icon(Icons.format_list_bulleted_rounded),
                                    ),
                                    linkCard(
                                      "GitHub",
                                      "Check out my source code",
                                      "https://github.com/Puzzak",
                                      const Icon(Icons.code_rounded),
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
                                      const Icon(Icons.android_rounded),
                                    ),
                                    linkCard(
                                      "Telegram",
                                      "Read my personal blog",
                                      "https://t.me/Puzzaks",
                                      const Icon(Icons.mark_unread_chat_alt_rounded),
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
                                      const Icon(Icons.people_outline_rounded),
                                    ),
                                    linkCard(
                                      "Twitter/X",
                                      "Abandoned blog, nevermind",
                                      "https://x.com/puzzaks",
                                      const Icon(Icons.rss_feed_rounded),
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
                                      const Icon(Icons.contact_page_rounded),
                                    ),
                                    linkCard(
                                      "Instagram",
                                      "Look at my photography",
                                      "https://instagram.com/puzzaks/",
                                      const Icon(Icons.camera_alt_rounded),
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
                                      const Icon(Icons.video_library_rounded),
                                    ),
                                    linkCard(
                                      "Twitch",
                                      "Join my streams  ",
                                      "https://twitch.tv/puzzak",
                                      const Icon(Icons.videogame_asset_rounded),
                                    ),
                                  ],
                                ),
                                linkCard(
                                    "Privacy policy",
                                    "Read how we handle your data",
                                    "https://stories.puzzak.page/privacy_policy.html",
                                    const Icon(Icons.privacy_tip_outlined),
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
