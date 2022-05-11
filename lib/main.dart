import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const requestURL =
    "https://api.hgbrasil.com/finance/stock_price?key=6afb0ece&symbol=";

void main() async {
  runApp(const MyApp());
}

Future<Map> getData(symbol) async {
    http.Response response = await http.get(Uri.parse(requestURL + symbol));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return throw Exception('Erro ao carregar dados...');
    }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanças',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Finanças'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController symbolController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _symbol = "";

  void _getDataFromAPI() async {
    _symbol = symbolController.text;

    if(_symbol.isNotEmpty) {
      await getData(_symbol);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(
              color: Colors.white,
            )),
        centerTitle: true,
      ),

      body: SingleChildScrollView (
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(Icons.monetization_on,
                  size: 100, color: Colors.orange),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    labelText: "Nome da ação",
                    labelStyle: TextStyle(color: Colors.orange)),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.orange, fontSize: 25.0),
                controller: symbolController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "* Insira o nome da ação para continuar";
                  }
                },
              ),
              Padding(
                  padding:
                    const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: ButtonTheme(
                    height: 50.0,
                    highlightColor: Colors.amber,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                            _getDataFromAPI();
                            setState(() {});
                        }
                      },
                      child: const Text(
                        "Ver valor",
                        style: TextStyle(
                            color: Colors.white, fontSize: 25.0),
                      ),
                    )),
              ),

              _symbol.isEmpty ?
                const Center(
                      child: Text(
                    "",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ))
              :
              FutureBuilder<Map>(
                future: getData(_symbol),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return const Center(
                        child: Text(
                      "Carregando dados...",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  default:
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text(
                        "Erro ao carregar dados...",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center,
                      ));
                    } else {
                        return Text(
                        snapshot.data!["results"][_symbol.toUpperCase()]["price"] == null ?
                        "Insira um nome válido!"
                        :  "Valor: R\$" + snapshot.data!["results"][_symbol.toUpperCase()]["price"].toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.amber, fontSize: 25.0),
                        );
                    }
                  }
                }
              )
          ]
      )
      )),
    );
  }
}
