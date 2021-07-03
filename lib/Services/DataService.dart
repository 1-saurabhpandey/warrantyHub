import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/SnackBar.dart';
import 'package:warranty_tracker/ViewModels/AddressViewModel.dart';
import 'package:warranty_tracker/ViewModels/ItemsViewModel.dart';

class DataService extends GetxController{

  final itemList = List<QueryDocumentSnapshot>.empty(growable: true).obs;
  final addressList = Map().obs;
  final categoryList = List<QueryDocumentSnapshot>.empty(growable: true).obs;
  final manufacturerList = List<QueryDocumentSnapshot>.empty(growable: true).obs;

  @override 
  void onInit(){
    super.onInit();
    itemList.bindStream(getProductData());
    addressList.bindStream(getAddressData());
    categoryList.bindStream(getCategory());
    manufacturerList.bindStream(getManufacturer()); 
    
  }
  
  String uid = FirebaseAuth.instance.currentUser!.uid;

  
  Stream<List<QueryDocumentSnapshot>> getProductData() async*{ 

    yield* FirebaseFirestore.instance.collection('customers').doc(uid).collection('Products').snapshots().map((event) => event.docs); 
    
  }




  Stream<Map> getAddressData() async*{ 

    yield* FirebaseFirestore.instance.collection('customers').doc(uid).snapshots().map((event) {
      if(event.data() != null){
        return event.data()!;
      }else return {};
    });
  }
  

  
 
  Stream<List<QueryDocumentSnapshot>> getCategory() async*{
    yield* FirebaseFirestore.instance.collection('product_categories').snapshots().map((event) => event.docs);
  }





  Stream<List<QueryDocumentSnapshot>> getManufacturer() async*{ 
    yield* FirebaseFirestore.instance.collection('manufacturers').snapshots().map((event) => event.docs);
  }





  Future addProduct( 

    String productName,
    Timestamp purchase,
    Timestamp expiry,
    String category,
    String manufacturer,
    String invoice,
    String address, 
    String retailer,
    String retailerAddress,
    List imageList,
    List billList,

  ) async{ 

    try{

      List billUrlList = [];
      List imgUrlList = [];
      List<Map> bill = [];
      String urldoc;
      String urlimg; 

      //getting docWrite Slot

      Map<String,dynamic>? docWriteSlot  = Get.put(AddressViewModel()).docWriteSlot;
      docWriteSlot == null ? await FirebaseFirestore.instance.collection('customers').doc(uid).set({
        'doc_write_slot' : {
          'D100' : true
        }
      }, SetOptions(merge: true)): print('');
      String docSlot = docWriteSlot != null ? docWriteSlot.keys.firstWhere((element) => docWriteSlot[element] == true) : 'D100'; 

      //getting productIdList from that document 

      List productIdList = Get.put(ItemViewModel()).getProductIdList(docSlot);
      int a = productIdList.isEmpty ? 100 : int.parse(productIdList.last.split('P').last) + 1;

      //setting productId for this new product

      String productId = 'P$a';
      
      //first upload files to storage 

      if(billList.isNotEmpty){
        for (int i = 0; i < billList.length; i++) {

          UploadTask uploadTask1 = FirebaseStorage.instance.ref().child("users/$uid/$productId/bill/Receipt ${i+1}").putFile(File(billList[i]));
          TaskSnapshot downloadUrl1 = (await uploadTask1);
          urldoc = (await downloadUrl1.ref.getDownloadURL());
          billUrlList.add(urldoc);
        }
      }

      if(imageList.isNotEmpty){
        for (int i = 0; i < imageList.length; i++) {

          UploadTask uploadTask2 = FirebaseStorage.instance.ref().child("users/$uid/$productId/image/Image ${i+1}").putFile(File(imageList[i]));
          TaskSnapshot downloadUrl2 = (await uploadTask2);
          urlimg = (await downloadUrl2.ref.getDownloadURL());
          imgUrlList.add(urlimg);
        }
      }
      
      //then upload to firestore

      if(billUrlList.isNotEmpty){
        for (int i = 0; i < billList.length; i++) {

          String ext = billList[i].split('.').last;   //storing extension of every bill
          var a = {
            'type' : ext,
            'url' : billUrlList[i]
          };
          bill.add(a);
        }
      }else{
        bill = [];
      }

      Map product = {
        'added_by' : FirebaseAuth.instance.currentUser?.displayName,
        'added_on' : Timestamp.now(),
        'address_id' : address,
        'bill' : bill,
        'category' : category,
        'expiry' : expiry,
        'image' : imgUrlList.isEmpty ? [] : imgUrlList,
        'invoice_no' : invoice,
        'isActive' : true,
        'manufacturer' : manufacturer,
        'name' : productName,
        'purchase' : purchase,
        'retailer' : retailer,
        'retailer_address' : retailerAddress,
      };

      
      
      await FirebaseFirestore.instance.collection('customers').doc(uid).collection('Products').doc(docSlot).set({
        '$productId' : product,
        'product_id_list' : FieldValue.arrayUnion([productId])
      }, SetOptions(merge: true)); 

      Get.back();
      Get.back();
      snackBar('Item added successfully!');

    }catch(e){
      snackBar('Something went wrong!');
    }
  }






