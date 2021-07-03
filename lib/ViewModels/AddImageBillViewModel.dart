import 'package:get/get.dart';

class AddImageBillViewModel extends GetxController{


  List<String> imageList = [];
  List<String> billList = [];

  setImageList(var data){
    imageList.add(data);
    update();
  }

  getImageList(){
    return imageList;
  }

  setBillList(var data){
    billList.add(data);
    update();
  }

  getBillList(){
    return billList;
  }
}
