import 'package:get/get.dart';
import 'package:warranty_tracker/Services/DataService.dart';

class AddressViewModel extends GetxController{

  final addressStream = Get.put(DataService());

  List addressList = [];

  Map<String,dynamic>? docWriteSlot = {};

  getAddressList(){

    docWriteSlot = addressStream.addressList['doc_write_slot'];

    if(addressStream.addressList['addresses'] != null){
      addressList = addressStream.addressList['addresses'];
    }

    if(addressStream.addressList['addresses'] == null){
      addressList = [];
    }

    return addressList;
  }
}