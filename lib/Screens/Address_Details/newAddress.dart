import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warranty_tracker/Model/dataModel.dart';
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

  String address;
  String city;
  String state;
  String landmark;
  String country;
  int pincode;
  String personname;
  int phone;
  String lastAddressId;

  @override
  Widget build(BuildContext context) {

    List data = Provider.of<DataModel>(context).getAddressData();
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
              textSelectionColor: Color(0xff5458e1),
              textSelectionHandleColor: Color(0xff5458e1),
              accentColor: Color(0xff5458e1),
              primaryColor: Color(0xff5458e1),
              colorScheme: ColorScheme.light(primary: const Color(0xff5458e1)),
              cursorColor: Color(0xff5458e1),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary)
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column( 
                  children: [

                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                      child: TextFormField(
                        controller: addresscon,
                        decoration: InputDecoration(
                          labelText: 'Address Line'
                        ),
                        validator: (val){
                          return val.isEmpty ?  'Please enter your address' : null;
                        } ,
                        onChanged: (val){
                          address = val;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                      child: TextFormField(
                        controller: citycon,
                        decoration: InputDecoration(
                          labelText: 'City'
                        ),
                        validator: (val){
                          return val.isEmpty ? 'Please enter your city' : null;
                        },
                        onChanged: (val){
                          city = val;
                        },
                      )
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                      child: TextFormField(
                        controller: statecon,
                        decoration: InputDecoration(
                          labelText: 'State'
                        ),
                        validator: (val){
                         return val.isEmpty ? 'Please enter your state' : null ;
                        },
                        onChanged: (val){
                          state = val;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                      child: TextFormField(
                        controller: landmarkcon,
                        decoration: InputDecoration(
                          labelText: 'Landmark'
                        ),
                        validator: (val){
                         return  val.isEmpty ? 'Please enter your landmark' : null;
                        } ,
                        onChanged: (val){
                          landmark = val;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: pincodecon,
                        decoration: InputDecoration(
                          labelText: 'Pincode'
                        ),
                        validator: (val){
                         return  val.isEmpty ? 'Please enter your pincode' : null;
                        },
                        onChanged: (val){
                          pincode = int.parse(val);
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                      child: TextFormField(
                        controller: countrycon,
                        decoration: InputDecoration(
                          labelText: 'Country'
                        ),
                        validator: (val){
                          return val.isEmpty ? 'Please enter your country' : null;
                        }, 
                        onChanged: (val){
                          country = val;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                      child: TextFormField(
                        controller: personcon,
                        decoration: InputDecoration(
                          labelText: 'Person\'s name'
                        ),
                        validator: (val){
                          return val.isEmpty ? 'Please enter person\'s name' : null;
                        },
                        onChanged: (val){
                          personname = val;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        controller: phonecon,
                        decoration: InputDecoration(
                          labelText: 'Phone number'
                        ),
                        validator: (val){
                          return val.isEmpty ? 'Please enter your phone number' : null;
                        },
                        onChanged: (val){
                          phone = int.parse(val);
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Container(
                        width: 250,
                        child: RaisedButton(
                           
                          child: Text('Save'),
                          color: Color(0xff5458e1),
                          onPressed: ()async{ 
                            if(_formKey.currentState.validate()){

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

                              var result = await DataService().addNewAddress(address,city,state,country,pincode,phone,personname,landmark,lastAddressId);
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
}