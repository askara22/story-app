import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_4/provider/story_provider.dart';
import 'package:submission_flutter_4/provider/take_image_provider.dart';
import 'package:submission_flutter_4/provider/upload_story_provider.dart';
import 'package:geocoding/geocoding.dart' as geo;

class NewStoryScreen extends StatefulWidget {
  final Function onNewStory;

  const NewStoryScreen({super.key, required this.onNewStory});

  @override
  State<NewStoryScreen> createState() => _NewStoryScreenState();
}

class _NewStoryScreenState extends State<NewStoryScreen> {
  final myLocation = const LatLng(-6.2825318, 107.0932444);
  TextEditingController desController = TextEditingController();
  GoogleMapController? mapController;
  LatLng? currentLocation;
  late final Set<Marker> markers = {};
  geo.Placemark? placemark;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final uploadProvider = context.watch<UploadStoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Story"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: context.watch<TakeImageProvider>().imagePath == null
                  ? const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image,
                        size: 100,
                      ),
                    )
                  : _showImage(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _onGalleryView(),
                    child: const Text("Gallery"),
                  ),
                  ElevatedButton(
                    onPressed: () => _onCameraView(),
                    child: const Text("Camera"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: SizedBox(
                height: 100,
                child: TextField(
                  controller: desController,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Description'),
                  maxLines: 5,
                  minLines: 4,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Stack(children: [
                GoogleMap(
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: myLocation,
                    zoom: 18,
                  ),
                  onMapCreated: (controller) async {
                    final info = await geo.placemarkFromCoordinates(
                        myLocation.latitude, myLocation.longitude);
                    final place = info[0];
                    final street = place.street!;
                    final address =
                        '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
                    setState(() {
                      placemark = place;
                    });
                    defineMarker(myLocation, street, address);

                    setState(() {
                      mapController = controller;
                    });
                  },
                  markers: markers,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                  onLongPress: (LatLng latLng) {
                    onLongPressGoogleMap(latLng);
                    currentLocation = latLng;
                  },
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: FloatingActionButton(
                    child: const Icon(Icons.my_location),
                    onPressed: () {
                      onMyLocationButtonPress();
                    },
                  ),
                ),
              ]),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: ElevatedButton(
                  onPressed: () => _onUpload(context),
                  child: uploadProvider.isUploading
                      ? const CircularProgressIndicator(
                          color: Colors.purple,
                        )
                      : const Text('Upload'),
                )),
          ],
        ),
      ),
    );
  }

  void onLongPressGoogleMap(LatLng latLng) async {
    final info =
        await geo.placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    final place = info[0];
    final street = place.street!;
    final address =
        '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {
      placemark = place;
    });
    defineMarker(latLng, street, address);

    mapController?.animateCamera(
      CameraUpdate.newLatLng(latLng),
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

  void onMyLocationButtonPress() async {
    final Location location = Location();
    late bool serviceEnabled;
    late PermissionStatus permissionGranted;
    late LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    locationData = await location.getLocation();
    final latLng = LatLng(locationData.latitude!, locationData.longitude!);
    final info =
        await geo.placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    final place = info[0];
    final street = place.street!;
    final address =
        '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {
      placemark = place;
    });
    defineMarker(latLng, street, address);
    mapController?.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }

  _onUpload(BuildContext context) async {
    final takeImageProvider = context.read<TakeImageProvider>();
    final imagePath = takeImageProvider.imagePath;
    final imageFile = takeImageProvider.imageFile;

    if (imagePath == null || imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    final description = desController.text;
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    if (currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    final fileName = imageFile.name;
    final bytes = await imageFile.readAsBytes();

    final uploadProvider = context.read<UploadStoryProvider>();
    final newBytes = await uploadProvider.compressImage(bytes);
    await uploadProvider.upload(newBytes, fileName, description,
        currentLocation!.latitude, currentLocation!.longitude);

    if (uploadProvider.uploadResponse != null) {
      desController.clear();
      takeImageProvider.setImageFile(null);
      takeImageProvider.setImagePath(null);
      setState(() {
        currentLocation = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(uploadProvider.message)),
      );
      final storyProvider = context.read<StoryProvider>();
      storyProvider.fetchStories();
      widget.onNewStory();
    }
  }

  _onGalleryView() async {
    final provider = context.read<TakeImageProvider>();

    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final isLinux = defaultTargetPlatform == TargetPlatform.linux;
    if (isMacOS || isLinux) return;

    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  _onCameraView() async {
    final provider = context.read<TakeImageProvider>();

    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isiOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isNotMobile = !(isAndroid || isiOS);
    if (isNotMobile) return;

    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  Widget _showImage() {
    final imagePath = context.read<TakeImageProvider>().imagePath;
    return kIsWeb
        ? Image.network(
            imagePath.toString(),
            fit: BoxFit.contain,
          )
        : Image.file(
            File(imagePath.toString()),
            fit: BoxFit.contain,
          );
  }
}
