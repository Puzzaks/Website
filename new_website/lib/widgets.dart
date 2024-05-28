
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

Widget linkCard(String title, String subtitle, String url, Icon icon, [double width=350]){
  return Container(
    width: width,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: width==350?0:width==700?0:10),
      child: Card(
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
    ),
  );
}
Widget rusnyaCard(String title, amount, String icon, color, [double width=350]){
  return Container(
    width: width,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: width==350?0:width==700?0:10),
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left:10, right:10, bottom:5
                ),
                child: SvgPicture.asset(
                  'rusnya/$icon.svg',
                  height: 26,
                  color: color,
                ),
              ),
              Container(
                width: width==350?width-75:width==700?width-74:width-104,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      amount.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

Widget headerLine(String title, int count, [Color color=Colors.white, double width=680]){
  return Padding(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 15
      ),
      child: Container(
        width: width,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 32,
                  color: color,
                  fontWeight: FontWeight.w100
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(
                  fontSize: 32,
                  color: color,
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
                      "$subtitle\n\n\n",
                      maxLines: 3,
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