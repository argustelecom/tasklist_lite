import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';

import 'attach_repository.dart';
import 'model/object_attach.dart';

/// Контроллер загрузки файлов, ассоциирующихся с конкретной задачей
/// особенности:
///   стэк файлов можно разделаять по типу файла:
///     файлы ОС
///     изображения (типо ни разу не файлы ОС???)
///   каждый из типов таже можно побить на:
///     уже прикрепленные файлы (получаются с сервера)
///     прикрепляемые файлы (пока не понятно в какой момент они д.б. отправлены на сервер)
class ObjectAttachController extends GetxController{

  // объект для которого будут извлекаться/отправляться attach
  final int objectId;

  final _ignoring = false.obs;

  get ignoring => _ignoring.value;

  bool tuggleIgnoring(){
    _ignoring.value = !_ignoring.value;
    update();
    return _ignoring.value;
  }

  // Предоставляет данные о текущих вложениях объекта
  AttachRepository _attachRepository = AttachRepository();

  // Список аттачей, которые сейчас приложены и ассоциированы с объектом аттача
  List<ObjectAttach> _objectAttachList = <ObjectAttach>[].obs;

  List<ObjectAttach> get objectAttachList => _objectAttachList;

  // список прикрепляемых файлов (пока не отказался от идеи держать файлы и изображения
  // в разных списках)
  List<File> _files = <File>[].obs;

  List<File> get files => _files;

  // список изображений(пока не отказался от идеи держать файлы и изображения
  // в разных списках)
  List<XFile>? _images = <XFile>[].obs;

  List<XFile>? get images => _images;

  ObjectAttachController(this.objectId);

  @override
  Future<void> onInit() async {
    super.onInit();
    // инициализируем список уже имеющимися вложениями
    _objectAttachList = await _attachRepository.getObjectAttaches(objectId, true);
  }

  /// позволяет сформировать список файлов с ограничениями по расширению файлов
  void pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        // допустимые расширения выбираемых файлов
        allowedExtensions: ['doc', 'docx',  'xls', 'xlsx', 'pdf', 'txt', 'log']);

    if (result != null) {
      List<File> selectedFiles = result.paths.map((path) => File(path!)).toList();

      // см. комент к полю _files
      List<File> _files = <File>[];
      _files.addAll(selectedFiles);
      _attachRepository.sendObjectAttaches(_files.map((e) => fileToObjectAttach(e)).toList());

      // TODO: перечитаем репозиторий, для проверки просто сетим выбранные файлы напрямую
      //_objectAttachList = await _attachRepository.getObjectAttaches(objectId, true);
      _objectAttachList.addAll(_files.map((e) => fileToObjectAttach(e)).toList());

    } else {
      // пользователь отменил прикрепления файлов
    }
    update();
  }

  /// Позволяет запустить камеру, снимок прикладывается во вложения
  void pickCamera() async {
    final ImagePicker _picker = ImagePicker();

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if(photo != null) {
      // см. комент к полю _images
      List<XFile>? _images = <XFile>[];
      _images.add(photo);
      _attachRepository.sendObjectAttaches(_images.map((e) => fileXToObjectAttach(e)).toList());

      // TODO: перечитаем репозиторий, для проверки просто сетим выбранные файлы напрямую
      //_objectAttachList = await _attachRepository.getObjectAttaches(objectId, true);
      _objectAttachList.addAll(_images.map((e) => fileXToObjectAttach(e)).toList());
    }
    else {
      // пользователь отменил прикрепление фото
    }
    update();
  }

  /// Позволяет сформировать список фотографий и изображений. Файлы достаются стредствами ОС
  void pickImage() async {
    final ImagePicker _picker = ImagePicker();

    List<XFile>? selectedImages = await _picker.pickMultiImage();
    if(selectedImages != null){
      // см. комент к полю _images
      List<XFile>? _images = <XFile>[];
      _images.addAll(selectedImages);
      _attachRepository.sendObjectAttaches(_images.map((e) => fileXToObjectAttach(e)).toList());

      // TODO: перечитаем репозиторий, для проверки просто сетим выбранные файлы напрямую
      //_objectAttachList = await _attachRepository.getObjectAttaches(objectId, true);
      _objectAttachList.addAll(_images.map((e) => fileXToObjectAttach(e)).toList());

    }
    else {
      // пользователь отменил прикрепление изображений
    }
    update();
  }

  /// Удаление конкретного вложения
  void deleteAttach(ObjectAttach objectAttach){
    _attachRepository.deleteObjectAttach(objectAttach);

    // TODO: для проверки просто удаляем соответствующий аттач из общего листа аттачей
    //_objectAttachList = await _attachRepository.getObjectAttaches(objectId, true);
    _objectAttachList.remove(objectAttach);
    update();
  }

  /// Конвертация файла в объект для отправки на бэкенд
  ObjectAttach fileToObjectAttach(File file){
    return ObjectAttach(-1, objectId, file.path, file.path, DateTime.now(), "null");
  }

  /// Конвертация файла изображения в объект для отправки на иэкенд
  ObjectAttach fileXToObjectAttach(XFile xFile){
    return ObjectAttach(-1 , objectId, xFile.name, xFile.path, DateTime.now(), "null");
  }

  /// Скачивание файла на конечное устройство
  Future<void> downloadFile(ObjectAttach objectAttach) async {
    /*WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize();
    final taskId = await FlutterDownloader.enqueue(
      url: objectAttach.filePath,
      savedDir: '/data/user/0/com.example.tasklist_lite/cache/',
      showNotification: false, // show download progress in status bar (for Android)
      openFileFromNotification: false, // click on notification to open downloaded file (for Android)
    );*/
  }

}