import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_4/provider/story_provider.dart';
import 'package:geocoding/geocoding.dart' as geo;

class StoryDetailScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailScreen({super.key, required this.storyId});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  GoogleMapController? mapController;
  late final Set<Marker> markers = {};
  geo.Placemark? placemark;

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final story =
        storyProvider.stories.firstWhere((story) => story.id == widget.storyId);
    final storyLocation = LatLng(story.lat!, story.lon!);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Story Detail"),
      ),
      body: story.lat != null && story.lon != null
          ? Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: storyLocation,
                    zoom: 18,
                  ),
                  markers: markers,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                  onMapCreated: (controller) async {
                    final info = await geo.placemarkFromCoordinates(
                        story.lat!, story.lon!);
                    final place = info[0];
                    final street = place.street!;
                    final address =
                        '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
                    setState(() {
                      placemark = place;
                    });
                    defineMarker(storyLocation, street, address);

                    setState(() {
                      mapController = controller;
                    });
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, -1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              story.photoUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            story.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            story.description,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      story.photoUrl,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    story.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    story.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void defineMarker(LatLng latLng, String street, String address) {
    final marker = Marker(
      markerId: const MarkerId("source"),
      position: latLng,
      infoWindow: InfoWindow(
        title: street,
        snippet: address,
      ),
    );
    setState(() {
      markers.clear();
      markers.add(marker);
    });
  }
}
