import 'package:flutter/material.dart';
import '../bloc/call_state.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final CallState state;
  
  const ConnectionStatusWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    
    switch (state.status) {
      case CallStatus.callConnected:
        statusColor = Colors.green;
        statusText = '✅ Conectado';
        break;
      case CallStatus.creatingCall:
        statusColor = Colors.orange;
        statusText = '⏳ Creando llamada...';
        break;
      case CallStatus.joiningCall:
        statusColor = Colors.orange;
        statusText = '⏳ Uniéndose a llamada...';
        break;
      case CallStatus.callCreated:
        statusColor = Colors.blue;
        statusText = '📞 Llamada creada';
        break;
      case CallStatus.error:
        statusColor = Colors.red;
        statusText = '❌ Error';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '📱 Desconectado';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}