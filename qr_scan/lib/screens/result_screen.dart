// lib/screens/result_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends StatefulWidget {
  final String scannedCode;
  final VoidCallback onClose;

  const ResultScreen({
    super.key,
    required this.scannedCode,
    required this.onClose,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Map<String, String> _parseVCard(String data) {
    final Map<String, String> contactInfo = {};
    final lines = data.split('\n');
    for (var line in lines) {
      if (line.startsWith('FN:')) {
        contactInfo['name'] = line.substring(3).trim();
      } else if (line.startsWith('TEL')) {
        contactInfo['phone'] = line.substring(line.indexOf(':') + 1).trim();
      } else if (line.startsWith('EMAIL')) {
        contactInfo['email'] = line.substring(line.indexOf(':') + 1).trim();
      }
    }
    return contactInfo;
  }

  Future<void> _addContact(Map<String, String> contactData) async {
    final name = contactData['name'] ?? 'Contact';
    final vcfString = StringBuffer("BEGIN:VCARD\nVERSION:3.0\n");
    if (contactData['name'] != null)
      vcfString.writeln("FN:${contactData['name']}");
    if (contactData['phone'] != null)
      vcfString.writeln("TEL;TYPE=CELL:${contactData['phone']}");
    if (contactData['email'] != null)
      vcfString.writeln("EMAIL:${contactData['email']}");
    vcfString.writeln("END:VCARD");

    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$name.vcf';
      final file = File(path);
      await file.writeAsString(vcfString.toString());
      await OpenFilex.open(path);
    } catch (e) {
      _showSnackbar("Error saving contact: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onClose();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.onClose();
              Navigator.pop(context);
            },
          ),
          title: const Text("Scan Result"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildContentWidget(),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.scannedCode));
                  _showSnackbar("Copied to clipboard!");
                },
                icon: const Icon(Icons.copy, size: 24),
                label: const Text(
                  "Copy Raw Text",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueGrey.shade100,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    if (widget.scannedCode.startsWith('WIFI:')) {
      String ssid = '';
      String password = '';
      final ssidMatch = RegExp(r'S:([^;]+);').firstMatch(widget.scannedCode);
      if (ssidMatch != null) {
        ssid = ssidMatch.group(1) ?? '';
      }
      final passwordMatch = RegExp(
        r'P:([^;]+);',
      ).firstMatch(widget.scannedCode);
      if (passwordMatch != null) {
        password = passwordMatch.group(1) ?? '';
      }
      return _buildWifiWidget(ssid, password);
    }

    if (widget.scannedCode.trim().startsWith('BEGIN:VCARD')) {
      final contactData = _parseVCard(widget.scannedCode);
      return _buildVCardWidget(contactData);
    }

    final uri = Uri.tryParse(widget.scannedCode);
    if (uri != null &&
        (uri.scheme == 'http' ||
            uri.scheme == 'https' ||
            uri.scheme == 'mailto' ||
            uri.scheme == 'tel')) {
      return _buildUrlWidget(uri);
    }

    return _buildTextWidget();
  }

  Widget _buildWifiWidget(String ssid, String password) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.wifi_password_rounded,
          size: 72,
          color: Colors.blue.shade400,
        ),
        const SizedBox(height: 16),
        const Text(
          "Wi-Fi Network Found",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          "Network Name (SSID):",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SelectableText(
          ssid,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          "Password:",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SelectableText(
          password.isNotEmpty ? password : "No Password",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            if (password.isNotEmpty) {
              Clipboard.setData(ClipboardData(text: password));
              _showSnackbar("Password copied to clipboard!");
            }
          },
          icon: const Icon(Icons.copy_rounded, size: 24),
          label: const Text("Copy Password", style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.teal.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVCardWidget(Map<String, String> contactData) {
    final name = contactData['name'] ?? "No Name";
    final phone = contactData['phone'];
    final email = contactData['email'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.person_rounded, size: 72, color: Colors.indigo.shade400),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (phone != null) ...{
          const SizedBox(height: 12),
          Text(
            "Phone: $phone",
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        },
        if (email != null) ...{
          const SizedBox(height: 8),
          Text(
            "Email: $email",
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        },
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _addContact(contactData),
          icon: const Icon(Icons.person_add_rounded, size: 24),
          label: const Text("Add to Contacts", style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrlWidget(Uri uri) {
    String title = "Link Found";
    String buttonText = "Open Link";
    IconData icon = Icons.link_rounded;
    Color buttonColor = Colors.blue.shade400;

    if (uri.scheme == 'mailto') {
      title = "Email Address";
      buttonText = "Send Email";
      icon = Icons.email_rounded;
      buttonColor = Colors.deepOrange.shade400;
    } else if (uri.scheme == 'tel') {
      title = "Phone Number";
      buttonText = "Call Number";
      icon = Icons.call_rounded;
      buttonColor = Colors.green.shade400;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, size: 72, color: buttonColor),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        SelectableText(
          widget.scannedCode,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.blueAccent),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () async {
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              _showSnackbar("Could not open ${uri.scheme}");
            }
          },
          icon: Icon(icon, size: 24),
          label: Text(buttonText, style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.text_snippet_rounded, size: 72, color: Colors.grey.shade600),
        const SizedBox(height: 16),
        const Text(
          "Plain Text",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        SelectableText(
          widget.scannedCode,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
