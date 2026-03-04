import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../backend.dart';
import '../widgets.dart'; // for headerLine if needed, though we might move it here or keep it there.

// --- Small Helper Widgets ---

class ProfileCard extends StatelessWidget {
  final double width;
  const ProfileCard({super.key, this.width = 350});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
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
                child: Icon(Icons.person_rounded),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Yo, I am Puzzak!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Welcome to my website!",
                    style: TextStyle(fontSize: 16),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AgeCard extends StatelessWidget {
  final double width;
  const AgeCard({super.key, this.width = 350});

  @override
  Widget build(BuildContext context) {
    return Consumer<backend>(
      builder: (context, backend, child) {
        return SizedBox(
          width: width,
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
                    child: Icon(Icons.cake_rounded),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "I'm ${((DateTime.now().difference(DateTime.utc(2002, 3, 18)).inDays / 365.25)).toStringAsFixed(2)} y.o.",
                        // Note: Original code had a -1 logic in mobile but not desktop?
                        // Desktop: (diff / 365.25).toStringAsFixed(2)
                        // Mobile: ((diff / 365.25) - 1).toStringAsFixed(2)
                        // I will align to the Desktop version as it seems more standard, or maybe the user is 22 turning 23?
                        // Let's stick to the simpler desktop math for consistency unless requested otherwise.
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${backend.daysLeft} days left till I'm ${backend.age + 1}.",
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ThemeSwitchCard extends StatelessWidget {
  final double width;
  const ThemeSwitchCard({super.key, this.width = 700}); // Default larger width

  @override
  Widget build(BuildContext context) {
    return Consumer<backend>(
      builder: (context, backend, child) {
        return SizedBox(
          width: width,
          child: Card(
            color: Theme.of(context).cardColor,
            clipBehavior: Clip.hardEdge,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 15, right: 20),
                      child: Icon(Icons.contrast),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Theme Preference",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          backend.mode == ThemeMode.system
                              ? "Adapting to your browser"
                              : backend.mode == ThemeMode.light
                                  ? "Forced Light Mode"
                                  : "Forced Dark Mode",
                          style: const TextStyle(fontSize: 14),
                        )
                      ],
                    ),
                  ]),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode_rounded),
                        label: width > 600
                            ? const Text('Light',
                                style: TextStyle(fontSize: 12))
                            : null,
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.brightness_auto_rounded),
                        label: width > 600
                            ? const Text('System',
                                style: TextStyle(fontSize: 12))
                            : null,
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_rounded),
                        label: width > 600
                            ? const Text('Dark', style: TextStyle(fontSize: 12))
                            : null,
                      ),
                    ],
                    selected: <ThemeMode>{backend.mode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      backend.setThemeMode(newSelection.first);
                    },
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoadingCard extends StatelessWidget {
  final double width;
  const LoadingCard({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Consumer<backend>(
      builder: (context, backend, child) {
        return SizedBox(
          width: width,
          child: Card(
            color: Theme.of(context).cardColor,
            clipBehavior: Clip.hardEdge,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 15),
                    child: CircularProgressIndicator(
                      value: backend.progress,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        backend.status,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Hold on, loading data and statistics",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class OfflineCard extends StatelessWidget {
  final double width;
  const OfflineCard({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        color: Theme.of(context).colorScheme.errorContainer,
        clipBehavior: Clip.hardEdge,
        child: ExpansionTileTheme(
          data: const ExpansionTileThemeData(
            tilePadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: const Icon(Icons.error_outline_rounded),
              iconColor: Theme.of(context).textTheme.bodyMedium?.color,
              title: const Text(
                "Disconnected from the server!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                "Server is offline, expand to read more.",
                style: TextStyle(fontSize: 14),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 15, bottom: 15, top: 10),
                  child: SizedBox(
                    width: width,
                    child: const Text(
                      "We're currently unable to connect to the server. This is likely due to recent russian terroristic bombardments on Ukraine's social infrastructure.\nYou can learn more about how YOU can help Ukraine or just check server status in Telegram using button below.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 15, bottom: 15, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          launchUrl(Uri.parse("https://t.me/PuzzakServer"),
                              mode: LaunchMode.externalApplication);
                        },
                        child: Text(
                          "Server Status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          launchUrl(
                              Uri.parse(
                                  "https://war.ukraine.ua/support-ukraine/"),
                              mode: LaunchMode.externalApplication);
                        },
                        child: Text(
                          "Help Ukraine",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UptimeCard extends StatelessWidget {
  final double width;
  const UptimeCard({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Consumer<backend>(
      builder: (context, backend, child) {
        // Safe splitting of uptime string
        String booted = "";
        String since = "";
        if (backend.formattedUptime.contains("\n")) {
          var parts = backend.formattedUptime.split("\n");
          since = parts[0];
          if (parts.length > 1 &&
              parts[1].contains("(") &&
              parts[1].contains(")")) {
            booted = parts[1].split("(")[1].split(")")[0];
          } else {
            booted = parts.length > 1 ? parts[1] : "";
          }
        } else {
          since = backend.formattedUptime;
        }

        return SizedBox(
          width: width,
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
                        "Booted $booted",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Since $since",
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TelemetryCard extends StatelessWidget {
  final String title;
  final String valueText;
  final double progressValue; // 0.0 to 1.0
  final IconData icon;
  final double width;

  const TelemetryCard({
    super.key,
    required this.title,
    required this.valueText,
    required this.progressValue,
    required this.icon,
    this.width = 233, // Default somewhat small width
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
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
                      value: progressValue,
                      backgroundColor: Colors.transparent,
                      strokeCap: StrokeCap.round,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.5),
                    child: Icon(icon),
                  )
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      valueText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RusnyaCard extends StatelessWidget {
  final double contentWidth;
  final double cardWidth;

  const RusnyaCard({
    super.key,
    required this.contentWidth,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<backend>(
      builder: (context, backend, child) {
        Color? iconColor =
            Theme.of(context).iconTheme.color; // Used for icon color typically

        bool isMobile = cardWidth < 700;
        double fullWidth = isMobile ? cardWidth : 700;
        double halfWidth = isMobile ? cardWidth : 350;

        return Column(
          children: [
            headerLine(
              "Russian Casualties",
              backend.rusnya.isEmpty ? 1 : 15,
              contentWidth > 800 ? contentWidth : contentWidth,
            ),
            backend.rusnya.isEmpty
                ? SizedBox(
                    width: fullWidth,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Card(
                          color: Theme.of(context).cardColor,
                          clipBehavior: Clip.hardEdge,
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 15),
                                        child:
                                            Icon(Icons.cloud_download_rounded)),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            "Loading casualties",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Hold on, loading russian casualties data.",
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ])
                                  ]))),
                    ),
                  )
                : Column(
                    children: [
                      rusnyaCard("Personnel", backend.rusnya["personnel_units"],
                          "Personnel", iconColor, backend.context, fullWidth),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          rusnyaCard(
                              "Missiles",
                              backend.rusnya["cruise_missiles"],
                              "missiles",
                              iconColor,
                              backend.context,
                              halfWidth),
                          rusnyaCard("UAVs", backend.rusnya["uav_systems"],
                              "uav", iconColor, backend.context, halfWidth),
                          rusnyaCard("Tanks", backend.rusnya["tanks"], "tanks",
                              iconColor, backend.context, halfWidth),
                          rusnyaCard(
                              "Armored",
                              backend.rusnya["armoured_fighting_vehicles"],
                              "armored",
                              iconColor,
                              backend.context,
                              halfWidth),
                          rusnyaCard("MLRS", backend.rusnya["mlrs"], "Mlrs",
                              iconColor, backend.context, halfWidth),
                          rusnyaCard(
                              "Artillery",
                              backend.rusnya["artillery_systems"],
                              "Cannons",
                              iconColor,
                              backend.context,
                              halfWidth),
                          rusnyaCard(
                              "Anti-Air",
                              backend.rusnya["aa_warfare_systems"],
                              "aa",
                              iconColor,
                              backend.context,
                              halfWidth),
                          rusnyaCard(
                              "Spec Vehicles",
                              backend.rusnya["special_military_equip"],
                              "equipment",
                              iconColor,
                              backend.context,
                              halfWidth),
                          rusnyaCard("Planes", backend.rusnya["planes"],
                              "planes", iconColor, backend.context, halfWidth),
                          rusnyaCard(
                              "Helicopters",
                              backend.rusnya["helicopters"],
                              "helicopters",
                              iconColor,
                              backend.context,
                              halfWidth),
                          rusnyaCard(
                              "Submarines",
                              backend.rusnya["submarines"],
                              "submarine",
                              iconColor,
                              backend.context,
                              halfWidth),
                          rusnyaCard(
                              "Ships",
                              backend.rusnya["warships_cutters"],
                              "Ships",
                              iconColor,
                              backend.context,
                              halfWidth),
                          rusnyaCard(
                              "Fuel Tanks",
                              backend.rusnya["vehicles_fuel_tanks"],
                              "cars",
                              iconColor,
                              backend.context,
                              halfWidth),
                          rusnyaCard(
                              "ATGMs & SRBMs",
                              backend.rusnya["atgm_srbm_systems"],
                              "atgms",
                              iconColor,
                              backend.context,
                              halfWidth),
                        ],
                      ),
                    ],
                  ),
          ],
        );
      },
    );
  }
}

class TestTelemetryGraphCard extends StatefulWidget {
  final String title;
  final String valueText;
  final double progressValue; // 0.0 to 1.0
  final IconData icon;
  final double width;

  const TestTelemetryGraphCard({
    super.key,
    required this.title,
    required this.valueText,
    required this.progressValue,
    required this.icon,
    this.width = 233,
  });

  @override
  State<TestTelemetryGraphCard> createState() => _TestTelemetryGraphCardState();
}

class _TestTelemetryGraphCardState extends State<TestTelemetryGraphCard> {
  final List<double> _history = [];
  final int _maxHistory = 30; // Store up to 30 history points

  @override
  void initState() {
    super.initState();
    _history.add(widget.progressValue);
  }

  @override
  void didUpdateWidget(TestTelemetryGraphCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Add to history even if unchanged to show time progression
    _history.add(widget.progressValue);
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Card(
        color: Theme.of(context).cardColor,
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Background Graph
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: CustomPaint(
                  painter: _GraphPainter(
                    history: _history,
                    maxHistory: _maxHistory,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            // Foreground Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.5),
                    child: Icon(widget.icon),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.valueText,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<double> history;
  final int maxHistory;
  final Color color;

  _GraphPainter({
    required this.history,
    required this.maxHistory,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    double step = size.width / (maxHistory - 1);

    // Position the end of the history at the right edge
    double startX = size.width - ((history.length - 1) * step);

    for (int i = 0; i < history.length; i++) {
      double val = history[i].clamp(0.0, 1.0);
      double x = startX + (i * step);
      double y = size.height - (val * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    if (history.isNotEmpty) {
      fillPath.lineTo(startX + ((history.length - 1) * step), size.height);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return true;
  }
}
