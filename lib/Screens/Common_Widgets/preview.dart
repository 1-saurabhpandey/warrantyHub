import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';

class Preview extends StatelessWidget {

 final String fileName ;
 final String fileType ;
 final String filePath ;
 final String fileUrl ;

  Preview(this.fileName,this.filePath,this.fileType,this.fileUrl);

  @override
  Widget build(BuildContext context) {
    var document;
    if(fileType == 'pdf' && filePath != null){
      document = PDFDocument.fromFile(File(filePath));
    }

    if(fileType == 'pdf' && fileUrl != null){
      document = PDFDocument.fromURL(fileUrl);
    }

    return Scaffold(
      appBar: AppBar(
        title:Text(fileName)
      ),
      body: Container(
        child: Center(
          child: fileType == 'pdf' 
          ? FutureBuilder(
            future: document,
            builder: (context, snapshot) {
              return Container(
                padding: EdgeInsets.all(10), 
                width: MediaQuery.of(context).size.width - 20,
                height: MediaQuery.of(context).size.height - 150, 
                child: PDFViewer (document: snapshot.data ,showPicker: false,));
            }
          ) 
          : filePath != null 

            ? Padding(
              padding: const EdgeInsets.all(20),
              child: Image.file(File(filePath),),
            )
            : Padding(
              padding: const EdgeInsets.all(20),
              child: Image.network(
                fileUrl,scale: 0.5 ,
                loadingBuilder: (context, child, loadingProgress){
                  return loadingProgress == null 
                  ? child 
                  : CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null 
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null
                  );
                },
              ),
            )
        ),
      ),
    );
  }
}