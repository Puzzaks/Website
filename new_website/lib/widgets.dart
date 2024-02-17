
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

Widget headerLine(String title, int count){
  return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Container(
        width: 680,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 32,
                  color: Colors.grey,
                  fontWeight: FontWeight.w100
              ),
            ),
            Text(
              count.toString(),
              style: const TextStyle(
                  fontSize: 32,
                  color: Colors.grey,
                  fontWeight: FontWeight.w100
              ),
            )
          ],
        ),
      )
  );
}

Widget projectCard(Image pic, String title, String subtitle, String action){
  return Container(
    width: 350,
    child: Card(
      color: Color.fromRGBO(29, 27, 32, 1),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
          onTap: () {
            launchUrl(Uri.parse(action), mode: LaunchMode.externalApplication);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: pic,
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
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
                ),
              ),
            ],
          )
      ),
    ),
  );
}