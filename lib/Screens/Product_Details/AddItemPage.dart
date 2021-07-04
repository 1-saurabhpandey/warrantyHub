import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:warranty_tracker/Screens/Address_Details/NewAddress.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/UploadingDialog.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/AlertDialog.dart';
import 'package:warranty_tracker/Screens/Product_Details/CatManSearch.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/PreviewPage.dart';
import 'package:warranty_tracker/Services/DataService.dart';
import 'package:warranty_tracker/ViewModels/AddImageBillViewModel.dart';
import 'package:warranty_tracker/ViewModels/AddressViewModel.dart';
import 'package:warranty_tracker/ViewModels/CatManViewModel.dart';

class AddItem extends StatefulWidget {
  
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
  String? address;
  
  late List<String> imageList;
  late List<String> billList;
 
  @override
  Widget build(BuildContext context){
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new item'),
        backgroundColor: Color(0xff5458e1)
      ),
      body: Container(
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
                      
                    
                GetBuilder<AddImageBillViewModel>(
                  init: AddImageBillViewModel(),
                  builder:(data){

                    imageList = data.getImageList();
                    billList = data.getBillList();
                    
                    return Column(
                      children: [
                        ListTile( 
                          leading: Icon(Icons.photo_camera,color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[600],),
                          title: Text('Upload image of product',style: TextStyle(color: Get.isDarkMode ? Colors.grey[500] : Colors.black)), 
                          onTap: () async{  
          
                            imageList.length == 5 
                            ? alertWidget('You can upload only 5 images per product') 
                            : filePicker('image',data); 
                            
                          },                   
                        ),
              
                        imageList.length > 0 
                          ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container( child: selectedFiles(imageList), color: Get.isDarkMode ? Color(0xff202020) : Color(0xffeaeaea)),
                          ) 
                          : Container(),
              
                        ListTile( 
                          leading: Icon(Icons.receipt,color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                          title: Text('Upload receipt of product',style: TextStyle(color: Get.isDarkMode ? Colors.grey[500] : Colors.black)),
                          onTap: () async{
          
                            billList.length == 5 
                            ? alertWidget('You can upload only 5 bills per product') 
                            : filePicker('bill',data);
                          } 
                        ),
                        
                        billList.length > 0 
                        ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container( child: selectedFiles(billList), color: Get.isDarkMode ? Color(0xff202020) : Color(0xffeaeaea)),
                        ) 
                        : Container(),
                      ],
                    );
                  } 
                ),
          
                buildHeader('ADDRESS ASSOCIATED WITH THIS PRODUCT',0),
          
                addressDropdown(),
          
