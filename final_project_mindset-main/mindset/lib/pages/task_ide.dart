import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskIDEPage extends StatefulWidget {
  final String taskId;
  final String taskTitle;
  final String taskDescription;
  final String? taskQuestion;
  final List<String>? requirements;
  final String? exampleInput;
  final String? exampleOutput;

  const TaskIDEPage({
    Key? key,
    required this.taskId,
    required this.taskTitle,
    required this.taskDescription,
    this.taskQuestion,
    this.requirements,
    this.exampleInput,
    this.exampleOutput,
  }) : super(key: key);

  @override
  State<TaskIDEPage> createState() => _TaskIDEPageState();
}

class _TaskIDEPageState extends State<TaskIDEPage> {
  late TextEditingController _codeController;
  late TextEditingController _filenameController;
  String _selectedLanguage = 'dart';
  bool _isSubmitting = false;
  String? _submitMessage;
  String? _submitStatus; // 'success' or 'error'
  int _selectedIndex = 1;

  // Code Execution Variables
  bool _isExecuting = false;
  String? _executionOutput;
  String? _executionError;
  String? _executionStatus; // 'success', 'error', 'running'

  final List<String> _languages = ['dart', 'python', 'javascript', 'java', 'cpp'];
  final Map<String, String> _languageExtensions = {
    'dart': '.dart',
    'python': '.py',
    'javascript': '.js',
    'java': '.java',
    'cpp': '.cpp',
  };

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _filenameController = TextEditingController(text: 'solution${_languageExtensions['dart']}');
    
