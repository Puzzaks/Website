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

projectPage (Map projectData) {
  return Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double scaffoldHeight = constraints.maxHeight;
          double scaffoldWidth = constraints.maxWidth;
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
              child: Column(
                  children: projectData["content"].map((paragraph) {
                    return Card(
                      elevation: 10,
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 5,top:4,bottom:4),
                                  child: Checkbox(
                                    value: engine.selectedUsers.contains(account),
                                    onChanged: (value) {
                                      setState(() {
                                        if(engine.selectedUsers.contains(account)){
                                          engine.selectedUsers.remove(account);
                                        }else{
                                          engine.selectedUsers.add(account);
                                        }
                                      });
                                      if(engine.selectedUsers.isEmpty){engine.filterUsers();}
                                    },
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${account["address"]}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: engine.demoMode?"Flow":null
                                      ),
                                    ),
                                    Text(
                                      "${account["size"]==0?"Empty":formatSize(account["size"])} • Created ${timePassed(account["created_at"])}",
                                      style: const TextStyle(fontSize: 14,color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: engine.getUserLabels(account["address"].split("@")[1]).map((label){
                                        return Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Chip(
                                            labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                                            padding: const EdgeInsets.all(6),
                                            backgroundColor: Colors.transparent,
                                            side: const BorderSide(
                                                color: Colors.transparent
                                            ),
                                            elevation: 5,
                                            label: Text(label),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                engine.selectedUsers.isEmpty
                                    ? Row(
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          await Clipboard.setData(ClipboardData(text: account["address"]));
                                        },
                                        icon: const Icon(Icons.copy_rounded)
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) => AlertDialog(
                                              content: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Updating password for ${engine.filtered[login][0]["login"]}'),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 10),
                                                    child: TextField(
                                                      controller: engine.updatePassword,
                                                      onChanged: (value) {
                                                      },
                                                      decoration: const InputDecoration(
                                                        prefixIcon: Icon(Icons.password_rounded),
                                                        labelText: 'New password',
                                                        helperText: 'Leave empty for random password',
                                                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Colors.grey)),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    FilledButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).colorScheme.error)),
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(color: Theme.of(context).colorScheme.background),
                                                        )
                                                    ),
                                                    FilledButton(
                                                        onPressed: () async {
                                                          Navigator.pop(context);
                                                          await engine.updateUser(account).then((value) async {

                                                          });
                                                        },
                                                        child: const Text('Confirm')
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.edit_rounded)
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) => AlertDialog(
                                              icon: const Icon(Icons.delete_rounded),
                                              title: const Text('Confirm deletion'),
                                              content: Text('You are about to delete ${account["address"]}.\nConfirm deletion please.'),
                                              actions: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    FilledButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).colorScheme.error)),
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(color: Theme.of(context).colorScheme.background),
                                                        )
                                                    ),
                                                    FilledButton(
                                                        onPressed: () async {
                                                          Navigator.pop(context);
                                                          await engine.deleteUser(account).then((value) async {
                                                            engine.toUpdate.add(account["address"].replaceAll("${account["login"]}@", ""));
                                                            await engine.getAllUsers().then((value) async {
                                                              await engine.filterUsers().then((value) async {

                                                              });
                                                            });
                                                          });
                                                        },
                                                        child: const Text('Confirm')
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.delete_rounded)
                                    )
                                  ],
                                ) : Container()
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList()
              ),
            ),
          );
        },
      ),
    ),
  );
}
