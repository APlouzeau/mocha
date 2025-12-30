import 'toast_context.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

// If ToastNoContext is not defined in the imported file, define a placeholder here for demonstration.
// Remove this if your import provides ToastNoContext.
class ToastNoContext extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Toast No Context')),
      body: Center(child: Text('ToastNoContext Widget')),
    );
  }
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() => runApp(
  MaterialApp(
    builder: FToastBuilder(),
    home: MyApp(),
    navigatorKey: navigatorKey,
  ),
);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Toast")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ToastNoContext()),
                );
              },
              child: Text("Flutter Toast No Context"),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => ToastContext()));
              },
              child: Text("Flutter Toast Context"),
            ),
          ],
        ),
      ),
    );
  }
}
