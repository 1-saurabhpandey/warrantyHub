import 'package:get/get.dart';
import 'package:warranty_tracker/Services/DataService.dart';

class CatManViewModel extends GetxController{

  final categoryStream = Get.put(DataService());

  List categoryList = [];
  List manufacturerList = [];

  List getCategory(){
    categoryStream.categoryList.forEach((element) {
      categoryList = element['categories'];
    });
    return categoryList;
  }

  List getManufacturer(){
    categoryStream.manufacturerList.forEach((element) {
      manufacturerList = element['manufacturers'];
    });
    return manufacturerList;
  }
}