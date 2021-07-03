import 'package:get/get.dart';
import 'package:warranty_tracker/Services/DataService.dart';

class ItemViewModel extends GetxController{

  final itemsStream = Get.put(DataService());

  List<Map<String,dynamic>> itemList = [];

  List getItemList(){
    
    itemList.clear();

    try{
      itemsStream.itemList.forEach((document) {
      
        List data = document['product_id_list'];

        data.forEach((element) {
          itemList.add({

            'docId' : document.id,
            'details' : document[element],
            'productId' : element

          });
        });
      });
      return itemList;
    }catch(e){
      return [];
    }
  }

  getProductIdList(String docId){

    List? data = [];

    try{ 
      itemsStream.itemList.forEach((element) {
        if(element.id == docId){
          data = element['product_id_list'];
        }
      });
      return data;

    }catch(e){
      
      return data = [];
    }

    
  }

}