  deleteProducts(String productId, int productListLength, String docSlot) async{
   
    try{

      List deleteItems = [];
      List data = Get.put(ItemViewModel()).itemList;
      Map item = data.where((e) => e['productId'] == productId).first['details'];

      if(item['image'].isNotEmpty){
        deleteItems.addAll(item['image']);
      }

      if(item['bill'].isNotEmpty){
        item['bill'].forEach((e){
          deleteItems.add(e['url']);
        });
      }

      await FirebaseFirestore.instance.collection('customers').doc(uid).collection('Products').doc(docSlot).update({

        '$productId' : FieldValue.delete(),

        //if it is a last element then delete complete idList

        'product_id_list' : productListLength == 1 ? FieldValue.delete() : FieldValue.arrayRemove([productId]) 
      });

      //deleting files from storage
      
      deleteItems.forEach((element) async{
        await FirebaseStorage.instance.refFromURL(element).delete();
      });

      Get.back();
      Get.back();
      snackBar('Item deleted successfully!');
    } 
    catch(e){
      Get.back();
      snackBar('Something went wrong!'); 
    }  
  } 






  addNewAddress(String address, String city, String state, String country, int pincode, int phone, String person , String landmark, String? addId) async{

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
      await FirebaseFirestore.instance.collection('customers').doc(uid).set({
        'addresses' : FieldValue.arrayUnion([data]),

      },SetOptions(merge: true));
      Get.back();
      Get.back();
      snackBar('Address added successfully!');
    }
    catch(e){
      Get.back();
      Get.back();
      snackBar('Something went wrong!');
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
      await FirebaseFirestore.instance.collection('customers').doc(uid).update({
        'addresses' : addressListLength == 1 ? FieldValue.delete() : FieldValue.arrayRemove([data])
      });

      Get.put(AddressViewModel()).update();
      Get.back();
      snackBar('Address deleted successfully!');

    }catch(e){
      Get.back();
      snackBar('Something went wrong!');
    }
  }






  updateAddress(String addressId, String productId,String docSlot) async{

    try{

      await FirebaseFirestore.instance.collection('customers').doc(uid).collection('Products').doc(docSlot).update({
        '$productId.address_id' : addressId
      });

      Get.put(ItemViewModel()).update();
      Get.back();

      snackBar('Address updated successfully!');

    }catch(e){
      Get.back();
      snackBar('Something went wrong!');
    }
  }







  uploadBill(File file,String fileType,String filename, String productId, String docSlot) async {
    
  //first upload files in storage
    try {

      Reference storageReference =  FirebaseStorage.instance.ref().child("users/$uid/$productId/bill/$filename");

      final UploadTask uploadTask = storageReference.putFile(file);
      final TaskSnapshot downloadUrl = (await uploadTask);
      final String url = (await downloadUrl.ref.getDownloadURL());

    // then upload url in firestore

      var values = {
        'type' : fileType, 
        'url' : url
      };

      await FirebaseFirestore.instance.collection('customers').doc(uid).collection('Products').doc(docSlot).update({
        '$productId.bill' : FieldValue.arrayUnion([values]),
        
      });

      
      Get.back();
      Get.back();
      snackBar('New receipt added successfully!');

    }catch(e){
      Get.back();
      Get.back();
      snackBar('Something went wrong!');
    }
  }





  

  Future deleteBill(String productId, String type, String url, String docSlot)async {

    var values = {
      'type' : type,
      'url' : url
    };

    try{

      await FirebaseFirestore.instance.collection('customers').doc(uid).collection('Products').doc(docSlot).update({
        '$productId.bill' : FieldValue.arrayRemove([values]),
              
      });
      await FirebaseStorage.instance.refFromURL(url).delete();

      Get.back();
      snackBar('Item receipt deleted successfully!');

    }catch(e){
      Get.back();
      snackBar('Something went wrong!');
    } 
       
  }
}