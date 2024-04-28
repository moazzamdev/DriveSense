import 'package:asaf/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_places_for_flutter/google_places_for_flutter.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: SearchGooglePlacesWidget(
        placeType: PlaceType.address,
        placeholder: 'Enter the address',
        apiKey: 'AIzaSyDIQQ7PPMh1M3lDmw2yB_9Mm71qLno-rQc',
        onSearch: (Place place) {},
        onSelected: (Place place) async {
          homeController.setDestination(place);
        },
      ),
    );
  }
}
