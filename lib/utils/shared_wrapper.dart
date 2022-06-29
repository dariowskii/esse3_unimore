import 'package:Esse3/models/auth_credential_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/studente_model.dart';

class SharedWrapper {
  SharedWrapper._();
  static final SharedWrapper shared = SharedWrapper._();

  Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  Future<AuthCredential?> getUserCreditentials() async {
    final prefs = await _prefs();
    final authCredential = AuthCredential();
    final raw = prefs.getString(AuthCredential.sharedKey);
    if (raw != null) {
      authCredential.decode(raw);
      return authCredential;
    }
    return null;
  }

  Future<void> setUserCreditentials(AuthCredential authCredential) async {
    final prefs = await _prefs();
    prefs.setString(AuthCredential.sharedKey, authCredential.encode());
  }

  Future<void> setStudenteModel(StudenteModel studenteModel) async {
    final prefs = await _prefs();
    prefs.setString(StudenteModel.sharedKey, studenteModel.encode());
  }

  Future<StudenteModel?> getStudenteModel() async {
    final prefs = await _prefs();
    final studenteModel = StudenteModel();
    final raw = prefs.getString(StudenteModel.sharedKey);
    if (raw != null) {
      studenteModel.decode(raw);
      return studenteModel;
    }
    return null;
  }
}
