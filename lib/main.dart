import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spica/models/log.dart';
import 'package:flutter_spica/services/log.dart';
import 'package:flutter_spica/services/auth.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  final model = LogModel();

  // Login and fetch logs in the background
  Future(() async {
    final token = await login();
    fetchLogs(model, token);
  });

  runApp(ChangeNotifierProvider(
    create: (context) => model,
    child: const MainApp(),
  ));
}

class HomeScreen extends StatelessWidget {
  final selectedDate = ValueNotifier<DateTime>(DateTime.now());
  final PageController pageController;

  final List<DateTime> daysOfThisWeek = [
    for (var i = 1; i <= 7; i++)
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - i)),
  ];

  HomeScreen({super.key})
      : pageController =
            PageController(initialPage: DateTime.now().weekday - 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter for Spica"),
      ),
      body: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<DateTime>(
                  valueListenable: selectedDate,
                  builder: (context, value, child) {
                    return SizedBox(
                      height: 48.0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: daysOfThisWeek.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            child: Container(
                              width: 56,
                              color: daysOfThisWeek[index].day ==
                                      selectedDate.value.day
                                  ? Colors.deepOrange
                                  : Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${daysOfThisWeek[index].month.toString().padLeft(2, '0')}.${daysOfThisWeek[index].day.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      color: daysOfThisWeek[index].day ==
                                              selectedDate.value.day
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    DateFormat.E()
                                        .format(daysOfThisWeek[index]),
                                    style: TextStyle(
                                      color: daysOfThisWeek[index].day ==
                                              selectedDate.value.day
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              pageController.animateToPage(index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Body
          Expanded(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                selectedDate.value = DateTime.now()
                    .subtract(Duration(days: DateTime.now().weekday - 1))
                    .add(Duration(days: index));
              },
              itemCount: 7,
              itemBuilder: (BuildContext context, int outerIndex) {
                return Consumer<LogModel>(builder: (context, log, child) {
                  return ListView.builder(
                    itemCount: log.getLogsForDateIndex(outerIndex).length == 0
                        ? 1
                        : log.getLogsForDateIndex(outerIndex).length,
                    itemBuilder: (BuildContext context, int index) {
                      if (log.getLogsForDateIndex(outerIndex).length == 0) {
                        if (!log.isLoading) {
                          return Container(
                            color: Colors.white,
                            child: Column(
                              children: const [
                                ListTile(
                                    title: Text("No logs for this day"),
                                    subtitle: Text(
                                        "Swipe left or right to check the other days")),
                                Divider(
                                  height: 0,
                                  thickness: 1,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.all(16),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      } else {
                        return Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(log
                                    .getLogsForDateIndex(outerIndex)[index]
                                    .logName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(log
                                        .getLogsForDateIndex(outerIndex)[index]
                                        .logDescription),
                                    Wrap(
                                      spacing: 4,
                                      children: [
                                        for (var tag in log
                                            .getLogsForDateIndex(
                                                outerIndex)[index]
                                            .logTags)
                                          Chip(
                                            label: Text(tag.name),
                                            backgroundColor: Color(int.parse(
                                                    tag.hexColor
                                                        .substring(1, 7),
                                                    radix: 16) +
                                                0xFF000000),
                                            labelStyle: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            padding: const EdgeInsets.all(0),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${log.getLogsForDateIndex(outerIndex)[index].logEndDate.difference(log.getLogsForDateIndex(outerIndex)[index].logStartDate).inHours.toString().padLeft(2, '0')}:${log.getLogsForDateIndex(outerIndex)[index].logEndDate.difference(log.getLogsForDateIndex(outerIndex)[index].logStartDate).inMinutes.remainder(60).toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      "${log.getLogsForDateIndex(outerIndex)[index].logStartDate.month.toString().padLeft(2, '0')}.${log.getLogsForDateIndex(outerIndex)[index].logStartDate.day.toString().padLeft(2, '0')} - ${log.getLogsForDateIndex(outerIndex)[index].logEndDate.month.toString().padLeft(2, '0')}.${log.getLogsForDateIndex(outerIndex)[index].logEndDate.day.toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 0,
                                thickness: 1,
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.black12,
        child: InkWell(
          onTap: () => 0,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const Text('Home'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter for Spica',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: HomeScreen(),
    );
  }
}
