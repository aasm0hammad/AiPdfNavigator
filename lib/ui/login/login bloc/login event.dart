
import '../../../database/user model/user_model.dart';

abstract class RegisterEvent{


}

class RegisterUserEvent extends RegisterEvent{

  UserModel newUserModel;
  RegisterUserEvent({required this.newUserModel});


}