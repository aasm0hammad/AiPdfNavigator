import 'package:aipdfnavigator/database/user%20model/user_model.dart';
import 'package:aipdfnavigator/ui/login/login%20bloc/login%20event.dart';
import 'package:aipdfnavigator/ui/login/login%20bloc/login%20state.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  FirebaseAuth auth=FirebaseAuth.instance;
  RegisterBloc() : super(RegisterInitialState()) {
    on<RegisterUserEvent>((event, emit) async {
      emit(RegisterLoadingState());
      try {
        UserCredential userCredential = await auth
            .createUserWithEmailAndPassword(email: event.newUserModel.email,
            password: event.newUserModel.password);

        CollectionReference userRef=FirebaseFirestore.instance.collection("BlocUser");
        await userRef.add(
          UserModel(name: event.newUserModel.name,
              email: event.newUserModel.email, number: int.parse(event.newUserModel.number.toString())).toMap(),
        );
        emit(RegisterSuccessState());
      }on FirebaseAuthException catch (e) {
        String errorMsg;

        if (e.code == 'email-already-in-use') {
          errorMsg = 'Email already exists!';
        } else if (e.code == 'weak-password') {
          errorMsg = 'The password is too weak.';
        } else {
          errorMsg = 'Registration failed: ${e.message}';
        }

        emit(RegisterFailureState(errorMsg: errorMsg));
      } catch (e) {
        emit(RegisterFailureState(errorMsg: 'Something went wrong: $e'));
        print("$e");
      }

    });
  }
}
