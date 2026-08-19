import 'package:flutter/foundation.dart';

class AuditSchool {
  final String id;
  final String name;
  final String city;
  final String distance;
  final String status; // 'scheduled', 'pending', 'completed'
  final int totalAssets;
  int visitedAssets;

  AuditSchool({
    required this.id,
    required this.name,
    required this.city,
    required this.distance,
    required this.status,
    required this.totalAssets,
    required this.visitedAssets,
  });
}

class AuditItem {
  final String id;
  final String name;
  final String unitNumber;
  final String totalUnits;
  final String docNumber;
  String status; // 'done', 'miss', 'pending', 'active', 'warn', 'extra'
  String patrimonio;

  AuditItem({
    required this.id,
    required this.name,
    required this.unitNumber,
    required this.totalUnits,
    required this.docNumber,
    required this.status,
    required this.patrimonio,
  });
}

class AuditProvider extends ChangeNotifier {
  final List<AuditSchool> _schools = [
    AuditSchool(
      id: '1',
      name: 'E.E. Maria José da Silva',
      city: 'São Paulo, SP',
      distance: '2.4 km',
      status: 'scheduled',
      totalAssets: 9,
      visitedAssets: 5,
    ),
    AuditSchool(
      id: '2',
      name: 'E.M. Prof. Antônio Carlos',
      city: 'Guarulhos, SP',
      distance: '8.1 km',
      status: 'pending',
      totalAssets: 12,
      visitedAssets: 0,
    ),
    AuditSchool(
      id: '3',
      name: 'Inst. Educar Mais - Unidade Centro',
      city: 'Osasco, SP',
      distance: '14.5 km',
      status: 'completed',
      totalAssets: 7,
      visitedAssets: 7,
    ),
  ];

  int _selectedSchoolIndex = 0;

  final List<AuditItem> _checklistItems = [
    AuditItem(
      id: 'i1',
      name: 'Chromebook Lenovo N23',
      unitNumber: '01',
      totalUnits: '10',
      docNumber: 'NF 48291',
      status: 'done',
      patrimonio: 'PAT-2024-8831',
    ),
    AuditItem(
      id: 'i2',
      name: 'Chromebook Lenovo N23',
      unitNumber: '02',
      totalUnits: '10',
      docNumber: 'NF 48291',
      status: 'done',
      patrimonio: 'PAT-2024-8832',
    ),
    AuditItem(
      id: 'i3',
      name: 'Chromebook Lenovo N23',
      unitNumber: '03',
      totalUnits: '10',
      docNumber: 'NF 48291',
      status: 'active',
      patrimonio: 'PAT-2024-8839',
    ),
    AuditItem(
      id: 'i4',
      name: 'Projetor Epson PowerLite X41',
      unitNumber: '01',
      totalUnits: '02',
      docNumber: 'NF 51022',
      status: 'miss',
      patrimonio: 'PAT-2024-9104',
    ),
    AuditItem(
      id: 'i5',
      name: 'Mesa Digitalizadora Wacom',
      unitNumber: '01',
      totalUnits: '05',
      docNumber: 'NF 53901',
      status: 'done',
      patrimonio: 'PAT-2024-4410',
    ),
    AuditItem(
      id: 'i6',
      name: 'Roteador Cisco Meraki MR36',
      unitNumber: '01',
      totalUnits: '01',
      docNumber: 'NF 60119',
      status: 'pending',
      patrimonio: 'PAT-2024-7723',
    ),
    AuditItem(
      id: 'i7',
      name: 'Tablet Samsung Galaxy Tab A',
      unitNumber: '01',
      totalUnits: '04',
      docNumber: 'NF 62001',
      status: 'pending',
      patrimonio: 'PAT-2024-1182',
    ),
    AuditItem(
      id: 'i8',
      name: 'No-Break APC 1500VA',
      unitNumber: '01',
      totalUnits: '01',
      docNumber: 'NF 63110',
      status: 'pending',
      patrimonio: 'PAT-2024-9901',
    ),
    AuditItem(
      id: 'i9',
      name: 'Kit Robótica Lego SPIKE',
      unitNumber: '01',
      totalUnits: '02',
      docNumber: 'NF 65440',
      status: 'pending',
      patrimonio: 'PAT-2024-3320',
    ),
  ];

  int _selectedItemIndex = 2; // Default to item #03
  Uint8List? _signatureBytes;

  List<AuditSchool> get schools => _schools;
  AuditSchool get currentSchool => _schools[_selectedSchoolIndex];
  List<AuditItem> get checklistItems => _checklistItems;
  int get selectedItemIndex => _selectedItemIndex;
  AuditItem get currentItem => _checklistItems[_selectedItemIndex];
  Uint8List? get signatureBytes => _signatureBytes;

  int get completedCount => _checklistItems.where((i) => i.status == 'done').length;
  int get damagedCount => _checklistItems.where((i) => i.status == 'warn').length;
  int get missingCount => _checklistItems.where((i) => i.status == 'miss').length;
  int get extraCount => _checklistItems.where((i) => i.status == 'extra').length;
  int get totalChecked => _checklistItems.where((i) => i.status != 'pending' && i.status != 'active').length;

  void selectSchool(int index) {
    if (index >= 0 && index < _schools.length) {
      _selectedSchoolIndex = index;
      notifyListeners();
    }
  }

  void selectItem(int index) {
    if (index >= 0 && index < _checklistItems.length) {
      _selectedItemIndex = index;
      // Mark as active if it was pending
      if (_checklistItems[index].status == 'pending') {
        _checklistItems[index].status = 'active';
      }
      notifyListeners();
    }
  }

  void updateCurrentItemStatus(String status, {String? patrimonio}) {
    _checklistItems[_selectedItemIndex].status = status;
    if (patrimonio != null && patrimonio.isNotEmpty) {
      _checklistItems[_selectedItemIndex].patrimonio = patrimonio;
    }
    
    // Update school visited assets count
    currentSchool.visitedAssets = _checklistItems.where((i) => i.status != 'pending').length;

    notifyListeners();
  }

  void advanceToNextItem() {
    if (_selectedItemIndex < _checklistItems.length - 1) {
      _selectedItemIndex++;
      if (_checklistItems[_selectedItemIndex].status == 'pending') {
        _checklistItems[_selectedItemIndex].status = 'active';
      }
      notifyListeners();
    }
  }

  void setSignature(Uint8List? bytes) {
    _signatureBytes = bytes;
    notifyListeners();
  }

  void completeVisit() {
    _schools[_selectedSchoolIndex] = AuditSchool(
      id: currentSchool.id,
      name: currentSchool.name,
      city: currentSchool.city,
      distance: currentSchool.distance,
      status: 'completed',
      totalAssets: currentSchool.totalAssets,
      visitedAssets: currentSchool.totalAssets,
    );
    notifyListeners();
  }
}
