import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AdBannerCarousel extends StatelessWidget {
  const AdBannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final List<String> dummyAds = [
      "https://images.unsplash.com/photo-1607083213165-cb0255907c81?q=80&w=800",
      "https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=800",
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 120.0,
          autoPlay: true,
          enlargeCenterPage: true,
          aspectRatio: 16/9,
          autoPlayCurve: Curves.fastOutSlowIn,
          enableInfiniteScroll: true,
          autoPlayInterval: const Duration(seconds: 5),
          viewportFraction: 0.85,
        ),
        items: dummyAds.map((imageUrl) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
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
