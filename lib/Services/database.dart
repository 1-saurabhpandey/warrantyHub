import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DataService{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<String> addProduct( 

    String productName ,List productIdList , Timestamp purchase , Timestamp expiry ,String category ,
    String manufacturer , String invoice , String address , var fileimg , String fileimgname , var filedoc , String filedocname, 
    String billtype , String retailer, String retailerAddress
  ) async{ 

    try{
      final User user = _auth.currentUser;
      final uid = user.uid;

      int a = productIdList == null ? 100 : int.parse(productIdList.last.split('P').last) + 1;
      String productId = 'P$a';
  
      //first upload files to storage
      String urldoc;
      String urlimg;

      StorageReference storageReference1 = FirebaseStorage.instance.ref().child("users/$uid/$productId/bill/$filedocname");
      StorageReference storageReference2 = FirebaseStorage.instance.ref().child("users/$uid/$productId/image/$fileimgname");

      if(filedoc != null){
        final StorageUploadTask uploadTask1 = storageReference1.putFile(filedoc);
        final StorageTaskSnapshot downloadUrl1 = (await uploadTask1.onComplete);
        urldoc = (await downloadUrl1.ref.getDownloadURL());

      }
      if(fileimg != null){
        final StorageUploadTask uploadTask2 = storageReference2.putFile(fileimg);
        final StorageTaskSnapshot downloadUrl2 = (await uploadTask2.onComplete);
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
      }[true]); 
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
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    try{
      await Firestore.instance.collection('customers').document(uid).updateData({
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
    
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    yield* Firestore.instance.collection('customers').document(uid).snapshots(); 
    
  }

  Future getCategory() async{
    return await Firestore.instance.collection('product_categories').getDocuments(); 
  }

  Future getManufacturer() async{
    return await Firestore.instance.collection('manufacturers').getDocuments();
  }


  Future addNewAddress(String address, String city, String state, String country, int pincode, int phone, String person , String landmark, String addId) async{
    
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

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
      await Firestore.instance.collection('customers').document(uid).setData({
        'addresses' : FieldValue.arrayUnion([data])
      },merge: true);
      return 'success';
    }
    catch(e){
      return 'error';
    }
  }

  Future deleteAddress(String address, String city, String state, String country, int pincode, int phone, String person , String landmark, String addId , int addressListLength) async{


    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

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
      await Firestore.instance.collection('customers').document(uid).updateData({
        'addresses' : addressListLength == 1 ? FieldValue.delete() : FieldValue.arrayRemove([data])
      });
      return 'success';

    }catch(e){
      return 'error';
    }
    
  }

  Future updateAddress(String addressId, String productId) async{

    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    try{
      await Firestore.instance.collection('customers').document(uid).updateData({
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
     
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

   StorageReference storageReference =  FirebaseStorage.instance.ref().child("users/$uid/$productId/bill/$filename");

    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());

   // then upload url in firestore

    var values = {
      'name' : filename,
      'type' : fileType, 
      'url' : url
    };

    await Firestore.instance.collection('customers').document(uid).updateData({
      '$productId.bill' : FieldValue.arrayUnion([values]),
       
    });

  }catch(e){
    print(e);
    return 'error';
  }
  return 'success';
  }

  Future deleteBill(String productId, String name, String type, String url)async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    var values = {
      'name' : name,
      'type' : type,
      'url' : url
    };

    try{
      await Firestore.instance.collection('customers').document(uid).updateData({
        '$productId.bill' : FieldValue.arrayRemove([values]),
              
      });
      return 'success';

    }catch(e){
      return 'error';
    }
       
  }
}
