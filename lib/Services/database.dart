import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DataService{

  User user = FirebaseAuth.instance.currentUser;
  
  Future<String> addProduct( 

    String productName,
    List productIdList,
    Timestamp purchase,
    Timestamp expiry,
    String category,
    String manufacturer,
    String invoice,
    String address, 
    String fileimgname,
    String filedocname,
    String billtype,
    String retailer,
    String retailerAddress,
    var filedoc,
    var fileimg,

  ) async{ 

    try{

      String urldoc;
      String urlimg;
      String uid = user.uid;

      int a = productIdList == null ? 100 : int.parse(productIdList.last.split('P').last) + 1;
      String productId = 'P$a';
  
      //first upload files to storage
     
      Reference storageReference1 = FirebaseStorage.instance.ref().child("users/$uid/$productId/bill/$filedocname");
      Reference storageReference2 = FirebaseStorage.instance.ref().child("users/$uid/$productId/image/$fileimgname");

      if(filedoc != null){
        final UploadTask uploadTask1 = storageReference1.putFile(filedoc);
        final TaskSnapshot downloadUrl1 = (await uploadTask1);
        urldoc = (await downloadUrl1.ref.getDownloadURL());

      }
      if(fileimg != null){
        final UploadTask uploadTask2 = storageReference2.putFile(fileimg);
        final TaskSnapshot downloadUrl2 = (await uploadTask2);
        urlimg = (await downloadUrl2.ref.getDownloadURL());
      }
    
      
      //then upload to firestore

      List<Map> bill = filedoc == null ? [] : [{
        'name' : filedocname,
        'type' : billtype,
        'url' : urldoc
      }];

      Map product = {
        'added_by' : user.displayName,
        'added_on' : Timestamp.now(),
        'address_id' : address,
        'bill' : bill,
        'category' : category,
        'expiry' : expiry,
        'image' : fileimg == null ? null : urlimg,
        'invoice_no' : invoice,
        'isActive' : true,
        'manufacturer' : manufacturer,
        'name' : productName,
        'purchase' : purchase,
        'retailer' : retailer,
        'retailer_address' : retailerAddress,
      };

      
      
      await FirebaseFirestore.instance.collection('customers').doc(uid).set({
        '$productId' : product,
        'products' : FieldValue.arrayUnion([productId])
      }, SetOptions(merge: true)); 
      
      //await FirebaseFirestore.instance.collection('customers').doc(uid).set({
      //  '$productId' : product,
      //  'products' : FieldValue.arrayUnion([productId])
     // },merge: true); 
     
      return 'success';
    }catch(e){
      print(e.toString());
      return 'error';
    }
  }


  Future deleteProducts(String productId, int productListLength) async{
   
    try{
      await FirebaseFirestore.instance.collection('customers').doc(user.uid).update({
        '$productId' : FieldValue.delete(),
        'products' : productListLength == 1 ? FieldValue.delete() : FieldValue.arrayRemove([productId])
      });
      return 'success';
    }
    catch(e){
      return 'error';
    }  
  }

  Stream<DocumentSnapshot> getData() async* {

    yield* FirebaseFirestore.instance.collection('customers').doc(user.uid).snapshots(); 
    
  }

  Future getCategory() async{
    return await FirebaseFirestore.instance.collection('product_categories').get(); 
  }

  Future getManufacturer() async{
    return await FirebaseFirestore.instance.collection('manufacturers').get();
  }


  Future addNewAddress(String address, String city, String state, String country, int pincode, int phone, String person , String landmark, String addId) async{

    int a = addId == null ? 100 : int.parse(addId.split('ADD').last) + 1;
    String id = 'ADD$a';

    Map data = {
      'id' : id,
      'address' : address,
      'city' : city,
      'state' : state,
      'country' : country,
      'pincode' : pincode, 
      'phone' : phone,
      'person_name' : person,
      'landmark' : landmark
    };
    try{
      await FirebaseFirestore.instance.collection('customers').doc(user.uid).set({
        'addresses' : FieldValue.arrayUnion([data]),

      },SetOptions(merge: true));
      
      return 'success';
    }
    catch(e){
      return 'error';
    }
  }

  Future deleteAddress(
    String address, 
    String city, 
    String state, 
    String country, 
    int pincode, 
    int phone, 
    String person , 
    String landmark, 
    String addId , 
    int addressListLength) async{

    Map data = {
      'id' : addId,
      'address' : address,
      'city' : city,
      'state' : state,
      'country' : country,
      'pincode' : pincode, 
      'phone' : phone,
      'person_name' : person,
      'landmark' : landmark
    };

    try{
      await FirebaseFirestore.instance.collection('customers').doc(user.uid).update({
        'addresses' : addressListLength == 1 ? FieldValue.delete() : FieldValue.arrayRemove([data])
      });
      return 'success';

    }catch(e){
      return 'error';
    }
    
  }

  Future updateAddress(String addressId, String productId) async{

    try{
      await FirebaseFirestore.instance.collection('customers').doc(user.uid).update({
        '$productId.address_id' : addressId
      });
      return 'success';

    }catch(e){
      return 'error';
    }
    
  }

  Future<String> uploadItemBill(dynamic file,String fileType,String filename, String productId,BuildContext context) async {
  
  //first upload files in storage
   try {

    String uid = user.uid;

    Reference storageReference =  FirebaseStorage.instance.ref().child("users/$uid/$productId/bill/$filename");

    final UploadTask uploadTask = storageReference.putFile(file);
    final TaskSnapshot downloadUrl = (await uploadTask);
    final String url = (await downloadUrl.ref.getDownloadURL());

   // then upload url in firestore

    var values = {
      'name' : filename,
      'type' : fileType, 
      'url' : url
    };

    await FirebaseFirestore.instance.collection('customers').doc(uid).update({
      '$productId.bill' : FieldValue.arrayUnion([values]),
       
    });

  }catch(e){
    print(e);
    return 'error';
  }
  return 'success';
  }

  Future deleteBill(String productId, String name, String type, String url)async {
    var values = {
      'name' : name,
      'type' : type,
      'url' : url
    };

    try{
      await FirebaseFirestore.instance.collection('customers').doc(user.uid).update({
        '$productId.bill' : FieldValue.arrayRemove([values]),
              
      });
      return 'success';

    }catch(e){
      return 'error';
    }
       
  }
}
