import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AdBannerCarousel extends StatelessWidget {
  const AdBannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final List<String> dummyAds = [
      "assets/images/banner_1.png",
      "assets/images/banner_2.png",
      "assets/images/banner_3.png",
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180.0,
          autoPlay: true,
          enlargeCenterPage: true,
          aspectRatio: 16/9,
          autoPlayCurve: Curves.fastOutSlowIn,
          enableInfiniteScroll: true,
          autoPlayInterval: const Duration(seconds: 5),
          viewportFraction: 0.80,
        ),
        items: dummyAds.map((assetPath) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(assetPath),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                        child: const Text("AD", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
