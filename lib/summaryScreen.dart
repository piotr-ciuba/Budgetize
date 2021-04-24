import 'package:budgetize/account.dart';
import 'package:budgetize/transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'transactionScreen.dart';

DateFormat formatter = DateFormat('dd-MM');
DateTime today = DateTime.now();

class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  List<DateTime> days = [];
  List<String> daysFormatted = [];
  var transactionsBox = Hive.box<Transaction>('transactions');
  bool initialized = false;
  List<double> daySpendingAmount = [];
  List<String> daySpendingAmountCompactString = [];
  List<int> showTooltipIndicator = [];
  double amount;
  double maxSpendingValue = 0;

  void initDays () {
    for(int i = 6; i >= 0; i--){
      var nextDay = today.subtract(Duration(days: i));
      var nextDayFormatted = formatter.format(nextDay);
      days.add(nextDay);
      daysFormatted.add(nextDayFormatted);
      daySpendingAmount.insert(6-i, 0);
      showTooltipIndicator.insert(6-i, 0);
      daySpendingAmountCompactString.insert(6-i, "");
    }
  }

  void calculateDaySpendings() {
    for (int i = 0; i < transactionsBox.length; i++) {
      var transaction = transactionsBox.getAt(i);

      for (int j = 6; j >= 0; j--) {
        var date = days.elementAt(j);

        if (transaction.type == TransactionType.expenditure &&
            transaction.date.year == date.year &&
            transaction.date.month == date.month &&
            transaction.date.day == date.day ) {

          daySpendingAmount[j] += transaction.amount;
        }
      }
    }

    for (int j = 6; j >= 0; j--) {
      if (daySpendingAmount[j] > maxSpendingValue)
        maxSpendingValue = daySpendingAmount[j] * 1.4;

      if (daySpendingAmount[j] != 0)
        showTooltipIndicator[j] = 0;
      else
        showTooltipIndicator[j] = 1;

      daySpendingAmountCompactString[j] = NumberFormat.compact().format(daySpendingAmount[j]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(initialized == false) {
      initDays();
      calculateDaySpendings();
      initialized = true;
    }

    return Container(
      color: Color.fromRGBO(223, 223, 223, 100),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child:  Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        child: Text("Accounts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                      ),
                      Expanded(
                        child: accountsListView(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              child:  Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                          ),
                          child: Text("Weekly expenses", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                        ),
                        Expanded(
                          child: Container(
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxSpendingValue,
                                barTouchData: BarTouchData(
                                  enabled: false,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: Colors.indigo,
                                    tooltipPadding: const EdgeInsets.only(bottom: -3),
                                    tooltipMargin: 6,
                                    getTooltipItem: (
                                        BarChartGroupData group,
                                        int groupIndex,
                                        BarChartRodData rod,
                                        int rodIndex,
                                        ) {
                                      return BarTooltipItem(
                                        daySpendingAmountCompactString[groupIndex],
                                        TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: SideTitles(
                                    showTitles: true,
                                    getTextStyles: (value) => const TextStyle(
                                        color: Color(0xff7589a2), fontWeight: FontWeight.bold, fontSize: 12),
                                    getTitles: (double value) {
                                      return daysFormatted.elementAt(value.toInt());
                                    },
                                  ),
                                  leftTitles: SideTitles(
                                    showTitles: false,
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                barGroups: [
                                  BarChartGroupData(
                                    x: 0,
                                    barRods: [
                                      BarChartRodData(y: daySpendingAmount[0], colors: [Colors.lightBlueAccent, Colors.greenAccent])
                                    ],
                                    showingTooltipIndicators: [showTooltipIndicator[0]],
                                  ),
                                  BarChartGroupData(
                                    x: 1,
                                    barRods: [
                                      BarChartRodData(y: daySpendingAmount[1], colors: [Colors.lightBlueAccent, Colors.greenAccent])
                                    ],
                                    showingTooltipIndicators: [showTooltipIndicator[1]],
                                  ),
                                  BarChartGroupData(
                                    x: 2,
                                    barRods: [
                                      BarChartRodData(y: daySpendingAmount[2], colors: [Colors.lightBlueAccent, Colors.greenAccent])
                                    ],
                                    showingTooltipIndicators: [showTooltipIndicator[2]],
                                  ),
                                  BarChartGroupData(
                                    x: 3,
                                    barRods: [
                                      BarChartRodData(y: daySpendingAmount[3], colors: [Colors.lightBlueAccent, Colors.greenAccent])
                                    ],
                                    showingTooltipIndicators: [showTooltipIndicator[3]],
                                  ),
                                  BarChartGroupData(
                                    x: 4,
                                    barRods: [
                                      BarChartRodData(y: daySpendingAmount[4], colors: [Colors.lightBlueAccent, Colors.greenAccent])
                                    ],
                                    showingTooltipIndicators: [showTooltipIndicator[4]],
                                  ),
                                  BarChartGroupData(
                                    x: 5,
                                    barRods: [
                                      BarChartRodData(y: daySpendingAmount[5], colors: [Colors.lightBlueAccent, Colors.greenAccent])
                                    ],
                                    showingTooltipIndicators: [showTooltipIndicator[5]],
                                  ),
                                  BarChartGroupData(
                                    x: 6,
                                    barRods: [
                                      BarChartRodData(y: daySpendingAmount[6], colors: [Colors.lightBlueAccent, Colors.greenAccent])
                                    ],
                                    showingTooltipIndicators: [showTooltipIndicator[6]],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
            ),
            Flexible(
              child:  Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        child: Text("Monthly balance changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    child: SizedBox(
                      child: FloatingActionButton(
                          heroTag: "addExpenditureButton",
                          elevation: 0,
                          onPressed: () {
                            print("Add expenditure button pressed.");
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => TransactionScreen(transactionType: TransactionType.expenditure,))).then((value) {
                                  setState(() {
                                    initialized = false;
                                  });
                                });
                          },
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.remove,
                            size: 45,
                          )),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    margin: EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      child: FloatingActionButton(
                          heroTag: "addIncomeButton",
                          elevation: 0,
                          onPressed: () {
                            print("Add income button pressed.");
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => TransactionScreen(transactionType: TransactionType.income,))).then((value) {
                                  setState(() {
                                    initialized = false;
                                  });
                                });
                          },
                          backgroundColor: Colors.green,
                          child: Icon(Icons.add, size: 45)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  ListView accountsListView() {
    var accountBox = Hive.box<Account>('accounts');

    return ListView.builder(
      itemExtent: 46,
      itemCount: accountBox.length + 1,
      itemBuilder: (context, index) {
        if(index < accountBox.length) {
          var account = accountBox.getAt(index) as Account;

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(flex: 5, child: Text(account.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)),
                  Expanded(flex: 5, child: Text(account.cashAmount.toString())),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: Icon(Icons.edit, size: 28),
                      onPressed: () {
                        print("Edit account $index - button pressed");
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        else {
          return Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(flex: 10, child: Text("Add account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)),
                  Expanded(flex: 1,
                    child: IconButton(
                      icon: Icon(Icons.add_circle, size: 28,),
                      onPressed: () {
                        print("Add account - button pressed");
                      },
                    ),
                  ),
                ],
              ),
          );
        }
      },
    );
  }
}
