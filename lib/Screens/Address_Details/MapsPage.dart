import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
 

class MapsPage extends StatefulWidget {

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  
  late GoogleMapController controller;
  Set<Marker> listMarkers = Set<Marker>();
  late BitmapDescriptor markerIcon;
  late String address;
  MapType maptype = MapType.normal;
  var initialPosition;
   

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
    addMarkers(initialPosition.target.latitude, initialPosition.target.longitude);
  }
    
   getCurrentLocation(){
     Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value){
      setState(() {  
        initialPosition = CameraPosition(target: LatLng(value.latitude,value.longitude),zoom: 17);
      });
      }
    ).catchError((onError){
      alertBox(context, 'Location permission is denied, please allow it in the settings');
      setState(() {  
        initialPosition = CameraPosition(target: LatLng(28.7041,77.1025),zoom: 17);
      });
    });
  }

  void search(BuildContext context){
    
    GeocodingPlatform.instance.locationFromAddress(address).then((value){
        controller. animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(value[0].latitude, value[0].longitude),
          zoom: 17
        )
      ));
    }
    ).catchError((onError){
      Get.snackbar('', 'Location not found',duration: Duration(seconds: 3));
    });
      
  }
  void addMarkers(double lat, double long){
    setState(() {
      listMarkers.add(
        Marker(
          markerId: MarkerId('Mark'),
          draggable: true,
          position: LatLng(lat,long),
          icon: markerIcon,
          onTap:() => markerDetails(lat,long)
        )
      );
    });
    markerDetails(lat,long);
  }

  void markerDetails(double lat, double long){
   
     GeocodingPlatform.instance.placemarkFromCoordinates(lat, long).then((value){
      Get.bottomSheet(
        Container( 
          height: 220,
          color: Theme.of(context).cardColor,
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
                    value[0].name! + ', ' + value[0].locality! + ', ' 
                    + value[0].subAdministrativeArea! + ', ' + value[0].postalCode! + ', ' +
                    value[0].administrativeArea! + ', ' + value[0].country!,
                    style: TextStyle(
                      fontSize: 20 
                    ),
                  ),
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
                    Get.back();
                    Get.back(result: value[0]);
                    
                  },
                ),
              )
            ],
          ),
        )
      );
    });
  }

  alertBox(BuildContext context, String alertMessage){
   
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))), 
        title: Text('Oops...'),
        content: Text(alertMessage),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Get.back();
            },
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(  
          children: [ 
             
            
            initialPosition != null ? GoogleMap( 
              onMapCreated: onMapCreated,   
              initialCameraPosition: initialPosition ,  
              onTap: (value){
                addMarkers(value.latitude, value.longitude);  
              },
              markers: listMarkers,
              zoomControlsEnabled: false,    
              mapType: maptype, 
            ) : Center(child: Container(child: CircularProgressIndicator())),

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
                      onPressed: () => Get.back()),
                    
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
        ) 
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              backgroundColor: Color(0xff5458e1),
              elevation: 7,
              shape: RoundedRectangleBorder( 
                borderRadius: BorderRadius.circular(5)
              ),
              child: Icon(Icons.map,color: Colors.white,),
              tooltip: 'Change Map Type',
              onPressed: (){
                setState(() {
                  maptype = maptype == MapType.normal ? MapType.satellite : MapType.normal;
                });
                
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              backgroundColor: Color(0xff5458e1),
              elevation: 7,
              shape: RoundedRectangleBorder( 
                borderRadius: BorderRadius.circular(5)
              ),
              child: Icon(Icons.my_location,color: Colors.white),
              tooltip: 'My Location',
              onPressed: (){
                if(initialPosition == CameraPosition(target: LatLng(28.7041,77.1025),zoom: 17)){
                  alertBox(context, 'Location permission is denied, please allow it in the settings');
                }
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    initialPosition
                  )
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}