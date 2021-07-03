import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class Preview extends StatelessWidget {

 final String fileName ;
 final String fileType ;
 final String? filePath ;
 final String? fileUrl ;

  Preview(this.fileName,this.filePath,this.fileType,this.fileUrl);

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title:Text(fileName),
        backgroundColor: Color(0xff5458e1)
      ),
      body: Container(
        child: Center(
          child: fileType == 'pdf' 
          ? filePath != null

            ? Container(
              padding: EdgeInsets.all(10), 
              width: MediaQuery.of(context).size.width - 20,
              height: MediaQuery.of(context).size.height - 150, 
              child: PDF().fromPath(filePath!)
            )
            : Container(
              padding: EdgeInsets.all(10), 
              width: MediaQuery.of(context).size.width - 20,
              height: MediaQuery.of(context).size.height - 150, 
              child: PDF().cachedFromUrl(fileUrl!,placeholder: (p) => Center(child: CircularProgressIndicator()))
            )
            
            
          : filePath != null 

            ? Padding(
              padding: const EdgeInsets.all(20),
              child: Image.file(File(filePath!),),
            )
            : Padding(
              padding: const EdgeInsets.all(20),
              child: Image.network(
                fileUrl!,scale: 0.5 ,
                loadingBuilder: (context, child, loadingProgress){
                  return loadingProgress == null 
                  ? child 
                  : CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null 
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null
                  );
                },
              ),
            )
        ),
      ),
    );
  }
}