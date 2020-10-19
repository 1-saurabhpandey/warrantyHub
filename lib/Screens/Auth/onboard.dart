import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warranty_tracker/main.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Onboard(),
    );
  }
}
class Onboard extends StatefulWidget {
  @override
  _OnboardState createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {

 final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  Widget _indicator(bool active){
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 3),
      height: active ? 8 : 6, width: active ? 15 : 6,
      decoration: BoxDecoration(
        color: Color(0xff5458e1),
        borderRadius: BorderRadius.all(Radius.circular(12))
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: Container(
          child: PageView(
            controller: _pageController,
            onPageChanged: (int page){
              _currentPage = page;
              setState((){});
            },
            children: <Widget>[
              pageContent (
                image: 'lib/images/onboard/track.png',
                title: 'Track warranty of your product',

              ),
              pageContent (
                image: 'lib/images/onboard/upload.png',
                title: 'Upload your files at one click',

              ),
              
              pageContent (
                image: 'lib/images/onboard/share.png',
                title: 'Share files with others',

              ),
            ]
          )
        ),
      ),

      bottomSheet: _currentPage != 2 ? 
      Container(
        height: 80,
        color: Colors.white,
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
          FlatButton(
            onPressed: (){
              _pageController.animateToPage(3, duration: Duration(milliseconds: 400), curve: Curves.linear);
              setState(() {});     
            },
            splashColor: Colors.deepPurpleAccent,
            child: Text('SKIP'),
          ),

          Container(
            child: Row(
              children: <Widget>[
                for(int i=0 ; i < _numPages ; i++)

                i == _currentPage ? _indicator(true) : _indicator(false) 
                  //for --> if else
              ],
            ),
          ),

          FlatButton(
            onPressed: (){
              _pageController.animateToPage(_currentPage + 1 , duration: Duration(milliseconds: 400), curve: Curves.linear);
              setState((){});
            },
            splashColor: Colors.deepPurpleAccent,
            child: Container(
              padding: EdgeInsets.fromLTRB(35,15,35,15), 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0xff5458e1), 
              ),
              child: Text('NEXT',style: TextStyle(color: Colors.white),)),
          )
        ],
      ),
    ) 
      
      : FlatButton(
        color: Colors.white,
        onPressed: () =>
        Navigator.pushReplacement(
          context, MaterialPageRoute(
            builder: (BuildContext context) => App()
          ),
        ),
        
          child: Container(
            height: 60,
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.fromLTRB(40,10,40,10),
            child: Text(
              'Get Started',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,color: Colors.white
              ),

            ),
            decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Color(0xff5458e1),
          ),
        ),
      )
    );
  }
      
  Widget pageContent({
    String image , 
    String title , 
  }){
    return Container(
      padding: EdgeInsets.symmetric(horizontal:22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child:Image.asset(image),
          ),
          SizedBox(height: 40),
          Align(
            child: Text(title,
            style:GoogleFonts.libreFranklin(textStyle:TextStyle(fontSize: 25 , fontWeight: FontWeight.w400)) )
          ),
          SizedBox(height:10) 
        ],
      ),
    );
  }
}