import 'package:campuszone/ui/community/events/events.dart';
import 'package:campuszone/custom/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Class representing each community's data
class Community {
  final String name; // Name of the community
  final Color color; // Background color for the container
  final String imageUrl; // Path to the local image asset

  Community({
    required this.name,
    required this.color,
    required this.imageUrl,
  });
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _clgname = dotenv.env['CLG_NAME'];

  @override
  Widget build(BuildContext context) {
    // Sample community data (list of Community objects)
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Community Title Section
              SizedBox(
                width: double.infinity,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  color: Colors.white,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Community",
                      style: TextStyle(
                        fontFamily: 'Excalifont',
                        fontSize: 50,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              // Title of Popular Communities
              Padding(
                padding: const EdgeInsets.only(top: 60.0, bottom: 30.0),
                child: Text(
                  "Popular Communities:",
                  style: TextStyle(
                    fontFamily: 'Excalifont',
                    fontSize: 26,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Custom Divider
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: SquigglyDivider(
                  height: 50,
                  width: 200,
                  color: Colors.black,
                ),
              ),

              // College Name Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Events at: \n$_clgname",
                  style: TextStyle(
                    fontFamily: 'Excalifont',
                    fontSize: 26,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Event Section
              Padding(
                padding: const EdgeInsets.only(bottom: 200.0),
                child: EventPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
