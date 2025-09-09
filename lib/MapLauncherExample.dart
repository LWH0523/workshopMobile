import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncherExample extends StatelessWidget {
  // Pickup and shipping addresses
  final String pickupAddress =
      "Tunku Abdul Rahman University of Management and Technology (TAR UMT), Ground Floor, Bangunan Tan Sri Khaw Kai Boh (Block A), Jalan Genting Kelang, Setapak, 53300 Kuala Lumpur, Federal Territory of Kuala Lumpur";
  final String shippingAddress =
      "Tunku Abdul Rahman University of Management and Technology (TAR UMT), Ground Floor, Bangunan Tan Sri Khaw Kai Boh (Block A), Jalan Genting Kelang, Setapak, 53300 Kuala Lumpur, Federal Territory of Kuala Lumpur";

  Future<void> _openGoogleMaps(String address) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(address)}",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $uri';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.blue.shade100,
      width: double.infinity,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAddress = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
          if (isAddress)
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.blue),
              onPressed: () => _openGoogleMaps(value),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Pickup detail
            Card(
              margin: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Pick Up Detail"),
                  _buildInfoRow("Destination", "Workshop Bay 4"),
                  _buildInfoRow("Location", pickupAddress, isAddress: true),
                  _buildInfoRow("Date & Time", "22-07-2025 5:00 PM"),
                  _buildInfoRow("Item Quantity", "QTY: 3"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: const Text("Item Details:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Brake Pad - 3"),
                        Text("Air Filter - 5"),
                        Text("Spark Plug - 2"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Shipping detail
            Card(
              margin: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Shipping Details"),
                  _buildInfoRow("Shipping To", shippingAddress, isAddress: true),
                  _buildInfoRow("Contact", "+012 345 6789"),
                  _buildInfoRow("Payment Type", "Cash"),
                  _buildInfoRow("Payment Status", "Pending"),
                  _buildInfoRow("Message for Deliver", "None"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
