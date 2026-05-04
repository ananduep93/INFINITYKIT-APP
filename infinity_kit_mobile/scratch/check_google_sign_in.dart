import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  final gsi = GoogleSignIn.instance;
  final googleUser = await gsi.authenticate();
  final auth = googleUser.authentication;
  print(auth.idToken);
}
