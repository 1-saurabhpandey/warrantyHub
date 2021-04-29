import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:geocoder/geocoder.dart';
import 'package:provider/provider.dart';
import 'package:warranty_tracker/Model/dataModel.dart';
import 'package:warranty_tracker/Screens/Address_Details/maps.dart';
import 'package:warranty_tracker/Services/database.dart';

class NewAddress extends StatefulWidget {
  @override
  _NewAddressState createState() => _NewAddressState();
}

class _NewAddressState extends State<NewAddress> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController addresscon = TextEditingController();
  TextEditingController citycon = TextEditingController();
  TextEditingController statecon = TextEditingController();
  TextEditingController landmarkcon = TextEditingController();
  TextEditingController pincodecon = TextEditingController();
  TextEditingController countrycon = TextEditingController();
  TextEditingController personcon = TextEditingController();
  TextEditingController phonecon = TextEditingController();

  String? lastAddressId;

  @override
  Widget build(BuildContext context) {

    List? data = Provider.of<DataModel>(context).getAddressData();
    data == null ? lastAddressId = null : lastAddressId = data.last['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new address'),
      ),
      body: Builder(
        builder: (BuildContext context) =>
        Container(
          child: Theme(
            data: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: Color(0xff5458e1),
                selectionHandleColor: Color(0xff5458e1),
                cursorColor: Color(0xff5458e1)
              ),
              accentColor: Color(0xff5458e1),
              primaryColor: Color(0xff5458e1),
              colorScheme: ColorScheme.light(primary: const Color(0xff5458e1)),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary)
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column( 
                  children: [

                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                      child: Card(
                        elevation: 5,
                        child: ListTile(
                          leading: Image.asset('lib/images/map.png',height: 30,width: 30),
                          title: Text('Open in Google Maps'),
                          onTap: ()async{
                            Address result = await Navigator.push(context, MaterialPageRoute(builder: (_) => MapsPage()));
                            // if(result != null){
                              
                            // }
                            addresscon.text = result.addressLine;
                            citycon.text = result.subAdminArea;
                            statecon.text = result.adminArea;
                            landmarkcon.text = result.addressLine.split(',').first;
                            countrycon.text = result.countryName;
                            pincodecon.text = result.postalCode;
                             
                          },
                        ),
                      ),
                    ),

                    Center(child: Text('Or')),

                    textFields(addresscon, 'Address Line', 'address'),
                    textFields(citycon, 'City', 'city'),
                    textFields(statecon, 'State', 'state'),
                    textFields(landmarkcon, 'Landmark', 'landmark'),
                    textFields(countrycon, 'Country', 'country'),
                    textFields(pincodecon, 'Pincode', 'pincode'),
                    textFields(personcon, 'Person\'s name', 'Please enter person\'s name'),
                    textFields(phonecon, 'Phone number', 'Phone number'),
                    Container(
                      child: Text(
                        '*Please verify the details before saving',
                        style:TextStyle(color: Colors.red)
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Container(
                        width: 250,
                        child: ElevatedButton(
                           
                          child: Text('Save'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color(0xff5458e1))
                          ),
                          onPressed: ()async{ 
                            if(_formKey.currentState!.validate()){

                              showDialog(
                                context: context,
                                builder: (context){
                                  return SimpleDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0), 
                                          child: Text('Uploading...'),
                                        ),
                                      )
                                    ], 
                                  );
                                }
                              );

                              var result = await DataService().addNewAddress(
                                addresscon.text,citycon.text,statecon.text,countrycon.text,
                                int.parse(pincodecon.text),int.parse(phonecon.text),
                                personcon.text,landmarkcon.text,lastAddressId);
                              Navigator.of(context,rootNavigator: true).pop(result);
                              Navigator.pop(context, result);
                            }
                          }
                        ),
                      ),
                    ) 
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textFields(TextEditingController con, String label, String validator){
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
      child: TextFormField(
        controller: con,
        decoration: InputDecoration(
          labelText: label
        ),
        validator: (val){
          return val!.isEmpty ?  con == personcon ? validator : 'Please enter your $validator' : null;
        } ,
      ),
    );
  }
  
}