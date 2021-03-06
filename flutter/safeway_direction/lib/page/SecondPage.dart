import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../models/search_map_place.dart';
import '../models/PlaceInfo.dart';
import '../models/RecentSearch.dart';
import '../models/AlertDialog.dart';
import '../models/Favorite.dart';
import '../page/ThirdPage.dart';
import '../page/RecentSearchPage.dart';
import '../db/KikeeDB.dart';
import '../keys.dart';
import '../src/Server.dart';

class NewSearchPage extends StatefulWidget {
  @override
  _NewSearchPageState createState() => _NewSearchPageState();
}

class _NewSearchPageState extends State<NewSearchPage> {
  bool first = true;

  PlaceInfo start; // start location class variable
  PlaceInfo end; // end location class variable
  PlaceInfo update; // end location given from recent search data

  RecentSearch recentSearchInfo; // recent search class variable

  TextEditingController searchController  =  new TextEditingController(); // start location controller
  TextEditingController searchController2 = new TextEditingController(); // end location controller

  final List<IconData> icons = [ // favorite icons list
    Icons.add,
    Icons.home,
    Icons.school,
    Icons.book
  ];

  List iconArray = [ 0, 0, 0, 0, 0 ]; // 몇 번째 즐겨찾기 아이콘을 가리키는 변수, variable which points numberth favorite icons

  @override
  void initState() {
    super.initState();
    _updateFavoriteIcon();
  }

  void _updateFavoriteIcon() async {
    List<Favorite> data = await KikeeDB.instance.getFavoriteIcon();
    List iconTempArray = [ 0, 0, 0, 0, 0 ];

    for( int i = 0; i < data.length; i++ ) {
      iconTempArray[ data[i].id - 1 ] = data[i].icon;
    }

    iconArray = iconTempArray;

    setState( () {} );
    print(iconArray);
  }

  void updateEndPlace( ) { // update end data fetched from recent search
    setState(() {
      try { end = update; searchController2.text = update.mainText; }
      catch (e) { print(e); }
    });
  }

  void updateStartPlace( ) { // update end data fetched from recent search
    setState(() {
      try { start = update; searchController.text = update.mainText; }
      catch(e) { print(e); }
    });
  }


