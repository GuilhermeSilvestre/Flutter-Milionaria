import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:milionaria/pages/acertosjogo.dart';
import 'package:path_provider/path_provider.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  List<Map<String, dynamic>> _jogos = [];

  @override
  void initState() {
    super.initState();
    _loadJogos();
  }

  Future<void> _loadJogos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/jogosdousuario.json');
      if (await file.exists()) {
        final fileContent = await file.readAsString();
        setState(() {
          _jogos =
              (json.decode(fileContent) as List).cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print('Erro ao carregar jogos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E3078), Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _jogos.isEmpty
                    ? const Text(
                        'Você ainda não possui jogos registrados.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )
                    : Expanded(child: _buildJogosList()),
                Visibility(
                  visible: _jogos.isNotEmpty,
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _deleteAllJogos,
                      child: const Text('Deletar todos os registros'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJogosList() {
    return ListView.builder(
      itemCount: _jogos.length,
      itemBuilder: (context, index) {
        final jogo = _jogos[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AcertosJogo(
                  concurso: jogo['concurso'],
                  numeros: jogo['numeros'],
                  trevos: jogo['trevos'],
                ),
              ),
            );
          },
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            child: ListTile(
              title: Text(
                'Concurso: ${jogo['concurso']}',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Row(
                children: [
                  _buildNumeroBolas(jogo['numeros'], Colors.blue),
                  const SizedBox(width: 10),
                  _buildNumeroBolas(jogo['trevos'], Colors.green),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNumeroBolas(List<dynamic> numeros, Color cor) {
    return Row(
      children: numeros.map<Widget>((numero) {
        return Container(
          margin: const EdgeInsets.only(right: 5),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              numero.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _deleteAllJogos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/jogosdousuario.json');
      if (await file.exists()) {
        await file.delete();
        setState(() {
          _jogos = [];
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jogos deletados!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color.fromARGB(221, 223, 100, 83), // Cor de fundo
        ),
      );
    } catch (e) {
      print('Erro ao deletar jogos: $e');
    }
  }
}
