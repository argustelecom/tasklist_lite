### Виджет раскрывающейся кнопки

* в основе лежит обычный floating action button + немного анимации
* параметризуется как
 this.initialOpen - состояние инициализации открыт/закрыта
 required this.distance - дальность радиуса по которому раскрываются дочерние кнопки
 required this.children - список виджетов типа action_button
 this.absorbParent - заготовка на функционал блокировки родительского виджета-контейнера

### Пример использования:
```dart
ExpandableFab(
                distance: 112.0,
                children: [
                  ActionButton(
                    onPressed: () => {_.pickImage()},
                    icon: const Icon(
                      Icons.panorama,
                      color: Colors.black,
                    ),
                  ),
                  ActionButton(
                    onPressed: () => {_.pickCamera()},
                    icon: const Icon(
                      Icons.camera,
                      color: Colors.black,
                    ),
                  ),
                  ActionButton(
                    onPressed: () => {_.pickFiles()},
                    icon: const Icon(
                      Icons.article_outlined,
                      color: Colors.black,
                    ),
                  ),
                ],
              )
````
