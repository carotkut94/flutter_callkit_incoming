import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming_example/app_router.dart';
import 'package:flutter_callkit_incoming_example/navigation_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  var _uuid;
  var _currentUuid;
  var textEvents = "";

  var token = "";

  @override
  void initState() {
    super.initState();
    _uuid = Uuid();
    _currentUuid = "";
    textEvents = "";
    token = "Loading token....";
    //initCurrentCall();
    listenerEvent(onEvent);
    getDevicePushTokenVoIP();
    checkForDeclinedCalls();
  }

  Future<void> checkForDeclinedCalls() async {
    var data = await FlutterCallkitIncoming.declinedCalls();
    print("Declined calls");
    var decoded = jsonDecode(data);
    print(decoded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.call,
              color: Colors.white,
            ),
            onPressed: () async {
              this.makeFakeCallInComing();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.call_end,
              color: Colors.white,
            ),
            onPressed: () async {
              this.endCurrentCall();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.call_made,
              color: Colors.white,
            ),
            onPressed: () async {
              this.startOutGoingCall();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.call_merge,
              color: Colors.white,
            ),
            onPressed: () async {
              this.activeCalls();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.clear_all_sharp,
              color: Colors.white,
            ),
            onPressed: () async {
              this.endAllCalls();
            },
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          if (textEvents.isNotEmpty) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: Column(
                  children: [
                    SelectableText(token),
                    Divider(),
                    Text('$textEvents'),
                  ],
                )
              ),
            );
          } else {
            return Column(
              children: [
                SelectableText(token),
                Divider(),
                Text('No Event'),
              ],
            );
          }
        },
      ),
    );
  }

  Future<void> makeFakeCallInComing() async {
    await Future.delayed(const Duration(seconds: 10), () async {
      this._currentUuid = _uuid.v4();
      var params = <String, dynamic>{
        'id': _currentUuid,
        'nameCaller': 'Sidhant Rajora',
        'appName': 'Sample',
        'avatar': 'https://i.pravatar.cc/100',
        'handle': '0123456789',
        'type': 0,
        'duration': 10000,
        'textAccept': 'Accept',
        'textDecline': 'Decline',
        'textMissedCall': 'Missed call',
        'textCallback': 'Call back',
        'extra': <String, dynamic>{'userId': '1a2b3c4d'},
        'headers': <String, dynamic>{
          'apiKey': 'Abc@123!',
          'platform': 'flutter'
        },
        'android': <String, dynamic>{
          'isCustomNotification': true,
          'isShowLogo': false,
          'isShowCallback': true,
          'isShowMissedCallNotification': true,
          'ringtonePath': 'system_ringtone_default',
          'backgroundColor': '#0955fa',
          'background': 'https://i.pravatar.cc/500',
          'actionColor': '#4CAF50'
        },
        'ios': <String, dynamic>{
          'iconName': 'CallKitLogo',
          'handleType': '',
          'supportsVideo': true,
          'maximumCallGroups': 2,
          'maximumCallsPerCallGroup': 1,
          'audioSessionMode': 'default',
          'audioSessionActive': true,
          'audioSessionPreferredSampleRate': 44100.0,
          'audioSessionPreferredIOBufferDuration': 0.005,
          'supportsDTMF': true,
          'supportsHolding': true,
          'supportsGrouping': false,
          'supportsUngrouping': false,
          'ringtonePath': 'system_ringtone_default'
        }
      };
      await FlutterCallkitIncoming.showCallkitIncoming(params);
    });
  }

  Future<void> endCurrentCall() async {
    //initCurrentCall();
    //var params = <String, dynamic>{'id': this._currentUuid};
    //await FlutterCallkitIncoming.endCall(params);
  }

  Future<void> startOutGoingCall() async {
    this._currentUuid = _uuid.v4();
    var params = <String, dynamic>{
      'id': this._currentUuid,
      'nameCaller': 'Sidhant Rajora',
      'handle': '0123456789',
      'type': 1,
      'extra': <String, dynamic>{'userId': '1a2b3c4d'},
      'ios': <String, dynamic>{'handleType': 'number'}
    }; //number/email
    await FlutterCallkitIncoming.startCall(params);
  }

  Future<void> activeCalls() async {
    var calls = await FlutterCallkitIncoming.activeCalls();
    print(calls);
  }

  Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }

  Future<void> getDevicePushTokenVoIP() async {
    await Firebase.initializeApp();
    var _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.getToken().then((value) {
      setState(() {
        token = value ?? "";
      });
      print("Sidhant");
      print(token);
    });
  }

  Future<void> listenerEvent(Function? callback) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        print('HOME: $event');
        switch (event!.name) {
          case CallEvent.ACTION_CALL_INCOMING:
            // TODO: received an incoming call
            break;
          case CallEvent.ACTION_CALL_START:
            // TODO: started an outgoing call
            // TODO: show screen calling in Flutter
            break;
          case CallEvent.ACTION_CALL_ACCEPT:
            // TODO: accepted an incoming call
            // TODO: show screen calling in Flutter
            NavigationService.instance
                .pushNamedIfNotCurrent(AppRoute.callingPage, args: event.body);
            break;
          case CallEvent.ACTION_CALL_DECLINE:
            // TODO: declined an incoming call
            FlutterCallkitIncoming.clearDeclinedCalls();
            await requestHttp("ACTION_CALL_DECLINE_FROM_DART");
            break;
          case CallEvent.ACTION_CALL_ENDED:
            // TODO: ended an incoming/outgoing call
            break;
          case CallEvent.ACTION_CALL_TIMEOUT:
            // TODO: missed an incoming call
            break;
          case CallEvent.ACTION_CALL_CALLBACK:
            // TODO: only Android - click action `Call back` from missed call notification
            break;
          case CallEvent.ACTION_CALL_TOGGLE_HOLD:
            // TODO: only iOS
            break;
          case CallEvent.ACTION_CALL_TOGGLE_MUTE:
            // TODO: only iOS
            break;
          case CallEvent.ACTION_CALL_TOGGLE_DMTF:
            // TODO: only iOS
            break;
          case CallEvent.ACTION_CALL_TOGGLE_GROUP:
            // TODO: only iOS
            break;
          case CallEvent.ACTION_CALL_TOGGLE_AUDIO_SESSION:
            // TODO: only iOS
            break;
          case CallEvent.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
            // TODO: only iOS
            break;
        }
        if (callback != null) {
          callback(event.toString());
        }
      });
    } on Exception {}
  }

  //check with https://webhook.site/#!/2748bc41-8599-4093-b8ad-93fd328f1cd2
  Future<void> requestHttp(content) async {
    get(Uri.parse(
        'https://webhook.site/2748bc41-8599-4093-b8ad-93fd328f1cd2?data=$content'));
  }

  onEvent(event) {
    if (!mounted) return;
    setState(() {
      textEvents += "${event.toString()}\n";
    });
  }

}
