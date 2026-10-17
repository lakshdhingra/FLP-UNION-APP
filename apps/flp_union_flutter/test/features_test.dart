import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flp_union_app/core/constants/predefined_options.dart';
import 'package:flp_union_app/features/manager/models/manager_profile_dto.dart';
import 'package:flp_union_app/shared/models/engineer.dart';
import 'package:flp_union_app/shared/models/other_manager.dart';
import 'package:flp_union_app/shared/widgets/app_multi_select.dart';

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
      expect(PredefinedOptions.brands.contains('Others'), isFalse); // "Others" handled dynamically in form
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

    test('backward compatibility: parses legacy comma-separated string for brandsWorkedWith', () {
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
      expect(dto.brandsWorkedWith, ['Samsung', 'Haier', 'Bluestar', 'Custom Brand']);
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
      expect(eng.skills, ['Air Conditioner', 'Refrigerator', 'Washing Machine']);
      expect(eng.profilePhotoUrl, 'engineers/photos/eng_1_avatar.jpg');
      expect(eng.aadhaarCardUrl, 'engineers/aadhaar/eng_1_aadhaar.pdf');

      final serialized = eng.toJson();
      expect(serialized['profilePhotoUrl'], 'engineers/photos/eng_1_avatar.jpg');
      expect(serialized['aadhaarCardUrl'], 'engineers/aadhaar/eng_1_aadhaar.pdf');
    });
  });

  group('AppMultiSelect UI Widget', () {
    testWidgets('renders placeholder when empty and selected chips when populated',
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
}
