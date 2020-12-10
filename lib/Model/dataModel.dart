import 'package:flutter/cupertino.dart';

class DataModel extends ChangeNotifier{
  
  var productsData;
  List addressData;
  List catmanStream;
  List<String> imageDataList = [];
  List<String> billDataList = [];

  void setProductsData(var data){
    productsData = data;
    notifyListeners();
  }

  dynamic getProductsData(){
    return productsData;
  }

  void setAddressData(List data){
    addressData = data;
    notifyListeners();
  }

  List getAddressData(){
    return addressData;
  }

  void setCatManStream(List data){
    catmanStream = data;
  }

  dynamic getCatManStream(){
    return catmanStream;
  }

  void setProductImage(var data){
   
    imageDataList.add(data);
    notifyListeners();
  }

  dynamic getProductImage(){
    return imageDataList;
  }

  void setProductBill(var data){
   
    billDataList.add(data);
    notifyListeners();
  }

  dynamic getProductBill(){
    return billDataList;
  }

  void clearImageandBillList(){
    print('clear');
    imageDataList.clear();
    billDataList.clear();
  }

}