    // Add listener to update line numbers when text changes
    _codeController.addListener(() {
      setState(() {
        // This will trigger a rebuild and update line numbers
      });
      
      // Clean up trailing spaces and tabs
      _cleanupCode();
    });
  }

  void _cleanupCode() {
    // This method can be used to auto-clean code if needed
    // For now, we just ensure consistent spacing
  }

  void _formatCode() {
    // Format code with proper indentation and spacing
    final text = _codeController.text;
    final lines = text.split('\n');
    
    // Clean up lines
    final cleanedLines = <String>[];
    for (var line in lines) {
      // Trim trailing whitespace but keep leading indentation
      final cleaned = line; // Keep as is for now, can add more logic
      cleanedLines.add(cleaned);
    }
    
    // Rejoin with proper newlines
    final formattedCode = cleanedLines.join('\n');
    
    _codeController.text = formattedCode;
    _codeController.selection = TextSelection.fromPosition(
      TextPosition(offset: _codeController.text.length),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Code formatted successfully!'),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onLanguageChanged(String newLanguage) {
    setState(() {
      _selectedLanguage = newLanguage;
      _filenameController.text = 'solution${_languageExtensions[newLanguage]}';
    });
  }


  Future<void> _executeCode() async {
    if (_codeController.text.isEmpty) {
      _showMessage('Please enter code', 'error');
      return;
    }

    setState(() {
      _isExecuting = true;
      _executionOutput = null;
      _executionError = null;
      _executionStatus = 'running';
    });

    final result = await ApiService.executeCode(
      code: _codeController.text,
      language: _selectedLanguage,
      input: widget.exampleInput,
    );

    setState(() {
      _isExecuting = false;
      if (result['success']) {
        _executionStatus = 'success';
        _executionOutput = result['output'] ?? 'No output';
        _executionError = null;
      } else {
        _executionStatus = 'error';
        _executionOutput = null;
        // Show full error details for debugging
        final errorOutput = result['output'] ?? '';
        final errorMessage = result['message'] ?? 'Unknown error';
        
        // Combine both message and output for full debugging info
        if (errorOutput.isNotEmpty && errorMessage.isNotEmpty) {
          _executionError = '$errorMessage\n\n--- Full Error Details ---\n$errorOutput';
        } else if (errorOutput.isNotEmpty) {
          _executionError = errorOutput;
        } else {
          _executionError = errorMessage;
        }
      }
    });
  }

  Future<void> _submitCode() async {
    if (_codeController.text.isEmpty) {
      _showMessage('Please enter code', 'error');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitMessage = null;
    });

    // Get all required data
    final token = await StorageService.getToken() ?? '';
    final phone = await StorageService.getPhoneNumber() ?? '';
    final repoUrl = await StorageService.getRepoUrl() ?? '';
    final ghToken = await StorageService.getGithubToken() ?? '';

    print('🔍 Task IDE Debug Info:');
    print('🔑 Token: ${token.isNotEmpty ? 'Present' : 'Missing'}');
    print('📱 Phone: $phone');
    print('🔗 Repo URL: $repoUrl');
    print('🔑 GitHub Token: ${ghToken.isNotEmpty ? 'Present' : 'Missing'}');
    print('📄 Filename: ${_filenameController.text}');
    print('🏷️ Task ID: ${widget.taskId}');
    print('💻 Language: $_selectedLanguage');

    // Check if required data is missing
    if (token.isEmpty) {
      _showMessage('Please login first', 'error');
      setState(() => _isSubmitting = false);
      return;
    }
    
    if (phone.isEmpty) {
      _showMessage('Phone number not found. Please login again.', 'error');
      setState(() => _isSubmitting = false);
      return;
    }

    // Extract numeric task ID if it's in format 'task_X'
    String taskId = widget.taskId;
    if (taskId.startsWith('task_')) {
      taskId = taskId.replaceFirst('task_', '');
    }

    // Use backend submitCode (same as Quiz page)
    final result = await ApiService.submitCode(
      token: token,
      code: _codeController.text,
      filename: _filenameController.text,
      language: _selectedLanguage,
      taskId: taskId,
      xPhone: phone,
      repoUrl: repoUrl,
      githubToken: ghToken,
    );

    // If backend submission succeeds, push to GitHub if credentials are available
    if (result['success'] && repoUrl.isNotEmpty && ghToken.isNotEmpty) {
      print('📤 Pushing code to GitHub...');
      final githubResult = await ApiService.pushCodeToGithub(
        code: _codeController.text,
        filename: _filenameController.text,
        repoUrl: repoUrl,
        githubToken: ghToken,
        taskId: taskId,
        phoneNumber: phone,
      );

      if (githubResult['success']) {
        print('✅ Code pushed to GitHub successfully');
        final fileUrl = githubResult['html_url'];
        if (fileUrl != null && fileUrl.isNotEmpty) {
          _showMessage('Code submitted and pushed to GitHub!\nView: $fileUrl', 'success');
        } else {
          _showMessage('Code submitted and pushed to GitHub!', 'success');
        }
      } else {
        print('⚠️ Backend submission succeeded but GitHub push failed: ${githubResult['message']}');
        // Still show success for backend submission, but warn about GitHub
        _showMessage('Code submitted successfully, but GitHub push failed: ${githubResult['message']}', 'error');
      }
    } else if (result['success'] && (repoUrl.isEmpty || ghToken.isEmpty)) {
      // Backend submission succeeded but GitHub credentials missing
      print('⚠️ Backend submission succeeded but GitHub credentials not configured');
      _showMessage('Code submitted successfully. Configure GitHub in settings to enable automatic push.', 'success');
    }

    setState(() {
      _isSubmitting = false;
      _submitMessage = result['message'];
      _submitStatus = result['success'] ? 'success' : 'error';
    });

    if (result['success']) {
      _showCompletionDialog(result['score'] ?? 0);
    } else {
      // Show error message to user
      _showMessage(result['message'] ?? 'Failed to submit code', 'error');
    }
  }

  void _showMessage(String message, String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: status == 'success' ? Colors.green : Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showCompletionDialog(dynamic score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue[900]?.withOpacity(0.98),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 32),
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                'Task completed!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Points earned: $score',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )),
                  ),
                  child: Text(
                    'Return',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _onNavTap(int index2) {
    setState(() {
      _selectedIndex = index2;
    });

    if (index2 == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coming soon!'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    if (index2 == 1) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    if (index2 == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coming soon!'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }
  }

  Widget _buildCodeEditor() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Editor Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFF2D2D30),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Text(
                  '${_selectedLanguage.toUpperCase()} Editor',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code Editor Content
          Expanded(
            child: Row(
              children: [
                // Line Numbers
                Container(
                  width: 50,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF252526),
                    border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  child: _buildLineNumbers(),
                ),
                // Code Area with Syntax Highlighting
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: ClipRect(
                      child: Stack(
                        children: [
                          // Syntax Highlighted Background
                          Container(
                            padding: EdgeInsets.zero,
                            child: SingleChildScrollView(
                              child: HighlightView(
                                _codeController.text.isEmpty 
                                  ? ' ' 
                                  : _codeController.text,
                                language: _getHighlightLanguage(),
                                theme: vs2015Theme,
                                textStyle: TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          // Hint text overlay (shown when editor is empty)
                          if (_codeController.text.isEmpty)
                            Positioned(
                              top: 8,
                              left: 0,
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: Text(
                                  '// Write your code here...\nvoid main() {\n  // Your code goes here\n}',
                                  style: TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.grey.withOpacity(0.5),
                                    letterSpacing: 0.5,
                                  ),
                              ),
                            ),
                          ),
                          // Transparent TextField for input
                          TextField(
                            controller: _codeController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.transparent,
                              letterSpacing: 0.5, // Better character spacing
                            ),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            // Proper indentation handling
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            // Handle Tab and indentation
                            onChanged: (text) {
                              // This is already handled by the listener in initState
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getHighlightLanguage() {
    switch (_selectedLanguage.toLowerCase()) {
      case 'dart':
        return 'dart';
      case 'python':
        return 'python';
      case 'javascript':
        return 'javascript';
      case 'java':
        return 'java';
      case 'cpp':
        return 'cpp';
      default:
        return 'dart';
    }
  }

  Widget _buildLineNumbers() {
    final lines = _codeController.text.split('\n');
    final lineCount = lines.length;
    final minLines = 10; // Minimum lines to show
    final totalLines = lineCount < minLines ? minLines : lineCount;
    
    return ListView.builder(
      itemCount: totalLines,
      itemBuilder: (context, index2) {
        return Container(
          height: 21, // Same as line height
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 8),
          child: Text(
            '${index2 + 1}',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.6),
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
        );
      },
    );
  }

  Widget _buildLinkButton({required IconData icon, required String label, required String url, required Color color}) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Assets/background/splash_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.taskTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Code Editor',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // IDE Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Description
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.taskDescription,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Task Question (if provided)
                        if (widget.taskQuestion != null) ...[
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[900]?.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.help_outline, color: Colors.blue, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Task Question',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  widget.taskQuestion!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16, // Increased from 12
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 12),
                                // Documentation and YouTube Links
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildLinkButton(
                                      icon: Icons.menu_book,
                                      label: 'Docs',
                                      url: 'https://dart.dev/guides',
                                      color: Colors.blue,
                                    ),
                                    _buildLinkButton(
                                      icon: Icons.video_library,
                                      label: 'YouTube',
                                      url: 'https://www.youtube.com/results?search_query=dart+programming+tutorial',
                                      color: Colors.red,
                                    ),
                                    _buildLinkButton(
                                      icon: Icons.code,
                                      label: 'Examples',
                                      url: 'https://dart.dev/samples',
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Requirements (if provided)
                        if (widget.requirements != null && widget.requirements!.isNotEmpty) ...[
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[900]?.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.checklist, color: Colors.green, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Requirements',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                ...widget.requirements!.map((requirement) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '• ',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          requirement,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Examples (if provided)
                        if (widget.exampleInput != null && widget.exampleOutput != null) ...[
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[900]?.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.notes, color: Colors.orange, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Example',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // Example Input
                                Text(
                                  'Input:',
                                  style: TextStyle(
                                    color: Colors.orange[200],
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.exampleInput!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 11,
                                      fontFamily: 'Courier',
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Example Output
                                Text(
                                  'Expected Output:',
                                  style: TextStyle(
                                    color: Colors.orange[200],
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.exampleOutput!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 11,
                                      fontFamily: 'Courier',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Language & Filename Row
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: DropdownButton<String>(
                                  value: _selectedLanguage,
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  dropdownColor: Color(0xFF0D3B66),
                                  items: _languages.map((lang) {
                                    return DropdownMenuItem<String>(
                                      value: lang,
                                      child: Text(
                                        lang.toUpperCase(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      _onLanguageChanged(value);
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: _filenameController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Filename',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Code Editor
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.code, color: Colors.blue, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Code Editor',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 300,
                                child: _buildCodeEditor(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Execution Output Section (NEW)
                        if (_executionOutput != null || _executionError != null) ...[
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _executionStatus == 'success'
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _executionStatus == 'success'
                                    ? Colors.green.withOpacity(0.5)
                                    : Colors.red.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _executionStatus == 'success' ? Icons.check_circle : Icons.error,
                                      color: _executionStatus == 'success' ? Colors.green : Colors.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      _executionStatus == 'success' ? 'Output' : 'Error',
                                      style: TextStyle(
                                        color: _executionStatus == 'success' ? Colors.green : Colors.red,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _executionStatus == 'success'
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.red.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: SelectableText(
                                    _executionOutput ?? _executionError ?? 'No output',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontFamily: 'Courier',
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                // Debug tips for errors
                                if (_executionError != null) ...[
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.lightbulb_outline, color: Colors.orange, size: 16),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Debugging Tip: Look for line numbers in the error. Check your syntax, variables, and function names.',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 10,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Execution Buttons Row
                        Row(
                          children: [
                            // Execute Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isExecuting ? null : _executeCode,
                                icon: _isExecuting
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Icon(Icons.play_arrow),
                                label: Text(
                                  _isExecuting ? 'Running...' : 'Run Code',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.blue[700]),
                                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12)),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  )),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            // Submit Button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : _submitCode,
                                icon: _isSubmitting
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Icon(Icons.send),
                                label: Text(
                                  _isSubmitting ? 'Submitting...' : 'Push',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12)),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  )),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Status Message
                        if (_submitMessage != null)
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _submitStatus == 'success'
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _submitStatus == 'success'
                                    ? Colors.green.withOpacity(0.5)
                                    : Colors.red.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _submitStatus == 'success' ? Icons.check_circle : Icons.error,
                                  color: _submitStatus == 'success' ? Colors.green : Colors.red,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _submitMessage!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Navigation
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavButton(Icons.emoji_events_outlined, isSelected: _selectedIndex == 0, onTap: () => _onNavTap(0)),
                      _buildNavButton(Icons.home_rounded, isSelected: _selectedIndex == 1, isHome: true, onTap: () => _onNavTap(1)),
                      _buildNavButton(Icons.sports_esports_rounded, isSelected: _selectedIndex == 2, onTap: () => _onNavTap(2)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, {bool isSelected = false, bool isHome = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isHome ? 24 : 20),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color.fromARGB(255, 33, 150, 243).withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isHome ? 30 : 25),
          border: Border.all(
            color: isSelected 
              ? const Color.fromARGB(255, 33, 150, 243)
              : Colors.white.withOpacity(0.2),
            width: isHome ? 3 : 2,
          ),
          boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color.fromARGB(255, 33, 150, 243).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
            : [],
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.white,
          size: isHome ? 48 : 38,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _filenameController.dispose();
    super.dispose();
  }
}
