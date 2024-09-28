import 'dart:convert';
import 'dart:typed_data';
import 'package:udp/udp.dart';
import 'dart:io';

class VBAN {
  // Méthode statique pour envoyer un message VBAN Text
  static Future<void> sendText(
      String message, String ipAddress, int port) async {
    if (ipAddress.isEmpty || port == 0) {
      throw Exception('Adresse IP ou port invalide.');
    }

    // Créer un expéditeur UDP
    var sender = await UDP.bind(Endpoint.any(port: const Port(65000)));

    // Structure de l'en-tête VBAN
    List<int> vbanHeader = [
      // 'VBAN' en ASCII
      0x56, 0x42, 0x41, 0x4E, 0x4E, 0x00, 0x00, 0x00,
      // Nom du flux
      0x43, 0x6F, 0x6D, 0x6D, 0x61, 0x6E, 0x64, 0x31,
      // Compteur de paquets
      0x00,
      // Format SR index
      0x00,
      // Nombre d'éléments dans la charge utile
      message.length,
      // Sous-protocole (T pour Text)
      0x54, 0x00,
      // Réservé (24 bits)
      0x00, 0x00, 0x00,
      // Réservé (32 bits)
      0x00, 0x00, 0x00, 0x00,
    ];

    // Encoder le message en UTF-8
    List<int> messageBytes = utf8.encode(message);

    // Combiner l'en-tête et le message
    List<int> vbanPacket = vbanHeader + messageBytes;

    // Envoyer le paquet
    sender.send(Uint8List.fromList(vbanPacket),
        Endpoint.unicast(InternetAddress(ipAddress), port: Port(port)));

    return;

    // Fermer l'expéditeur UDP
    sender.close();
  }
}