                Padding(
                  padding: const EdgeInsets.only(top:40.0,left: 30,right: 30,bottom: 15),
                  child: Container(
                    width: 250,
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xff5458e1))),
                      onPressed: () async {
            
                        if(_formKey1.currentState!.validate()){ 
          
                          uploadingDialog('Uploading...');
          
                          await DataService().addProduct(
                            namecon.text, Timestamp.fromDate(purchase) ,
                            Timestamp.fromDate(expiry) , categorycon.text, manufacturercon.text, invoicecon.text, address!,
                            retailercon.text , retailerAddresscon.text ,imageList, billList
                          );
          
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(8), 
                        padding : EdgeInsets.all(8), 
                        decoration: BoxDecoration( 
                          borderRadius: BorderRadius.all(Radius.circular(60)),
                        ), 
                        child: Text('Save',style: TextStyle(color: Colors.white))),
                      
                    ),
                  ),
                )                  
              ]
            )
          )
        )
      ),
    );
  }

  Widget buildHeader(String text, int pad){
    return Padding(
      padding: pad != 0 ? const EdgeInsets.only(top:10, bottom:10) : const EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(10),
        height: 40,width: double.maxFinite,
        color: Get.isDarkMode ? Color(0xff323232 ) : Color(0xffe0e0e0),
        child: Text(text),
      ),
    );
  }

  Widget commonFields(String label, String? validator, TextEditingController controller){

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 15),
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        controller: controller,
        textInputAction: label == "Retailer address"  ? TextInputAction.done : TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xff757575 ))),
          labelStyle: TextStyle(color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[600]),
        ),
          
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
          labelText: type == 'expiry' ? 'Expiry Date' : 'Purchase Date',
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xff757575 ))),
          labelStyle: TextStyle(color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[600]),
        ),
  
        onShowPicker: (context, currentValue) {
          return showDatePicker(
            context: context,
            firstDate: DateTime(1900),
            initialDate: DateTime.now() ,
            lastDate: DateTime(2100),
            builder: (BuildContext context,Widget? child){
              return Theme(
                data: ThemeData(
                  colorScheme: Get.isDarkMode 
                  ? ColorScheme.dark(surface: Color(0xff5458e1),primary: Color(0xff5458e1)) 
                  : ColorScheme.light(primary: const Color(0xff5458e1)),
                ),
                child: child!,
              );
              
              
            }
          );
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

    return GetX<CatManViewModel>(
      init: CatManViewModel(),
      builder: (data){

          var result = type == 'Category' ? data.getCategory() : data.getManufacturer();
          
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
                labelText: type,
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xff757575 ))),
                labelStyle: TextStyle(color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[600]),
              ),
              validator: (val) => val!.isEmpty ? 'Please Enter $type' : null,
              onTap:  ()async{
                var result = await showSearch(context: context, delegate: SearchList(dataList,type));

                if(result != null){
                  type == 'Category' ? categorycon.text = result : manufacturercon.text = result;
                }
              },
            ),
          );
      },
    );
  }

  Widget addressDropdown(){
    bool isSelected = true;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GetX<AddressViewModel>(
        init: AddressViewModel(),
        builder:(data){

          var addressData = data.getAddressList();
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
                    + ',' + addressData[i]['state'] + ',' + addressData[i]['pincode'].toString(),

                    style: TextStyle(color: Get.isDarkMode ? Colors.grey[500] : Colors.black)
                  ),

                  value: addressData[i]['id'], 
                )
              );
            }
          }

          return DropdownButtonFormField<dynamic>(
            items: dropdownItems,
            hint: Text('Select a address'),
            isExpanded: true,
            isDense: false,
            validator: (val){
              if(val == null || val == 'new address'){
                return 'Please select an address';
              }
              else return null;
            },
            
            onChanged: (val){
              val == 'new address' 
              ? Get.to(() => NewAddress())
              : address = val;
              setState(() {
                isSelected = !isSelected;
              });
            },
            value: address,
          );
        }
      ),
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

                onTap: () => Get.to(() =>  Preview(fileName,fileList[index],fileType,null))
              ),
            )
          );
        }
      )
    ); 
  }

  Future filePicker(String fileType, AddImageBillViewModel data) async {

    List<String?> overSizedFiles = [];

    try{
      if (fileType == 'image') {

        FilePickerResult? imageFiles = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);

        if(imageFiles != null){
          if(imageFiles.count > 5 || imageList.length == 5){
            alertWidget('You can only upload 5 images per product'); 
          }

          if(imageFiles.count <= 5){
            for(int i = 0; i < imageFiles.count; i++){
  
              if(imageFiles.files[i].size! > 5000000){
                overSizedFiles.add(imageFiles.files[i].name); 
              } 
              else if(imageList.length < 5){ 
                data.setImageList(imageFiles.files[i].path);
              }
            }
          }

          if(overSizedFiles.length > 0){
            alertWidget('File size is too big! Size must be less than 5Mb' );
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
            alertWidget('You can only upload 5 bills per product'); 
          }

          if(filedoc.count <= 5){
            for(int i = 0; i < filedoc.count; i++){
  
              if(filedoc.files[i].size! > 5000000){
                overSizedFiles.add(filedoc.files[i].name); 
              } 
              if(billList.length < 5){
                data.setBillList(filedoc.files[i].path);
              }
            }
          }

          if(overSizedFiles.length > 0){
            alertWidget('File size is too big! Size must be less than 5Mb'); 
          }
        }
      }
    }catch(e){
      alertWidget('Storage access permission is denied, please allow it in the settings');
    }
  }
}