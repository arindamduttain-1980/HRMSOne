import 'package:get/get.dart';
import '../../features/authentication/bindings/auth_binding.dart';
import '../../features/authentication/views/login_view.dart';
import '../../features/calendar/bindings/calendar_binding.dart';
import '../../features/calendar/views/calendar_view.dart';
import '../../features/dashboard/bindings/dashboard_binding.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/digital_cards/bindings/card_binding.dart';
import '../../features/digital_cards/views/digital_cards_view.dart';
import '../../features/employee_profile/bindings/profile_binding.dart';
import '../../features/employee_profile/views/profile_view.dart';
import '../../features/leads_contacts/bindings/leads_binding.dart';
import '../../features/leads_contacts/views/lead_thread_view.dart';
import '../../features/leads_contacts/views/leads_view.dart';
import '../../features/leave_management/bindings/leave_binding.dart';
import '../../features/leave_management/views/leave_management_view.dart';
import '../../features/meetings/bindings/meetings_binding.dart';
import '../../features/meetings/views/meetings_view.dart';
import '../../features/messenger/bindings/messenger_binding.dart';
import '../../features/messenger/views/chat_thread_view.dart';
import '../../features/messenger/views/messenger_view.dart';
import '../../features/notice_board/bindings/notice_binding.dart';
import '../../features/notice_board/views/notice_board_view.dart';
import '../../features/salary_slips/bindings/salary_binding.dart';
import '../../features/salary_slips/views/salary_slip_detail_view.dart';
import '../../features/salary_slips/views/salary_slips_view.dart';
import '../../features/sales_invoices/bindings/sales_invoice_binding.dart';
import '../../features/sales_invoices/views/sales_invoice_detail_view.dart';
import '../../features/sales_invoices/views/sales_invoices_view.dart';
import '../../features/sales_targets/bindings/sales_target_binding.dart';
import '../../features/sales_targets/views/sales_target_view.dart';
import '../../features/sticky_notes/bindings/notes_binding.dart';
import '../../features/sticky_notes/views/sticky_notes_view.dart';
import '../../features/support_tickets/bindings/ticket_binding.dart';
import '../../features/support_tickets/views/support_tickets_view.dart';
import '../../features/support_tickets/views/ticket_thread_view.dart';
import '../../features/task_manager/bindings/task_binding.dart';
import '../../features/task_manager/views/task_manager_view.dart';
import '../../features/travel_allowance/bindings/travel_binding.dart';
import '../../features/travel_allowance/views/travel_allowance_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.noticeBoard,
      page: () => const NoticeBoardView(),
      binding: NoticeBinding(),
    ),
    GetPage(
      name: AppRoutes.stickyNotes,
      page: () => const StickyNotesView(),
      binding: NotesBinding(),
    ),
    GetPage(
      name: AppRoutes.calendar,
      page: () => const CalendarView(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: AppRoutes.meetings,
      page: () => const MeetingsView(),
      binding: MeetingsBinding(),
    ),
    GetPage(
      name: AppRoutes.taskManager,
      page: () => const TaskManagerView(),
      binding: TaskBinding(),
    ),
    GetPage(
      name: AppRoutes.leaveManagement,
      page: () => const LeaveManagementView(),
      binding: LeaveBinding(),
    ),
    GetPage(
      name: AppRoutes.digitalCards,
      page: () => const DigitalCardsView(),
      binding: CardBinding(),
    ),
    GetPage(
      name: AppRoutes.supportTickets,
      page: () => const SupportTicketsView(),
      binding: TicketBinding(),
    ),
    GetPage(
      name: AppRoutes.ticketThread,
      page: () => const TicketThreadView(),
    ),
    GetPage(
      name: AppRoutes.salarySlips,
      page: () => const SalarySlipsView(),
      binding: SalaryBinding(),
    ),
    GetPage(
      name: AppRoutes.salarySlipDetail,
      page: () => const SalarySlipDetailView(),
    ),
    GetPage(
      name: AppRoutes.travelAllowance,
      page: () => const TravelAllowanceView(),
      binding: TravelBinding(),
    ),
    GetPage(
      name: AppRoutes.leadsContacts,
      page: () => const LeadsView(),
      binding: LeadsBinding(),
    ),
    GetPage(
      name: AppRoutes.leadThread,
      page: () => const LeadThreadView(),
    ),
    GetPage(
      name: AppRoutes.salesInvoices,
      page: () => const SalesInvoicesView(),
      binding: SalesInvoiceBinding(),
    ),
    GetPage(
      name: AppRoutes.salesInvoiceDetail,
      page: () => const SalesInvoiceDetailView(),
    ),
    GetPage(
      name: AppRoutes.salesTargets,
      page: () => const SalesTargetView(),
      binding: SalesTargetBinding(),
    ),
    GetPage(
      name: AppRoutes.messenger,
      page: () => const MessengerView(),
      binding: MessengerBinding(),
    ),
    GetPage(
      name: AppRoutes.chatThread,
      page: () => const ChatThreadView(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}