  void moveRecentSearchPage() async { // navigate to recent search page and save its location data using updateend
    update = null;
    update = await Navigator.push( context, MaterialPageRoute(builder: (context) => RecentSearchPage()) );
    if(update!=null)
      {
        Alert(
          context: context,
          title: "무엇으로 설정할까요?",
          style: AlertStyle(
            titleStyle: TextStyle(fontFamily: 'BMJUA',color: Colors.orangeAccent),
          ),
          buttons: [
            DialogButton(
              radius: BorderRadius.circular(30),
              color: Colors.orangeAccent,
              child: Text(
                "출발지",
                style: TextStyle(color: Colors.white, fontSize: 20,fontFamily: 'BMJUA'),
              ),
              onPressed: (){
                updateStartPlace();
                Navigator.pop(context);
              },
              width: 120,
            ),
            DialogButton(
              radius: BorderRadius.circular(30),
              color: Colors.orangeAccent,
              child: Text(
                "도착지",
                style: TextStyle(color: Colors.white, fontSize: 20,fontFamily: 'BMJUA'),
              ),
              onPressed: (){
                updateEndPlace();
                Navigator.pop(context);
              },
              width: 120,
            ),
          ],
        ).show();
      }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if(first) {
      start = ModalRoute.of(context).settings.arguments;
      searchController.text = start.description;
      first = false;
    }
    return Scaffold(
      backgroundColor: Color(0xfffce76e),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight((MediaQuery.of(context).size.height / 12)),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xfffdee96),
          title: Text('KIKEE',style: TextStyle(fontFamily: 'BMJUA',color: Colors.orange,fontSize: 40),),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: (width/5)*2 + (height/40)*9,
              left: (MediaQuery.of(context).size.width / 20),
              child: Container(
                width: MediaQuery.of(context).size.width / 20 * 18,
                height: MediaQuery.of(context).size.height / 2.5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    color: Color(0xfffdee96),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffe5d877),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text('즐겨찾기',style: TextStyle(fontFamily: 'BMJUA',fontSize: 20),),
                    Row(
                      children: <Widget>[
                        Container(
                          width : width/4,
                          height: width/4,
                          padding: EdgeInsets.all(width/32),
                          child: RawMaterialButton(
                            onPressed: () { moveRecentSearchPage(); },
                            elevation: 0,
                            fillColor: Color(0xffec748c),
                            child: Icon(
                              Icons.query_builder,
                              color: Colors.white,
                              size: width/8,
                            ),
                            shape: CircleBorder(),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xffe2d485),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),]
                          ),
                        ),
                        Container(
                          width : width/4,
                          height: width/4,
                          padding: EdgeInsets.all(width/32),
                          child: RawMaterialButton(
                            onPressed: () {
                              KikeeDB.instance.getFavorite(1).then((data) {
                                try {
                                  searchController2.text = data[0]['mainText'];
                                  end = PlaceInfo(
                                      description: data[0]['description'],
                                      longitude: data[0]['longitude'],
                                      latitude: data[0]['latitude'],
                                      mainText: data[0]['mainText']);
                                } catch (error) {
                                  print(error);
                                }
                              });
                            },
                            onLongPress: () {
                              KikeeDB.instance.getFavorite(1).then((data) async {
                                try {
                                  viewFavorite(context, 1, data);
                                }
                                catch (e) {
                                  print(e);
                                }
                              });
                            },
                            elevation: 0,
                            fillColor: Color(0xff47c2bb),
                            child: Icon(
                              icons[iconArray[0]],
                              color: Colors.white,
                              size: width/8,
                            ),
                            shape: CircleBorder(),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xffe2d485),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),]
                          ),
                        ),
                        Container(
                          width : width/4,
                          height: width/4,
                          padding: EdgeInsets.all(width/32),
                          child: RawMaterialButton(
                            onPressed: () {
                              KikeeDB.instance.getFavorite(2).then((data) {
                                try {
                                  searchController2.text = data[0]['mainText'];
                                  end = PlaceInfo(
                                      description: data[0]['description'],
                                      longitude: data[0]['longitude'],
                                      latitude: data[0]['latitude'],
                                      mainText: data[0]['mainText']);
                                } catch (error) {
                                  print(error);
                                }
                              });
                            },
                            onLongPress: () {
                              KikeeDB.instance.getFavorite(2).then((data) {
                                viewFavorite(context, 2, data);
                              });
                            },
                            elevation: 0,
                            fillColor: Colors.blueAccent,
                            child: Icon(
                              icons[iconArray[1]],
                              color: Colors.white,
                              size: width/8,
                            ),
                            shape: CircleBorder(),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xffe2d485),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),]
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width : width/4,
                          height: width/4,
                          padding: EdgeInsets.all(width/32),
                          child: RawMaterialButton(
                            onPressed: () { 
                              KikeeDB.instance.getFavorite(3).then((data) {
                                try {
                                  searchController2.text = data[0]['mainText'];
                                  end = PlaceInfo(
                                      description: data[0]['description'],
                                      longitude: data[0]['longitude'],
                                      latitude: data[0]['latitude'],
                                      mainText: data[0]['mainText']);
                                } catch (error) {
                                  print(error);
                                }
                              });
                             },
                            onLongPress: () {
                              KikeeDB.instance.getFavorite(3).then((data) {
                                viewFavorite(context, 3, data);
                              });
                            },
                            elevation: 0,
                            fillColor: Colors.purple,
                            child: Icon(
                              icons[iconArray[2]],
                              color: Colors.white,
                              size: width/8,
                            ),
                            shape: CircleBorder(),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xffe2d485),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),]
                          ),
                        ),
                        Container(
                          width : width/4,
                          height: width/4,
                          padding: EdgeInsets.all(width/32),
                          child: RawMaterialButton(
                            onPressed: () {
                              KikeeDB.instance.getFavorite(4).then((data) {
                                try {
                                  searchController2.text = data[0]['mainText'];
                                  end = PlaceInfo(
                                      description: data[0]['description'],
                                      longitude: data[0]['longitude'],
                                      latitude: data[0]['latitude'],
                                      mainText: data[0]['mainText']);
                                } catch (error) {
                                  print(error);
                                }
                              });
                            },
                            onLongPress: () {
                              KikeeDB.instance.getFavorite(4).then((data) {
                                viewFavorite(context, 4, data);
                              });
                            },
                            elevation: 0,
                            fillColor: Color(0xFFF0AD74),
                            child: Icon(
                              icons[iconArray[3]],
                              color: Colors.white,
                              size: width/8,
                            ),
                            shape: CircleBorder(),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xffe2d485),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),]
                          ),
                        ),
                        Container(
                          width : width/4,
                          height: width/4,
                          padding: EdgeInsets.all(width/32),
                          child: RawMaterialButton(
                            onPressed: () {
                              KikeeDB.instance.getFavorite(5).then((data) {
                                try {
                                  searchController2.text = data[0]['mainText'];
                                  end = PlaceInfo(
                                      description: data[0]['description'],
                                      longitude: data[0]['longitude'],
                                      latitude: data[0]['latitude'],
                                      mainText: data[0]['mainText']);
                                } catch (error) {
                                  print(error);
                                }
                              });
                            },
                            onLongPress: () {
                              KikeeDB.instance.getFavorite(5).then((data) {
                                viewFavorite(context, 5, data);
                              });
                            },
                            elevation: 0,
                            fillColor: Color(0xFFF0AD74),
                            child: Icon(
                              icons[iconArray[4]],
                              color: Colors.white,
                              size: width/8,
                            ),
                            shape: CircleBorder(),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xffe2d485),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),]
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    ),
                  ],
                ),
              ),
            ), // short cut buttons
            Positioned(
              top: height/24,
              right: (width / 10),
              child: InkWell(
                child: Image.asset('image/kiki.png',width: (width/5),),
                onTap: () {
                  if(searchController.text==""||searchController2.text==""){
                   showMyDialog(context,"출발지와 도착지를 모두 채우셔야\n길찾기를 시작할 수 있습니다.");
                  }else if(searchController.text == searchController2.text){
                    showMyDialog(context,"어라?? 출발지와 도착지가 같아요~!");
                  }else if(start==null||end==null){
                    showMyDialog(context,"출발지/도착지를 검색한 후 검색결과를 선택해야 진행이 됩니다.");
                  }else{
                    List<PlaceInfo> args = [start, end];
                    stopUpdateLocation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ThirdPage(),
                          settings: RouteSettings(arguments: args)),
                    );
                  }
                },
              ),
            ),
            Positioned(
              top: (height/40)*3,
              right: (width/9.5)*3,
              child: Bubble(
                padding: BubbleEdges.all(15),
                shadowColor: Color(0xffe5d877),
                child: Row(
                  children: <Widget>[
                    Text(
                      '나를 누르면 길찾기를 시작해!',
                      style: TextStyle(
                          fontFamily: 'BMJUA',
                          fontSize: 18,
                          color: Colors.orange),
                    ),
                  ],
                ),
                nip: BubbleNip.rightTop,
                radius: Radius.circular(30.0),
              ),
            ),
            Positioned(
              child: SearchMapPlaceWidget(
                  apiKey: Keys.place,
                  language: 'ko',
                  controller: searchController2,
                  hasClearButton: true,
                  iconColor: Color(0xFFF0AD74),
                  placeholder: '',
                  lableText: '도착지: ',
                  onSelected: (place) async {
                    final geolocation = await place.geolocation;
                    double lat = geolocation.lat();
                    double lng = geolocation.lng();
                    end = PlaceInfo(placeId: place.placeId, description: place.description, longitude: lng, latitude: lat, mainText: place.mainText);
                    recentSearchInfo = RecentSearch(placeId: place.placeId, description: place.description, longitude: lng, latitude: lat, mainText: place.mainText);
                    KikeeDB.instance.insertRecentSearch(recentSearchInfo);
                  }),
              width: (MediaQuery.of(context).size.width / 5) * 4,
              top: (width/5)*2 + (height/48)*5,
              left: (MediaQuery.of(context).size.width / 20),
            ), // 도착지 검색바
            Positioned(
              child: SearchMapPlaceWidget(
                  apiKey: Keys.place,
                  language: 'ko',
                  controller: searchController,
                  hasClearButton: true,
                  iconColor: Color(0xFFF0AD74),
                  placeholder: '',
                  lableText: '출발지: ',
                  onSelected: (place) async {
                    first = false;
                    final geolocation = await place.geolocation;

                    double lat = geolocation.lat();
                    double lng = geolocation.lng();

                    start = PlaceInfo(
                        placeId: place.placeId,
                        description: place.description,
                        longitude: lng,
                        latitude: lat,
                        mainText: place.mainText);

                    recentSearchInfo = RecentSearch(
                        placeId: place.placeId,
                        description: place.description,
                        longitude: lng,
                        latitude: lat,
                        mainText: place.mainText);

                    KikeeDB.instance.insertRecentSearch(recentSearchInfo);
                  }),
              width: (MediaQuery.of(context).size.width / 5) * 4,
              top: (width/5)*2,
              left: (MediaQuery.of(context).size.width / 20),
            ), // 출발지 검색바
            Positioned(
              top: (width/5)*2 + (height/96)*5,
              right: 0,
              child: RawMaterialButton(
                onPressed: () {
                  String tmp = searchController2.text;
                  searchController2.text = searchController.text;
                  searchController.text = tmp;
                  var tmp2 = end;
                  end = start;
                  start = tmp2;
                },
                elevation: 2.0,
                fillColor: Color(0xFFF0AD74),
                child: Icon(
                  Icons.swap_vert,
                  color: Colors.white,
                  size: 40,
                ),
                shape: CircleBorder(),
              ),
            ),

          ],
        ),
      ),
    );
  }

  viewFavorite(BuildContext context, int id, var data) {
    Favorite favoriteInfo = Favorite(
      id: id,
      description: null,
      text: null,
      longitude: null,
      latitude: null,
      mainText: null,
      icon: null
    );

    RecentSearch recentSearchInfo;

    final favoriteController = new TextEditingController();
    final favoriteTextController = new TextEditingController();

    // update favorite
    try {
      favoriteTextController.text = data[0]['text'];

      favoriteInfo = Favorite(
        // placeId: place.placeId,
        id: data[0]['id'],
        description: data[0]['description'],
        longitude: data[0]['longtitude'],
        latitude: data[0]['latitude'],
        mainText: data[0]['mainText'],
        icon: data[0]['icon']
      );

      Alert(
        context: context,
        title: '즐겨찾기 수정',
        type: AlertType.none,
        style: AlertStyle(
          titleStyle: TextStyle( fontFamily: 'BMJUA',color: Colors.black,fontSize: 20),
          backgroundColor: Color(0xfffdfbf4),
          alertBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0),),),
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(height: 20,),
            Container(
              child:TextField(
                style: TextStyle(fontFamily: 'BMJUA', color: Color(0xfff7d8ae), fontSize: 15),
                controller: favoriteTextController,
                decoration: InputDecoration(
                  hintText: '즐겨찾기 이름 설정',
                  hintStyle: TextStyle(fontFamily: 'BMJUA', color: Color(0xfff7d8ae), fontSize: 15),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1.0),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30.0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1.0),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30.0),
                    ),
                  ),
                  fillColor: Colors.white,
                  filled:true,
                ),
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xffe5e3dd),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),]
              ),
            ),
            SizedBox(height: 20,),
            SearchMapPlaceWidget(
              apiKey: Keys.googleMap,
              language: 'ko',
              controller: favoriteController,
              hasClearButton: true,
              iconColor: Color(0xFFF0AD74),
              placeholder: '주소를 입력해 주세요',
              lableText: '',
              boxShadowColor: Color(0xffe5e3dd),
              onSelected: (place) async {
                final geolocation = await place.geolocation;

                double lat = geolocation.lat();
                double lng = geolocation.lng();

                recentSearchInfo = RecentSearch(
                  placeId: place.placeId,
                  description: place.description,
                  longitude: lng,
                  latitude: lat,
                  mainText: place.mainText,);

                  favoriteInfo.id = id;
                  favoriteInfo.description = place.description;
                  favoriteInfo.longitude = lng;
                  favoriteInfo.latitude = lat;
                  favoriteInfo.mainText = place.mainText;
                  favoriteInfo.text = favoriteTextController.text;

                _insertRecentSearch(recentSearchInfo);
              },
            ),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Container(
                  height:80,
                  width: 80,
                  padding: EdgeInsets.all(10),
                  child: RawMaterialButton(
                    onPressed:(){ favoriteInfo.icon = 1; },
                    elevation: 0,
                    fillColor: Color(0xff47c2bb),
                    child: Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 40,
                    ),
                    shape: CircleBorder(),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffe5e3dd),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),]
                  ),
                ),
                Container(
                  height:80,
                  width: 80,
                  padding: EdgeInsets.all(10),
                  child: RawMaterialButton(
                    onPressed:() { favoriteInfo.icon = 2; },
                    elevation: 0,
                    fillColor: Color(0xff75b8f4),
                    child: Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 40,
                    ),
                    shape: CircleBorder(),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffe5e3dd),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),]
                  ),
                ),
                Container(
                  height:80,
                  width: 80,
                  padding: EdgeInsets.all(10),
                  child: RawMaterialButton(
                    onPressed:() { favoriteInfo.icon = 3; },
                    elevation: 0,
                    fillColor: Color(0xffdd84c6),
                    child: Icon(
                      Icons.book,
                      color: Colors.white,
                      size: 40,
                    ),
                    shape: CircleBorder(),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffe5e3dd),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),]
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
          ],
        ),
        buttons: [
          DialogButton(
            color: Color(0xfff36c4c),
            radius: BorderRadius.circular(15),
            onPressed: () {
              _deleteFavorite(id);
              print('db delete');
              Navigator.pop(context);
              _updateFavoriteIcon();
            },
            child:
            Text("삭제", style: TextStyle(color: Colors.white, fontSize: 15,fontFamily: 'BMJUA')),
          ),
          DialogButton(
            color: Color(0xfff7b413),
            radius: BorderRadius.circular(15),
            onPressed: () {
              _updateFavorite(favoriteInfo);
              print('db update');
              Navigator.pop(context);
              _updateFavoriteIcon();
            },
            child:
            Text("수정", style: TextStyle(color: Colors.white, fontSize: 15,fontFamily: 'BMJUA')),
          ),
        ],
        closeFunction: () {}
      ).show();
    }

    // insert favorite
    catch (error) {
      Alert(
        context: context,
        title: '즐겨찾기 추가',
        type: AlertType.none,
        style: AlertStyle(
          titleStyle: TextStyle( fontFamily: 'BMJUA',color: Colors.black,fontSize: 20),
          backgroundColor: Color(0xfffdfbf4),
          alertBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0),),
          ),
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(height: 20,),
            Container(
              child:TextField(
                style: TextStyle(fontFamily: 'BMJUA', color: Color(0xfff7d8ae), fontSize: 15),
                controller: favoriteTextController,
                decoration: InputDecoration(
                  hintText: '즐겨찾기 이름 설정',
                  hintStyle: TextStyle(fontFamily: 'BMJUA', color: Color(0xfff7d8ae), fontSize: 15),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1.0),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30.0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1.0),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30.0),
                    ),
                  ),
                  fillColor: Colors.white,
                  filled:true,
                ),
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xffe5e3dd),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),]
              ),
            ),
            SizedBox(height: 20,),
            SearchMapPlaceWidget(
              apiKey: Keys.googleMap,
              language: 'ko',
              controller: favoriteController,
              hasClearButton: true,
              iconColor: Color(0xFFF0AD74),
              placeholder: '주소를 입력해 주세요',
              lableText: '',
              boxShadowColor: Color(0xffe5e3dd),
              onSelected: (place) async {
                final geolocation = await place.geolocation;

                double lat = geolocation.lat();
                double lng = geolocation.lng();

                recentSearchInfo = RecentSearch(
                  placeId: place.placeId,
                  description: place.description,
                  longitude: lng,
                  latitude: lat,
                  mainText: place.mainText,);

                  favoriteInfo.id = id;
                  favoriteInfo.description = place.description;
                  favoriteInfo.longitude = lng;
                  favoriteInfo.latitude = lat;
                  favoriteInfo.mainText = place.mainText;
                  favoriteInfo.text = favoriteTextController.text;

                _insertRecentSearch(recentSearchInfo);
              },
            ),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Container(
                  height:80,
                  width: 80,
                  padding: EdgeInsets.all(10),
                  child: RawMaterialButton(
                    onPressed:(){ favoriteInfo.icon = 1; },
                    elevation: 0,
                    fillColor: Color(0xff47c2bb),
                    child: Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 40,
                    ),
                    shape: CircleBorder(),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffe5e3dd),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),]
                  ),
                ),
                Container(
                  height:80,
                  width: 80,
                  padding: EdgeInsets.all(10),
                  child: RawMaterialButton(
                    onPressed:() { favoriteInfo.icon = 2; },
                    elevation: 0,
                    fillColor: Color(0xff75b8f4),
                    child: Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 40,
                    ),
                    shape: CircleBorder(),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffe5e3dd),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),]
                  ),
                ),
                Container(
                  height:80,
                  width: 80,
                  padding: EdgeInsets.all(10),
                  child: RawMaterialButton(
                    onPressed:() { favoriteInfo.icon = 3; },
                    elevation: 0,
                    fillColor: Color(0xffdd84c6),
                    child: Icon(
                      Icons.book,
                      color: Colors.white,
                      size: 40,
                    ),
                    shape: CircleBorder(),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffe5e3dd),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),]
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
          ],
        ),
        buttons: [
          DialogButton(
              color: Color(0xfff7b413),
              radius: BorderRadius.circular(15),
              onPressed: () {
                if( favoriteInfo.icon == null ) { showMyDialog(context,"아이콘을 선택 해주세요!"); }
                if( favoriteInfo.latitude == null ) { showMyDialog(context,"장소를 검색 해주세요."); }

                else {
                  _insertFavorite(favoriteInfo);
                  print('favorite db insert');
                  Navigator.pop(context);
                  _updateFavoriteIcon();
                }
              },
              child: Text("저장", style: TextStyle(color: Colors.white, fontSize: 20,fontFamily: 'BMJUA'))
          ),
        ],
        closeFunction: () {}
      ).show();
    }
  }
}

_insertRecentSearch ( RecentSearch recentSearchInfo ) { print('recent insert'); KikeeDB.instance.insertRecentSearch(recentSearchInfo); }
_insertFavorite ( Favorite favoriteInfo ) { print('id: ' + favoriteInfo.id.toString() ); KikeeDB.instance.insertFavorite(favoriteInfo); }
_updateFavorite ( Favorite favoriteInfo ) { KikeeDB.instance.updateFavorite(favoriteInfo); }
_deleteFavorite ( int id ) { KikeeDB.instance.deleteFavorite(id); }