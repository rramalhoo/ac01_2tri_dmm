import 'package:flutter/material.dart';

import 'widgets/texto.dart';
import 'widgets/botoes.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CalculadoraHome(),
  ));
}

class CalculadoraHome extends StatefulWidget {
  const CalculadoraHome({super.key});

  @override
  State<CalculadoraHome> createState() => _CalculadoraHomeState();
}

class _CalculadoraHomeState extends State<CalculadoraHome> {
  final _valorInicialCtrl = TextEditingController();
  final _aporteMensalCtrl = TextEditingController();
  final _taxaJurosCtrl = TextEditingController();
  final _mesesCtrl = TextEditingController();
  final _metaFinanceiraCtrl = TextEditingController();

  String _resultados = "";

  void _calcular() {

    if (_valorInicialCtrl.text.isEmpty ||
        _aporteMensalCtrl.text.isEmpty ||
        _taxaJurosCtrl.text.isEmpty ||
        _mesesCtrl.text.isEmpty ||
        _metaFinanceiraCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos")),
      );
      return;
    }

    double p = double.parse(_valorInicialCtrl.text);
    double aporte = double.parse(_aporteMensalCtrl.text);
    double juros = double.parse(_taxaJurosCtrl.text);
    int t = int.parse(_mesesCtrl.text);
    double meta = double.parse(_metaFinanceiraCtrl.text);

    double i = juros / 100;


    double multiplicador = 1.0;
    for (int mes = 0; mes < t; mes++) {
      multiplicador = multiplicador * (1 + i);
    }

  
    double montanteFinal = (p * multiplicador);
    if (i > 0) {
      montanteFinal += (aporte * ((multiplicador - 1) / i));
    } else {
      montanteFinal += (aporte * t);
    }
    // ------------------------------------

    double totalInvestido = p + (aporte * t); 
    double lucro = montanteFinal - totalInvestido; 

    String situacao = "";
    String perfil = "";

    if (montanteFinal >= meta) { 
      situacao = "Meta alcançada";
    } else {
      situacao = "Meta não alcançada";
    }

    if (juros < 0.5) { 
      perfil = "Conservador";
    } else if (juros <= 1.5) {
      perfil = "Moderado";
    } else {
      perfil = "Agressivo";
    }

    setState(() {
      _resultados = """
Montante Final: R\$ ${montanteFinal.toStringAsFixed(2)}
Total Investido: R\$ ${totalInvestido.toStringAsFixed(2)}
Lucro: R\$ ${lucro.toStringAsFixed(2)}
Situação da Meta: $situacao
Perfil Financeiro: $perfil
      """;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Simulação realizada com sucesso")), 
    );
  }

  void _limparDados() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Atenção"),
        content: const Text("O que deseja fazer?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"), 
          ),
          TextButton(
            onPressed: () {
              _valorInicialCtrl.clear();
              _aporteMensalCtrl.clear();
              _taxaJurosCtrl.clear();
              _mesesCtrl.clear();
              _metaFinanceiraCtrl.clear();
              setState(() => _resultados = "");
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Dados removidos com sucesso")), 
              );
            },
            child: const Text("LIMPAR TUDO"), 
          ),
          TextButton(
            onPressed: () {
              _valorInicialCtrl.text = "1000"; 
              _aporteMensalCtrl.text = "500"; 
              _taxaJurosCtrl.text = "1.2"; 
              _mesesCtrl.text = "24"; 
              _metaFinanceiraCtrl.text = "30000"; 
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Dados de exemplo carregados")), 
              );
            },
            child: const Text("CARREGAR EXEMPLO"), 
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Simulador")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            campoTexto(label: "Valor Inicial", controller: _valorInicialCtrl), 
            campoTexto(label: "Aporte Mensal", controller: _aporteMensalCtrl), 
            campoTexto(label: "Taxa de Juros (%)", controller: _taxaJurosCtrl), 
            campoTexto(label: "Quantidade de Meses", controller: _mesesCtrl), 
            campoTexto(label: "Meta Financeira", controller: _metaFinanceiraCtrl), 

            const SizedBox(height: 16),

            Row(
              children: [
                botao(texto: "CALCULAR", cor: Colors.blue, onPressed: _calcular), 
                botao(texto: "LIMPAR DADOS", cor: Colors.red, onPressed: _limparDados), 
              ],
            ),

            const SizedBox(height: 24),

            if (_resultados.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: Text(
                  _resultados,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}