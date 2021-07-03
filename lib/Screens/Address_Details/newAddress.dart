import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:warranty_tracker/Screens/Address_Details/MapsPage.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/UploadingDialog.dart';
import 'package:warranty_tracker/Services/DataService.dart';
import 'package:warranty_tracker/ViewModels/AddressViewModel.dart';

// ignore: must_be_immutable
class NewAddress extends StatelessWidget {

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

    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new address'),
        backgroundColor: Color(0xff5458e1),
      ),
      body: Container(
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
                        Placemark? result = await Get.to(() => MapsPage());
                        
                        addresscon.text = result?.name ?? '';
                        citycon.text = result?.subAdministrativeArea ?? '';
                        statecon.text = result?.administrativeArea ?? '';
                        landmarkcon.text = result?.street ?? '';
                        countrycon.text = result?.country ?? '';
                        pincodecon.text = result?.postalCode ?? '';
                          
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
                    child: GetX<AddressViewModel>(
                      init: AddressViewModel(),
                      builder:(data){

                        List addressData = data.getAddressList();
                        addressData.isEmpty ? lastAddressId = null : lastAddressId = addressData.last['id'];

                        return ElevatedButton(
                          
                          child: Text('Save'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color(0xff5458e1))
                          ),
                          onPressed: ()async{ 
                            if(_formKey.currentState!.validate()){

                              uploadingDialog('Uploading...');

                              await DataService().addNewAddress(
                                addresscon.text,citycon.text,statecon.text,countrycon.text,
                                int.parse(pincodecon.text),int.parse(phonecon.text),
                                personcon.text,landmarkcon.text,lastAddressId
                              );
                            }
                          }
                        );
                      } 
                    ),
                  ),
                ) 
              ],
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
          labelText: label,
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xff757575 ))),
          labelStyle: TextStyle(color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[600]),
        ),
        keyboardType: label == 'Phone number' ? TextInputType.number : label == 'Pincode' ? TextInputType.number : TextInputType.name,
        validator: (val){
          if(val!.isEmpty){
            if(con == personcon){
              return validator ;
            }
            return 'Please enter your $validator';
          }
          if(label == 'Phone number' || label == 'Pincode'){
            if(!val.isNumericOnly){
              return 'Please enter $label in numbers';
            }
          }
        } ,
      ),
    );
  }
}