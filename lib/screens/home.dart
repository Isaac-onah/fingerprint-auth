
import 'package:fingerprint/screens/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
          ? _SupportState.supported
          : _SupportState.unsupported),
    );
    _checkBiometric();
    _getAvailableBiometric();
  }

    Future<void> _checkBiometric() async{
      late bool canCheckBiometric;
      try{
        canCheckBiometric = await auth.canCheckBiometrics;
      }on PlatformException catch (e){
        print(e);
      }

      if(!mounted) {
        return;
      }

      setState(() {
        _canCheckBiometrics = canCheckBiometric;
      });

    }

    Future<void> _getAvailableBiometric() async{
      late List<BiometricType> availableBiometrics;
      try{
        availableBiometrics = await auth.getAvailableBiometrics();
      }on PlatformException catch (e){
        availableBiometrics = <BiometricType>[];
        print(e);
      }

      setState(() {
        _availableBiometrics = availableBiometrics;
      });
    }
    Future<void> _authenticate() async{
      late bool authenticated = false;
      try{
        authenticated = await auth.authenticate(localizedReason: 'Scan your finger to authenticate', useErrorDialogs: true, stickyAuth: false);
      }on PlatformException catch (e){
        print(e);
      }
      if(!mounted) {return;}
      setState(() {
        _authorized = authenticated ? "Authorized sucess" : "Failed to authenticate";
        if(authenticated){
          Navigator.push(context, MaterialPageRoute(builder: (context) => SecondPage()));
        }
        print(_authorized);
      });
    }




  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: const Text(
                  'Login',style: TextStyle(color: Colors.blue, fontSize: 48.0, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 50.0),
                child: Column(
                  children:<Widget>[
                    Image.asset('assets/fingerprints.png',width: 120,),
                  Text("Fingerprint Auth", style: TextStyle(color: Colors.blue, fontSize: 22.0,fontWeight: FontWeight.bold),),
                    Container(width: double.infinity, child: Text("Authenticate using fingerprint instead of your password  ", textAlign: TextAlign.center,style: TextStyle(color: Colors.blue, height: 1.5,),),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 15.0),
                      width: double.infinity,
                    child: RaisedButton(
                      elevation: 0.0,
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)
                      ),
                      onPressed: _authenticate, child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                        child: Text("Authenticate", style: TextStyle(color: Colors.white),),
                      ),),
                    )
                  ]
                ),
              )
            ],
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
enum _SupportState {
  unknown,
  supported,
  unsupported,
}