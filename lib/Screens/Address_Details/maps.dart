import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
 

class MapsPage extends StatefulWidget {

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  
  late GoogleMapController controller;
  late Set<Marker> listMarkers = Set<Marker>();
  late BitmapDescriptor markerIcon;
  late String address;
  late MapType maptype = MapType.normal;
  late CameraPosition? initialPosition ;
   

  @override
  void initState(){
    super.initState();
    getCurrentLocation();
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5), 'lib/images/mapicon.png').then((value){
        markerIcon = value; 
      });
  }
 
  void onMapCreated(GoogleMapController con,){
    controller = con; 
    addMarkers(Coordinates(initialPosition?.target.latitude, initialPosition?.target.longitude));
  }
    
   getCurrentLocation(){    
     Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value){
      setState(() {  
        initialPosition = CameraPosition(target: LatLng(value.latitude,value.longitude),zoom: 17);
      });
      }
    ).catchError((onError){
      alertBox(context, 'Location Permission is Denied,Please allow it in the Settings');
    });
  }

  void search(BuildContext context){
    
      Geocoder.local.findAddressesFromQuery(address).then((value){
        controller. animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(value[0].coordinates.latitude, value[0].coordinates.longitude),
          zoom: 17
        )
      ));
    }
    ).catchError((onError){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location Not Found'),
        )
      );
    });
      
    
  }
  void addMarkers(Coordinates c){
    setState(() {
      listMarkers.add(
        Marker(
          markerId: MarkerId('Mark'),
          draggable: true,
          position: LatLng(c.latitude,c.longitude),
          icon: markerIcon,
          onTap:() => markerDetails(c)
        )
      );
    });
    markerDetails(c);
  }

  void markerDetails(Coordinates c){

    Geocoder.local.findAddressesFromCoordinates(c).then((value){
      return showModalBottomSheet(
        context: context, 
        builder: (context){
          return Container( 
          height: 220,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 60,height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.grey
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 50),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    value[0].addressLine,
                    style: TextStyle(
                      fontSize: 20
                    ),),
                ),
              ), 

              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: Text('Save this address'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xff5458e1))
                  ) ,
                  onPressed: (){
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(value[0]);
                  },
                ),
              )
            ],
          ),
        );
      });
    });
  }

  Future alertBox(BuildContext context, String alertMessage){
   
    return  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))), 
          title: Text('Oops...'),
          content: Text(alertMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: initialPosition != null ? Stack(  
          children: [ 
             
            GoogleMap( 
              onMapCreated: onMapCreated,   
              initialCameraPosition: initialPosition! ,  
              onTap: (value){
                addMarkers(Coordinates(value.latitude, value.longitude));  
              },
              markers: listMarkers,
              zoomControlsEnabled: false,    
              mapType: maptype, 
            ),

            Align(
              alignment: Alignment.topCenter,
              child: Card(
                shape:RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(60),
                    right: Radius.circular(60)
                  )),
                elevation: 8,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: ListTile(
                    
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop()),
                    
                    title: TextFormField(
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search your address',
                        hintStyle: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 18
                          )
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val){
                        address = val;
                      },
                      onFieldSubmitted: (val) => search(context) ,
                    
                    ),
                  ),
                ),
              ),
            ), 
          ],
        ) : Container(child: Center(child: CircularProgressIndicator(),),)
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Card(
            elevation: 7,color: Color(0xff5458e1),
            shape: RoundedRectangleBorder( 
              borderRadius: BorderRadius.circular(50)
            ),
            child: Container(
              height: 55,width: 55, 
              child: IconButton(
                icon: Icon(Icons.map,color: Colors.white,), 
                tooltip: 'Change Map Type',
                onPressed: (){
                  setState(() {
                    maptype = maptype == MapType.normal ? MapType.satellite : MapType.normal;
                  });
                  
                },
              )
            ),
          ),
          Card(
            elevation: 7,color: Color(0xff5458e1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50)
            ),
            child: Container(
              height: 55,width: 55,
              child: IconButton(
                icon: Icon(Icons.my_location,color: Colors.white),
                tooltip: 'My Location',
                onPressed: (){
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      initialPosition!
                    )
                  );
                }
              )
            ),
          )
        ],
      ),
    );
  }
}