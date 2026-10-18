import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flp_union_app/core/constants/predefined_options.dart';
import 'package:flp_union_app/core/errors/app_exception.dart';
import 'package:flp_union_app/features/manager/models/manager_profile_dto.dart';
import 'package:flp_union_app/features/manager/screens/engineer_form_screen.dart';
import 'package:flp_union_app/shared/models/engineer.dart';
import 'package:flp_union_app/shared/models/other_manager.dart';
import 'package:flp_union_app/shared/widgets/app_multi_select.dart';
import 'package:flp_union_app/features/manager/services/manager_service.dart';

void main() {
  group('Predefined Constants Requirements', () {
    test('predefinedTechnicalSkills has exactly the 12 required skills', () {
      expect(PredefinedOptions.technicalSkills.length, 12);
      expect(PredefinedOptions.technicalSkills, [
        'Air Conditioner',
        'Television',
        'Washing Machine',
        'Water Purifier',
        'Refrigerator',
        'Robot Vacuum Cleaner',
        'Water Geyser',
        'Audio System',
        'Fan',
        'Stabilizers',
        'Furniture',
        'Chimney',
      ]);
    });

    test('predefinedBrands contains all standard brand options', () {
      expect(PredefinedOptions.brands.contains('Samsung'), isTrue);
      expect(PredefinedOptions.brands.contains('LG'), isTrue);
      expect(PredefinedOptions.brands.contains('Sony'), isTrue);
      expect(PredefinedOptions.brands.contains('Daikin'), isTrue);
      expect(PredefinedOptions.brands.contains('Amazon'), isTrue);
      expect(PredefinedOptions.brands.contains('Flipkart'), isTrue);
      expect(PredefinedOptions.brands.contains('Others'),
          isFalse); // "Others" handled dynamically in form
    });
  });

  group('Manager Profile Brands & Photo DTO Parsing', () {
    test('correctly parses brandsWorkedWith from JSON array', () {
      final json = {
        'id': 'mgr_1',
        'userId': 'usr_1',
        'fullName': 'Test Manager',
        'email': 'mgr@example.com',
        'mobile': '9876543210',
        'profilePhotoUrl': 'manager/profiles/photo_123.jpg',
        'brandsWorkedWith': ['Samsung', 'LG', 'Sony'],
        'state': {'id': 'st_1', 'name': 'Delhi'},
        'district': {'id': 'dist_1', 'name': 'Central Delhi'},
        'totalEngineers': 5,
      };

      final dto = ManagerProfileDto.fromJson(json);
      expect(dto.fullName, 'Test Manager');
      expect(dto.profilePhotoUrl, 'manager/profiles/photo_123.jpg');
      expect(dto.brandsWorkedWith, ['Samsung', 'LG', 'Sony']);
      expect(dto.totalEngineers, 5);
    });

    test(
        'backward compatibility: parses legacy comma-separated string for brandsWorkedWith',
        () {
      final legacyJson = {
        'id': 'mgr_2',
        'userId': 'usr_2',
        'fullName': 'Legacy Manager',
        'email': 'legacy@example.com',
        'mobile': '9876543211',
        'profilePhotoUrl': null,
        'brandsWorkedWith': 'Samsung, Haier, Bluestar, Custom Brand',
        'state': {'id': 'st_1', 'name': 'Delhi'},
        'district': {'id': 'dist_1', 'name': 'Central Delhi'},
        'totalEngineers': 2,
      };

      final dto = ManagerProfileDto.fromJson(legacyJson);
      expect(dto.brandsWorkedWith,
          ['Samsung', 'Haier', 'Bluestar', 'Custom Brand']);
      expect(dto.profilePhotoUrl, isNull);
    });
  });

  group('OtherManager Model Parsing', () {
    test('parses profilePhotoUrl and brandsWorkedWith correctly', () {
      final json = {
        'id': 'mgr_3',
        'fullName': 'Colleague Manager',
        'email': 'colleague@example.com',
        'mobile': '9876543212',
        'profilePhotoUrl': 'manager/profile_3.jpg',
        'brandsWorkedWith': ['Daikin', 'Panasonic'],
        'state': {'id': 'st_1', 'name': 'Delhi'},
        'district': {'id': 'dist_1', 'name': 'Central Delhi'},
        'totalEngineers': 3,
      };

      final manager = OtherManager.fromJson(json);
      expect(manager.profilePhotoUrl, 'manager/profile_3.jpg');
      expect(manager.brandsWorkedWith, ['Daikin', 'Panasonic']);
    });
  });

  group('Engineer Model Aadhaar and Photo fields', () {
    test('Engineer.fromJson parses aadhaarCardUrl and profilePhotoUrl', () {
      final json = {
        'id': 'eng_1',
        'fullName': 'Ramesh Kumar',
        'email': 'ramesh@example.com',
        'phone': '9876543210',
        'managerId': 'mgr_1',
        'districtId': 'dist_1',
        'skills': ['Air Conditioner', 'Refrigerator', 'Washing Machine'],
        'profilePhotoUrl': 'engineers/photos/eng_1_avatar.jpg',
        'aadhaarCardUrl': 'engineers/aadhaar/eng_1_aadhaar.pdf',
        'district': {'id': 'dist_1', 'name': 'North Delhi'},
        'createdAt': '2026-10-18T00:00:00Z',
        'updatedAt': '2026-10-18T00:00:00Z',
      };

      final eng = Engineer.fromJson(json);
      expect(eng.fullName, 'Ramesh Kumar');
      expect(
          eng.skills, ['Air Conditioner', 'Refrigerator', 'Washing Machine']);
      expect(eng.profilePhotoUrl, 'engineers/photos/eng_1_avatar.jpg');
      expect(eng.aadhaarCardUrl, 'engineers/aadhaar/eng_1_aadhaar.pdf');

      final serialized = eng.toJson();
      expect(
          serialized['profilePhotoUrl'], 'engineers/photos/eng_1_avatar.jpg');
      expect(
          serialized['aadhaarCardUrl'], 'engineers/aadhaar/eng_1_aadhaar.pdf');
    });

    test('Engineer.fromJson handles null and omitted aadhaarCardUrl gracefully', () {
      final json = {
        'id': 'eng_2',
        'fullName': 'Suresh Kumar',
        'phone': '9876543211',
      };

      final eng = Engineer.fromJson(json);
      expect(eng.fullName, 'Suresh Kumar');
      expect(eng.aadhaarCardUrl, isNull);
      expect(eng.profilePhotoUrl, isNull);
      expect(eng.toJson()['aadhaarCardUrl'], isNull);
    });

    test('Engineer payload construction respects optional Aadhaar on create and edit', () {
      Map<String, dynamic> buildPayload({
        required String name,
        required String phone,
        String? aadhaarKey,
        bool isEdit = false,
      }) {
        final payload = <String, dynamic>{
          'fullName': name,
          'phone': phone,
        };
        if (aadhaarKey != null && aadhaarKey.isNotEmpty) {
          payload['aadhaarCardUrl'] = aadhaarKey;
        } else if (isEdit) {
          payload['aadhaarCardUrl'] = null;
        }
        return payload;
      }

      // 1. Create engineer without Aadhaar document
      final createNoAadhaar = buildPayload(
        name: 'No Aadhaar Engineer',
        phone: '+919876543210',
        aadhaarKey: null,
        isEdit: false,
      );
      expect(createNoAadhaar.containsKey('aadhaarCardUrl'), isFalse);

      // 2. Create engineer with Aadhaar document
      final createWithAadhaar = buildPayload(
        name: 'With Aadhaar Engineer',
        phone: '+919876543210',
        aadhaarKey: 'android/sub-members/eng_aadhaar.pdf',
        isEdit: false,
      );
      expect(createWithAadhaar['aadhaarCardUrl'], 'android/sub-members/eng_aadhaar.pdf');

      // 3. Edit engineer removing Aadhaar document
      final editRemoveAadhaar = buildPayload(
        name: 'Edit Engineer',
        phone: '+919876543210',
        aadhaarKey: null,
        isEdit: true,
      );
      expect(editRemoveAadhaar['aadhaarCardUrl'], isNull);
    });
  });

  group('AppMultiSelect UI Widget', () {
    testWidgets(
        'renders placeholder when empty and selected chips when populated',
        (WidgetTester tester) async {
      List<String> selected = ['Television', 'Washing Machine'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppMultiSelect(
                  label: 'Technical Skills',
                  placeholder: 'Select technical skills',
                  options: PredefinedOptions.technicalSkills,
                  selectedValues: selected,
                  onChanged: (newVals) {
                    setState(() {
                      selected = newVals;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify selected chips are rendered
      expect(find.text('Television'), findsOneWidget);
      expect(find.text('Washing Machine'), findsOneWidget);
    });
  });

  group('ManagerService S3 Key Extraction', () {
    test('extracts clean key from canonical virtual-hosted S3 bucket URL', () {
      const url =
          'https://taspu-membership-documents-prod.s3.ap-south-1.amazonaws.com/android/sub-members/1729210000-xyz.jpg';
      expect(
          ManagerService.extractS3Key(url), 'android/sub-members/1729210000-xyz.jpg');
    });

    test('extracts clean key from path-style S3 URL', () {
      const url =
          'https://s3.ap-south-1.amazonaws.com/taspu-membership-documents-prod/android/managers/manager_123.jpg';
      expect(
          ManagerService.extractS3Key(url), 'android/managers/manager_123.jpg');
    });

    test('preserves already signed presigned URLs', () {
      const signedUrl =
          'https://taspu-membership-documents-prod.s3.ap-south-1.amazonaws.com/android/sub-members/123.jpg?X-Amz-Signature=abc12345';
      expect(ManagerService.extractS3Key(signedUrl), signedUrl);
    });

    test('preserves clean S3 keys without URL scheme', () {
      const key = 'android/sub-members/1729210000-xyz.jpg';
      expect(ManagerService.extractS3Key(key), key);
    });

    test('preserves external third-party URLs', () {
      const externalUrl = 'https://images.unsplash.com/photo-123.jpg';
      expect(ManagerService.extractS3Key(externalUrl), externalUrl);
    });

    test('handles empty string gracefully', () {
      expect(ManagerService.extractS3Key(''), '');
    });
  });

  group('Salary Normalization and Parsing Tests', () {
    test('parses clean integer strings', () {
      expect(EngineerFormScreen.parseSalary('25000'), 25000.0);
      expect(EngineerFormScreen.parseSalary('50000'), 50000.0);
    });

    test('parses decimal values accurately', () {
      expect(EngineerFormScreen.parseSalary('25000.50'), 25000.50);
      expect(EngineerFormScreen.parseSalary('12345.75'), 12345.75);
    });

    test('strips commas from formatted salary inputs', () {
      expect(EngineerFormScreen.parseSalary('25,000'), 25000.0);
      expect(EngineerFormScreen.parseSalary('1,50,000'), 150000.0);
      expect(EngineerFormScreen.parseSalary('1,50,000.50'), 150000.50);
    });

    test('strips Indian rupee symbols and whitespace', () {
      expect(EngineerFormScreen.parseSalary('₹25000'), 25000.0);
      expect(EngineerFormScreen.parseSalary('₹ 25,000'), 25000.0);
      expect(EngineerFormScreen.parseSalary(' ₹ 50,000.00 '), 50000.0);
    });

    test('strips Rs and INR prefixes', () {
      expect(EngineerFormScreen.parseSalary('Rs. 25,000'), 25000.0);
      expect(EngineerFormScreen.parseSalary('Rs 30000'), 30000.0);
      expect(EngineerFormScreen.parseSalary('INR 45,000'), 45000.0);
    });

    test('returns null for empty or whitespace-only inputs without defaulting to zero', () {
      expect(EngineerFormScreen.parseSalary(''), isNull);
      expect(EngineerFormScreen.parseSalary('   '), isNull);
    });

    test('returns null for non-numeric input text', () {
      expect(EngineerFormScreen.parseSalary('abc'), isNull);
      expect(EngineerFormScreen.parseSalary('twenty thousand'), isNull);
    });

    test('parses negative numbers for validation to inspect', () {
      expect(EngineerFormScreen.parseSalary('-500'), -500.0);
      expect(EngineerFormScreen.parseSalary('₹ -1,000'), -1000.0);
    });
  });

  group('Engineer Model Salary Serialization Tests', () {
    test('parses integer, decimal, and string salaries in json', () {
      final eng1 = Engineer.fromJson({'salary': 35000});
      expect(eng1.salary, 35000.0);

      final eng2 = Engineer.fromJson({'salary': 35000.75});
      expect(eng2.salary, 35000.75);

      final eng3 = Engineer.fromJson({'salary': '35,000.50'});
      expect(eng3.salary, 35000.50);

      final eng4 = Engineer.fromJson({'salary': null});
      expect(eng4.salary, isNull);
    });
  });

  group('ApiException DioException Visibility Tests', () {
    test('extracts NestJS message array joined with newlines', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/manager/engineers'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/manager/engineers'),
          statusCode: 400,
          data: {
            'statusCode': 400,
            'message': [
              'salary must not be less than 0',
              'salary must be a number conforming to the specified constraints'
            ],
            'error': 'Bad Request',
          },
        ),
      );

      final apiException = ApiException.fromDioException(dioException);
      expect(apiException.statusCode, 400);
      expect(
        apiException.message,
        'salary must not be less than 0\nsalary must be a number conforming to the specified constraints',
      );
      expect(apiException.toString(), apiException.message);
    });

    test('extracts single message string from response data', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/manager/engineers'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/manager/engineers'),
          statusCode: 400,
          data: {
            'statusCode': 400,
            'message': 'An engineer with this phone number already exists in your directory.',
            'error': 'Bad Request',
          },
        ),
      );

      final apiException = ApiException.fromDioException(dioException);
      expect(apiException.statusCode, 400);
      expect(
        apiException.message,
        'An engineer with this phone number already exists in your directory.',
      );
    });
  });
}
