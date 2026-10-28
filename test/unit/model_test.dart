import 'package:flutter_test/flutter_test.dart';
import 'package:mbs_attendance_app/data/models/user_model.dart';
import 'package:mbs_attendance_app/data/models/attendance_model.dart';
import 'package:mbs_attendance_app/data/models/notice_model.dart';
import 'package:mbs_attendance_app/data/models/note_model.dart';
import 'package:mbs_attendance_app/data/models/task_model.dart';
import 'package:mbs_attendance_app/data/models/salary_slip_model.dart';
import 'package:mbs_attendance_app/data/models/travel_claim_model.dart';
import 'package:mbs_attendance_app/data/models/crm_lead_model.dart';

void main() {
  group('Model Serialization Tests', () {
    test('UserModel serialization and initials test', () {
      final json = {
        'id': 14,
        'name': 'Rajesh Kumar',
        'email': 'rajesh@example.com',
        'role': 'salesman',
        'designation': 'Sales Executive',
        'photo_url': 'http://localhost/mobile/upload/avatars/user_14.jpg',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 14);
      expect(user.name, 'Rajesh Kumar');
      expect(user.initials, 'RK');
      expect(user.role, 'salesman');

      final serialized = user.toJson();
      expect(serialized['id'], 14);
      expect(serialized['name'], 'Rajesh Kumar');
    });

    test('AttendanceRecord serialization and status helpers', () {
      final json = {
        'id': 102,
        'employee_id': 8,
        'date': '2026-10-26',
        'check_in': '2026-10-26 09:30:15',
        'check_out': null,
        'status': 'present',
        'remarks': 'On time',
      };

      final record = AttendanceRecord.fromJson(json);
      expect(record.id, 102);
      expect(record.isCheckedIn, true);
      expect(record.isCompleted, false);
      expect(record.isPresent, true);
    });

    test('NoticeModel priority and read status', () {
      final json = {
        'id': 12,
        'title': 'Diwali Office Schedule',
        'content': 'Office will remain closed.',
        'priority': 'high',
        'is_pinned': 1,
        'created_at': '2026-10-20 10:00:00',
        'is_read': false,
      };

      final notice = NoticeModel.fromJson(json);
      expect(notice.id, 12);
      expect(notice.isPinned, true);
      expect(notice.isRead, false);

      final updated = notice.copyWith(isRead: true);
      expect(updated.isRead, true);
    });

    test('NoteModel pinned and color mapping', () {
      final json = {
        'id': 5,
        'title': 'Client follow-up',
        'content': 'Call Acme Corp.',
        'color': '#fef08a',
        'pinned': 1,
        'updated_at': '2026-10-26 11:20:00',
      };

      final note = NoteModel.fromJson(json);
      expect(note.id, 5);
      expect(note.pinned, true);
      expect(note.color, '#fef08a');
    });

    test('TaskModel serialization test', () {
      final json = {
        'id': 41,
        'task_no': 'TSK-0041',
        'title': 'Prepare GST Reconciliation',
        'description': 'Cross-verify GSTR-2B',
        'priority': 'high',
        'status': 'in_progress',
        'assigned_to': 14,
        'due_date': '2026-10-31',
      };

      final task = TaskModel.fromJson(json);
      expect(task.id, 41);
      expect(task.taskNo, 'TSK-0041');
      expect(task.isDone, false);
    });

    test('SalarySlipDetailModel calculation and banking info', () {
      final json = {
        'id': 73,
        'name': 'Rajesh Kumar',
        'emp_code': 'EMP-008',
        'designation': 'Sales Executive',
        'month': 9,
        'year': 2026,
        'basic_salary': '30000.00',
        'hra': '15000.00',
        'special_allowance': '10000.00',
        'gross_salary': '55000.00',
        'pf_employee': '1800.00',
        'esi_employee': '0.00',
        'professional_tax': '200.00',
        'tds': '2500.00',
        'total_deductions': '4500.00',
        'net_salary': '50500.00',
        'bank_name': 'HDFC Bank',
      };

      final slip = SalarySlipDetailModel.fromJson(json);
      expect(slip.grossSalary, 55000.00);
      expect(slip.totalDeductions, 4500.00);
      expect(slip.netSalary, 50500.00);
      expect(slip.bankName, 'HDFC Bank');
    });

    test('TravelClaimModel expense mapping', () {
      final json = {
        'id': 24,
        'claim_date': '2026-10-26',
        'travel_date': '2026-10-25',
        'from_place': 'Noida',
        'to_place': 'Gurugram',
        'purpose': 'Client meeting',
        'travel_type': 'local',
        'mode': 'own_vehicle',
        'distance_km': '45.00',
        'rate_per_km': '8.00',
        'km_amount': '360.00',
        'ticket_amount': '0.00',
        'other_expense': '120.00',
        'total_amount': '480.00',
        'status': 'pending',
      };

      final claim = TravelClaimModel.fromJson(json);
      expect(claim.distanceKm, 45.00);
      expect(claim.totalAmount, 480.00);
      expect(claim.isPending, true);
    });

    test('CrmLeadModel pipeline and deal value', () {
      final json = {
        'id': 35,
        'lead_no': 'LD-00035',
        'type': 'lead',
        'name': 'Sunil Mehta',
        'company': 'Apex Corp',
        'priority': 'high',
        'status': 'proposal_sent',
        'deal_value': '150000.00',
        'updated_at': '2026-10-26 11:45:00',
      };

      final lead = CrmLeadModel.fromJson(json);
      expect(lead.leadNo, 'LD-00035');
      expect(lead.dealValue, 150000.00);
      expect(lead.status, 'proposal_sent');
    });
  });
}
