import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tasklist_lite/presentation/controllers/comment_controller.dart';
import 'package:tasklist_lite/presentation/controllers/tasklist_controller.dart';
import 'package:tasklist_lite/presentation/widgets/object_attach_widget/utils/file_converter.dart';
import 'package:tasklist_lite/presentation/widgets/object_attach_widget/utils/file_manager.dart';

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
class ObjectAttachController extends GetxController {
  /// Активный списоок аттачей для текущего выбранного объекта
  //final _objectAttachList = Future.value(<ObjectAttach>[]).obs;

  // объект для которого будут извлекаться/отправляться attach
  final int objectId;

  // заготовка на блокирование экрана при раскрытии кнопки "прикрепить файл"
  final _ignoring = false.obs;

  get ignoring => _ignoring.value;

  bool tuggleIgnoring() {
    _ignoring.value = !_ignoring.value;
    update();
    return _ignoring.value;
  }

  //TODO: Часть костылика, тоже надо будет убрать
  // Ищем коммент контроллер, что положить в него комментарий с файлом
  CommentController commentController = Get.find();

  // Ищем тасклист контроллер, чтобы взять из него текущий таск
  TaskListController taskListController = Get.find();

  //тут кончается кусок, который надо будет убрать

  // Предоставляет данные о текущих вложениях объекта
  AttachRepository _attachRepository = AttachRepository();

  // Список аттачей, которые сейчас приложены и ассоциированы с объектом аттача
  final objectAttachList = Future.value(<ObjectAttach>[]).obs;

  // список прикрепляемых файлов (пока не отказался от идеи держать файлы и изображения
  // в разных списках)
  List<File> _files = <File>[].obs;

  List<File> get files => _files;

  ObjectAttachController(this.objectId);

  @override
  Future<void> onInit() async {
    super.onInit();
    // инициализируем список уже имеющимися вложениями
    refreshObjectAttachList();
  }

  /// Обновляем список имеющихся у объекта вложений, перестраиваем компонент
  Future<void> refreshObjectAttachList() async {
    objectAttachList.value =
        _attachRepository.getAttachmentsByObjectId(this.objectId);
    update();
  }

  /// позволяет сформировать список файлов с ограничениями по расширению файлов
  Future<void> pickFiles() async {
    List<ObjectAttach>? oaList =
        await FileManager.instance.pickFiles(this.objectId);
    if (oaList != null) {
      await _attachRepository.sendObjectAttaches(oaList);
    }
    refreshObjectAttachList();

    // TODO: Убрать костыльную отправку коммента, когда перейдем на subscriptions
    objectAttachList.value.asStream().forEach((element) =>
        {commentController.addAttachComment(element.first.fileName)});
  }

  /// Позволяет запустить камеру, снимок прикладывается во вложения
  Future<void> pickCamera() async {
    final ImagePicker _picker = ImagePicker();

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      ObjectAttach attach =
          await FileConverter().fileXToObjectAttach(photo, this.objectId);
      await _attachRepository.sendObjectAttaches(List.filled(1, attach));
    } else {
      // пользователь отменил прикрепление фото
    }
    refreshObjectAttachList();
  }

  /// Позволяет сформировать список фотографий и изображений. Файлы достаются стредствами ОС
  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();

    List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      List<ObjectAttach> objectAttaches = [];
      ObjectAttach object;

      for (var i = 0; i < selectedImages.length; i++) {
        object = await FileConverter()
            .fileXToObjectAttach(selectedImages[i], this.objectId);
        objectAttaches.add(object);
      }

      await _attachRepository.sendObjectAttaches(objectAttaches);
    } else {
      // пользователь отменил прикрепление изображений
    }
    refreshObjectAttachList();
  }

  /// Удаление конкретного вложения
  Future<void> deleteAttach(ObjectAttach objectAttach) async {
    await _attachRepository.deleteObjectAttach(objectAttach);
    refreshObjectAttachList();
    // TODO: Убрать костыльную отправку коммента, когда перейдем на subscriptions
    objectAttachList.value.asStream().forEach((element) =>
        {commentController.addDeleteAttachComment(element.first.fileName)});
  }

  /// Скачивание файла на конечное устройство
  Future<void> downloadFile(
      ObjectAttach objectAttach, BuildContext context) async {
    ObjectAttach attach = await _attachRepository.getObjectAttach(objectAttach);
    FileManager.instance.downloadFile(attach, context);
  }
}
