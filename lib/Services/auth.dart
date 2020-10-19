import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  //sign in with google

  Future signInGoogle() async {

    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gsa = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential
    (idToken: gsa.idToken, accessToken: gsa.accessToken);

    FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    return user;                                               
  }


//sign out

  Future signOut() async{
    
    await googleSignIn.signOut();
    FirebaseAuth.instance.signOut();
  }

}