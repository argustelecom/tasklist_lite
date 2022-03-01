import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tasklist_lite/common/widgets/object_attach_widget/utils/file_manager.dart';
import 'package:tasklist_lite/state/application_state.dart';
import 'package:tasklist_lite/state/auth_controller.dart';

import 'attach_repository.dart';
import 'model/object_attach.dart';

/// Контроллер загрузки файлов, ассоциирующихся с конкретным объектом
/// особенности:
///   стэк файлов можно разделаять по типу файла:
///     файлы ОС
///     изображения (типо ни разу не файлы ОС???)
///   каждый из типов таже можно побить на:
///     уже прикрепленные файлы (получаются с сервера)
///     прикрепляемые файлы (пока не понятно в какой момент они д.б. отправлены на сервер)
class ObjectAttachController extends GetxController{

  /// Активный списоок аттачей для текущего выбранного объекта
  //final _objectAttachList = Future.value(<ObjectAttach>[]).obs;

  // объект для которого будут извлекаться/отправляться attach
  final int objectId;

  // заготовка на блокирование экрана при раскрытии кнопки "прикрепить файл"
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
  final objectAttachList = Future.value(<ObjectAttach>[]).obs;

  // список прикрепляемых файлов (пока не отказался от идеи держать файлы и изображения
  // в разных списках)
  List<File> _files = <File>[].obs;

  List<File> get files => _files;

  // список изображений(пока не отказался от идеи держать файлы и изображения
  // в разных списках)
  List<XFile>? _images = <XFile>[].obs;

  List<XFile>? get images => _images;

  ObjectAttachController(this.objectId);

  AuthController authController = Get.find();
  ApplicationState state = Get.find();

  //late String basicAuth = authController.getAuth();
  late String basicAuth = "Basic ZGV2ZWxvcGVyOmRldmVsb3Blcg==";
  late String serverAddress = state.serverAddress;

  @override
  Future<void> onInit() async {
    super.onInit();
    // инициализируем список уже имеющимися вложениями
    refreshObjectAttachList();
  }

  /// Обновляем список имеющихся у объекта вложений, перестраиваем компонент
  Future<void> refreshObjectAttachList() async {
    objectAttachList.value = _attachRepository.getAttachmentsByObjectId(basicAuth, serverAddress, this.objectId);
    update();
  }

  /// позволяет сформировать список файлов с ограничениями по расширению файлов
  void pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        // допустимые расширения выбираемых файлов
        // TODO: нужно вынести во входные параметры виджета
        allowedExtensions: ['doc', 'docx',  'xls', 'xlsx', 'pdf', 'txt', 'log']);

    if (result != null) {
      List<File> selectedFiles = result.paths.map((path) => File(path!)).toList();

      // см. комент к полю _files
      List<File> _files = <File>[];
      _files.addAll(selectedFiles);
      _attachRepository.sendObjectAttaches(_files.map((e) => fileToObjectAttach(e)).toList());

      // TODO: перечитаем репозиторий, для проверки просто сетим выбранные файлы напрямую
      // refreshObjectAttachList()
      //_objectAttachList.addAll(_files.map((e) => fileToObjectAttach(e)).toList());

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
      // refreshObjectAttachList();
      //_objectAttachList.addAll(_images.map((e) => fileXToObjectAttach(e)).toList());
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
      // refreshObjectAttachList();
      //_objectAttachList.addAll(_images.map((e) => fileXToObjectAttach(e)).toList());

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
    // refreshObjectAttachList();
    //_objectAttachList.remove(objectAttach);
    update();
  }

  /// Конвертация файла в объект для отправки на бэкенд
  ObjectAttach fileToObjectAttach(File file){
    return ObjectAttach(id: -1, objectId: objectId, fileName: file.path, filePath: file.path,
        attachmentData:"" ,createDate: DateTime.now(), workerName: authController.userInfo!.workerName??"Неизвестен");
  }

  /// Конвертация файла изображения в объект для отправки на бэкенд
  ObjectAttach fileXToObjectAttach(XFile xFile){
    return ObjectAttach(id:-1 , objectId: objectId, fileName:xFile.name, filePath:xFile.path,
        attachmentData:"", createDate: DateTime.now(), workerName: authController.userInfo!.workerName??"Неизвестен");
  }

  /// Скачивание файла на конечное устройство
  Future<void> downloadFile(ObjectAttach objectAttach, BuildContext context) async {
    FileManager.instance.downloadFile(objectAttach, context);
  }

  /// Конвертация Base64 -> Файл. Сохранение во временном каталоге, возвращает путь до файла
  Future<String> _createFileFromString(ObjectAttach objectAttach) async {
    Uint8List bytes = base64.decode(objectAttach.attachmentData);
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File(
        "$tempPath/" + objectAttach.fileName);
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Конвертация Файл -> Base64. Для передачи через GraphQL
  Future<String> _createStringFromFile(String path) async {
    File file = File(path);
    List<int> fileBytes = file.readAsBytesSync();
    return base64Encode(fileBytes);
  }

}
