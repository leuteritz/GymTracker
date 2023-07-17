import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color.fromARGB(255, 173, 15, 226);
    return CupertinoApp(
      title: 'My Gym Tracker App',
      home: MyHomePage(),
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryColor,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.systemGrey6,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return Foodscreen();
          case 1:
            return HomeScreen();
          case 2:
            return SettingsScreen();
          default:
            return HomeScreen();
        }
      },
    );
  }
}

class Foodscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Text('Food Screen'),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('GymTracker'),
      ),
      child: Center(
        child: Align(
          alignment: Alignment.center,
          child: CupertinoButton.filled(
            onPressed: () {
              showCupertinoModal(context);
            },
            child: Text('Add'),
          ),
        ),
      ),
    );
  }

  // function to open modal view
  void showCupertinoModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 300,
            height: 300,
            child: CupertinoPopupSurface(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, // Change the desired width
                    child: CupertinoTextField(
                        placeholder: 'Sets',
                        onChanged: (value) {
                          // Handle text input changes
                        },
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .copyWith(
                              fontSize: 20, // Change the font size
                            ),
                        padding: EdgeInsets.all(16),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Text('Settings Screen'),
      ),
    );
  }
}
