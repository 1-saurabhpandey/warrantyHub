import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warranty_tracker/Model/dataModel.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/alert.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/preview.dart';
import 'package:warranty_tracker/Services/database.dart';
import 'package:http/http.dart' as http;

class Receipt extends StatefulWidget {

  final productid ;
  Receipt({@required this.productid});

  @override
  _ReceiptState createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
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
        onPressed: ()async {
            
          if(receiptData.length == 5){
            alertWidget(context, 'You can only upload 5 receipts per product');
            
          }else{
            var result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => PreviewWidget(productid: widget.productid))); 
            
            if (result != null){ 
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: result == 'success' ? Text('New receipt added successfully') : Text('Some error occured'),
                  duration: Duration(seconds: 3), 
                )
              );
            }
          } 
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
                            child: Text('Receipt ${index + 1}'),
                            onTap: () => receiptData[index]['type'] != 'pdf' 
                              ? Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => Preview('Receipt ${index + 1}', null, 'image', receiptData[index]['url'])))
 
                              : Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => Preview('Receipt ${index + 1}', null, 'pdf', receiptData[index]['url'])))
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

  Future delete(BuildContext context , String productId, String name, String type, String url){

    return showDialog(context: context,
      builder: (BuildContext deletecontext){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text('Delete Receipt'),
          content: Text('Are you sure you want to delete this file?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',style: TextStyle(color: Color(0xff5458e1)),),
              onPressed: () {
                Navigator.of(deletecontext).pop();
              },
            ),
            TextButton(
              child: Text('Yes',style: TextStyle(color: Color(0xff5458e1)),),
              onPressed: () {
                DataService().deleteBill(productId, name, type, url)
                .whenComplete(()async => 
                  ScaffoldMessenger.of(context).showSnackBar(
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

  Future share(Uri url, String type) async{

   
    http.Response response = await http.get(url);
    String path = File.fromRawPath(response.bodyBytes).path;

    await Share.shareFiles(
      [path],
      subject: 'Item Receipt',
      text: 'Item Receipt'
    );
  }
}

class PreviewWidget extends StatefulWidget {
  
  final String productid;

  PreviewWidget({ required this.productid});

  @override
  _PreviewWidgetState createState() => _PreviewWidgetState();
}
class _PreviewWidgetState extends State<PreviewWidget> {

  late String type;
  late String file;
  late String fileName;

  @override
  void initState() {
    filePicker(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      appBar: AppBar( 
        title: Text(fileName),    //fileName != null ? Text(fileName) : null,
      ),
      body: ListView(  //file != null 
        children: [

          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              child: type == 'pdf'
                ? Container(
                  padding: EdgeInsets.all(10), 
                  width: 480,height: 480, 
                  child: PDF().fromPath(file)
                )
              : Image.file(File(file),width: 450,height: 450,)
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xff5458e1)),),
                  onPressed: () async{                // again calling filepicker to get new file        
                    filePicker(context);
                  }, 
                  child: Text('Select another',style: TextStyle(color: Colors.white),)
                ),

                ElevatedButton(
                  style:ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xff5458e1))
                  ),
                  onPressed: ()async {
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

                    await DataService().uploadItemBill(File(file),type,fileName,widget.productid, context).then((result){
                      Navigator.of(context,rootNavigator: true).pop();  //to close uploading popup
                      Navigator.pop(context,result);  //to close preview widget
                    });
                  }, 
                  child: Text('Save',style: TextStyle(color: Colors.white),)
                ),
              ],
            ),
          ),
        ]
      )
    );
  }

  Future filePicker(BuildContext context) async {

    String extensionCheck;
    String filename;
    List allowedExtension = ['pdf','jpg','jpeg','png'];
    FilePickerResult? filedoc = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf','jpg','jpeg','png']);

    
    extensionCheck = filedoc!.files.first.path!.split('.').last;
    filename = filedoc.files.first.path!.split('/').last.split('.').first;
    
     

    if(!allowedExtension.contains(extensionCheck)){
      Navigator.of(context).pop();
      alertWidget(context, 'This File Extension($extensionCheck) is not allowed');
    }
    if (filedoc.files.first.size! > 5000){ 
      Navigator.of(context).pop();
      alertWidget(context, 'File size is too big! Size must be less than 5Mb');
    }
    else{
      setState(() {
        type = extensionCheck;
        fileName = filename;
        file = filedoc.files.first.path!;
      });
    }
  }
}