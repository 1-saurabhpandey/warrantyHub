import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warranty_tracker/Screens/Address_Details/NewAddress.dart';
import 'package:warranty_tracker/Services/DataService.dart';
import 'package:warranty_tracker/ViewModels/AddressViewModel.dart';

class AddressPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title: Text('My addresses'),
        backgroundColor: Color(0xff5458e1),
      ),

      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
        backgroundColor: Color(0xff5458e1),
        child: Icon(Icons.add, color: Colors.white),
        elevation: 7,mini: true,
        onPressed: () => Get.to(() => NewAddress())
      ),

      body: GetX<AddressViewModel>(
        init: AddressViewModel(),
        builder: (data){

          List addressData = data.getAddressList();

          return addressData.isNotEmpty
          ? Container(
            child: ListView.builder(
              itemCount: addressData.length, 
              itemBuilder: (context, index){
              
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 7,
                    child: Container(

                      padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  addressData[index]['person_name'],
                                  style:const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17
                                  )),
                              ),
                              optionButton(addressData[index], addressData.length),
                            
                            ]),

                          Text(
                            addressData[index]['address'] + ',' ,
                            style:const TextStyle(
                              fontSize: 17
                            )),
                            
                          Text(
                            addressData[index]['landmark'],
                            style:const TextStyle(
                              fontSize: 17
                            )),

                          Text(
                            addressData[index]['city'] + ',' + ' ' + addressData[index]['state'] + ' ' + addressData[index]['pincode'].toString(),
                            style:const TextStyle(
                              fontSize: 17
                            )),

                          Text(
                            addressData[index]['country'],
                            style: const TextStyle(
                              fontSize: 17
                            )),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text('Phone number: ${addressData[index]['phone']}',
                                  style: const TextStyle(
                                    fontSize: 17
                                )),
                              ),

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
          );
        }
      )
    );
  }

  Widget optionButton(var data, int addressListLength){
    
    return PopupMenuButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      itemBuilder: (_) => [
        PopupMenuItem(
          child: const Text('Delete'), 
          value: 'delete',
        )
      ],
      onSelected: (value) async {
        deletePopup(data, addressListLength);
      }
    );
  }

  Future deletePopup(var data, int addressListLength)async{

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        title: Text('Delete Address'),
        content: Text('Are you sure you want to delete this address?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel',style: TextStyle(color: Color(0xff5458e1)),),
            onPressed: () => Get.back()
          ),
          TextButton(
            child: Text('Yes',style: TextStyle(color: Color(0xff5458e1))),

            onPressed: () async {
              await DataService().deleteAddress(data['address'], data['city'], data['state'], data['country'],
                data['pincode'], data['phone'], data['person_name'], data['landmark'], data['id'], addressListLength);             
            },
          )
        ],
      )
    );
  }
} 