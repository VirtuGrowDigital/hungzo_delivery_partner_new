import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import '../services/Api/api_constants.dart';
import '../utils/color_constants.dart';

class PolicyDocumentScreen extends StatefulWidget {
  final String appKey;
  final String policyKey;
  final String title;

  const PolicyDocumentScreen({
    super.key,
    required this.appKey,
    required this.policyKey,
    required this.title,
  });

  @override
  State<PolicyDocumentScreen> createState() => _PolicyDocumentScreenState();
}

class _PolicyDocumentScreenState extends State<PolicyDocumentScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  _PolicyDocument? _policy;

  @override
  void initState() {
    super.initState();
    _loadPolicy();
  }

  Future<void> _loadPolicy() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseURL}store/policies?app=${widget.appKey}&key=${widget.policyKey}',
        ),
      );

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : const <String, dynamic>{};

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          body['message']?.toString() ?? 'Unable to load policy right now.',
        );
      }

      final policies = (body['policies'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => _PolicyDocument.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);

      if (policies.isEmpty) {
        throw Exception('This policy is not available right now.');
      }

      if (!mounted) return;
      setState(() {
        _policy = policies.first;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: ColorConstants.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (_isLoading)
            _stateCard(
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_errorMessage != null)
            _stateCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unable to load policy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ColorConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: ColorConstants.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _loadPolicy,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_policy != null)
            _stateCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_policy!.summary.isNotEmpty) ...[
                    Text(
                      _policy!.summary,
                      style: const TextStyle(
                        color: ColorConstants.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Html(
                    data: _toHtml(_policy!.content),
                    style: {
                      'body': Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        color: ColorConstants.textSecondary,
                        fontSize: FontSize(14.5),
                        lineHeight: LineHeight(1.7),
                      ),
                      'h1': Style(
                        fontSize: FontSize(22),
                        fontWeight: FontWeight.w800,
                        margin: Margins.only(bottom: 12),
                        color: ColorConstants.textPrimary,
                      ),
                      'h2': Style(
                        fontSize: FontSize(18),
                        fontWeight: FontWeight.w700,
                        margin: Margins.only(top: 16, bottom: 10),
                        color: ColorConstants.textPrimary,
                      ),
                      'p': Style(
                        margin: Margins.only(bottom: 12),
                        color: ColorConstants.textSecondary,
                      ),
                      'ul': Style(
                        padding: HtmlPaddings.only(left: 18),
                        margin: Margins.only(bottom: 12),
                      ),
                      'li': Style(
                        margin: Margins.only(bottom: 8),
                        color: ColorConstants.textSecondary,
                      ),
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _stateCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorConstants.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  String _toHtml(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return '<p>Policy content is not available right now.</p>';
    }

    final looksLikeHtml = trimmed.contains('<p') ||
        trimmed.contains('<h1') ||
        trimmed.contains('<h2') ||
        trimmed.contains('<ul') ||
        trimmed.contains('<li') ||
        trimmed.contains('<br');

    if (looksLikeHtml) {
      return trimmed;
    }

    final paragraphs = trimmed
        .split(RegExp(r'\n\s*\n'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .map((part) => '<p>${_escapeHtml(part).replaceAll('\n', '<br/>')}</p>')
        .join();

    return paragraphs;
  }

  String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
}

class _PolicyDocument {
  final String key;
  final String title;
  final String summary;
  final String content;

  const _PolicyDocument({
    required this.key,
    required this.title,
    required this.summary,
    required this.content,
  });

  factory _PolicyDocument.fromJson(Map<String, dynamic> json) {
    return _PolicyDocument(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }
}
