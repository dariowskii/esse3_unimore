import 'package:Esse3/models/auth_credential_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedWrapper {
  SharedWrapper._();
  static final SharedWrapper shared = SharedWrapper._();

  Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  Future<AuthCredential> getUserCreditentials() async {
    final prefs = await _prefs();
    final authCredential = AuthCredential();
    authCredential.decode(prefs.getString(AuthCredential.sharedKey));
    return authCredential;
  }

  Future<void> setUserCreditentials(AuthCredential authCredential) async {
    final prefs = await _prefs();
    prefs.setString(AuthCredential.sharedKey, authCredential.encode());
  }
}
