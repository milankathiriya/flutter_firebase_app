import 'dart:convert';

import 'package:firebase_app/helpers/firebase_helper.dart';
import 'package:firebase_app/screens/dashboard.dart';
import 'package:firebase_app/variables..dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("${message.notification!.title}, ${message.notification!.body}");

  print("${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MaterialApp(
      routes: {
        '/': (context) => const HomePage(),
        'dashboard': (context) => const DashBoard(),
      },
      debugShowCheckedModeBanner: false,
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController emailSignInController = TextEditingController();
  final TextEditingController passwordSignInController =
      TextEditingController();

  String email = "";
  String password = "";

  fetchMyDeviceToken() async {
    String? token = await messaging.getToken();
    print("==================================");
    print(token);
    print("==================================");
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    fetchMyDeviceToken();

    // For foreground FCM
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text("Notification data: ${message.data}"),
        ),
      );
      if (message.data != null) {
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        print(
            'Message also contained a notification: ${message.notification!.title}, ${message.notification!.body}');
      }
    });

    var initialiseSettingsAndroid =
        const AndroidInitializationSettings("mipmap/ic_launcher");
    var initialiseSettingsIOS = const IOSInitializationSettings();

    var initSettings = InitializationSettings(
        android: initialiseSettingsAndroid, iOS: initialiseSettingsIOS);

    tz.initializeTimeZones();

    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);
  }

  void onSelectNotification(String? payload) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Payload Data"),
        content: Text("$payload"),
      ),
    );
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        print("============================");
        print("App in Background");
        print("============================");
        break;
      case AppLifecycleState.resumed:
        print("============================");
        print("App in Foreground");
        print("============================");
        break;
      case AppLifecycleState.inactive:
        print("============================");
        print("App is in inactive mode");
        print("============================");
        break;
      case AppLifecycleState.detached:
        print("============================");
        print("App is closed even from background");
        print("============================");
        break;
    }
  }

  Future<void> showSimpleNotification() async {
    var androidNotificationDetails = const AndroidNotificationDetails(
      '1',
      'Flutter Pro',
      importance: Importance.high,
      priority: Priority.max,
    );

    var iOSNotificationDetails = const IOSNotificationDetails();

    var notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iOSNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      1,
      'My First Simple Notification',
      'This is dummy content',
      notificationDetails,
      payload: 'Simple Notification data',
    );
  }

  Future<void> showScheduleNotification() async {
    var androidNotificationDetails = const AndroidNotificationDetails(
      '1',
      'Flutter Pro',
      importance: Importance.high,
      priority: Priority.max,
    );

    var iOSNotificationDetails = const IOSNotificationDetails();

    var notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iOSNotificationDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      'My Scheduled Notification',
      'Dummy Content',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: 'Scheduled Notification data',
    );
  }

  Future<void> showBigPictureNotification() async {
    var bigPictureStyleInfo = const BigPictureStyleInformation(
      DrawableResourceAndroidBitmap('mipmap/ic_launcher'),
      contentTitle: 'Big Notification...',
      largeIcon: DrawableResourceAndroidBitmap('mipmap/ic_launcher'),
    );

    var androidNotificationDetails = AndroidNotificationDetails(
      '1',
      'Flutter Pro',
      importance: Importance.high,
      priority: Priority.max,
      styleInformation: bigPictureStyleInfo,
    );

    var notificationDetails =
        NotificationDetails(android: androidNotificationDetails, iOS: null);

    await flutterLocalNotificationsPlugin.show(
      3,
      'My First Big Picture Notification',
      'This is dummy content',
      notificationDetails,
      payload: 'Big Picture Notification data',
    );
  }

  Future<void> showMediaNotification() async {
    var androidNotificationDetails = const AndroidNotificationDetails(
      '1',
      'Flutter Pro',
      importance: Importance.high,
      priority: Priority.max,
      color: Colors.red,
      enableLights: true,
      largeIcon: DrawableResourceAndroidBitmap('mipmap/ic_launcher'),
      styleInformation: MediaStyleInformation(),
    );

    var notificationDetails =
        NotificationDetails(android: androidNotificationDetails, iOS: null);

    await flutterLocalNotificationsPlugin.show(
      4,
      'My First Media Notification',
      'This is dummy content',
      notificationDetails,
      payload: 'Media Notification data',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase App"),
        centerTitle: true,
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("FCM Notification"),
              onPressed: sendFCM,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: const Text("Subscribe"),
                  onPressed: () async {
                    await FirebaseMessaging.instance
                        .subscribeToTopic('education');

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Subscribed successfully..."),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  child: const Text("Unsubscribe"),
                  onPressed: () async {
                    await FirebaseMessaging.instance
                        .unsubscribeFromTopic('education');

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Unsubscribed successfully..."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(),
            ElevatedButton(
              child: const Text("Simple Notification"),
              onPressed: () {
                showSimpleNotification();
              },
            ),
            ElevatedButton(
              child: const Text("Scheduled Notification"),
              onPressed: () {
                showScheduleNotification();
              },
            ),
            ElevatedButton(
              child: const Text("Big Picture Notification"),
              onPressed: () {
                showBigPictureNotification();
              },
            ),
            ElevatedButton(
              child: const Text("Media Style Notification"),
              onPressed: () {
                showMediaNotification();
              },
            ),
            const Divider(color: Colors.black),
            ElevatedButton(
              child: const Text("Anonymous Login"),
              onPressed: () async {
                String response =
                    await FirebaseHelper.firebaseHelper.logInAnonymously();

                if (response == "Your account is disabled...") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                          "Login Failed\nBecause Your account is disabled..."),
                    ),
                  );
                } else if (response == "Unknown Error") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text("Login Failed\nUnknown Error"),
                    ),
                  );
                } else {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     backgroundColor: Colors.green,
                  //     content: Text("Login Successfully...\nUID: $response"),
                  //   ),
                  // );

                  Navigator.of(context).pushNamed('dashboard');
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: const Text("Sign Up"),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Center(
                          child: Text("Sign Up User"),
                        ),
                        actions: [
                          ElevatedButton(
                            child: const Text("Sign Up"),
                            onPressed: () async {
                              if (signUpFormKey.currentState!.validate()) {
                                signUpFormKey.currentState!.save();

                                String response = await FirebaseHelper
                                    .firebaseHelper
                                    .signUpWithEmailAndPassword(
                                        email: email, password: password);

                                if (response == "operation-not-allowed") {
                                  showSnackBar(
                                      myColor: Colors.red,
                                      msg: "Your account is disabled...");
                                } else if (response == "weak-password") {
                                  showSnackBar(
                                      myColor: Colors.red,
                                      msg: "Your password is too weak...");
                                } else if (response == "email-already-in-use") {
                                  showSnackBar(
                                      myColor: Colors.red,
                                      msg: "This account is already in use...");
                                } else {
                                  showSnackBar(
                                      myColor: Colors.green,
                                      msg:
                                          "Sign Up Successfully....\nUID: $response");
                                }
                              }

                              emailController.clear();
                              passwordController.clear();

                              setState(() {
                                email = "";
                                password = "";
                              });

                              Navigator.of(context).pop();
                            },
                          ),
                          OutlinedButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              emailController.clear();
                              passwordController.clear();

                              setState(() {
                                email = "";
                                password = "";
                              });

                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                        content: Form(
                          key: signUpFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Enter email id first...";
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  setState(() {
                                    email = val!;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: "Enter your email",
                                  label: Text("Email"),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              TextFormField(
                                controller: passwordController,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Enter password first...";
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  setState(() {
                                    password = val!;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: "Enter your password",
                                  label: Text("Password"),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  child: const Text("Sign In"),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Center(
                          child: Text("Sign In User"),
                        ),
                        actions: [
                          ElevatedButton(
                            child: const Text("Sign In"),
                            onPressed: () async {
                              if (signInFormKey.currentState!.validate()) {
                                signInFormKey.currentState!.save();

                                String response = await FirebaseHelper
                                    .firebaseHelper
                                    .signInWithEmailAndPassword(
                                        email: email, password: password);

                                if (response == "operation-not-allowed") {
                                  Navigator.of(context).pop();
                                  showSnackBar(
                                      myColor: Colors.red,
                                      msg: "Your account is disabled...");
                                } else if (response == "user-not-found") {
                                  Navigator.of(context).pop();
                                  showSnackBar(
                                      myColor: Colors.red,
                                      msg:
                                          "User with this email does not exists.");
                                } else if (response == "wrong-password") {
                                  Navigator.of(context).pop();
                                  showSnackBar(
                                      myColor: Colors.red,
                                      msg: "Wrong Password.");
                                } else if (response == "weak-password") {
                                  Navigator.of(context).pop();
                                  showSnackBar(
                                      myColor: Colors.red,
                                      msg: "Your password is too weak...");
                                } else if (response == "email-already-in-use") {
                                  Navigator.of(context).pop();
                                  showSnackBar(
                                      myColor: Colors.red,
                                      msg: "This account is already in use...");
                                } else if (response == "user-disabled") {
                                  Navigator.of(context).pop();
                                  showSnackBar(
                                      myColor: Colors.red,
                                      msg: "This account is disabled.");
                                } else {
                                  // showSnackBar(
                                  //     myColor: Colors.green,
                                  //     msg:
                                  //         "Sign In Successfully....\nUID: $response");
                                  Navigator.of(context).pop();

                                  Navigator.of(context).pushNamed('dashboard');
                                }
                              } else {
                                Navigator.of(context).pop();
                              }

                              emailSignInController.clear();
                              passwordSignInController.clear();

                              setState(() {
                                email = "";
                                password = "";
                              });
                            },
                          ),
                          OutlinedButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              emailSignInController.clear();
                              passwordSignInController.clear();

                              setState(() {
                                email = "";
                                password = "";
                              });

                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                        content: Form(
                          key: signInFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: emailSignInController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Enter email id first...";
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  setState(() {
                                    email = val!;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: "Enter your email",
                                  label: Text("Email"),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              TextFormField(
                                controller: passwordSignInController,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Enter password first...";
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  setState(() {
                                    password = val!;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: "Enter your password",
                                  label: Text("Password"),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            ElevatedButton(
              child: const Text("Sign in with Google"),
              onPressed: () async {
                User? user =
                    await FirebaseHelper.firebaseHelper.signInWithGoogle();

                if (user != null) {
                  Global.user = user;

                  print("${user.uid}");
                  print("${user.displayName}");
                  print("${user.email}");
                  print("${user.photoURL}");

                  Navigator.of(context).pushNamed('dashboard');
                } else {
                  showSnackBar(
                    myColor: Colors.red,
                    msg: "Sign in failed...",
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void showSnackBar({required Color myColor, required String msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: myColor,
        content: Text(msg),
      ),
    );
  }

  sendFCM() async {
    Uri url = Uri.parse("https://fcm.googleapis.com/fcm/send");

    var myHeaders = {
      'Content-type': 'application/json',
      'Authorization':
          'key=AAAAah4SXEU:APA91bGIl5T1vEC9G1Qmb94-ovqTS_zfiPV1lZ2pxdlm2RCDzl_hb8E0wPMlqK0d6q9wAwgY0QSQe8OswYOJe-YlkfdIK7N9spqhAd4TD15EK60yRUdf_i6JuQWP67R8L8YL4Eex6Biq',
    };

    Map<String, dynamic> myBody = {
      "to": "/topics/education",
      "notification": {
        "content_available": true,
        "priority": "high",
        "title": "hello",
        "body": "My Body"
      },
      "data": {
        "priority": "high",
        "content_available": true,
        "school": "RNW",
        "age": "22"
      }
    };

    http.Response res =
        await http.post(url, headers: myHeaders, body: jsonEncode(myBody));

    print("--------------------------------------");
    print(res.statusCode);
    if (res.statusCode == 200) {
      Map<String, dynamic> decodedData = jsonDecode(res.body);

      print(decodedData['message_id']);
    }
    print("--------------------------------------");
  }
}
