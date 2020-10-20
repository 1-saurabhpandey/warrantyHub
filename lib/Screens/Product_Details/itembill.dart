import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warranty_tracker/Model/dataModel.dart';
import 'package:warranty_tracker/Services/database.dart';
import 'package:http/http.dart' as http;
import 'package:wc_flutter_share/wc_flutter_share.dart';

class Receipt extends StatefulWidget {

  final productid ;
   Receipt({Key key, @required this.productid,}) : super(key: key);

  @override
  _ReceiptState createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  dynamic filedoc;
  String filepath;
  String filename;
  var data;
  
  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Nothing to download';
    }
  }

  @override
  Widget build(BuildContext context){
    data = Provider.of<DataModel>(context).getProductsData();
    List receiptData = data[widget.productid]['bill'];
    
    return Scaffold(

      key: _globalKey, 
      appBar: AppBar(title: Text('Product Receipts'),
        backgroundColor: Color(0xff5458e1), 
      ),

      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
        backgroundColor: Color(0xff5458e1),
        child: Icon(Icons.add, color: Colors.white),  
        elevation: 7, mini: true,
        onPressed: (){
            
          if(receiptData.length == 5){
            limitAlert(context);
          }else selectReceiptType(context);
        }
      ),

      body: receiptData.isNotEmpty 
        ? Container(
          padding: EdgeInsets.all(10), 
          color: Color(0xfff0f4ff),
          child: ListView.builder( 
            itemCount: receiptData.length,
            itemBuilder: (context,index){
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Card(
                  elevation: 7,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(borderRadius: 
                      BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Align( 
                          alignment: Alignment.topLeft,
                          child: receiptData[index]['type'] != 'pdf'

                            ? Icon(Icons.image,size: 25, color: Colors.blue)
                            
                            : Icon(Icons.picture_as_pdf,size: 25,color: Colors.red,),

                        ),

                        SizedBox(width: 20,),
                               
                        Expanded(
                          child: InkWell(
                            child: Text(receiptData[index]['name']),
                            onTap: () => receiptData[index]['type'] != 'pdf' 
                              ? imageView(context,receiptData[index]['url'])
                              : pdfView(context, receiptData[index]['url']),
                          )
                        ),

                        optionButton(receiptData[index])
                      ],
                    )
                  ),
                ),
              );
            }                   
          )
        )
      : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("No Receipts\n\n",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                                
            Text(" Click on PLUS button to add new receipt", 
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
          ],
        ),
      )
    );
  }

  Widget optionButton(var data){

    return PopupMenuButton(
      itemBuilder: (_) => 
      [
        PopupMenuItem(
          child: Text('Delete'),
          value: 'delete',
        ),
        PopupMenuItem(
          child: Text('Download'),
          value: 'download',
        ),
        PopupMenuItem(
          child: Text('Share'),
          value: 'share',
        ),
      ],
      onSelected: (value) async{
        if(value == 'delete'){
          delete( context,widget.productid, data['name'], data['type'],data['url']);
        }
        if(value == 'download'){
          await launchURL(data['url']);
        }
        if(value == 'share'){
         await share(data['url'],data['type']);
        }
      },
    );
  }


  PersistentBottomSheetController imageView(BuildContext context , String file){

    return showBottomSheet(
      context: context, 
      builder: (BuildContext context){
        return Container(
          color: Color(0xfff0f4ff),
          child: Center(
            child: Image.network(file,
              fit: BoxFit.contain,),
          ),
        );
      }
    );
  }

  PersistentBottomSheetController  pdfView(BuildContext context , String file){

    var document;
    document = PDFDocument.fromURL(file);

    return showBottomSheet(
      context: context, 
      builder: (BuildContext context){
        return Container(
          color: Color(0xfff0f4ff),
          child: Center(
            child: FutureBuilder(
              future: document,
              builder: (BuildContext context,snapshot){ 
                return PDFViewer(document: snapshot.data,showPicker: false,);
              },
            )
          ),
        );
      }
    ); 
  }
 
  Future selectReceiptType(BuildContext con){
    return showDialog(
      context: con,
      builder: (BuildContext context){
        return SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))), 
          children: [
            Column(
              children: <Widget>[

                SizedBox(height:10),

                Align(
                  child: Container(
                  width: 60,height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    color: Colors.grey))),

                SizedBox(height: 20,),

                ListTile(
                  leading: Icon(Icons.image,color: Colors.blue,),
                  title: Text('Upload as image'),
                  onTap: (){
                    filePicker('billimage');
                    Navigator.of(context).pop();
                  }),

                ListTile(
                  leading: Icon(Icons.picture_as_pdf,color: Colors.red,),
                  title: Text('Upload as PDF'),
                  onTap: (){
                    filePicker('pdf');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ]
        );
      }
    );
  }


  Future filePicker(String type) async {

    if (type == 'billimage') {
      filedoc = await FilePicker.platform.pickFiles(type: FileType.image);
        
      if ( await filedoc.length() > 5000000){
        sizeAlert('File size is too big! Size must be less than 5Mb' );
      }
      else{
        preview(filedoc,type,filedoc.path);
      }
    }

    if (type == 'pdf') {
      filedoc = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      String extensionCheck = filedoc.path.split('.').last; 
      
       
      // to eliminate other extensions
      if(extensionCheck != 'pdf'){
          
        sizeAlert('Only PDF documents allowed');
                      
      }else{

        if ( await filedoc.length() > 5000000 ){
          sizeAlert('File size is too big! Size must be less than 5Mb');
        }
        else{
          preview(filedoc, type, filedoc.path);
        }
      }       
    }
  }

  Future sizeAlert (String alertMessage){
   
    return  showDialog(
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
  preview(dynamic file, String type, String filename) async{

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    String name = filename.split('/').reversed.first;
    String finalFilename = name.split('.').first;
    TextEditingController _con = TextEditingController(text: finalFilename);
  
    var document = type == 'pdf' ? await PDFDocument.fromFile(file) : null;

    return _globalKey.currentState.showBottomSheet(
      (BuildContext context){
        return Container(
                  
          color: Color(0xffeaeaea), 
          child: ListView(
            children: <Widget>[
              SizedBox(height: 30),
              Align(
                alignment: Alignment.bottomCenter ,
                child: Container(

                  child: type == 'pdf'
                  ? Container(
                    padding: EdgeInsets.all(10), 
                    width: 480,height: 480, 
                    child: PDFViewer (document: document,showPicker: false,)) 
        
                  : Image.file(file,width: 450,height: 450,))
              ),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:20,right: 20,bottom: 10,top:10),
                      child: TextFormField(
                        controller: _con,
                        cursorColor: Color(0xff5458e1),
                        decoration: InputDecoration(
                          focusColor: Color(0xff5458e1),
                          fillColor: Color(0xff5458e1), 
                                
                          labelText: 'File name', 
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),),
                        validator: (String val){
                          return val.isEmpty ? 'Please Enter the receipt name' : null;
                        },
                        onChanged: (val)=>{ 
                          finalFilename = val,
                                                        
                        },
                      )
                    ),
                        
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RaisedButton(color: Color(0xff5458e1),
                            onPressed: () async{                // again calling filepicker to get new file
                              filePicker(type);
                            },      
                            
                            child: Text('Select another',style: TextStyle(color: Colors.white),)
                          ),

                          RaisedButton(
                            color:Color(0xff5458e1),
                            onPressed: ()async {
                              
                              if(_formKey.currentState.validate()){
                                if(file != null){

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

                                  var result = await DataService().uploadItemBill(file,type,finalFilename,widget.productid, context);

                                  Navigator.of(context).pop();   //to close preview bottomsheet
                                  Navigator.pop(context);  //to close uploading popup

                                  _globalKey.currentState.showSnackBar( 
                                    SnackBar(
                                      content: result == 'error' ? Text('Some error occured') : Text('New receipt added successfully'),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            }, 
                            child: Text('Save',style: TextStyle(color: Colors.white),)
                          ),
                        ],
                      ),
                    ),
                  ], 
                ),
              ),
            ],
          ),
        );
      }, 
    );
  }

  Future limitAlert(BuildContext context){
    return  showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text('Sorry...'),
          content: Text('You can only upload 5 receipts per product'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future delete(BuildContext context , String productId, String name, String type, String url){

    return showDialog(context: context,
      builder: (BuildContext deletecontext){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text('Delete Receipt'),
          content: Text('Are you sure you want to delete this file?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel',style: TextStyle(color: Color(0xff5458e1)),),
              onPressed: () {
                Navigator.of(deletecontext).pop();
              },
            ),
            FlatButton(
              child: Text('Yes',style: TextStyle(color: Color(0xff5458e1)),),
              onPressed: () {
                DataService().deleteBill(productId, name, type, url)
                .whenComplete(()async => 
                  _globalKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text('Item receipt deleted successfully'),
                      duration: Duration(seconds: 3),
                    ))
                );
                Navigator.of(deletecontext).pop();
              },
            )
          ],
        );
      }
    );
  }

 Future share(String url, String type) async{
  http.Response response = await http.get(url);
  await WcFlutterShare.share(  
    sharePopupTitle: 'share',  
    subject: 'Item Receipt',  
    text: 'Item Receipt',  
    fileName: type == 'pdf' ? 'Receipt.pdf'  : 'Receipt.$type',
    mimeType: type == 'pdf' ? 'document/pdf' : 'image/$type',
    bytesOfFile: response.bodyBytes,
    );
  }
}