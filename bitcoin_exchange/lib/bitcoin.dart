import 'dart:convert';

import 'package:bitcoin_exchange/exchange.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:http/http.dart' as http;

class BitcoinScreen extends StatelessWidget {
  const BitcoinScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
            title: const Text('Bitcoin Exchange',
                style: TextStyle(color: Color.fromARGB(255, 247, 244, 237))),
            backgroundColor: const Color.fromARGB(255, 98, 75, 75)),
        body: const BitCoinForm(),
      ),
    );
  }
}

class BitCoinForm extends StatefulWidget {
  const BitCoinForm({Key? key}) : super(key: key);

  @override
  State<BitCoinForm> createState() => _BitCoinFormState();
}

class _BitCoinFormState extends State<BitCoinForm> {
  String selectCoin = "btc",
      ans = "",
      desc = "No available bitcoin currency excahnge information";
  double total = 0.0, bit = 1.0;

  List<String> loctList = [
    "btc",
    "eth",
    "ltc",
    "bch",
    "bnb",
    "eos",
    "xrp",
    "xlm",
    "link",
    "dot",
    "yfi",
    "usd",
    "aed",
    "ars",
    "aud",
    "bdt",
    "bhd",
    "bmd",
    "brl",
    "cad",
    "chf",
    "clp",
    "cny",
    "czk",
    "dkk",
    "eur",
    "gbp",
    "hkd",
    "huf",
    "idr",
    "ils",
    "inr",
    "jpy",
    "krw",
    "kwd",
    "lkr",
    "mmk",
    "mxn",
    "myr",
    "ngn",
    "nok",
    "nzd",
    "php",
    "pkr",
    "pln",
    "rub",
    "sar",
    "sek",
    "sgd",
    "thb",
    "try",
    "twd",
    "uah",
    "vef",
    "vnd",
    "zar",
    "xdr",
    "xag",
    "xau",
    "bits",
    "sats"
  ];

  Exchange curexchange = Exchange("Not available", 0.0, "", "Not available");
  TextEditingController bitcoinEditingController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                                height: 15,
                                width: 220,
                                child: Text("Bitcoin: ",style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                            SizedBox(
                                height: 20,
                                width: 70,
                                child: Text("Select: ",style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 50,
                              child: TextField(
                                controller: bitcoinEditingController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(),
                                decoration: InputDecoration(
                                    hintText: "Number of bitcoin",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    )),
                              ),
                            ),
                            DropdownButton(
                              itemHeight: 60,
                              value: selectCoin,
                              onChanged: (newValue) {
                                setState(() {
                                  selectCoin = newValue.toString();
                                });
                              },
                              items: loctList.map((selectCoin) {
                                return DropdownMenuItem(
                                    child: Text(selectCoin), value: selectCoin);
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loadExchange,
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 98, 75,
                            75), //background color of button //border width and color
                        elevation: 3, //elevation of button
                        shape: RoundedRectangleBorder(
                            //to set border radius to button
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(Icons.change_circle_outlined, size: 30),
                          Text("Exchange"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 300,
                    height: 50,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 231, 228, 220),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.transparent)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(ans),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(desc,
                      style: const TextStyle(
                          fontWeight: FontWeight.w300, fontSize: 12)),
                  const SizedBox(height: 30),
                  Expanded(
                    child: BitCoinGrid(curexchange: curexchange),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadExchange() async {
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Progress"), title: const Text("Searching..."));
    progressDialog.show();

    var url = Uri.parse('https://api.coingecko.com/api/v3/exchange_rates');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonData = response.body;
      var parsedData = json.decode(jsonData);
      var name = parsedData['rates'][selectCoin]['name'];
      var unit = parsedData['rates'][selectCoin]['unit'];
      var value = parsedData['rates'][selectCoin]['value'];
      var type = parsedData['rates'][selectCoin]['type'];

      curexchange = Exchange(name, value, unit, type);

      setState(() {
        double bit = double.parse(bitcoinEditingController.text);
        total = double.parse((bit * value).toStringAsFixed(2));
        desc = "The exchange rate is $value $unit per bitcoin.";
        ans = "$total  $unit";
      });
      progressDialog.dismiss();
    }
  }
}

class BitCoinGrid extends StatefulWidget {
  final Exchange curexchange;
  const BitCoinGrid({ Key? key, required this.curexchange }) : super(key: key);

  @override
  State<BitCoinGrid> createState() => _BitCoinGridState();
}

class _BitCoinGridState extends State<BitCoinGrid> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          width: double.infinity,
          height: 28,
          child: Text("\t\t\t\t\tCryptocurrency Exchange Information",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 19.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Schyler")),
        ),
        SizedBox(
          height: 400,
          width: 500,
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
            crossAxisSpacing: 30,
            mainAxisSpacing: 30,
            children: [
              GestureDetector(
                onTap: _pressMe,
                child: InkWell(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                      color: Color.fromARGB(255, 239, 224, 192),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Icon(Icons.currency_bitcoin_rounded, size: 55),
                        const Text(
                          "Name",
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                        Text(widget.curexchange.name)
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                  color: Color.fromARGB(255, 239, 224, 192),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset('assets/images/exchangerate.png', scale: 13),
                    const Text(
                      "Exchange Rate",
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold),
                    ),
                    Text("1 BTC = " +
                        widget.curexchange.value.toStringAsFixed(2) +
                        " " +
                        widget.curexchange.unit)
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                  color: Color.fromARGB(255, 239, 224, 192),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset('assets/images/type.png', scale: 7),
                    const Text(
                      "Type",
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.curexchange.type)
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _pressMe() {
    if (kDebugMode) {
      print("Hello");
    }
  }
}
