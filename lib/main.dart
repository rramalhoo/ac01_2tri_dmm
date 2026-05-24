import 'package:flutter/material.dart';
import 'dart:math';
import 'custom_textfield.dart';
import 'custom_button.dart';

void main() {
  runApp(const SimuladorFinanceiroApp());
}

class SimuladorFinanceiroApp extends StatelessWidget {
  const SimuladorFinanceiroApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simulador Financeiro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SimuladorHome(),
    );
  }
}

class SimuladorHome extends StatefulWidget {
  const SimuladorHome({Key? key}) : super(key: key);

  @override
  _SimuladorHomeState createState() => _SimuladorHomeState();
}

class _SimuladorHomeState extends State<SimuladorHome> {
  final TextEditingController _valorInicialCtrl = TextEditingController();
  final TextEditingController _aporteMensalCtrl = TextEditingController();
  final TextEditingController _taxaJurosCtrl = TextEditingController();
  final TextEditingController _mesesCtrl = TextEditingController();
  final TextEditingController _metaCtrl = TextEditingController();

  double _montanteFinal = 0.0;
  double _totalInvestido = 0.0;
  double _lucro = 0.0;
  String _situacaoMeta = "";
  String _perfilFinanceiro = "";
  bool _calculado = false;

  void _exibirSnackbar(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _calcular() {
    if (_valorInicialCtrl.text.isEmpty ||
        _aporteMensalCtrl.text.isEmpty ||
        _taxaJurosCtrl.text.isEmpty ||
        _mesesCtrl.text.isEmpty ||
        _metaCtrl.text.isEmpty) {
      _exibirSnackbar("Preencha todos os campos", erro: true);
      return;
    }

    double valorInicial = double.tryParse(_valorInicialCtrl.text.replaceAll(',', '.')) ?? 0.0;
    double aporteMensal = double.tryParse(_aporteMensalCtrl.text.replaceAll(',', '.')) ?? 0.0;
    double taxaJuros = double.tryParse(_taxaJurosCtrl.text.replaceAll(',', '.')) ?? 0.0;
    int meses = int.tryParse(_mesesCtrl.text) ?? 0;
    double meta = double.tryParse(_metaCtrl.text.replaceAll(',', '.')) ?? 0.0;

    if (meses <= 0 || taxaJuros < 0) {
      _exibirSnackbar("Valores inválidos", erro: true);
      return;
    }

    double taxaDecimal = taxaJuros / 100;
    
    double montanteP = valorInicial * pow(1 + taxaDecimal, meses);
    double montanteA = taxaDecimal > 0 
        ? aporteMensal * ((pow(1 + taxaDecimal, meses) - 1) / taxaDecimal)
        : aporteMensal * meses;
    
    double montanteFinal = montanteP + montanteA;
    double totalInvestido = valorInicial + (aporteMensal * meses);
    double lucro = montanteFinal - totalInvestido;

    String perfil;
    if (taxaJuros < 0.5) {
      perfil = "Conservador";
    } else if (taxaJuros >= 0.5 && taxaJuros <= 1.5) {
      perfil = "Moderado";
    } else {
      perfil = "Agressivo";
    }

    String situacao;
    if (montanteFinal >= meta) {
      situacao = "Meta alcançada";
    } else {
      double falta = meta - montanteFinal;
      situacao = "Faltam R\$ ${falta.toStringAsFixed(2)} para atingir a meta";
    }

    setState(() {
      _montanteFinal = montanteFinal;
      _totalInvestido = totalInvestido;
      _lucro = lucro;
      _perfilFinanceiro = perfil;
      _situacaoMeta = situacao;
      _calculado = true;
    });

    _exibirSnackbar("Simulação realizada com sucesso");
  }

  void _abrirDialogLimpeza() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Opções de Dados"),
          content: const Text("O que você deseja fazer com os dados atuais?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("CANCELAR"),
            ),
            TextButton(
              onPressed: () {
                _limparTudo();
                Navigator.of(context).pop();
                _exibirSnackbar("Dados removidos com sucesso");
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("LIMPAR TUDO"),
            ),
            TextButton(
              onPressed: () {
                _carregarExemplo();
                Navigator.of(context).pop();
                _exibirSnackbar("Dados de exemplo carregados");
              },
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text("CARREGAR EXEMPLO"),
            ),
          ],
        );
      },
    );
  }

  void _limparTudo() {
    setState(() {
      _valorInicialCtrl.clear();
      _aporteMensalCtrl.clear();
      _taxaJurosCtrl.clear();
      _mesesCtrl.clear();
      _metaCtrl.clear();
      _calculado = false;
    });
  }

  void _carregarExemplo() {
    setState(() {
      _valorInicialCtrl.text = "1000";
      _aporteMensalCtrl.text = "500";
      _taxaJurosCtrl.text = "1.2";
      _mesesCtrl.text = "24";
      _metaCtrl.text = "30000";
      _calculado = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simulador de Investimentos"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Preencha os dados da simulação",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "1. Valor Inicial",
              prefix: "R\$ ",
              controller: _valorInicialCtrl,
            ),
            CustomTextField(
              label: "2. Aporte Mensal",
              prefix: "R\$ ",
              controller: _aporteMensalCtrl,
            ),
            CustomTextField(
              label: "3. Taxa de Juros (%)",
              controller: _taxaJurosCtrl,
            ),
            CustomTextField(
              label: "4. Quantidade de Meses",
              controller: _mesesCtrl,
            ),
            CustomTextField(
              label: "5. Meta Financeira",
              prefix: "R\$ ",
              controller: _metaCtrl,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CustomButton(
                    text: "CALCULAR",
                    onPressed: _calcular,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: "LIMPAR DADOS",
                    onPressed: _abrirDialogLimpeza,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (_calculado) ...[
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              const Text(
                "Resultados da Simulação",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildResultRow("Montante Final:", "R\$ ${_montanteFinal.toStringAsFixed(2)}"),
              _buildResultRow("Total Investido:", "R\$ ${_totalInvestido.toStringAsFixed(2)}"),
              _buildResultRow("Lucro Obtido:", "R\$ ${_lucro.toStringAsFixed(2)}", color: Colors.green),
              _buildResultRow("Perfil Financeiro:", _perfilFinanceiro, color: Colors.blueAccent),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _situacaoMeta,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}