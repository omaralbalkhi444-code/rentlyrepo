import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickLocationPage extends StatefulWidget {
  const PickLocationPage({super.key});

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  LatLng selected = const LatLng(32.55, 35.85);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
        backgroundColor: const Color(0xFF8A005D),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: selected,
          zoom: 14,
        ),
        onTap: (pos) {
          setState(() => selected = pos);
        },
        markers: {
          Marker(
            markerId: const MarkerId("selected"),
            position: selected,
          )
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8A005D),
        child: const Icon(Icons.check),
        onPressed: () => Navigator.pop(context, selected),
      ),
    );
  }
}
