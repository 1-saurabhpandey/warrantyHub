import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/SnackBar.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/UploadingDialog.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/AlertDialog.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/PreviewPage.dart';
import 'package:warranty_tracker/Services/DataService.dart';
import 'package:warranty_tracker/ViewModels/ItemsViewModel.dart';

// ignore: must_be_immutable
class ItemBill extends StatelessWidget {

  final productId ;
  ItemBill({@required this.productId});

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Nothing to download';
    }
  }

  String docSlot = '';

  @override
  Widget build(BuildContext context){
    
    return GetX<ItemViewModel>(
      init: ItemViewModel(),
      builder: (data){

        List receiptData = data.getItemList().where((e) => e['productId'] == productId).first['details']['bill'];
        docSlot = data.getItemList().where((e) => e['productId'] == productId).first['docId'];

        return Scaffold(

          appBar: AppBar(
            title: Text('Product Receipts'),
            backgroundColor: Color(0xff5458e1), 
          ),

          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
            backgroundColor: Color(0xff5458e1),
            child: Icon(Icons.add, color: Colors.white),  
            elevation: 7, mini: true,
            onPressed: ()async {
                
              if(receiptData.length == 5){
                alertWidget('Sorry...','You can only upload 5 receipts per product');
                
              }else{
                filePicker();
              } 
            }
          ),

          body: receiptData.isNotEmpty
            ? Container(
              padding: EdgeInsets.all(10), 
              color: Theme.of(context).canvasColor,
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
                        ),
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
                                  ? Get.to(() => Preview('Receipt ${index + 1}', null, 'image', receiptData[index]['url']))
  
                                  : Get.to(() => Preview('Receipt ${index + 1}', null, 'pdf', receiptData[index]['url']))
                              )
                            ),

                            optionButton(receiptData[index],'Receipt ${index + 1}')
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
    );
  }

  Widget optionButton(var data,String name){

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

        try{
          Dio dio = Dio();
          var directory = await getExternalStorageDirectory();
          var downloadedPath;

          if(value == 'delete'){
            delete(productId, data['type'],data['url']);
          }

          if(value == 'download'){

            uploadingDialog('Downloading...');

            await dio.download(
              data['url'], '${directory!.path}/name.${data['type']}',
            ).then(
              (value){
                Get.back();

                Get.dialog(
                  AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))), 
                    title: Text('Success'),
                    content: Text('File downloaded successfully'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('cancel'),
                        onPressed: () {
                          Get.back();
                        },
                      ),

                      TextButton(
                        child: Text('open'),
                        onPressed: () {
                          Get.back();
                          OpenFile.open('${directory.path}/name.${data['type']}');
                        },
                      ),
                    ],
                  )
                );
              }
            );
            
            downloadedPath = '${directory.path}/name.${data['type']}';
          }

          if(value == 'share'){
            
            if(downloadedPath != null) {
              await Share.shareFiles(
                [downloadedPath],
                subject: 'Item Receipt',
                text: name
              );
            }else{
              
              uploadingDialog('Loading...');

              await dio.download(
                data['url'], '${directory!.path}/name.${data['type']}',
              ).then(
                (value){

                  Get.back();

                  Share.shareFiles(
                    ['${directory.path}/name.${data['type']}'],
                    subject: 'Item Receipt',
                    text: name
                  );
                }
              );
            }
          }
        }catch(e){
          snackBar('Something went wrong');
        }
      },
    );
  }

  delete(String productId, String type, String url){

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        title: Text('Delete Receipt'),
        content: Text('Are you sure you want to delete this file?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel',style: TextStyle(color: Get.isDarkMode ? Colors.grey[300] : Color(0xff5458e1)),),
            onPressed: () => Get.back()
          ),
          TextButton(
            child: Text('Yes',style: TextStyle(color: Get.isDarkMode ? Colors.grey[300] : Color(0xff5458e1)),),
            onPressed: () {
              DataService().deleteBill(productId, type, url, docSlot);
            },
          )
        ],
      )
    );
  }

   Future filePicker() async {

    String fileExtension;
    String fileName;
    List allowedExtension = ['pdf','jpg','jpeg','png'];
    FilePickerResult? filedoc = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf','jpg','jpeg','png']);

    
    fileExtension = filedoc!.files.first.path!.split('.').last;
    fileName = filedoc.files.first.path!.split('/').last.split('.').first;
    
    if(!allowedExtension.contains(fileExtension)){
      alertWidget('Sorry...','This File Extension($fileExtension) is not allowed');
    }
    if (filedoc.files.first.size! > 5000000){ 
      alertWidget('Sorry...','File size is too big! Size must be less than 5Mb');
    }
    else{
      Get.to(() => uploadItemBill(productId, File(filedoc.files.first.path!), fileExtension, fileName,));
    }
  }

  Widget uploadItemBill(String productId, File file, String fileExtension, String fileName, ){
    return Scaffold(
      appBar: AppBar( 
        title: Text(fileName),
        backgroundColor: Color(0xff5458e1), 
      ),
      body: ListView(  
        children: [

          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              child: fileExtension == 'pdf'
                ? Container(
                  padding: EdgeInsets.all(10), 
                  width: 480,height: 480, 
                  child: PDF().fromPath(file.path)
                )
              : Image.file(file,width: 450,height: 450,)
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                
                ElevatedButton(
                  style:ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xff5458e1))
                  ),
                  onPressed: ()async {
                    uploadingDialog('Uploading...');

                    await DataService().uploadBill(file,fileExtension,fileName,productId,docSlot);
                  }, 
                  child: Text('Upload',style: TextStyle(color: Colors.white),)
                ),
              ],
            ),
          ),
        ]
      )
    );
  }
}

