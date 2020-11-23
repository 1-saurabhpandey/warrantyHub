import 'package:flutter/cupertino.dart';

class DataModel extends ChangeNotifier{
  
  var productsData;
  List addressData;
  List catmanStream;
  var chipdata;

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

  void setchipdata(var data){
   
    chipdata = data;
    notifyListeners();
  }

  dynamic getchipdata(){
    
    return chipdata;
  }

}