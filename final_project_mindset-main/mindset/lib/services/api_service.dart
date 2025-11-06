import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mindset/models/leaderBoard.dart';
import 'package:mindset/models/level.dart';
import '../models/category.dart';
import '../models/task.dart';
import '../models/question.dart';
import 'storage_service.dart';

class ApiService {
  // static const String baseUrl = 'http://127.0.0.1:8005/webstudent';
  static const String baseUrl = 'http://72.61.101.230:8005/webstudent';
  static const String localhostUrl =
      'http://localhost:8005/webstudent'; // For testing

  static Future<int> fetchHighestUnlockedLevel() async {
    String? accessToken = await StorageService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/levels'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 0) {
        final List levelsJson = data['data']['levels'];
        final levels = levelsJson.map((json) => Level.fromJson(json)).toList();

        // استخراج أعلى مستوى unlocked
        final unlockedLevels = levels.where((level) => level.unlocked);
        //  print("✅ numm of levels ${unlockedLevels.length}");
        if (unlockedLevels.isEmpty) return 1; // لا يوجد مستوى مفتوح

        final highestUnlocked = unlockedLevels
            .map((level) => level.id)
            .reduce((a, b) => a > b ? a : b);
        //print("✅ thheeeee highest level is ${highestUnlocked}");
        print("📡 Data from server: ${data['data']['levels']}");
        print("✅ Levels parsed: ${levels.map((e) => {
              'id': e.id,
              'unlocked': e.unlocked
            }).toList()}");
        print("➡️ Highest unlocked = $highestUnlocked");

        return highestUnlocked;
      } else {
        throw Exception('خطأ من السيرفر: ${data['msg']}');
      }
    } else {
      throw Exception('فشل الاتصال بالسيرفر');
    }
  }

  static Future<bool> updateUsername(String newUsername) async {
    String? accessToken = await StorageService.getToken();

    final url = Uri.parse('$baseUrl/update_profile');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'username': newUsername,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await StorageService.updateUsername(
          data['username']); // حفظ في التخزين المحلي
      return true;
    } else {
      print('فشل التحديث: ${response.body}');
      return false;
    }
  }

  static Future<List<Question>> fetchQuestions(int levelId) async {
    try {
      String? accessToken = await StorageService.getToken();

      if (accessToken == null) {
        throw Exception('Access token is null');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/exam/questions?level_id=$levelId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(response.body);

        if (body['code'] == 0) {
          if (body['data'] == null || body['data']['questions'] == null) {
            throw Exception('No questions found in response');
          }
          QuestionsResponse questionsResponse =
              QuestionsResponse.fromJson(body);
          return questionsResponse.questions;
        } else {
          throw Exception('Server error: ${body['msg']}');
        }
      } else {
        throw Exception(
            'Failed to load questions, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  static Future<List<Task>> fetchTasks(int categoryId) async {
    try {
      String? accessToken = await StorageService.getToken();

      final url = '$baseUrl/lessons?topic_id=$categoryId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['code'] == 0 &&
            responseData['data'] != null &&
            responseData['data']['lessons'] != null) {
          final List<dynamic> lessonsJson = responseData['data']['lessons'];
          //   print("✅ Fetched ${lessonsJson.length} //lessons");

          return lessonsJson.map((json) => Task.fromJson(json)).toList();
        } else {
          throw Exception('❌ Unexpected response format: $responseData');
        }
      } else {
        throw Exception('❌ Server error: HTTP ${response.statusCode}');
      }
    } catch (e) {
      //  print('🚨 Error fetching tasks: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  // Login API call - NOW USES PHONE NUMBER
  static Future<Map<String, dynamic>> login(
      String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['code'] == 0) {
        // developer.log('Login API Raw Response: ${response.body}', name: 'ApiService');
        final userData = data['data'];
        final accessToken = userData?['access_token'];

        // تأكد أن التوكن موجود وهو String
        if (accessToken != null &&
            accessToken is String &&
            accessToken.isNotEmpty) {
          await StorageService.saveAccessToken(accessToken);
        } else {
          return {
            'success': false,
            'message': 'Access token is missing in response',
          };
        }
        //print("ACCESS TOKEN: $accessToken");
        return {
          'success': true,
          'accessToken': accessToken,
          'name': userData['name'],
        };
      } else {
        return {
          'success': false,
          'message': data['msg'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Register API call - NOW USES PHONE NUMBER
  static Future<Map<String, dynamic>> register(
    String username,
    String phoneNumber,
    String password,
    String gender,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Name': username,
          'Phone': phoneNumber,
          'PassWord': password,
          'Gender': gender,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Registration successful',
          'username': username,
          'access_token': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error']?.toString() ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Send SMS for Password Reset
  static Future<Map<String, dynamic>> sendSMSReset(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_sms_reset'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'expires_in_minutes': responseData['expires_in_minutes'] ?? 10,
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Failed to send SMS',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Verify SMS Code and Reset Password
  static Future<Map<String, dynamic>> verifySMSReset(
      String phoneNumber, String verificationCode, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify_sms_reset'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'verification_code': verificationCode,
          'new_password': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Password reset failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Legacy method for compatibility (now uses phone)
  static Future<Map<String, dynamic>> resetPassword(
      String phoneNumber, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset_password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'new_password': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Password reset failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Update password API call (for authenticated users)
  static Future<Map<String, dynamic>> updatePassword(
      String oldPassword, String newPassword, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Password update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<List<LeaderboardUser>> fetchLeaderboard() async {
    String? accessToken = await StorageService.getToken();

    final response =
        await http.get(Uri.parse('$baseUrl/leaderboard'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    });

    print('Leaderboard response: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['code'] == 0) {
        final List<dynamic> leaderboardJson = jsonResponse['data'];
        // هنا لازم تتأكد أنك تمرر كل عنصر لوحده لـ fromJson
        return leaderboardJson
            .map((item) => LeaderboardUser.fromJson(item))
            .toList();
      } else {
        throw Exception('Server error: ${jsonResponse['msg']}');
      }
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }

  // Get profile API call
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      String? accessToken = await StorageService.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/get_profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Utility function to validate phone number format - ENHANCED for international
  static bool isValidPhoneNumber(String phone) {
    // Enhanced phone validation for international numbers including Libya (+218)
    // Format: +[1-9][0-9]{0,3}[0-9]{7,14} (country code 1-4 digits + 7-14 digit number)
    final phoneRegex = RegExp(r'^\+[1-9]\d{0,3}\d{7,14}$');
    return phoneRegex.hasMatch(phone) &&
        phone.length >= 10 &&
        phone.length <= 18;
  }

  // Utility function to format phone number - ENHANCED for Libya
  static String formatPhoneNumber(String phone) {
    // Remove any spaces, dashes, parentheses, or other non-digit characters except +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Handle Libya's 00218 format and convert to +218
    if (cleaned.startsWith('00218')) {
      cleaned = '+218${cleaned.substring(5)}';
    }
    // Handle other 00XX formats and convert to +XX
    else if (cleaned.startsWith('00') && cleaned.length > 2) {
      cleaned = '+${cleaned.substring(2)}';
    }
    // Add + if not present and doesn't start with +
    else if (!cleaned.startsWith('+') && cleaned.length >= 7) {
      // For demo, we require explicit country code
      // In production, you could default to a country based on user location
      return cleaned; // Return as-is, let validation handle it
    }

    return cleaned;
  }

  static Future<List<Category>> getTopicsByLevel(int levelId) async {
    try {
      String? accessToken = await StorageService.getToken();
      //   print("📌 Access Token: $accessToken");

      final url = '$baseUrl/topics?level_id=$levelId';
      //  print("📌 Requesting URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      //  print("📥 Response Status Code: ${response.statusCode}");
      //  print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['code'] == 0 &&
            responseData['data'] != null &&
            responseData['data']['topics'] != null) {
          final List<dynamic> topicsJson = responseData['data']['topics'];
          //  print("✅ Successfully fetched ${topicsJson.length} topics.");
          return topicsJson.map((json) => Category.fromJson(json)).toList();
        } else {
          throw Exception(
              '❌ Invalid response format or missing data. Full response: $responseData');
        }
      } else {
        throw Exception('❌ Server error: HTTP ${response.statusCode}');
      }
    } catch (e) {
      //  print('🚨 Error fetching topics: $e');
      throw Exception('Failed to load topics: $e');
    }
  }

  // Get country info from phone number
  static String getCountryFromPhone(String phone) {
    final countryMap = {
      '+1': 'US/Canada',
      '+44': 'UK',
      '+218': 'Libya 🇱🇾',
      '+20': 'Egypt',
      '+966': 'Saudi Arabia',
      '+971': 'UAE',
      '+33': 'France',
      '+49': 'Germany',
      '+86': 'China',
      '+91': 'India',
      '+81': 'Japan',
      '+82': 'South Korea',
      '+212': 'Morocco',
      '+213': 'Algeria',
      '+216': 'Tunisia',
    };

    for (final entry in countryMap.entries) {
      if (phone.startsWith(entry.key)) {
        return entry.value;
      }
    }
    return 'Unknown';
  }

  // Format phone number for display
  static String formatPhoneForDisplay(String phone) {
    if (phone.startsWith('+218')) {
      // Libya format: +218 XX XXX XXXX
      if (phone.length >= 12) {
        return '${phone.substring(0, 4)} ${phone.substring(4, 6)} ${phone.substring(6, 9)} ${phone.substring(9)}';
      }
    } else if (phone.startsWith('+1')) {
      // US/Canada format: +1 (XXX) XXX-XXXX
      if (phone.length >= 12) {
        return '${phone.substring(0, 2)} (${phone.substring(2, 5)}) ${phone.substring(5, 8)}-${phone.substring(8)}';
      }
    }
    // Default format: +XX XXX XXX XXXX
    return phone;
  }

  static Future<bool> markTaskCompleted(int taskId) async {
    try {
      String? accessToken = await StorageService.getToken();
      final url = '$baseUrl/tasks/$taskId/complete';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      //  print('Error marking task completed: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> submitAnswers(
      int levelId, List<Map<String, int>> answers) async {
    String? accessToken = await StorageService.getToken();
    final url = '$baseUrl/exam/submit';

    final body = jsonEncode({
      'level_id': levelId,
      'answers': answers,
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(
          'Failed to submit answers: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  static Future<bool> buyHearts({
    required int starsToSpend,
    required int heartsToAdd,
  }) async {
    String? accessToken = await StorageService.getToken();
    final url = Uri.parse('$baseUrl/buy_hearts');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'stars': starsToSpend,
        'hearts': heartsToAdd,
      }),
    );

    if (response.statusCode == 200) {
      // ممكن تحلل النتيجة لو أردت، مثلاً تحدّث بيانات في الواجهة
      return true;
    } else {
      // يمكنك طباعة الخطأ أو رمي استثناء
      print('Failed to buy hearts: ${response.body}');
      return false;
    }
  }

  static Future<void> addStars(int stars) async {
    String? accessToken = await StorageService.getToken();
    final url = Uri.parse('$baseUrl/reward');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken', // لو تستخدمين JWT
      },
      body: jsonEncode({'stars': stars}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Stars Added: ${data['data']['stars_total']}");
    } else {
      print("❌ Failed to add stars: ${response.body}");
    }
  }

  // Set GitHub repo URL for the authenticated user
  static Future<Map<String, dynamic>> setRepoUrl({
    required String token,
    required String repoUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/exam/save_repo_url'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'repo_url': repoUrl,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }
      return {
        'success': false,
        'message': data['error'] ?? 'Failed to set repo URL'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Submit code for a task; backend will validate and optionally check repo file
  static Future<Map<String, dynamic>> submitCode({
    required String token,
    required String code,
    String? filename,
    String language = 'dart',
    String? taskId,
    String? xPhone,
    String? repoUrl,
    String? githubToken,
  }) async {
    try {
      print('🚀 Submitting code to: $baseUrl/exam/code/submit');
      print('📱 Phone: $xPhone');
      print('🔗 Repo URL: $repoUrl');
      print('🔑 GitHub Token: ${githubToken != null ? 'Present' : 'Missing'}');
      print('📄 Filename: $filename');
      print('🏷️ Task ID: $taskId');

      final uri = Uri.parse('$baseUrl/exam/code/submit');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        if (xPhone != null && xPhone.isNotEmpty) 'X-Phone': xPhone,
        if (repoUrl != null && repoUrl.isNotEmpty) 'X-Repo-Url': repoUrl,
        if (githubToken != null && githubToken.isNotEmpty)
          'X-Github-Token': githubToken,
      };
      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode({
              'code': code,
              'filename': filename,
              'language': language,
              'question_id': taskId, // Backend expects question_id, not task_id
            }),
          )
          .timeout(Duration(seconds: 30));

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      // Handle different response formats
      Map<String, dynamic> data;
      try {
        // Try to parse the response body
        // If it contains multiple JSON objects, try to parse the first one
        String responseBody = response.body.trim();
        if (responseBody.contains('}{')) {
          // Multiple JSON objects concatenated - take the first one
          int firstCloseBrace = responseBody.indexOf('}');
          responseBody = responseBody.substring(0, firstCloseBrace + 1);
        }
        data = jsonDecode(responseBody);
      } catch (e) {
        // If JSON parsing fails, try to extract error message from raw response
        String errorMsg = response.body;
        if (errorMsg.contains('"msg"')) {
          // Try to extract msg field manually
          try {
            final msgMatch = RegExp(r'"msg"\s*:\s*"([^"]+)"').firstMatch(response.body);
            if (msgMatch != null) {
              errorMsg = msgMatch.group(1) ?? errorMsg;
            }
          } catch (_) {}
        }
        return {
          'success': false,
          'message': 'Invalid response from server: $errorMsg'
        };
      }

      // Handle success status codes (200, 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['msg'] ?? data['message'] ?? 'Code submitted successfully',
          'score': data['score'] ?? 0,
          'checks': data['checks'] ?? [],
        };
      }

      // Handle error responses
      String errorMessage = 'Code submission failed';
      if (data.containsKey('msg')) {
        // Backend uses 'msg' field for error messages
        errorMessage = data['msg'].toString();
      } else if (data.containsKey('error')) {
        errorMessage = data['error'].toString();
      } else if (data.containsKey('message')) {
        errorMessage = data['message'].toString();
      } else if (response.body.isNotEmpty) {
        errorMessage = 'Server error (${response.statusCode}): ${response.body}';
      }

      return {
        'success': false,
        'message': errorMessage
      };
    } catch (e) {
      print('❌ Submit code error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // Push code to GitHub repository
  static Future<Map<String, dynamic>> pushCodeToGithub({
    required String code,
    required String filename,
    required String repoUrl,
    required String githubToken,
    required String taskId,
    String? phoneNumber,
  }) async {
    try {
      // Extract owner and repo from URL
      // Expected format: https://github.com/username/repo or git@github.com:username/repo.git
      final repoRegex = RegExp(r'github\.com[:/](.+?)/(.+?)(?:\.git)?$');
      final match = repoRegex.firstMatch(repoUrl);

      if (match == null) {
        return {
          'success': false,
          'message': 'Invalid GitHub repository URL',
        };
      }

      final owner = match.group(1);
      final repo = match.group(2);

      // Get default branch (usually 'main' or 'master')
      final repoInfoResponse = await http.get(
        Uri.parse('https://api.github.com/repos/$owner/$repo'),
        headers: {
          'Authorization': 'Bearer $githubToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      String defaultBranch = 'main';
      if (repoInfoResponse.statusCode == 200) {
        final repoInfo = jsonDecode(repoInfoResponse.body);
        defaultBranch = repoInfo['default_branch'] ?? 'main';
      }

      // Push file directly to root (or with unique name if needed)
      // Use filename directly, or add task ID prefix if file already exists
      final filePath = filename;

      // GitHub API endpoint for creating/updating file
      final url = Uri.parse(
        'https://api.github.com/repos/$owner/$repo/contents/$filePath',
      );

      // Get file SHA if it exists (for updates)
      final getResponse = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $githubToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      String? fileSha;
      if (getResponse.statusCode == 200) {
        final data = jsonDecode(getResponse.body);
        fileSha = data['sha'];
      }

      // Encode code to base64
      final encodedCode = base64Encode(utf8.encode(code));

      // Push code to GitHub default branch
      final pushResponse = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $githubToken',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': 'Solution for task: $taskId',
          'content': encodedCode,
          'branch': defaultBranch,
          if (fileSha != null) 'sha': fileSha,
        }),
      );

      if (pushResponse.statusCode == 201 || pushResponse.statusCode == 200) {
        final responseData = jsonDecode(pushResponse.body);
        return {
          'success': true,
          'message': 'Code successfully pushed to GitHub',
          'filename': filePath,
          'branch': defaultBranch,
          'commit': responseData['commit']['sha'],
          'html_url': responseData['content']['html_url'] ?? responseData['html_url'] ?? '',
        };
      } else {
        final errorBody = pushResponse.body;
        String errorMsg = 'Failed to push code to GitHub';
        try {
          final errorData = jsonDecode(errorBody);
          errorMsg = errorData['message'] ?? errorBody;
        } catch (_) {
          errorMsg = '$errorMsg (${pushResponse.statusCode}): $errorBody';
        }
        return {
          'success': false,
          'message': errorMsg,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'GitHub push error: $e',
      };
    }
  }

  // Judge0 API for code execution
  static const String judge0Url =
      'https://judge0-ce.p.rapidapi.com/submissions';

  // Language ID mapping for Judge0
  static const Map<String, int> languageIds = {
    'dart': 90,
    'python': 71,
    'javascript': 63,
    'java': 62,
    'cpp': 54,
  };

  // Execute code using Judge0 API
  static Future<Map<String, dynamic>> executeCode({
    required String code,
    required String language,
    String? input,
  }) async {
    try {
      final languageId = languageIds[language.toLowerCase()];
      if (languageId == null) {
        return {
          'success': false,
          'message': 'Language not supported',
        };
      }

      // Submit code for execution
      final submitResponse = await http.post(
        Uri.parse('$judge0Url?base64_encoded=false&wait=false'),
        headers: {
          'Content-Type': 'application/json',
          'X-RapidAPI-Key':
              '05866d76afmsh1b71ef2bfce7463p13606bjsnec72c273dcb0',
          'X-RapidAPI-Host': 'judge0-ce.p.rapidapi.com',
        },
        body: jsonEncode({
          'language_id': languageId,
          'source_code': code,
          if (input != null) 'stdin': input,
        }),
      );

      if (submitResponse.statusCode != 201) {
        return {
          'success': false,
          'message':
              'Failed to submit code for execution (${submitResponse.statusCode}): ${submitResponse.body}',
        };
      }

      final submitData = jsonDecode(submitResponse.body);
      final token = submitData['token'];

      // Poll for results
      await Future.delayed(Duration(seconds: 2));

      final resultResponse = await http.get(
        Uri.parse('$judge0Url/$token?base64_encoded=false'),
        headers: {
          'X-RapidAPI-Key':
              '05866d76afmsh1b71ef2bfce7463p13606bjsnec72c273dcb0',
          'X-RapidAPI-Host': 'judge0-ce.p.rapidapi.com',
        },
      );

      if (resultResponse.statusCode == 200) {
        final resultData = jsonDecode(resultResponse.body);
        final status = resultData['status']['id'];

        // Status codes: 1=queued, 2=processing, 3=accepted, 4=wrong answer, 5=time limit, 6=compilation error, 7=runtime error
        if (status == 3) {
          return {
            'success': true,
            'output': resultData['stdout'] ?? '',
            'message': 'Execution successful',
          };
        } else if (status == 6) {
          // Compilation error - get full error details
          final compileOutput =
              resultData['compile_output'] ?? 'No compilation error details';
          final stderr = resultData['stderr'] ?? '';
          final combinedError = stderr.isNotEmpty
              ? '$compileOutput\n\nStandard Error:\n$stderr'
              : compileOutput;

          return {
            'success': false,
            'output': combinedError,
            'message': 'Compilation Error',
            'error_type': 'compilation',
            'line_number': _extractLineNumber(combinedError),
          };
        } else if (status == 7) {
          // Runtime error - get full error details
          final stderr = resultData['stderr'] ?? 'No runtime error details';
          final stdout = resultData['stdout'] ?? '';
          final combinedError = stdout.isNotEmpty
              ? 'Program Output:\n$stdout\n\nError:\n$stderr'
              : stderr;

          return {
            'success': false,
            'output': combinedError,
            'message': 'Runtime Error',
            'error_type': 'runtime',
            'line_number': _extractLineNumber(stderr),
          };
        } else if (status == 5) {
          return {
            'success': false,
            'output':
                'Time limit exceeded - Your code took too long to execute',
            'message': 'Execution Timeout',
            'error_type': 'timeout',
          };
        } else {
          return {
            'success': false,
            'output':
                'Status: ${resultData['status']['description'] ?? 'Unknown'}',
            'message': 'Processing...',
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to get execution results',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Helper method to extract line number from error messages
  static String? _extractLineNumber(String error) {
    // Try to find line number patterns like "line X", "at line X", ":X:", etc.
    final patterns = [
      RegExp(r'line\s+(\d+)', caseSensitive: false),
      RegExp(r':(\d+):\d+'), // Pattern like ":5:10"
      RegExp(r'\*(\d+)\*'), // Pattern like "*5*"
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(error);
      if (match != null && match.group(1) != null) {
        return match.group(1);
      }
    }
    return null;
  }
}
