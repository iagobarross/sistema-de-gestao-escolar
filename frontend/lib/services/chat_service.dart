import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:gestao_escolar_app/services/api_client.dart';

class ChatService {
  StompClient? _stompClient;
  final Function(Map<String, dynamic>) onMensagemRecebida;

  ChatService({required this.onMensagemRecebida});

  void conectar(String tokenJwt) {
    // Porta 8081 que corrigimos anteriormente!
    final String url = ApiClient.wsDomain;

    _stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) => print('Erro no WebSocket: $error'),
        onStompError: (StompFrame frame) => print('Erro no STOMP: ${frame.body}'),
        onDisconnect: (frame) => print('Desconectado do chat'),
        stompConnectHeaders: {'Authorization': 'Bearer $tokenJwt'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $tokenJwt'},
      ),
    );

    _stompClient?.activate();
  }

  void _onConnect(StompFrame frame) {
    print('Conectado ao WebSocket com sucesso!');

    // 1. Ouvir o Canal Público (Mural)
    _stompClient?.subscribe(
      destination: '/topic/publico',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final Map<String, dynamic> msg = json.decode(frame.body!);
          onMensagemRecebida(msg);
        }
      },
    );

    // 2. Ouvir o Canal Privado (Mensagens Diretas para mim)
    _stompClient?.subscribe(
      destination: '/user/queue/privado',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final Map<String, dynamic> msg = json.decode(frame.body!);
          onMensagemRecebida(msg);
        }
      },
    );
  }

  void enviarMensagemPublica(String texto) {
    if (_stompClient != null && _stompClient!.isActive) {
      final payload = json.encode({'conteudo': texto});
      _stompClient?.send(
        destination: '/app/chat.enviarPublico',
        body: payload,
      );
    }
  }

  // NOVO: Método para enviar mensagem privada passando o ID do destinatário
  void enviarMensagemPrivada(String texto, int destinatarioId) {
    if (_stompClient != null && _stompClient!.isActive) {
      final payload = json.encode({
        'conteudo': texto,
        'destinatarioId': destinatarioId,
      });
      _stompClient?.send(
        destination: '/app/chat.enviarPrivado',
        body: payload,
      );
    }
  }

  void desconectar() {
    _stompClient?.deactivate();
  }
}