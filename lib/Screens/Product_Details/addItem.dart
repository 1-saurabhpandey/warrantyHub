import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warranty_tracker/Model/dataModel.dart';
import 'package:warranty_tracker/Screens/Address_Details/newAddress.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/alert.dart';
import 'package:warranty_tracker/Screens/Product_Details/catmanSearch.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/preview.dart';
import 'package:warranty_tracker/Services/database.dart';

class AddItem extends StatefulWidget {

  final productsIdList;
  const AddItem({@required this.productsIdList});
  
  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {

  var _formKey1 = GlobalKey<FormState>();

  TextEditingController namecon = TextEditingController();
  TextEditingController purchasecon = TextEditingController();
  TextEditingController expirycon = TextEditingController();
  TextEditingController invoicecon = TextEditingController();
  TextEditingController receiptName = TextEditingController();
  TextEditingController retailercon = TextEditingController();
   
  TextEditingController retailerAddresscon = TextEditingController();
  TextEditingController manufacturercon = TextEditingController();
  TextEditingController categorycon = TextEditingController();

  late DateTime purchase ;
  late DateTime expiry ;
  late String address;

  var fileimg;
  String? fileimgname;
  var filedoc;
  String? filedocname;
  String? finaltype;
  
  var catmanStream; 
  List<String> imageList = [];
  List<String> billList = [];
 
  @override
  Widget build(BuildContext context){

    catmanStream = Provider.of<DataModel>(context).getCatManStream();
    imageList = Provider.of<DataModel>(context).getProductImage();
    billList = Provider.of<DataModel>(context).getProductBill();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new item'),
        backgroundColor: Color(0xff5458e1)),
      body: Builder(
        builder: (BuildContext context) =>
        Container(
          child: Theme(
            data: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: Color(0xff5458e1),
                selectionHandleColor: Color(0xff5458e1),
                cursorColor: Color(0xff5458e1)
              ),
              
              accentColor: Color(0xff5458e1),
              primaryColor: Color(0xff5458e1),
              colorScheme: ColorScheme.light(primary: const Color(0xff5458e1)),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary)
            ),
            child: Form(
              key: _formKey1,
            child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[

                    buildHeader('PRODUCT INFORMATION', 0),

                    commonFields('What would you like to call your product?', 'Please Enter name of product', namecon),
  
                    Column(
                      children: [
                        catmanField('Category'),
                        catmanField('Manufacturer'),
                      ],                      
                    ),

                    buildHeader('WARRANTY INFORMATION', 0),

                    dateField('purchase'),
                    dateField('expiry'),

                    commonFields('Product invoice number', 'Please enter product invoice number', invoicecon),

                    buildHeader('RETAILER DETAILS',0),

                    commonFields('Retailer name', null, retailercon),
                    commonFields('Retailer address', null, retailerAddresscon),

                    buildHeader('PRODUCT RECEIPT',0),
                          
                        
                    ListTile( 
                      leading: Icon(Icons.photo_camera),
                      title: Text('Upload image of product'), 
                      onTap: () async{  

                       imageList.length == 5 
                       ? alertWidget(context, 'You can upload only 5 images per product') 
                       : filePicker(context, 'image'); 
                        
                      },                   
                    ),
 
                    imageList.length > 0 
                      ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container( child: selectedFiles(imageList), color: Color(0xffeaeaea)),
                      ) 
                      : Container(),
  
                    ListTile( 
                      leading: Icon(Icons.receipt),
                      title: Text('Upload receipt of product'),
                      onTap: () async{

                        billList.length == 5 
                        ? alertWidget(context, 'You can upload only 5 bills per product') 
                        : filePicker(context,'bill');
                      } 
                    ),

                    billList.length > 0 
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container( child: selectedFiles(billList), color: Color(0xffeaeaea)),
                    ) 
                    : Container(),

                    buildHeader('ADDRESS ASSOCIATED WITH THIS PRODUCT',0),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: addressDropdown(),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top:40.0,left: 30,right: 30,bottom: 15),
                      child: Container(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () async {
 
                            if(_formKey1.currentState!.validate()){ 

                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context){
                                  return SimpleDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                    children: [
                                      Center(
                                        child: Padding(  
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(width:30),
                                              Text('Uploading...'),
                                            ],
                                          ),
                                        ),
                                      )
                                    ], 
                                  );
                                }
                              );

                              var result = await DataService().addProduct(
                                namecon.text, widget.productsIdList, Timestamp.fromDate(purchase) ,
                                Timestamp.fromDate(expiry) , categorycon.text, manufacturercon.text, invoicecon.text, address,
                                retailercon.text , retailerAddresscon.text ,imageList, billList
                              );

                              Navigator.of(context,rootNavigator: true).pop();
                              Navigator.of(context).pop(result);
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.all(8), 
                            padding : EdgeInsets.all(8), 
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(60)),
                              color: Color(0xff5458e1),
                            ), 
                            child: Text('Save',style: TextStyle(color: Colors.white))),
                          
                        ),
                      ),
                    )                  
                  ]
                ),
              )
            ),
          )
        ),
      )
    );
  }

  Widget buildHeader(String text, int pad){
    return Padding(
      padding: pad != 0 ? const EdgeInsets.only(top:10, bottom:10) : const EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(10),
        height: 40,width: double.maxFinite,
        color: Color(0xffe0e0e0),
        child: Text(text),
      ),
    );
  }

  Widget commonFields(String label, String? validator, TextEditingController controller){

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 15),
      child: TextFormField(
        controller: controller,
        textInputAction: label == "Retailer address" ? TextInputAction.done : TextInputAction.next,
        decoration: InputDecoration(
          labelText: label),
        validator: (val ){
          return val!.isEmpty ? validator : null;
        },
      ),
    );
  }

  Widget dateField(String type){
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
      child: DateTimeField(

        format: DateFormat("yyyy-MM-dd"),
        controller: type == 'expiry' ? expirycon : purchasecon,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText:type == 'expiry' ? 'Expiry Date' : 'Purchase Date',
        ),
  
        onShowPicker: (context, currentValue) {
          return showDatePicker(
            context: context,
            firstDate: DateTime(1900),
            initialDate: currentValue! ,
            lastDate: DateTime(2100));
        },

        validator: ( val){
           return val == null ? 'Please enter $type date' : null;
        },
        onChanged: (val){
          type == 'expiry' ? expiry = val! : purchase = val!;
        },
      ),
    );
  }

  Widget catmanField(String type){

    List<String> dataList = [];
 
    var stream = type == 'Category' ? catmanStream[0] : catmanStream[1]; 

    return FutureBuilder<QuerySnapshot>(
      future: stream,
      builder: (context,snap){
        if(snap.hasData){

          List result = type == 'Category' ? snap.data?.docs[0]['categories'] : snap.data?.docs[0]['manufacturers'];

          for(int i = 0; i< result.length; i++){
            dataList.add(result[i]['name']);
          }
          dataList.sort((a,b) => a.compareTo(b));

          return Padding(
            padding: const EdgeInsets.fromLTRB(30, 17, 30, 12),
            child: TextFormField(
              controller: type == 'Category' ? categorycon : manufacturercon,
              readOnly: true,
              decoration: InputDecoration(
                labelText: type
              ),
              validator: (val) => val!.isEmpty ? 'Please Enter $type' : null,
              onTap:  ()async{
                var result = await showSearch(context: context, delegate: SearchList(dataList,type));
                type == 'Category' ? categorycon.text = result : manufacturercon.text = result; 
              },
              
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget addressDropdown(){
    List? addressData = Provider.of<DataModel>(context).getAddressData();
    List<DropdownMenuItem> dropdownItems = [];

    dropdownItems.add(
      DropdownMenuItem(
        child: Text('Add new address',style:TextStyle(color: Color(0xff5458e1), fontWeight: FontWeight.bold)),
        value: 'new address',
      ),
    );

    if(addressData != null){
      for(int i=0 ; i< addressData.length; i++){
        dropdownItems.add(
          DropdownMenuItem(
            child: Text( 
              addressData[i]['address'] + ',' + addressData[i]['city']
              + ',' + addressData[i]['state'] + ',' + addressData[i]['pincode'].toString()
            ),

            value: addressData[i]['id'], 
          )
        );
      }
    }

    return DropdownButtonFormField<dynamic>(
      items: dropdownItems,
      isDense: true,
      hint: Text('Select a address'),

      validator: (val){
        if(val == null || val == 'new address'){
          return 'Please select an address';
        }
        else return null;
      },
      
      onChanged: (val){
        val == 'new address' 
        ? Navigator.push(context, MaterialPageRoute(builder: (_) => NewAddress()))
        : address = val;

      },
       
      value: address,
    );
  }

  Widget selectedFiles(List fileList){

    return Column(
      children: List.generate(
        fileList.length,(index){

          String fileType = fileList[index].split('.').last;
          String fileName = fileList[index].split('/').last.split('.').first; 
          double size = num.parse((File(fileList[index]).lengthSync() / 1000).toStringAsFixed(1)).toDouble() ;
          String sizeType;

          if(size > 1000){
            size = num.parse((size / 1000).toStringAsFixed(1)).toDouble(); 
            sizeType = 'MB';
          } 
          else{ 
            sizeType = 'kB';
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(30, 2, 30, 2), 
            child: Card(
              elevation: 5, 
              child: ListTile(  
                leading: fileType == 'pdf' ? Icon(Icons.picture_as_pdf, color: Colors.red) : Icon(Icons.image, color: Colors.blue),
                title: Text(fileName),
                subtitle: Text('$size $sizeType'),
                trailing: InkWell(
                  child: Icon(Icons.close),
                  onTap: (){
                    setState(() {
                      fileList.removeAt(index);
                    });
                  },
                ), 

                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Preview(fileName,fileList[index],fileType,null))), 
              ),
            )
          );
        }
      )
    ); 
  }

  Future filePicker(BuildContext context,String fileType) async {

    List<String?> overSizedFiles = [];

    if (fileType == 'image') {

      FilePickerResult? imageFiles = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);

      if(imageFiles != null){
        if(imageFiles.count > 5 || imageList.length == 5){
          alertWidget(context, 'You can only upload 5 images per product'); 
        }

        if(imageFiles.count <= 5){
          for(int i = 0; i < imageFiles.count; i++){

            if(imageFiles.files[i].size! > 5000){
              overSizedFiles.add(imageFiles.files[i].name); 
            } 
            else if(imageList.length < 5){
              Provider.of<DataModel>(context,listen: false).setProductImage(imageFiles.files[i].path);
            }
          }
        }

        if(overSizedFiles.length > 0){
          alertWidget(context, 'File size is too big! Size must be less than 5Mb' );
        }
      }
    }

    if (fileType == 'bill') {

      FilePickerResult? filedoc = await FilePicker.platform.pickFiles( 
        type: FileType.custom, allowedExtensions: ['pdf','jpg','jpeg','png'],
        allowMultiple: true
      );

      if(filedoc != null){
        if(filedoc.count > 5 || billList.length == 5){
          alertWidget(context, 'You can only upload 5 bills per product'); 
        }

        if(filedoc.count <= 5){
          for(int i = 0; i < filedoc.count; i++){
 
            if(filedoc.files[i].size! > 5000){
              overSizedFiles.add(filedoc.files[i].name); 
            } 
            if(billList.length < 5){
              Provider.of<DataModel>(context,listen: false).setProductBill(filedoc.files[i].path);
            }
          }
        }

        if(overSizedFiles.length > 0){
          alertWidget(context, 'File size is too big! Size must be less than 5Mb'); 
        }
      }
    }
  }
}