import 'package:audioplayers/audioplayers.dart';

class ServiceAudio {
  final AudioPlayer _lecteurAudio = AudioPlayer();
  
  // Callbacks pour notifier l'écran
  Function(Duration)? surChangementDuree;
  Function(Duration)? surChangementPosition;
  
  ServiceAudio() {
    _initialiserEcouteurs();
  }
  
  void _initialiserEcouteurs() {
    // Écouter la durée totale
    _lecteurAudio.onDurationChanged.listen((duree) {
      surChangementDuree?.call(duree);
    });
    
    // Écouter la position actuelle
    _lecteurAudio.onPositionChanged.listen((position) {
      surChangementPosition?.call(position);
    });
  }
  
  Future<void> jouer(String cheminFichier) async {
    await _lecteurAudio.play(DeviceFileSource(cheminFichier));
  }
  
  Future<void> pauser() async {
    await _lecteurAudio.pause();
  }
  
  Future<void> reprendre() async {
    await _lecteurAudio.resume();
  }
  
  Future<void> arreter() async {
    await _lecteurAudio.stop();
  }
  
  // Aller à une position spécifique
  Future<void> allerA(Duration position) async {
    await _lecteurAudio.seek(position);
  }
}