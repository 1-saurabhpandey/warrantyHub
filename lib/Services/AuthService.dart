import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:warranty_tracker/Screens/Common_Widgets/SnackBar.dart';
import 'package:warranty_tracker/main.dart';

class AuthService{
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(); 

  //sign in with google

  Future signInGoogle() async {

    final storage = GetStorage();

    try{
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      GoogleSignInAuthentication? gsa = await googleSignInAccount?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential
      (idToken: gsa?.idToken, accessToken: gsa?.accessToken);

      User? user = (await _auth.signInWithCredential(credential)).user;
      storage.write('firstLogin', false);
      return user;
    }catch(e){
      snackBar('Something went wrong');
    }
                                                   
  }


//sign out 

  Future signOut() async{
    
    await googleSignIn.signOut();
    FirebaseAuth.instance.signOut();
    Get.offAll(() => App());

  }

}