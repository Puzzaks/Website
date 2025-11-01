import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class backend with ChangeNotifier {

  final MaterialStateProperty<Icon?> thumbIcon = MaterialStateProperty.resolveWith<Icon?>(
        (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.dark_mode_rounded);
      }
      return const Icon(Icons.light_mode_rounded, color: Colors.white,);
    },
  );

 late BuildContext context;

  ThemeMode mode = ThemeMode.system;
  double scaffoldHeight = 1000;
  double scaffoldWidth = 1000;

  int startingTimestamp = DateTime.now().millisecondsSinceEpoch.toInt();
  int currentTimestamp = DateTime.now().millisecondsSinceEpoch.toInt();
  Duration ping = const Duration(milliseconds: 0);
  Map news = {};
  Map telemetry = jsonDecode('{"netspd":{"in":0,"out":0},"time":0.0,"temp":0,"util":0,"memo":{"total":"0","avail":"0"},"uptime":0}');
  Map rusnya = {};

  DateTime now = DateTime.now();

  DateTime birthday = DateTime(2002, 3, 18);
  DateTime nextBirthday = DateTime(2002, 3, 18);
  DateTime remoteTime = DateTime.now();
  DateTime startDate = DateTime.now();
  Duration uptimeDuration = Duration.zero;

  String formattedUptime = "";

  double mempercent = 0;

  int memtotal = 0;
  int memfree = 0;
  int memused = 0;


  int daysLeft = 0;
  int age = 0;
  bool isLoading = true;
  String status = "Loading...";
  double progress = 0;

  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String formatDuration(Duration duration) {
    int days = duration.inDays;
    String hours = twoDigits(duration.inHours - (days * 24));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    if(days == 0) {
      return '${DateFormat.yMMMEd().format(
          startDate)} ${DateFormat.jms().format(
          startDate)}\n(${hours == "00"
          ? ""
          : "$hours hrs, "}${minutes == "00"
          ? ""
          : "$minutes min, "}$seconds sec ago)';
    }else{
      return '${DateFormat.yMMMEd().format(
          startDate)} ${DateFormat.jms().format(
          startDate)}\n(${days == 0
          ? ""
          : "$days days, "}${hours == "00"
          ? ""
          : "$hours hrs, "}$minutes minutes ago)';
    }
  }
  setNewTheme(){
    if(mode == ThemeMode.dark){
      mode = ThemeMode.light;
    }else{
      mode = ThemeMode.dark;
    }
    notifyListeners();
  }
  setTimeDates(){
    now = DateTime.now();
    birthday = DateTime(2002, 3, 18);
    nextBirthday = DateTime(now.year, birthday.month, birthday.day);
    remoteTime = DateTime.fromMillisecondsSinceEpoch((telemetry["time"] * 1000).toInt());
    startDate = DateTime.fromMillisecondsSinceEpoch((telemetry["uptime"] * 1000).toInt()).subtract(remoteTime.timeZoneOffset);
    uptimeDuration = remoteTime.difference(startDate);

    formattedUptime = formatDuration(uptimeDuration);
    mempercent = 0;
    if(!(telemetry["memo"]["avail"]=="0" && telemetry["memo"]["total"]=="0")){
      mempercent = 100 - (int.parse(telemetry["memo"]["avail"]) / int.parse(telemetry["memo"]["total"])) * 100;
    }
     memtotal = int.parse(telemetry["memo"]["total"]);
     memfree = int.parse(telemetry["memo"]["avail"]);
     memused = memtotal - memfree;
    if (nextBirthday.isBefore(now) || nextBirthday.isAtSameMomentAs(now)) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }
    daysLeft = nextBirthday.difference(now).inDays - 1;
    age = (now.difference(birthday).inDays / 365.25).floor();
  }

  getTelemetryTimer(){
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      getTelemetry();
      setTimeDates();
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
      telemetry = jsonDecode(response.body);
      notifyListeners();
      return true;
    } catch (_) {
      telemetry = jsonDecode('{"netspd":{"in":0,"out":0},"time":0.0,"temp":0,"util":0,"memo":{"total":"1","avail":"1"},"uptime":0}');
      notifyListeners();
      return false;
    }
  }
  getRusnyaTimer(){
    Timer.periodic(const Duration(minutes: 10), (timer) async {
      getRusnya();
      notifyListeners();
    });
  }
  getRusnya() async {
    String endpoint = "russianwarship.rip";
    String method = "api/v2/statistics/latest";
    try {
      final response = await http.get(
        Uri.https(
            endpoint, method
        ),
      );
      rusnya = jsonDecode(response.body)["data"]["stats"];
      return true;
    } catch (_) {
      rusnya = jsonDecode('{"message":"The data were fetched successfully.","data":{"date":"2077-00-00","day":0,"resource":"https://www.facebook.com/GeneralStaff.ua/posts/pfbid0dLYDFvxNRCWNXxaS75CXA5Sihfbbb1QMxCKYXTi3oaBKTUJ5Xthzv11PsEfL9dFKl","war_status":{"code":0,"alias":"won"},"stats":{"personnel_units":144000000,"tanks":999999,"armoured_fighting_vehicles":999999,"artillery_systems":999999,"mlrs":999999,"aa_warfare_systems":999999,"planes":999999,"helicopters":999999,"vehicles_fuel_tanks":999999,"warships_cutters":999999,"cruise_missiles":999999,"uav_systems":999999,"special_military_equip":999999,"atgm_srbm_systems":999999,"submarines":999999},"increase":{"personnel_units":0,"tanks":0,"armoured_fighting_vehicles":0,"artillery_systems":0,"mlrs":0,"aa_warfare_systems":0,"planes":0,"helicopters":0,"vehicles_fuel_tanks":0,"warships_cutters":0,"cruise_missiles":0,"uav_systems":0,"special_military_equip":0,"atgm_srbm_systems":0,"submarines":0}}}')["data"]["stats"];
      return false;
    }

  }
  getNews() async {
    String endpoint = "raw.githubusercontent.com";
    String method = "Puzzaks/Website/refs/heads/main/new_website/assets/news/index.json";
    await http.get(
      Uri.https(
          endpoint, method
      ),
    ).then((data){
        news = jsonDecode(data.body);
        return true;
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

  progr(String statusNew, double progressNew,[bool loadingNew = true]){
    progress = progressNew;
    status = statusNew;
    isLoading = loadingNew;
    notifyListeners();
  }

  start () async {
    progr("Loading russian casualties...",0);
    await getRusnya().then((data) async {
      getRusnyaTimer();
      progr("Loaded news and articles...",0.25);
      await getNews().then((data) async {
        progr("Updating timers...",0.5);
        setTimeDates();
        progr("Loading telemetry...",0.75);
        await getTelemetry().then((data){
          getTelemetryTimer();
          progr("All done!",1, false);
        });
      });
    });
  }
}