import 'package:flutter/cupertino.dart';

class ProductsModel extends ChangeNotifier{

  String? docId;
  List productId = [];
  List<Map> products = [];

  void setProductIdList(data){
   
  
    for(int i= 0 ; i< data.length; i++){

      for(int j = 0; j<data[i]['product_id_list'].length; j++){
        productId.add(data[i]['product_id_list'][j]);
      }

      for(int k = 0; k< productId.length; k++){
 
        String id = productId[k];

        Map product = {
          '$id' : data[i][id]
        };
    
        products.add(product); 
        
        notifyListeners();
      }
    }
  }

  dynamic getProductsData(){
    return products;
  }
 
}