/// API Constants for AavenzaOne / BillMaster Mobile API
class ApiConstants {
  ApiConstants._();

  // Default Base URL (can be customized by user in login screen)
  static const String defaultServerUrl =
      'https://aavenzaone.aavenzatechnologies.com';
  static const String companyListUrl =
      'https://company.aavenzatechnologies.com/api/companylist';
  static const String apiPath = '/mobile/api.php';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'auth_user';
  static const String keyServerUrl = 'server_url';
  static const String keyRememberEmail = 'remember_email';
  static const String keyCompanyList = 'company_list';
  static const String keySelectedCompany = 'selected_company';

  // API Actions
  // Auth
  static const String actionLogin = 'login';
  static const String actionLogout = 'logout';

  // Attendance
  static const String actionAttendanceStatus = 'attendance_status';
  static const String actionCheckIn = 'check_in';
  static const String actionCheckOut = 'check_out';
  static const String actionMarkStatus = 'mark_status';
  static const String actionEarlyLeave = 'early_leave';

  // Notices
  static const String actionNoticesList = 'notices_list';
  static const String actionNoticeMarkRead = 'notice_mark_read';

  // Notes
  static const String actionNotesList = 'notes_list';
  static const String actionNotesCreate = 'notes_create';
  static const String actionNotesUpdate = 'notes_update';
  static const String actionNotesTogglePin = 'notes_toggle_pin';
  static const String actionNotesDelete = 'notes_delete';

  // Calendar
  static const String actionCalendarList = 'calendar_list';
  static const String actionCalendarCreate = 'calendar_create';
  static const String actionCalendarUpdate = 'calendar_update';
  static const String actionCalendarDelete = 'calendar_delete';

  // Tasks
  static const String actionTasksList = 'tasks_list';
  static const String actionTasksCreate = 'tasks_create';
  static const String actionTasksUpdate = 'tasks_update';
  static const String actionTasksUpdateStatus = 'tasks_update_status';
  static const String actionTasksDelete = 'tasks_delete';

  // Leaves
  static const String actionLeaveTypesList = 'leave_types_list';
  static const String actionLeavesList = 'leaves_list';
  static const String actionLeavesApply = 'leaves_apply';
  static const String actionLeavesCancel = 'leaves_cancel';

  // Meetings
  static const String actionMeetingsList = 'meetings_list';

  // Messenger
  static const String actionMessengerGroups = 'messenger_groups';
  static const String actionMessengerMessages = 'messenger_messages';
  static const String actionMessengerSend = 'messenger_send';

  // IT Support
  static const String actionItCategoriesList = 'it_categories_list';
  static const String actionTicketsList = 'tickets_list';
  static const String actionTicketsCreate = 'tickets_create';
  static const String actionTicketComments = 'ticket_comments';
  static const String actionTicketCommentAdd = 'ticket_comment_add';

  // Salary Slips
  static const String actionSalarySlipsList = 'salary_slips_list';
  static const String actionSalarySlipDetail = 'salary_slip_detail';

  // Travel Allowance
  static const String actionTravelList = 'travel_allowances_list';
  static const String actionTravelApply = 'travel_allowances_apply';
  static const String actionTravelCancel = 'travel_allowances_cancel';

  // CRM Leads
  static const String actionLeadsList = 'leads_list';
  static const String actionLeadGet = 'lead_get';
  static const String actionLeadCreate = 'lead_create';
  static const String actionLeadUpdateStatus = 'lead_update_status';
  static const String actionLeadNoteAdd = 'lead_note_add';
  static const String actionSalesTeamList = 'sales_team_list';

  // Sales Invoices & Target
  static const String actionSalesInvoicesList = 'sales_invoices_list';
  static const String actionSalesInvoiceMonths = 'sales_invoice_months';
  static const String actionSalesInvoiceGet = 'sales_invoice_get';
  static const String actionSalesTargetGet = 'sales_target_get';
  static const String actionSalesTargetHistory = 'sales_target_history';

  // Profile & Cards
  static const String actionProfilePhotoUpload = 'profile_photo_upload';
  static const String actionProfilePhotoRemove = 'profile_photo_remove';
  static const String actionCardData = 'card_data';
  static const String actionCardUpdateTagline = 'card_update_tagline';
  static const String actionCardUpdateSafety = 'card_update_safety';
}
