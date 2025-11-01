import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:system_theme/system_theme.dart';
import 'dart:core';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:new_website/backend.dart';
import 'package:provider/provider.dart';

import 'package:new_website/desktop.dart';
import 'package:new_website/mobile.dart';

void main() {
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
          return MaterialApp(
            title: "Puzzak's",
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.teal,
                  accentColor: Colors.teal,
                  cardColor: Colors.teal,
                  backgroundColor: Colors.teal,
                  errorColor: Colors.orange
              ),
              useMaterial3: true,
              cardColor: Colors.white,
              iconTheme: IconThemeData(
                color: Colors.black
              )
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.teal,
                  accentColor: Colors.teal,
                  cardColor: Colors.black,
                  backgroundColor: Colors.teal,
                  errorColor: Colors.orange
              ),
              useMaterial3: true,
              cardColor: Colors.teal.withValues(alpha: 198),
                iconTheme: IconThemeData(
                    color: Colors.white
                )
            ),
            themeMode: backend.mode,
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    backend.context = context;
                    backend.scaffoldWidth = constraints.maxWidth;
                    backend.scaffoldHeight = constraints.maxHeight;
                    if(backend.scaffoldWidth < 1060){
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
  }
}
