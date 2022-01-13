import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cron/cron.dart';


final String ip = 'http://10.117.154.165:8080/';

Future<Map> newPost(Map dict, String path) async {
  //debugPrint('$ip$path');

  final http.Response response = await http.post(
    '$ip$path',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(dict),
  );
  return json.decode(response.body);
}

Future<Position> getCurrentLocation() async {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position finalPosition;

  await geolocator
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
      .then((Position position) {
    finalPosition =  position;
  }).catchError((e) {
    print(e);
    finalPosition = Position(latitude: null, longitude: null);
  });

  //debugPrint('-------------------> ${finalPosition.toString()}');
  return finalPosition;
}


addStringToSF(String k, String v) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(k, v);
}

getStringValuesSF(String k) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String
  String stringValue = prefs.getString(k);
  return stringValue;
}

isValueInSF(String k) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool checkValue = prefs.containsKey(k);
  return checkValue;
}

Future<void> updateLocation() async {
  var commPass = await getStringValuesSF('commPass') ?? 'null';
  var username = await getStringValuesSF('username') ?? 'null';

  if ((commPass != 'null') && (commPass != null)) {
    //debugPrint('------------------------->Logged In, Uploading Location');
    getCurrentLocation().then((Position pos) {
      //debugPrint('------------------------>Position: ${pos.latitude} , ${pos.longitude}');
      newPost({
        'user': username, 'commPass': commPass, 'lat': pos.latitude.toString(), 'lng': pos.longitude.toString()}, 'uploadlocation').then((Map response) {
        //debugPrint('------------------------>Received response: ${response.toString()}');
        if (response['reply'] == 'pass') {
          //
        } else {
          debugPrint('FAILURE');
        }
      });
    });
  }
}

Future<void> updateLocationCron() async {
  updateLocation();

  var cron = new Cron();
  cron.schedule(new Schedule.parse('* * * * *'), () async {
    //debugPrint('------------------------>Cronjob Started....');
    updateLocation();
  });
}