import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'dart:html' as html;

Future<void> downloadBase64File({
  required BuildContext context,
  required String base64Data,
  required String fileName,
  required String type,
}) async {
  try {
    final bytes = base64Decode(base64Data);
    final mime = type == 'pdf'
        ? 'application/pdf'
        : (fileName.toLowerCase().endsWith('.png')
              ? 'image/png'
              : 'image/jpeg');

    if (kIsWeb) {
      final blob = html.Blob([bytes], mime);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File: $fileName (${bytes.length} bytes)')),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }
}

/// Open image/PDF in a new browser tab (view without forcing download)
Future<void> viewBase64File({
  required BuildContext context,
  required String base64Data,
  required String type,
  required String fileName,
}) async {
  try {
    final bytes = base64Decode(base64Data);
    final mime = type == 'pdf'
        ? 'application/pdf'
        : (fileName.toLowerCase().endsWith('.png')
              ? 'image/png'
              : 'image/jpeg');

    if (kIsWeb) {
      final blob = html.Blob([bytes], mime);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      // revoke later so tab can load
      Future.delayed(const Duration(seconds: 60), () {
        html.Url.revokeObjectUrl(url);
      });
    } else {
      if (type == 'pdf') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Use Download to open PDF on mobile.'),
            ),
          );
        }
      } else {
        final img = base64Decode(base64Data);
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) =>
                Dialog(child: InteractiveViewer(child: Image.memory(img))),
          );
        }
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('View failed: $e')));
    }
  }
}

Uint8List? decodeImageBase64(String? b64, String? type) {
  if (b64 == null || b64.isEmpty || type == 'pdf') return null;
  try {
    final bytes = base64Decode(b64);
    if (bytes.length >= 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46) {
      return null;
    }
    return bytes;
  } catch (_) {
    return null;
  }
}
