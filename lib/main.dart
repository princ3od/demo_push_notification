import 'package:demo_push_notification/Message.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  _receiveMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  String messageTitle = "Empty";
  String notificationAlert = "alert";
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return Scaffold(
            appBar: AppBar(
              title: Text("Demo Push Notification"),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    notificationAlert,
                  ),
                  Text(
                    messageTitle,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      print('start');
                      FirebaseMessaging.instance.requestPermission(
                        sound: true,
                        badge: true,
                        alert: true,
                        provisional: false,
                      );

                      FirebaseMessaging.instance
                          .setForegroundNotificationPresentationOptions(
                        alert: true,
                        badge: true,
                        sound: true,
                      );
                      FirebaseMessaging.instance.subscribeToTopic("ajent");
                      FirebaseMessaging.onMessage.listen((message) {
                        print('Got a message!!!');
                        // set up the button
                        Widget okButton = FlatButton(
                          child: Text("OK"),
                          onPressed: () {},
                        );

                        // set up the AlertDialog
                        AlertDialog alert = AlertDialog(
                          title: Text(message.notification.title),
                          content: Text(message.notification.body),
                          actions: [
                            okButton,
                          ],
                        );

                        // show the dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );

                        if (message.notification != null) {
                          print(
                              'Message tittle: ${message.notification.title}');

                          print(
                              'Message also contained a notification: ${message.notification.body}');
                        }
                      }).onError((error) {
                        print(error);
                      });
                      // FirebaseMessaging.onMessageOpenedApp.listen((message) {
                      //   print('Message data: ${message.notification}');
                      // }).onError((error) {
                      //   print(error);
                      // });
                    },
                    child: Text("start listenning notification"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final token = await FirebaseMessaging.instance.getToken();
                      print(token);
                      await Future.delayed(Duration(seconds: 10));
                      Messaging.sendToTopic(
                          title: "Send from users",
                          body: "Content",
                          topic: "ajent");
                    },
                    child: Text("send message (after 10s)"),
                  ),
                ],
              ),
            ),
          );
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
