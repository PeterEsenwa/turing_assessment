import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_webservice/places.dart';

class PlaceDetailsPage extends StatefulWidget {
  final PlaceDetails place;
  const PlaceDetailsPage({Key? key, required this.place}) : super(key: key);

  @override
  State<PlaceDetailsPage> createState() => PlaceDetailsPageState();
}

class PlaceDetailsPageState extends State<PlaceDetailsPage> {
  final _places =
  GoogleMapsPlaces(apiKey: "AIzaSyD3_sW1iNhniTTgTVpLLgVHr1MyvKKwy8Q");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: widget.place.photos.length,
              itemBuilder: (context, index) {
                return Image.network(
                  _places.buildPhotoUrl(photoReference: widget.place.photos[index].photoReference, maxWidth: MediaQuery.of(context).size.width.toInt()),
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.place.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(widget.place.formattedAddress ?? ""),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
