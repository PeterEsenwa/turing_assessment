import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:google_maps_webservice/places.dart";

import 'details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController mapController;
  int _counter = 0;
  final LatLng _center = const LatLng(45.521563, -122.677433);
  final _places =
      GoogleMapsPlaces(apiKey: "AIzaSyD3_sW1iNhniTTgTVpLLgVHr1MyvKKwy8Q");
  late PlacesSearchResponse response;
  Set<Marker> _markers = Set<Marker>();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Widget _buildInfoWindow(PlaceDetails place) {
    return Container(
      height: 250,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 120,
            child: Image.network(
              _places.buildPhotoUrl(
                  photoReference: place.photos.first.photoReference,
                  maxWidth: 300),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            place.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(place.formattedAddress ?? ""),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PlaceDetailsPage(place: place)));
            },
            child: const Text("See Details"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return Scaffold(
        body: Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          child: TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: const TextStyle(color: Colors.white),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(left: 15, top: 15),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () async {
                  response = await _places.searchByText(searchController.text);
                  // log response.results
                  if (kDebugMode) {
                    var results = response.results;
                    print(results.length);
                    setState(() {
                      _markers.clear();
                      for (var i = 0; i < results.length; i++) {
                        var geometry = results[i].geometry;

                        if (geometry == null) {
                          continue;
                        }

                        _markers.add(Marker(
                          markerId: MarkerId(results[i].name),
                          position: LatLng(
                              geometry.location.lat, geometry.location.lng),
                          // update the current place when the marker is tapped
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return FutureBuilder(
                                  future: _places.getDetailsByPlaceId(
                                      results[i].placeId ?? ""),
                                  builder: (context, snapshot) {
                                    var placeDetailsData = snapshot.data;
                                    if (snapshot.hasData &&
                                        placeDetailsData != null) {
                                      return AlertDialog(
                                        content: _buildInfoWindow(
                                            placeDetailsData.result),
                                        actions: <Widget>[
                                          OutlinedButton(
                                            child: const Text('Close'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                );
                              },
                            );
                          },
                        ));
                      }
                    });
                  }
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: GoogleMap(
            markers: _markers,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            // infoWindowBuilder: (marker) {
            //   return FutureBuilder(
            //     future: _places.getDetailsByPlaceId(marker.placeId),
            //     builder: (context, snapshot) {
            //       if (snapshot.hasData) {
            //         return _buildInfoWindow(snapshot.data);
            //       }
            //       return const SizedBox();
            //     },
            //   );
            // },
          ),
        ),
      ],
    ));
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
  }
}
