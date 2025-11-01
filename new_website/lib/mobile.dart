import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:system_theme/system_theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:new_website/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'backend.dart';

class MobilePage extends StatefulWidget {
  const MobilePage({super.key});
  @override
  MobilePageState createState() => MobilePageState();
}

class MobilePageState extends State<MobilePage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<backend>(builder: (context, backend, child) {
      return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.teal,
                accentColor: Colors.teal,
                cardColor: Colors.teal.withValues(alpha: 100),
                backgroundColor: Colors.teal,
                errorColor: Colors.orange
            ),
            useMaterial3: true,
            cardColor: Colors.white
          ),
          darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.teal,
                  accentColor: Colors.teal,
                  cardColor: Colors.teal.withValues(alpha: 220),
                  backgroundColor: Colors.teal,
                  errorColor: Colors.orange,
                  brightness: Brightness.dark

              ),
              useMaterial3: true,
              cardColor: Colors.teal.withValues(alpha: 198),
              iconTheme: IconThemeData(
                  color: Colors.white
              )
          ),
          themeMode: backend.mode,
          debugShowCheckedModeBanner: false,
          home: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            double scaffoldHeight = constraints.maxHeight;
            double scaffoldWidth = constraints.maxWidth;
            return Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          headerLine("About", 3, scaffoldWidth - 30),
                          Container(
                            width: scaffoldWidth,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Card(
                                color: Theme.of(context).cardColor,
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
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Card(
                                color: Theme.of(context).cardColor,
                                clipBehavior: Clip.hardEdge,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
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
                                            "I'm ${((DateTime.now().difference(DateTime.utc(2002, 3, 18)).inDays / 365.25) - 1).toStringAsFixed(2)} y.o.",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          Text(
                                            "${backend.daysLeft} days left till I'm ${backend.age + 1}.",
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
                                color: Theme.of(context).cardColor,
                                clipBehavior: Clip.hardEdge,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
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
                                                  backend.mode == ThemeMode.system?"Adjusted to your system now":backend.mode == ThemeMode.light?"Switched to Light Mode now":"Switched to Dark Mode now",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ]
                                      ),
                                      Switch(
                                        thumbIcon: backend.thumbIcon,
                                        value: backend.mode == ThemeMode.dark,
                                        inactiveThumbColor: Colors.teal,
                                        activeColor: Colors.teal,
                                        inactiveTrackColor: Color.fromRGBO(29, 27, 32, 1),
                                        onChanged: (bool value) {
                                          backend.setNewTheme();
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          headerLine("Telemetry", backend.telemetry["uptime"] == 0?1:7, scaffoldWidth-30),
                          backend.isLoading
                              ?Container(
                            width: scaffoldWidth,
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child:Card(
                                  color: Theme.of(context).cardColor,
                                clipBehavior: Clip.hardEdge,
                                  child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child:Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.only(left:10, right:15),
                                                child:CircularProgressIndicator(
                                                  value: backend.progress,
                                                  color: Theme.of(context).iconTheme.color,
                                                )
                                            ),
                                            Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    backend.status,
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  Text(
                                                    "Hold on, loading data and statistics",
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
                          )
                              : backend.telemetry["uptime"] == 0?Container(
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
                                          )
                                      )
                                  )
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
                                                                 color: Theme.of(context).cardColor,
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
                                                "Booted ${backend.formattedUptime.split("\n(")[1].split(")")[0]}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              Text(
                                                "Since ${backend.formattedUptime.split("\n")[0]}",
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
                                                                     color: Theme.of(context).cardColor,
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
                                                      value: backend.telemetry["netspd"]["in"]/125000000,
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
                                                    backend.formatNetworkSpeed(backend.telemetry["netspd"]["in"]),
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
                                                                     color: Theme.of(context).cardColor,
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
                                                      value: backend.telemetry["netspd"]["out"]/125000000,
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
                                                    backend.formatNetworkSpeed(backend.telemetry["netspd"]["out"]),
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
                                                                     color: Theme.of(context).cardColor,
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
                                                      value: backend.telemetry["util"]/100,
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
                                                    "${backend.telemetry["util"].toStringAsFixed(2)}%",
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
                                                                     color: Theme.of(context).cardColor,
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
                                                      value: (backend.telemetry["temp"] - 20)/60,
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
                                                    "${backend.telemetry["temp"].toStringAsFixed(2)}°",
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
                                                                     color: Theme.of(context).cardColor,
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
                                                      value: backend.mempercent/100,
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
                                                    "${((backend.memtotal - backend.memfree) / 1000000).toStringAsFixed(2)}/${(backend.memtotal / 1000000).toStringAsFixed(2)}GB (${backend.mempercent.toStringAsFixed(2)}%)",
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
                                                                     color: Theme.of(context).cardColor,
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
                                                      value: backend.ping.inMilliseconds/1000,
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
                                                    "${backend.ping.inMilliseconds.toInt()} ms",
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
                          headerLine("Russian Casualties", backend.rusnya.isEmpty?1:15, scaffoldWidth-30),
                          backend.rusnya.isEmpty?Container(
                            width: scaffoldWidth,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Card(
                                                               color: Theme.of(context).cardColor,
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
                                  backend.rusnya["personnel_units"],
                                  "Personnel",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "Tanks",
                                  backend.rusnya["tanks"],
                                  "tanks",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "Armored",
                                  backend.rusnya["armoured_fighting_vehicles"],
                                  "armored",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "Artillery",
                                  backend.rusnya["artillery_systems"],
                                  "Cannons",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "MLRS",
                                  backend.rusnya["mlrs"],
                                  "Mlrs",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "Anti-Air",
                                  backend.rusnya["aa_warfare_systems"],
                                  "aa",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "Spec Vehicles",
                                  backend.rusnya["special_military_equip"],
                                  "equipment",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "Planes",
                                  backend.rusnya["planes"],
                                  "planes",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "Helicopters",
                                  backend.rusnya["helicopters"],
                                  "helicopters",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "Fuel Tanks",
                                  backend.rusnya["vehicles_fuel_tanks"],
                                  "cars",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "Ships",
                                  backend.rusnya["warships_cutters"],
                                  "Ships",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "Missiles",
                                  backend.rusnya["cruise_missiles"],
                                  "missiles",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "UAVs",
                                  backend.rusnya["uav_systems"],
                                  "uav",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "ATGMs & SRBMs",
                                  backend.rusnya["atgm_srbm_systems"],
                                  "atgms",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                              rusnyaCard(
                                  "Submarines",
                                  backend.rusnya["submarines"],
                                  "submarine",
                                  Theme.of(context).textTheme.bodyMedium?.color,
                                  backend.context,
                                  scaffoldWidth
                              ),
                            ],
                          ),
                          headerLine("Links", 11, scaffoldWidth-30),
                          linkCard(
                              "Threads",
                              "Follow my apps development",
                              "https://threads.net/@puzzaks",
                              const Icon(Icons.format_list_bulleted_rounded),
                              backend.context,
                              scaffoldWidth
                          ),
                          linkCard(
                              "GitHub",
                              "Check out my source code",
                              "https://github.com/Puzzak",
                              const Icon(Icons.code_rounded),
                              backend.context,
                              scaffoldWidth
                          ),
                          linkCard(
                              "Play Store",
                              "Try out my apps",
                              "https://play.google.com/store/apps/dev?id=8304874346039659820",
                              const Icon(Icons.android_rounded),
                              backend.context,
                              scaffoldWidth
                          ),
                          linkCard(
                              "Telegram",
                              "Read my personal blog",
                              "https://t.me/Puzzaks",
                              const Icon(Icons.mark_unread_chat_alt_rounded),
                              backend.context,
                              scaffoldWidth
                          ),
                          linkCard(
                              "LinkedIn",
                              "Connect with my network",
                              "https://linkedin.com/in/puzzak",
                              const Icon(Icons.people_rounded),
                              backend.context,
                              scaffoldWidth
                          ),
                          linkCard(
                              "Twitter/X",
                              "Abandoned blog, nevermind",
                              "https://x.com/puzzaks",
                              const Icon(Icons.rss_feed_rounded),
                              backend.context,
                              scaffoldWidth
                          ),
                          linkCard(
                              "Reddit",
                              "Upvote my posts",
                              "https://reddit.com/u/Puzzak",
                              const Icon(Icons.contact_page_rounded),
                              backend.context,
                              scaffoldWidth
                          ),
                          linkCard(
                              "Instagram",
                              "Look at my photography",
                              "https://instagram.com/puzzaks/",
                              const Icon(Icons.camera_alt_rounded),
                              backend.context,
                              scaffoldWidth
                          ),
                          linkCard(
                              "YouTube",
                              "Watch my videos",
                              "https://youtube.com/@puzzak",
                              const Icon(Icons.video_library_rounded),
                              backend.context,
                              scaffoldWidth
                          ),
                          linkCard(
                              "Twitch",
                              "Join my streams  ",
                              "https://twitch.tv/puzzak",
                              const Icon(Icons.videogame_asset_rounded),
                              backend.context,
                              scaffoldWidth
                          ),
                          linkCard(
                              "Privacy policy",
                              "Read how we handle your data",
                              "https://stories.puzzak.page/privacy_policy.html",
                              const Icon(Icons.privacy_tip_outlined),
                              backend.context,
                              scaffoldWidth
                          ),
                          backend.news == {} || backend.news["projects"] == null
                              ? headerLine("Projects", 0)
                              : headerLine("Projects", backend.news["projects"].length),
                          Container(
                            width: scaffoldWidth,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: backend.news == {} || backend.news["projects"] == null
                                  ? Container()
                                  : Row(
                                  children: backend.news["projects"].toList().map((piece){
                                    return projectCard(
                                        Image.network(
                                            "https://raw.githubusercontent.com/Puzzaks/Website/refs/heads/main/new_website/${piece["pic"]["url"]}",
                                            width:350
                                        ),
                                        piece["title"],
                                        piece["description"],
                                        piece["content"]["body"],
                                        backend.context
                                    );
                                  }).toList().cast<Widget>()
                              ),
                            ),
                          ),
                          backend.news == {} || backend.news["news"] == null
                              ? headerLine("News", 0)
                              : headerLine("News", backend.news["news"].length),
                          Container(
                            width: scaffoldWidth,
                            child: backend.news == {} || backend.news["news"] == null
                                ? Container()
                                : Column(
                                children: backend.news["news"].toList().map((piece){
                                  return newsCardM(
                                      Image.network(
                                          "https://raw.githubusercontent.com/Puzzaks/Website/refs/heads/main/new_website/${piece["pic"]["url"]}",
                                          width:scaffoldWidth
                                      ),
                                      scaffoldWidth,
                                      piece["title"],
                                      piece["description"],
                                      piece["content"]["body"],
                                      backend.context
                                  );
                                }).toList().cast<Widget>()
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      });
    });
  }
}