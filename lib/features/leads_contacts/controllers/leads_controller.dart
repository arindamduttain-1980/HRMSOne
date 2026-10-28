import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/crm_lead_model.dart';
import '../../../data/repositories/crm_repository.dart';

class LeadsController extends GetxController {
  final CrmRepository _crmRepository;

  LeadsController({required CrmRepository crmRepository})
      : _crmRepository = crmRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<CrmLeadModel> leads = <CrmLeadModel>[].obs;
  final RxList<SalesTeamMemberModel> salesTeam = <SalesTeamMemberModel>[].obs;

  final RxString selectedTypeFilter = 'all'.obs;
  final RxString selectedStatusFilter = 'all'.obs;

  // Create Lead Form
  final nameController = TextEditingController();
  final companyController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dealValueController = TextEditingController();
  final notesController = TextEditingController();
  final RxString leadType = 'lead'.obs;
  final RxString leadPriority = 'medium'.obs;
  final RxString leadSource = 'referral'.obs;

  // Active Lead Detail & Timeline
  final Rx<CrmLeadModel?> activeLead = Rx<CrmLeadModel?>(null);
  final RxList<LeadHistoryModel> leadHistory = <LeadHistoryModel>[].obs;
  final RxBool isDetailLoading = false.obs;
  final timelineNoteController = TextEditingController();

  final List<String> leadTypes = ['lead', 'contact', 'opportunity'];
  final List<String> statuses = ['new', 'contacted', 'qualified', 'proposal_sent', 'negotiation', 'won', 'lost', 'inactive'];
  final List<String> sources = ['website', 'referral', 'cold_call', 'email_campaign', 'social_media', 'exhibition', 'walk_in', 'other'];

  @override
  void onInit() {
    super.onInit();
    loadLeads();
    loadSalesTeam();
  }

  Future<void> loadLeads() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final list = await _crmRepository.getLeads(
        type: selectedTypeFilter.value,
        status: selectedStatusFilter.value,
      );
      leads.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSalesTeam() async {
    try {
      final team = await _crmRepository.getSalesTeam();
      salesTeam.assignAll(team);
    } catch (_) {
      // Ignored if non-manager
    }
  }

  void openCreateModal() {
    nameController.clear();
    companyController.clear();
    emailController.clear();
    phoneController.clear();
    dealValueController.clear();
    notesController.clear();
    leadType.value = 'lead';
    leadPriority.value = 'medium';
    leadSource.value = 'referral';
  }

  Future<void> createLead() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Required', 'Lead person name is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final response = await _crmRepository.createLead(
        name: name,
        company: companyController.text.trim().isNotEmpty ? companyController.text.trim() : null,
        type: leadType.value,
        email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
        phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
        source: leadSource.value,
        priority: leadPriority.value,
        dealValue: double.tryParse(dealValueController.text.trim()),
        notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
      );

      Get.back();
      Get.snackbar(
        'Lead Added',
        response['message']?.toString() ?? 'Lead created successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      await loadLeads();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> loadLeadDetail(int id) async {
    isDetailLoading.value = true;

    try {
      final result = await _crmRepository.getLeadDetail(id);
      activeLead.value = result.lead;
      leadHistory.assignAll(result.history);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> updateStatus(String newStatus) async {
    if (activeLead.value == null) return;

    try {
      await _crmRepository.updateLeadStatus(
        id: activeLead.value!.id,
        status: newStatus,
      );
      await loadLeadDetail(activeLead.value!.id);
      await loadLeads();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addTimelineNote() async {
    final note = timelineNoteController.text.trim();
    if (note.isEmpty || activeLead.value == null) return;

    try {
      await _crmRepository.addLeadNote(
        id: activeLead.value!.id,
        note: note,
      );
      timelineNoteController.clear();
      await loadLeadDetail(activeLead.value!.id);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    companyController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dealValueController.dispose();
    notesController.dispose();
    timelineNoteController.dispose();
    super.onClose();
  }
}

