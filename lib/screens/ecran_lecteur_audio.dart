import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/service_audio.dart';

class EcranLecteurAudio extends StatefulWidget {
  const EcranLecteurAudio({super.key});

  @override
  State<EcranLecteurAudio> createState() => _EtatEcranLecteurAudio();
}

class _EtatEcranLecteurAudio extends State<EcranLecteurAudio> {
  final ServiceAudio _serviceAudio = ServiceAudio();
  String _nomFichier = 'Aucun fichier sélectionné';
  bool _estEnLecture = false;
  
  // Nouvelles variables pour la progression
  Duration _duree = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    
    // Écouter les changements de durée
    _serviceAudio.surChangementDuree = (duree) {
      setState(() {
        _duree = duree;
      });
    };
    
    // Écouter les changements de position
    _serviceAudio.surChangementPosition = (position) {
      setState(() {
        _position = position;
      });
    };
  }

  // Choisir un fichier
  Future<void> _choisirFichier() async {
    FilePickerResult? resultat = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (resultat != null) {
      String cheminFichier = resultat.files.single.path!;
      setState(() {
        _nomFichier = resultat.files.single.name;
      });
      await _serviceAudio.jouer(cheminFichier);
      setState(() {
        _estEnLecture = true;
      });
    }
  }

  // Play/Pause
  Future<void> _basculerLecturePause() async {
    if (_estEnLecture) {
      await _serviceAudio.pauser();
    } else {
      await _serviceAudio.reprendre();
    }
    setState(() {
      _estEnLecture = !_estEnLecture;
    });
  }

  // Formater la durée en mm:ss
  String _formaterDuree(Duration duree) {
    String deuxChiffres(int n) => n.toString().padLeft(2, '0');
    String minutes = deuxChiffres(duree.inMinutes.remainder(60));
    String secondes = deuxChiffres(duree.inSeconds.remainder(60));
    return '$minutes:$secondes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecteur Audio'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nom du fichier
              Text(
                _nomFichier,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Barre de progression
              Slider(
                min: 0.0,
                max: _duree.inSeconds.toDouble(),
                value: _position.inSeconds.toDouble().clamp(0.0, _duree.inSeconds.toDouble()),
                onChanged: (valeur) async {
                  final nouvellePossition = Duration(seconds: valeur.toInt());
                  await _serviceAudio.allerA(nouvellePossition);
                },
              ),
              
              // Temps actuel / Durée totale
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formaterDuree(_position)),
                    Text(_formaterDuree(_duree)),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Bouton choisir fichier
              ElevatedButton.icon(
                onPressed: _choisirFichier,
                icon: const Icon(Icons.folder_open),
                label: const Text('Choisir un fichier MP3'),
              ),
              
              const SizedBox(height: 20),
              
              // Bouton Play/Pause
              ElevatedButton.icon(
                onPressed: _estEnLecture || _duree.inSeconds > 0 ? _basculerLecturePause : null,
                icon: Icon(_estEnLecture ? Icons.pause : Icons.play_arrow),
                label: Text(_estEnLecture ? 'Pause' : 'Lecture'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}