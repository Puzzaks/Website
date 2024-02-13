
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget linkCard(String title, String subtitle, String url, Icon icon){
  return Container(
    width: 350,
    child: Card(
      color: Color.fromRGBO(29, 27, 32, 1),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 20),
                    child: icon,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      )
                    ],
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.navigate_next_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}