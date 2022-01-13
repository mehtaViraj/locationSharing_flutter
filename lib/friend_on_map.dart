import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locationsharing/special_functions.dart' as spFunc;

class FriendMap extends StatefulWidget {

  @override
  _FriendMapState createState() => _FriendMapState();
}

class _FriendMapState extends State<FriendMap> {

  static var username;
  static var commPass;

  String target;

  Completer<GoogleMapController> _controller = Completer();
  MapType _currentMapType = MapType.normal;
  GoogleMapController mapController;

  Set<Marker> _markers = {};
  int markerId = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<void> afterBuild() async {
    username = await spFunc.getStringValuesSF('username');
    commPass = await spFunc.getStringValuesSF('commPass');

    //debugPrint('--------->$username and $commPass');
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    mapController = controller;

    refreshMarker();
  }

  @override
  Widget build(BuildContext context) {
    afterBuild();
    target = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Finding $target'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh, size: 27,), onPressed: refreshMarker)
        ],
      ) ,
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(1.346302, 103.954510),
          zoom: 15.0,
        ),
        mapType: _currentMapType,
        markers: _markers,
      ),
    );
  }

  void refreshMarker() {
    spFunc.newPost({'user':username ,'commPass':commPass, 'target':target}, 'getfriendlocation').then((Map response) {
      //debugPrint('---------------------------->${response.toString()}');

      if (response['reply'] == 'pass') {
        double lng = double.parse(response['lng']);
        double lat = double.parse(response['lat']);
        String lastSeen = response['lastSeen'];
        LatLng pos = LatLng(lat, lng);

        setState(() {

          _markers = {};

          _markers.add(Marker(
            // This marker id can be anything that uniquely identifies each marker.
            markerId: MarkerId(markerId.toString()),
            position: pos,
            infoWindow: InfoWindow(
              title: '$target at $lastSeen',
            ),
            icon: BitmapDescriptor.defaultMarker,
          ));

          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: pos, zoom: 15.0),
            ),
          );
        });

      } else {
        SnackBar snackBar = SnackBar(content: Text(response['error']));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }
}
