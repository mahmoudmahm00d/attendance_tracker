import '../strings_enum.dart';

const Map<String, String> arAR = {
  Strings.hello: 'مرحباً!',
  Strings.loading: 'جاري التحميل',
  Strings.changeTheme: 'تغيير المظهر',
  Strings.changeLanguage: 'تغيير اللغة',
  Strings.viewAll: 'عرض الكل',
  Strings.retry: 'اعادة المحاولة',

  // Landing page translations
  Strings.welcomeTitle: 'مرحباً بك في Attendance Tracker',
  Strings.welcomeDescription: 'تطبيق بسيط لتتبع حضور طلابك',
  Strings.easyImportTitle: 'استيراد سهل',
  Strings.easyImportDescription:
      'استورد طلابك بسهولة باستخدام ملف اكسل يحتوي على الاسم واسم الاب فقط',
  Strings.qrGeneratorTitle: 'مولد رموز QR',
  Strings.qrGeneratorDescription:
      'تصدير ملف PDF يحتوي على معرفات طلابك في شكل رمز QR بنقرة واحدة',
  Strings.qrAttendanceTitle: 'الحضور عبر QR',
  Strings.qrAttendanceDescription:
      'اضف الحضور عن طريق مسح رمز QR الخاص بالطالب مع الحفظ التلقائي لاضافة حضور متعدد بسهولة',
  Strings.exportDataTitle: 'تصدير بياناتك',
  Strings.exportDataDescription:
      'قم بتصدير بياناتك بسهولة الى تنسيق اكسل، او قم بتصدير قاعدة البيانات باكملها!',
  Strings.moreToExploreTitle: 'والمزيد والمزيد لاستكشافه',

  // Features list
  Strings.linearGroupManagement: '* ادارة المجموعات بشكل خطي',
  Strings.softDelete: '* الحذف المؤقت',
  Strings.generateReport: '* انشاء تقرير الحضور',
  Strings.bulkOperation: '* عمليات جماعية',
  Strings.dataInsights: '* رؤى البيانات',
  Strings.andMore: 'والمزيد...',
  Strings.letsGetStarted: 'هيا نبدا',

  // Navigation
  Strings.next: 'التالي',
  Strings.previous: 'السابق',
  Strings.done: 'تم',

  // Subject translations
  Strings.editSubject: 'تعديل المادة',
  Strings.createSubject: 'انشاء مادة',
  Strings.subjectName: 'الاسم',
  Strings.enterSubjectName: 'الرجاء ادخال اسم المادة',
  Strings.primaryGroup: 'المجموعة الرئيسية',
  Strings.selectGroup: 'اختر المجموعة',
  Strings.pleaseSelectGroup: 'الرجاء اختيار المجموعة',
  Strings.importantNotice: 'ملاحظة مهمة',
  Strings.subjectGroupNotice:
      'يمكن لهذه المادة اضافة الحضور فقط للطلاب في نفس المجموعة الرئيسية المحددة او اي عضو فيها',
  Strings.updateSubject: 'تحديث المادة',

  // Subjects view translations
  Strings.subjects: 'المواد',
  Strings.subjectsOf: 'مواد @name',
  Strings.showDeleted: 'اظهار المحذوف',
  Strings.showNonDeleted: 'اظهار غير المحذوف',
  Strings.noDeletedSubject: 'لا توجد مواد محذوفة',
  Strings.noSubjectsFound: 'لم يتم العثور على مواد',
  Strings.deletedSubjectToShow: 'المواد المحذوفة ستظهر هنا',
  Strings.tryAddingSubject: 'جرب اضافة مادة',
  Strings.edit: 'تعديل',
  Strings.restore: 'استعادة',
  Strings.delete: 'حذف',
  Strings.deletePermanently: 'حذف نهائي',
  Strings.deleteSubject: 'حذف المادة؟',
  Strings.restoreSubject: 'استعادة المادة',
  Strings.deleteSubjectPermanently: 'حذف المادة نهائياً',
  Strings.goToSubjects: 'الذهاب الى المواد',
  Strings.attendance: 'الحضور',
  Strings.takeAttendance: 'تسجيل الحضور',
  Strings.noKeepDeleted: 'لا، ابقِ محذوفاً',
  Strings.noKeep: 'لا، ابقِ',
  Strings.yesRestore: 'نعم، استعد',
  Strings.yesDelete: 'نعم، احذف',
  Strings.confirmDeleteRestore: 'هل تريد حقاً @action @name؟',
  Strings.lackOfPermission: 'نقص في الصلاحيات',
  Strings.addCameraPermission: 'الرجاء اضافة صلاحية الكاميرا',
  Strings.showingSubjects: 'عرض @count من @total مادة',
  Strings.confirmDeleteSubjectPermanently:
      'هل تريد حقاً حذف مادة @name نهائياً؟',

  // Home view translations
  Strings.groups: 'المجموعات',
  Strings.students: 'الطلاب',
  Strings.exportDatabase: 'تصدير قاعدة البيانات',
  Strings.importDatabase: 'استيراد قاعدة البيانات',
  Strings.preferences: 'التفضيلات',
  Strings.about: 'حول التطبيق',
  Strings.giveMeAStar: 'ادعمني بنجمة',
  Strings.insights: 'الاحصائيات',
  Strings.quickActions: 'اجراءات سريعة',
  Strings.addGroup: 'اضافة مجموعة',
  Strings.addSubject: 'اضافة مادة',
  Strings.addStudent: 'اضافة طالب',
  Strings.recentSubjects: 'المواد الاخيرة',
  Strings.noRecentSubject: 'لا توجد مواد حديثة',
  Strings.useSubjectToAppear: 'استخدم المواد لتظهر هنا',

  // Group translations
  Strings.editGroup: 'تعديل المجموعة',
  Strings.createGroup: 'انشاء مجموعة',
  Strings.updateGroup: 'تحديث المجموعة',
  Strings.groupName: 'الاسم',
  Strings.groupNameHint: 'البرمجة',
  Strings.groupsOf: 'مجموعات @name',
  Strings.noDeletedGroup: 'لا توجد مجموعات محذوفة',
  Strings.noGroupsFound: 'لم يتم العثور على مجموعات',
  Strings.deletedGroupToShow: 'المجموعات المحذوفة ستظهر هنا',
  Strings.tryAddingGroup: 'جرب اضافة مجموعة',
  Strings.restoreGroup: 'استعادة المجموعة',
  Strings.deleteGroup: 'حذف المجموعة؟',
  Strings.deleteGroupPermanently: 'حذف المجموعة نهائياً',
  Strings.confirmDeleteGroupPermanently:
      'هل تريد حقاً حذف مجموعة @name نهائياً؟',
  Strings.showingGroups: 'عرض @count من @total مجموعة',

  // Preferences view translations
  Strings.changeTo: 'تغيير الى',
  Strings.dark: 'الوضع الليلي',
  Strings.light: 'الوضع النهاري',
  Strings.currentLanguage: 'اللغة الحالية',
  Strings.arabic: 'العربية',
  Strings.english: 'الانجليزية',
  Strings.defaultPageSize: 'حجم الصفحة الافتراضي',
  Strings.numberValidation: 'الرجاء ادخال رقم صحيح',

  // Student translations
  Strings.editStudent: 'تعديل الطالب',
  Strings.createStudent: 'انشاء طالب',
  Strings.updateStudent: 'تحديث الطالب',
  Strings.studentName: 'الاسم',
  Strings.studentNameHint: 'محمود محمود',
  Strings.enterStudentName: 'الرجاء ادخال اسم الطالب',
  Strings.fatherName: 'اسم الاب',
  Strings.fatherNameHint: 'درويش',
  Strings.showInGroups: 'اظهار في المجموعات',
  Strings.searchForGroup: 'البحث عن مجموعة',
  Strings.noSelectedGroups: 'لا توجد مجموعات محددة',

  // Import from Excel translations
  Strings.importFromExcel: 'استيراد من اكسل',
  Strings.pickFile: 'اختر ملف',
  Strings.fileSelected: 'الملف: تم اختيار @name',
  Strings.processing: 'جاري المعالجة',
  Strings.import: 'استيراد',
  Strings.fileRequirements: 'يجب ان يحتوي الملف على الاسم واسم الاب فقط',
  Strings.rowsIgnoreNotice:
      'سيتم تجاهل الصف الاول واي صف يحتوي على بيانات غير صالحة',
  Strings.fileExample: 'مثال الملف:',
  Strings.name: 'الاسم',
  Strings.exampleName: 'محمود محمود',
  Strings.exampleFatherName: 'درويش',

  // Manage Groups translations
  Strings.manageGroups: 'ادارة المجموعات',
  Strings.groupsOverwriteNotice:
      'بعد حفظ التغييرات سيتم استبدال جميع مجموعات الطلاب.',
  Strings.saveChanges: 'حفظ التغييرات',

  // Students filters translations
  Strings.filters: 'الفلاتر',
  Strings.applyFilters: 'تطبيق الفلاتر',
  Strings.removeFilters: 'ازالة الفلاتر',

  // Students view translations
  Strings.studentsOf: 'طلاب @name',
  Strings.selected: 'تم تحديد @count',
  Strings.exportToExcel: 'تصدير جميع الطلاب الى اكسل',
  Strings.exportQrs: 'تصدير رموز QR لجميع الطلاب',
  Strings.selectStudents: 'اختر الطلاب',
  Strings.removeSelection: 'ازالة التحديد',
  Strings.selectAll: 'تحديد الكل',
  Strings.unselectAll: 'الغاء تحديد الكل',
  Strings.noUserSelected: 'لم يتم تحديد مستخدم',
  Strings.mustSelectOneUser: 'يجب تحديد مستخدم واحد على الاقل',
  Strings.noStudentsFound: 'لم يتم العثور على طلاب',
  Strings.tryAddingStudent: 'جرب اضافة طالب',
  Strings.typeToSearch: 'ابحث',
  Strings.qr: 'QR',
  Strings.deleteStudent: 'حذف الطالب؟',
  Strings.restoreStudent: 'استعادة الطالب',
  Strings.deleteStudentPermanently: 'حذف الطالب نهائياً',
  Strings.confirmDeleteStudentPermanently:
      'هل تريد حقاً حذف الطالب @name نهائياً؟',
  Strings.areYouSureDelete: 'هل تريد حقاً حذف @name؟',
  Strings.areYouSureRestore: 'هل تريد حقاً استعادة @name؟',
  Strings.areYouSureDeletePermanently: 'هل تريد حقاً حذف @name نهائياً؟',
  Strings.showing: 'عرض @count من @total طالب',
  Strings.filteredFrom: 'تمت التصفية من @total',
  Strings.noMoreData: 'لا توجد المزيد من البيانات',
  Strings.loadMore: 'تحميل المزيد',

  // Add attendance translations
  Strings.dateIsRequired: 'التاريخ مطلوب',
  Strings.addAttendance: 'اضافة حضور',
  Strings.date: 'التاريخ',
  Strings.selectDate: 'اختر التاريخ',
  Strings.selectDateToAddAttendance: 'اختر التاريخ لاضافة الحضور',
  Strings.attendanceReportGeneratedSuccessfully: 'تم انشاء تقرير الحضور بنجاح',
  Strings.fileSavedAt: 'تم حفظ الملف في @path',
  Strings.failedToGenerateFile: 'فشل في انشاء الملف',
  Strings.addStoragePermission: 'الرجاء اضافة صلاحية التخزين',
  Strings.checkStoragePermission: 'تحقق من صلاحية التخزين',

  // Attendance filters translations
  Strings.nonZeroAttendance: 'لديه حضور فقط',
  Strings.dates: 'التواريخ',

  // Attendance view translations
  Strings.attendances: 'سجلات الحضور',
  Strings.attendancesOf: 'سجلات حضور @name',
  Strings.selectStudentsForAttendance: 'اختر الطلاب',
  Strings.noAttendancesFound: 'لم يتم العثور على سجلات حضور',
  Strings.tryAddingAttendance: 'جرب اضافة حضور',
  Strings.createAttendance: 'انشاء حضور',
  Strings.attended: 'حضر',
  Strings.of: 'من',
  Strings.selectDateFor: 'اختر التاريخ للاضافة الى @count طالب',
  Strings.cancel: 'الغاء',
  Strings.select: 'اختيار',
  Strings.invalidDate: 'تاريخ غير صالح',
  Strings.dateOutOfRange: 'التاريخ خارج النطاق',

  // QR attendance translations
  Strings.sessionUsersCount: 'عدد مستخدمي الجلسة:',
  Strings.showUsers: 'عرض المستخدمين',
  Strings.noUserAddedYet: 'لم تتم اضافة مستخدمين بعد',
  Strings.none: 'لا شيء',
  Strings.autoSave: 'حفظ تلقائي',
  Strings.autoSaveEnabled: 'تم تفعيل الحفظ التلقائي',
  Strings.userNotFound: 'لم يتم العثور على المستخدم',
  Strings.discard: 'تجاهل',
  Strings.ok: 'حسناً',
  Strings.error: 'خطا',
  Strings.somethingWentWrong: 'حدث خطا ما',

  // User attendance view translations
  Strings.userAttendances: 'سجلات حضور @name',
  Strings.deleteAttendance: 'حذف الحضور',
  Strings.deleteAttendanceConfirm: 'هل تريد حقاً حذف الحضور ليوم @date؟',

  Strings.aborted: 'تم الالغاء',
  Strings.directoryIsRequired: 'المجلد مطلوب',
  Strings.exportingDatabase: 'تصدير قاعدة البيانات',
  Strings.exportingDatabaseMessage:
      'جاري تصدير قاعدة البيانات الخاصة بك. لا تغلق التطبيق حتى ننتهي',

  Strings.selectDatabaseFile: 'اختر ملف قاعدة البيانات',
  Strings.fileIsRequired: 'الملف مطلوب',
  Strings.invalidDbFile: 'ملف قاعدة بيانات غير صالح',
  Strings.importedSuccessfully: 'تم الاستيراد بنجاح',
  Strings.importDatabaseMessage:
      'جاري استيراد قاعدة البيانات الخاصة بك. لا تغلق التطبيق حتى ننتهي',

  Strings.userAddedSuccessfully: 'تمت اضافة الطالب بنجاح',
  Strings.usernameAddedSuccessfully: 'تمت اضافة @name بنجاح',
  Strings.selectExcelFile: 'اختر ملف اكسل',
  Strings.pleaseSelectExcelFile: 'الرجاء اختيار ملف اكسل',
  Strings.noStudentAdded: 'لم تتم اضافة طلاب',
  Strings.noStudentFound: 'لم يتم العثور على طلاب',
  Strings.countStudentsAddedSuccessfully: 'تمت اضافة @count طالب بنجاح',
  Strings.studentsExportedSuccessfully: 'تم تصدير الطلاب بنجاح',
  Strings.noUseEnglish: 'لا، استخدم الانجليزية',
  Strings.yseUseArabic: 'نعم، استخدم العربية',
  Strings.exportStudentsWithAppliedFilters:
      'تصدير جميع الطلاب مع الفلاتر المطبقة باستخدام الخط العربي',
  Strings.textDirectionToRTL: 'سيجعل هذا اتجاه النص من اليمين الى اليسار',
  Strings.success: 'نجاح',
  Strings.studentsUpdatedSuccessfully: 'تم تحديث الطلاب بنجاح',
  Strings.countStudentsUpdated: 'تم تحديث @count طالب بنجاح',
  Strings.exportingStudentsTitle: "تصدير جميع الطلاب الذين تم تطبيق الفلاتر عليهم",
  Strings.exportingStudentsMessage:
      "هكذ سيتم تصدير جيع الطلاب الناتجة عن تطبيق الفلاتر المختارة",
};
