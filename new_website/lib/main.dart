import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:new_website/backend.dart';
import 'package:new_website/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:system_theme/system_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'desktop.dart';
import 'mobile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => backend(),
      child: WebMain(),
    ),
  );
}

class WebMain extends StatelessWidget {
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<backend>(context, listen: false).start();
    });
    return WebMainState();
  }
}

class WebMainState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<backend>(
        builder: (context, backend, child) {
          backend.context = context;
          return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
            return MaterialApp(
              title: "Puzzak's",
              theme: ThemeData(
                colorScheme: lightColorScheme ?? backend.lt,
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme ?? backend.dt,
                useMaterial3: true,
              ),
              themeMode: backend.mode,
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: SafeArea(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      backend.scaffoldWidth = constraints.maxWidth;
                      backend.scaffoldHeight = constraints.maxHeight;
                      if(backend.scaffoldWidth < 715){
                        return MobilePage();
                      }else{
                        return DesktopPage();
                      }
                    },
                  ),
                ),
              ),
            );
          });
        });
  }
}
