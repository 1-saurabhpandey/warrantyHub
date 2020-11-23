import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warranty_tracker/Model/dataModel.dart';
import 'package:warranty_tracker/Screens/Address_Details/newAddress.dart';
import 'package:warranty_tracker/Screens/Product_Details/catmanSearch.dart';
import 'package:warranty_tracker/Services/database.dart';

class AddItem extends StatefulWidget {

  final productsIdList;
  const AddItem({Key key, @required this.productsIdList}) : super(key: key);
  
  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {

  var _formKey1 = GlobalKey<FormState>();
  var _formKey2 = GlobalKey<FormState>();


  TextEditingController namecon = TextEditingController();
  TextEditingController purchasecon = TextEditingController();
  TextEditingController expirycon = TextEditingController();
  TextEditingController invoicecon = TextEditingController();
  TextEditingController receiptName = TextEditingController();
  TextEditingController retailercon = TextEditingController();
  TextEditingController retailerAddresscon = TextEditingController();
  TextEditingController manufacturercon = TextEditingController();
  TextEditingController categorycon = TextEditingController();

  DateTime purchase ;
  DateTime expiry ;
  String address;

  var fileimg;
  String fileimgname;
  var filedoc;
  String filedocname;
  String finaltype;
  var chipname;

  var catmanStream; 
  bool isChipActive = true;
  List<String> chipList = [];
 
  @override
  Widget build(BuildContext context){

    catmanStream = Provider.of<DataModel>(context).getCatManStream();
    chipname = Provider.of<DataModel>(context).getchipdata();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new item'),
        backgroundColor: Color(0xff5458e1)),
      body: Builder(
        builder: (BuildContext context) =>
        Container(
          child: Theme(
            data: ThemeData(
              textSelectionColor: Color(0xff5458e1),
              textSelectionHandleColor: Color(0xff5458e1),
              accentColor: Color(0xff5458e1),
              primaryColor: Color(0xff5458e1),
              colorScheme: ColorScheme.light(primary: const Color(0xff5458e1)),
              cursorColor: Color(0xff5458e1),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary)
            ),
            child: Form(
              key: _formKey1,
            child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[

                    // buildHeader('PRODUCT INFORMATION', 0),

                    // commonFields('What would you like to call your product?', 'Please Enter name of product', namecon),
  
                    // Column(
                    //   children: [
                    //     catmanField('Category'),
                    //     catmanField('Manufacturer'),
                    //   ],
                    // ),

                    // buildHeader('WARRANTY INFORMATION', 0),

                    // dateField('purchase'),
                    // dateField('expiry'),

                    // commonFields('Product invoice number', 'Please enter product invoice number', invoicecon),

                    // buildHeader('RETAILER DETAILS',0),

                    // commonFields('Retailer name', null, retailercon),
                    // commonFields('Retailer address', null, retailerAddresscon),

                    buildHeader('PRODUCT RECEIPT',0),
                          
                        
                    ListTile(
                      leading: Icon(Icons.photo_camera),
                      contentPadding: EdgeInsets.only(top:10,left: 50,right: 50), 
                      title: Text('Upload image of product'), 
                      onTap: () async{  

                       await filePicker(context, 'image'); 
                        
                      },                   
                    ),

                    chipList.isNotEmpty ? ListView.builder(
                      itemCount: chipList.length,
                      itemBuilder: (context,index){

                       // String chipName = chipList[index].      extract filename from path

                        return Chip(
                          label: InkWell(
                            child: Text('chipname'),
                            onTap: (){
                              //open bottom sheet to preview
                            },
                          ),

                          deleteIcon: CircleAvatar(
                            child: Icon(Icons.close),
                          ),

                          onDeleted: (){
                            chipList.removeAt(index);
                          },
                        );
                      }
                    ) : Container(),

                    // isChipActive ? Chip(
                    //   label: chipname != null ? Text(chipname) : Container(),
                    //   deleteIcon: Icon(Icons.close),
                    //   onDeleted: (){
                    //     setState(() {
                    //       isChipActive = false; 
                    //     });
                    //   },
                    // ) : Container(),
  
                    ListTile( 
                      leading: Icon(Icons.receipt),
                      contentPadding: EdgeInsets.only(left: 50,right: 50),
                      title: Text('Upload receipt of product'),
                      onTap: () async{
                        selectReceiptType(context);
                      } 
                    ),  

                    buildHeader('ADDRESS ASSOCIATED WITH THIS PRODUCT',0),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: addressDropdown(),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top:40.0,left: 30,right: 30,bottom: 15),
                      child: Container(
                        width: 250,
                        child: RaisedButton(
                          onPressed: () async {
 
                            if(_formKey1.currentState.validate()){ 

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
                                          child: Text('Uploading...'),
                                        ),
                                      )
                                    ], 
                                  );
                                }
                              );

                              var result = await DataService().addProduct(namecon.text, widget.productsIdList, Timestamp.fromDate(purchase) ,
                                Timestamp.fromDate(expiry) , categorycon.text, manufacturercon.text, invoicecon.text, address, fileimg,
                                fileimgname, filedoc, filedocname, finaltype , retailercon.text , retailerAddresscon.text
                              );

                              Navigator.of(context,rootNavigator: true).pop();
                              Navigator.of(context).pop(result);
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.all(8), 
                            padding : EdgeInsets.all(8), 
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(60))), 
                            child: Text('Save',style: TextStyle(color: Colors.white))),
                          color: Color(0xff5458e1),
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

  Widget commonFields(String label, String validator, TextEditingController controller){

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label),
        validator: (String val ){
          return val.isEmpty ? validator : null;
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

        decoration: InputDecoration(
          labelText:type == 'expiry' ? 'Expiry Date' : 'Purchase Date',
        ),
  
        onShowPicker: (context, currentValue) {
          return showDatePicker(
            context: context,
            firstDate: DateTime(1900),
            initialDate: currentValue ?? DateTime.now(),
            lastDate: DateTime(2100));
        },

        validator: (val){
           return val == null ? 'Please enter $type date' : null;
        },
        onChanged: (val){
          type == 'expiry' ? expiry = val : purchase = val;
        },
      ),
    );
  }

  Widget catmanField(String type){

    List<String> dataList = [];
 
    var stream = type == 'Category' ? catmanStream[0] : catmanStream[1];

    return FutureBuilder(
      future: stream,
      builder: (context,snap){
        if(snap.hasData){

          List result = type == 'Category' ? snap.data.documents[0]['categories'] : snap.data.documents[0]['manufacturers'];

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
              validator: (val) => val.isEmpty ? 'Please Enter $type' : null,
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
    List addressData = Provider.of<DataModel>(context).getAddressData();
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

    return DropdownButtonFormField(
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

  Future selectReceiptType(BuildContext context){
    return showDialog(
      context: context,
      builder: (BuildContext dcontext){
        return SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))), 
          children: [
            Column(
              children: <Widget>[

                SizedBox(height:10),

                Align(
                  child: Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      color: Colors.grey))),

                SizedBox(height: 20,),

                ListTile(
                  leading: Icon(Icons.image,color: Colors.blue,),
                  title: Text('Upload as image'),
                  onTap: (){
                    filePicker(context, 'billimage');
                    Navigator.of(dcontext).pop();
                  }),

                ListTile(
                  leading: Icon(Icons.picture_as_pdf,color: Colors.red,),
                  title: Text('Upload as PDF'),
                  onTap: (){
                    filePicker(context, 'pdf');
                    Navigator.of(dcontext).pop();
                  },
                )
              ],
            ),
          ]
        );
      }
    );
  }

  Future filePicker(BuildContext context,String fileType) async {

    List<String> overSizedFiles = [];

    if (fileType == 'image') {

      FilePickerResult imageFiles = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);
    
      if(imageFiles.count > 1){
        for(int i =0; i < imageFiles.count; i++){

          if(imageFiles.files[i].size > 5000000){
            overSizedFiles.add(imageFiles.files[i].name);
            
          } 
          else{
            chipList.add(imageFiles.files[i].path);
          }
        }
      }
      else if(imageFiles.files.first.size > 5000000){ 
        sizeAlertDialog(context, 'File size is too big! Size must be less than 5Mb' ); 
      }
      else{
        chipList.add(imageFiles.files.first.path);
      }

      if(overSizedFiles.length > 0){
        sizeAlertDialog(context, 'File size is too big! Size must be less than 5Mb' );
      }
      // if (await fileimg.count > 5000000){
      //   sizeAlertDialog(context, 'File size is too big! Size must be less than 5Mb' );
      // } 
      // else{
      //   preview(context,fileimg,fileType);
      // }
    }

    if (fileType == 'billimage') {
      filedoc = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);

      if ( await filedoc.count  > 5000000){
        sizeAlertDialog(context, 'File size is too big! Size must be less than 5Mb' );
      }
      else{
        preview(context,filedoc,fileType);
      }
    }

    if (fileType == 'pdf') {
      filedoc = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      String extensionCheck = filedoc.path.split('.').last; 
       
      // to eliminate other extensions
      if(extensionCheck != 'pdf'){
        sizeAlertDialog(context, 'Only PDF documents allowed');
      }
      else{

        if(await filedoc.count > 5000000 ){
          sizeAlertDialog(context, 'File size is too big! Size must be less than 5Mb');
        }
        else{
          preview(context, filedoc, fileType);
        }
      }       
    }
  }
  // Size alert dialog

  Future sizeAlertDialog(BuildContext context, String alertMessage){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))), 
          title: Text('Sorry...'),
          content: Text(alertMessage),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    ); 
  }
  // preview
  Future preview(BuildContext context , FilePickerResult file1, String type) async{
    
    String path = file1.paths.first;
    File file = File(path);

    if(type == 'pdf' || type == 'billimage'){
      filedocname = file.path.split('/').reversed.first.split('.').first;
      receiptName = TextEditingController(text: filedocname);
    }

    var document = type == 'pdf' ?  await PDFDocument.fromFile(file) : null;

    return showBottomSheet(
      context: context,
      builder:(BuildContext context){
        return Container(
          child: ListView(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter ,
                child: Container(

                  child: type == 'pdf'
                  ? Container(
                    padding: EdgeInsets.all(10), 
                    width: 480,height: 480, 
                    child: PDFViewer (document: document,showPicker: false,)) 
  
                  : Image.file(file,width: 450,height: 450,)
                )),

                type != 'image' ? Form(
                  key: _formKey2,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:20,right: 20,bottom: 10,top:10),
                        child: TextFormField(
                          controller: receiptName,
                          cursorColor: Color(0xff5458e1),
                          decoration: InputDecoration(
                            focusColor: Color(0xff5458e1),
                            fillColor: Color(0xff5458e1), 
                          
                            labelText: 'File name', 
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),),
                          validator: (String val){
                            return val.isEmpty ? 'Please Enter the receipt name' : null;
                          },
                          onChanged: (val){ 
                            filedocname = val;
                          },
                        ),
                      ),
                    ]
                  )
                ) 
                      
              : Container(),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(color: Color(0xff5458e1),
                      onPressed: (){                // again calling filepicker to get new file
                        filePicker(context, type);
                      },      
                    
                      child: Text('Select another',style: TextStyle(color: Colors.white),)),

                    RaisedButton(
                      color:Color(0xff5458e1),
                      onPressed: (){
                        if(type == 'image'){       

                          fileimg = file;
                          fileimgname = fileimg.path.split('/').reversed.first.split('.').first;
                         
                          Provider.of<DataModel>(context,listen: false).setchipdata(fileimgname);
                          // Navigator.of(context).pop(fileimgname);

                        }
                      if(type != 'image' && _formKey2.currentState.validate()){
                        
                        if(type == 'billimage' || type == 'pdf'){
                          filedoc = file;
                          finaltype = type;
                        }
                        Navigator.of(context).pop();
                      } 
                    }, child: Text('Save',style: TextStyle(color: Colors.white),)),

                    
                  ],
                ),
              )
            ],
          )
        );
      } 
    );
  }
}