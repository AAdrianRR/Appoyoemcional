import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final List<Map<String, dynamic>> patients = [
    {
      "name": "Usuario Anónimo #492",
      "risk": "Alto", // Rojo
      "status": "Crisis detectada por IA (Cámara)",
      "lastActive": "Hace 5 min",
      "color": Colors.redAccent,
      "icon": Icons.warning_amber_rounded,
    },
    {
      "name": "Juan Pérez",
      "risk": "Alto", // Rojo
      "status": "Reportó ansiedad severa",
      "lastActive": "Hace 20 min",
      "color": Colors.redAccent,
      "icon": Icons.warning_amber_rounded,
    },
    {
      "name": "María G.",
      "risk": "Medio", // Amarillo
      "status": "Patrón de sueño irregular",
      "lastActive": "Hace 2 horas",
      "color": Colors.orangeAccent,
      "icon": Icons.remove_red_eye_outlined,
    },
    {
      "name": "Carlos R.",
      "risk": "Bajo", // Verde
      "status": "Completó su Senda hoy",
      "lastActive": "Hace 1 día",
      "color": Colors.green,
      "icon": Icons.check_circle_outline,
    },
    {
      "name": "Sofía L.",
      "risk": "Bajo", // Verde
      "status": "Estable",
      "lastActive": "Hace 3 días",
      "color": Colors.green,
      "icon": Icons.check_circle_outline,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F9FC), // Fondo azul muy suave (Clínico)
      appBar: AppBar(
        title: const Text("Panel de Monitoreo",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black54),
            onPressed: () {},
          ),
          const CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 16,
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABECERA DE RESUMEN
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                _buildSummaryCard("Riesgo Alto", "2", Colors.redAccent),
                const SizedBox(width: 10),
                _buildSummaryCard("Seguimiento", "1", Colors.orangeAccent),
                const SizedBox(width: 10),
                _buildSummaryCard("Estables", "25", Colors.green),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Pacientes en Tiempo Real",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          const SizedBox(height: 10),

          // LISTA DE PACIENTES (SEMAFORO)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return _buildPatientCard(patient);
              },
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Tarjeta de Resumen (Las cajitas de arriba)
  Widget _buildSummaryCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(count,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // WIDGET: Tarjeta de Paciente (El Semáforo)
  Widget _buildPatientCard(Map<String, dynamic> patient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // ÍCONO DEL SEMÁFORO
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: patient['color'].withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(patient['icon'], color: patient['color']),
        ),
        // INFORMACIÓN
        title: Text(
          patient['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              patient['status'],
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            Text(
              "Activo: ${patient['lastActive']}",
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ],
        ),
        // BOTÓN DE ACCIÓN
        trailing: ElevatedButton(
          onPressed: () {
            // Aquí abrirías el chat con el paciente o su perfil
            print("Abrir expediente de ${patient['name']}");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blueAccent,
            elevation: 0,
            side: const BorderSide(color: Colors.blueAccent),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 0), // Botón compacto
          ),
          child: const Text("Ver"),
        ),
      ),
    );
  }
}
