import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:provider/provider.dart';

class FilePickModel extends StatefulWidget {
  @override
  _FilePickModelState createState() => _FilePickModelState();
}

class _FilePickModelState extends State<FilePickModel> {

  var _formKey = GlobalKey<FormState>();

  File fileimg;
  File filedoc;
  String filedocname;

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }

  Future filePicker(BuildContext context,String fileType) async {

    try {
      if (fileType == 'image') {
        fileimg = await FilePicker.getFile(type: FileType.image);

        if ( await fileimg.length() > 5000000){
          sizeAlertDialog(context, 'File size is too big! Size must be less than 5Mb' );
        }else{
          preview(context,fileimg,fileType);
        }
      }

      if (fileType == 'billimage') {
        filedoc = await FilePicker.getFile(type: FileType.image);

        if ( await filedoc.length() > 5000000){
          sizeAlertDialog(context, 'File size is too big! Size must be less than 5Mb' );
        }else{
          preview(context,filedoc,fileType);
        }
      }

       if (fileType == 'pdf') {
        filedoc = await FilePicker.getFile(type: FileType.custom, allowedExtensions: ['pdf']);
        String extensionCheck = filedoc.path.split('.').last; 
       
        // to eliminate other extensions
        if(extensionCheck != 'pdf'){
          sizeAlertDialog(context, 'Only PDF documents allowed');

        }else{         
          if ( await filedoc.length() > 5000000 ){
            sizeAlertDialog(context, 'File size is too big! Size must be less than 5Mb');
          }else{
            preview(context, filedoc, fileType);
          }
        }       
      }
      
    } catch(e){print(e);}
  
      
  }
  // Size alert dialog

  Future sizeAlertDialog (BuildContext context, String alertMessage){
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
  Future preview(BuildContext context , dynamic file, String type) async{

    //we only need filename of receipt
    filedocname = file.path.split('/').reversed.first.split('.').first;

    TextEditingController receiptName = TextEditingController(text: filedocname);

    //converting filedoc to pdf document
    var document = type == 'pdf' ? await PDFDocument.fromFile(file) : null;

   return showBottomSheet(
     context: context,
     builder:(BuildContext bottomcontext){
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
 
                : Image.file(file,width: 450,height: 450,))),

              type != 'image' ? Form(
                key: _formKey,
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
                      validator: (String val) => val.isEmpty ? 'Please Enter the receipt name' : null,
                      onChanged: (val){
                        filedocname = val;
                      },
                     
                    ),),])) 
                    
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

                        Provider.of<FilePickData>(context,listen: false).setFileimg(fileimg); 
                        Navigator.of(context).pop();

                      }
                    if(type != 'image' && _formKey.currentState.validate()){
                      
                      if(type == 'billimage' || type == 'pdf' ){ 
                        Provider.of<FilePickData>(context,listen: false).setFiledoc(filedoc, filedocname); 
                      }
                      
                      Navigator.of(context).pop();
                    }
                    
                  }, child: Text('Save',style: TextStyle(color: Colors.white),)),
                ],
              ),
            ),  
          ],
        )
        );
          
      
      } 
    );
  }

  // Future selectReceiptType(BuildContext context){
  //  return showDialog(
  //     context: context,
  //     builder: (BuildContext dialogcontext){
  //       return SimpleDialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))), 
  //         children: [
  //           Column(
  //               children: <Widget>[

  //               SizedBox(height:10),

  //           Align(child: Container(
  //              width: 60,
  //              height: 3,
  //              decoration: BoxDecoration(
  //               borderRadius: BorderRadius.all(Radius.circular(3)),
  //               color: Colors.grey))),

  //                 SizedBox(height: 20,),

  //                 ListTile(
  //                   leading: Icon(Icons.image,color: Colors.blue,),
  //                   title: Text('Upload as image'),
  //                   onTap: (){
                                                                  
  //                   filePicker(context, 'billimage');
                     
  //                   Navigator.of(context).pop();
  //                 }),

  //                 ListTile(
  //                   leading: Icon(Icons.picture_as_pdf,color: Colors.red,),
  //                   title: Text('Upload as PDF'),
  //                   onTap: (){
                                                                   
  //                    filePicker(context, 'pdf');
  //                    Navigator.of(context).pop();
  //                   },)
  //           ],
  //             ),
  //         ]
            
        
  //       );
      
  //     });
  // }
}

class FilePickData extends ChangeNotifier{

  var fileimg;
  Map filedoc;

  void setFileimg(var data){
    fileimg = data;
    notifyListeners();
  }

  getFileimg(){
    return fileimg;
  }

  void setFiledoc(var data, String filename){
    print(filename);
    filedoc = {
      'file' : data,
      'filename' : filename
    };

    notifyListeners();
  }

  getFiledoc(){
    return filedoc;
  }
}