
import 'package:flutter_test/flutter_test.dart';
import 'package:p2/logic/equipment_detail_logic.dart';
import 'package:p2/models/Item.dart';

void main() {
  test('EquipmentDetailLogic computes price correctly', () {
    final logic = EquipmentDetailLogic();
    
    final testItem = Item(
      id: 'test',
      name: 'Test',
      description: 'Test',
      images: [],
      category: 'Test',
      subCategory: 'Test',
      rentalPeriods: {'Daily': '50'},
      ownerId: 'owner',
      averageRating: 0.0,
      ratingCount: 0,
      latitude: null,
      longitude: null, ownerName: '', status: '',
    );
    
    logic.setItem(testItem);
    logic.selectedPeriod = 'Daily';
    logic.count = 3;
    
    final price = logic.computeTotalPrice();
    expect(price, 150.0); // 50 * 3
  });

  test('getUnitLabel works', () {
    final logic = EquipmentDetailLogic();
    
    logic.selectedPeriod = 'Hourly';
    expect(logic.getUnitLabel(), 'Hours');
    
    logic.selectedPeriod = 'Weekly';
    expect(logic.getUnitLabel(), 'Weeks');
  });

  test('canRent returns false initially', () {
    final logic = EquipmentDetailLogic();
    expect(logic.canRent(), false);
  });
}
