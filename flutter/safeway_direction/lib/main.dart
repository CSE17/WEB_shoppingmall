/* When you git pull this code, you should fill out keyblanks at googleMap.dart, tMap.dart, and store.dart */
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safewaydirection/api/storeInformation/store.dart';
import 'package:safewaydirection/tMap.dart';
import 'package:safewaydirection/route.dart' as way;
import 'package:safewaydirection/detour.dart';
var height = AppBar().preferredSize.height * 1.1;
var width =  AppBar().preferredSize.width;
void main() => runApp(MyApp()); //신경

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
} //안써도

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
} //괜찮.

class _MyHomePageState extends State<MyHomePage> {
  bool extended = false;
  //List<Color> colors = [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple, Colors.pink,Colors.amber,Colors.black,Colors.white,Colors.brown];
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};
  LatLng source = LatLng(35.2464852,129.090551);
  LatLng destination = LatLng(35.2487721, 129.091708);
  Detour detour;//initialize error. only static value can be passed.
  Set<Polyline> polylines = {};
  //List<List<LatLng>> polylinePoints = [];
  //way.Route route = way.Route();
  //Set<way.Route> routes ={};
  //List<LatLng> passPoints = [];

  @override
  Widget build(BuildContext context) {
    detour = Detour.map(source,destination);
    test();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(height),
        child : SafeArea(
            child: AppBar(
              automaticallyImplyLeading: true,
              flexibleSpace: Container(
                margin: EdgeInsets.all(1),
                decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius : BorderRadius.all(Radius.circular(90))
                ),
                child : FlatButton(
                  ////////onPressed:  () async =>  {await getPossibleRoute()},
                ),
              ),
            )
        ),
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            Opacity(opacity: extended ? 0 : 1,
              child: GoogleMap(
                mapType: MapType.normal,
                markers: markers,
                polylines: polylines,
                initialCameraPosition: CameraPosition(target:LatLng(35.2464852,129.090551),zoom: 16),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            FlatButton(
              color: Colors.yellow,
              ///////////onPressed: makePolylineVisible,
              child: Text(
                "Button"
              ),
            )
          ],
        )
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  } //레이아웃 파트. 내가 건들일 게 없음.

  void test() async{
    await detour.drawAllPolyline();
    polylines = detour.polylines;
    setState(() {

    });
  }

}
