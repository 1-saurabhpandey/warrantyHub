import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warranty_tracker/Model/dataModel.dart';
import 'package:warranty_tracker/Screens/Address_Details/newAddress.dart';
import 'package:warranty_tracker/Services/database.dart';

class AddressPage extends StatefulWidget {
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {

    List data = Provider.of<DataModel>(context).getAddressData();
    int addressListLength = data != null ? data.length : null;
   
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text('My addresses'),
 
      ),

      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
        backgroundColor: Color(0xff5458e1),
        child: Icon(Icons.add, color: Colors.white),
        elevation: 7,mini: true,
        onPressed: () async{ 
 
         var result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NewAddress())
        );
          if(result != null) {
            _globalKey.currentState.showSnackBar(
            SnackBar(
              content: result == 'error' ?  Text('Some error occured') : Text('New address added successfully'),
              duration: Duration(seconds: 3),
            )
          );}
        }
      ),

      body: data != null 
      ? Container(
        child: ListView.builder(
          itemCount: data.length, 
          itemBuilder: (context, index){
           
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 7,
                child: Container(

                  padding: const EdgeInsets.fromLTRB(15, 15, 5, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data[index]['person_name'],
                              style:const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17
                              )),
                          ),
                          optionButton(data[index], addressListLength),
                         
                        ]),

                      Text(
                        data[index]['address'] + ',' ,
                        style:const TextStyle(
                          fontSize: 17
                        )),
                        
                      Text(
                        data[index]['landmark'],
                        style:const TextStyle(
                          fontSize: 17
                        )),

                      Text(
                        data[index]['city'] + ',' + ' ' + data[index]['state'] + ' ' + data[index]['pincode'].toString(),
                        style:const TextStyle(
                          fontSize: 17
                        )),

                      Text(
                        data[index]['country'],
                        style: const TextStyle(
                          fontSize: 17
                        )),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text('Phone number: ${data[index]['phone']}',
                              style: const TextStyle(
                                fontSize: 17
                            )),
                          ),

                          InkWell(
                            child: Container(
                              child: Image.asset('lib/images/logo/map2.png',scale: 1.5,),
                            ),
                            // onTap: () => launchMap(data[index]['geolocation'].latitude, data[index]['geolocation'].longitude),
                          )
                        ],
                      ),
                    ], 
                  ),
                ),
              ),
            );
          },
        ),
      )
      : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("No Address\n\n",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                                  
            Text(" Click on PLUS button to add new address", 
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
          ],
        ),
      ) 
    );
  }

  Widget optionButton(var data, int addressListLength){
    
    return PopupMenuButton(
      itemBuilder: (_) => [

        PopupMenuItem(
          child: const Text('Edit'),
          value: 'edit'
        ),
        PopupMenuItem(
          child: const Text('Delete'), 
          value: 'delete',
        )
      ],
      onSelected: (value) async {

        value == 'delete'
         
        ? deletePopup(data, addressListLength)


        : print('edit');
      }
    );
  }

  void launchMap(var lat , var long) async{
    String url = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';

    if(await canLaunch(url)){
      await launch(url);
    }
  }

  Future deletePopup(var data, int addressListLength)async{

    return showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text('Delete Address'),
          content: Text('Are you sure you want to delete this address?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel',style: TextStyle(color: Color(0xff5458e1)),),
              onPressed: () {
                Navigator.of(context,rootNavigator: true).pop();
              },
            ),
            FlatButton(
              child: Text('Yes',style: TextStyle(color: Color(0xff5458e1))),

              onPressed: ()async {
                await DataService().deleteAddress(data['address'], data['city'], data['state'], data['country'],
                  data['pincode'], data['phone'], data['person_name'], data['landmark'], data['id'], addressListLength).then((value){

                    _globalKey.currentState.showSnackBar(
                      SnackBar(
                        content: value == 'success' ?  Text('Address deleted successfully') : Text('Some error occured')
                      )
                    );
                  }
                );

                Navigator.of(context,rootNavigator: true).pop();
                
              },
            )
          ],
        );
      }
    ); 
  }
} 