import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend.dart';
import '../../widgets.dart';
import '../../widgets/dashboard_cards.dart';

class TelemetryScreen extends StatelessWidget {
  const TelemetryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double maxWidth = constraints.maxWidth;

        // The standard card block width
        double elementWidth = 350;
        double padding = 20;

        // Two column center layout maximum wrapper (720px)
        double maxContentWidth = (elementWidth * 2) + padding;

        // True content container width
        double contentWidth =
            maxWidth > maxContentWidth ? maxContentWidth : maxWidth;

        // Two columns minus center spacing (10px) and padding
        double cardWidth = (contentWidth - padding - 10) / 2;

        // Full width elements within layout container
        double fullCardWidth = maxWidth < maxContentWidth
            ? contentWidth - padding
            : maxContentWidth - padding;

        return Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  children: [
                    Consumer<backend>(builder: (context, backendProvider, _) {
                      return Column(
                        children: [
                          headerLine(
                              "Telemetry",
                              backendProvider.telemetry["uptime"] == 0 ? 1 : 7,
                              contentWidth),
                          if (backendProvider.isLoading)
                            LoadingCard(width: fullCardWidth)
                          else if (backendProvider.telemetry["uptime"] == 0)
                            OfflineCard(width: fullCardWidth)
                          else ...[
                            UptimeCard(width: fullCardWidth),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 5,
                              runSpacing: 0,
                              children: [
                                TestTelemetryGraphCard(
                                  width: cardWidth,
                                  title: "Download",
                                  valueText: backendProvider.formatNetworkSpeed(
                                      backendProvider.telemetry["netspd"]
                                          ["in"]),
                                  progressValue: (backendProvider
                                              .telemetry["netspd"]["in"] /
                                          125000000)
                                      .clamp(0.0, 1.0),
                                  icon: Icons.download_rounded,
                                ),
                                TestTelemetryGraphCard(
                                  width: cardWidth,
                                  title: "Upload",
                                  valueText: backendProvider.formatNetworkSpeed(
                                      backendProvider.telemetry["netspd"]
                                          ["out"]),
                                  progressValue: (backendProvider
                                              .telemetry["netspd"]["out"] /
                                          125000000)
                                      .clamp(0.0, 1.0),
                                  icon: Icons.upload_rounded,
                                ),
                                TestTelemetryGraphCard(
                                  width: cardWidth,
                                  title: "Ping",
                                  valueText:
                                      "${backendProvider.ping.inMilliseconds} ms",
                                  progressValue:
                                      (backendProvider.ping.inMilliseconds /
                                              1000)
                                          .clamp(0.0, 1.0),
                                  icon: Icons.network_ping_rounded,
                                ),
                                TestTelemetryGraphCard(
                                  width: cardWidth,
                                  title: "CPU Load",
                                  valueText:
                                      "${backendProvider.telemetry["util"].toStringAsFixed(2)}%",
                                  progressValue:
                                      (backendProvider.telemetry["util"] / 100)
                                          .clamp(0.0, 1.0),
                                  icon: Icons.developer_board,
                                ),
                                TestTelemetryGraphCard(
                                  width: cardWidth,
                                  title: "CPU Temp",
                                  valueText:
                                      "${backendProvider.telemetry["temp"].toStringAsFixed(2)}°",
                                  progressValue:
                                      ((backendProvider.telemetry["temp"] -
                                                  20) /
                                              60)
                                          .clamp(0.0, 1.0),
                                  icon: Icons.thermostat_rounded,
                                ),
                                TestTelemetryGraphCard(
                                  width: cardWidth,
                                  title: "RAM Usage",
                                  valueText:
                                      "${backendProvider.mempercent.toStringAsFixed(1)}%",
                                  progressValue:
                                      (backendProvider.mempercent / 100)
                                          .clamp(0.0, 1.0),
                                  icon: Icons.memory,
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          RusnyaCard(
                              contentWidth: contentWidth,
                              cardWidth: contentWidth),
                        ],
                      );
                    }),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
