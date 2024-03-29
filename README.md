## ImageFeed

Многостраничное приложение предназначено для просмотра изображений через API Unsplash.
Цели приложения:

- Просмотр бесконечной ленты картинок из Unsplash Editorial.
- Просмотр краткой информации из профиля пользователя.

<img src="https://github.com/shishmakovaDaria/Tracker/assets/114743567/0dc46974-f4e3-452f-bd23-933a46369bea" width="150">
<img src="https://github.com/shishmakovaDaria/Tracker/assets/114743567/af5dc797-fbc1-450b-98c9-ffa9dc36e4f5" width="150">
<img src="https://github.com/shishmakovaDaria/Tracker/assets/114743567/900bb4e2-5a6c-477a-8fd4-6c443b011a2b" width="150">
<img src="https://github.com/shishmakovaDaria/Tracker/assets/114743567/5c0d3ddc-d9a5-4d27-babe-8c245a1a665d" width="150">
<img src="https://github.com/shishmakovaDaria/Tracker/assets/114743567/69fd4ee4-9b1f-4ec8-8296-b678730aff43" width="150">

## Ссылки

- [Дизайн в Figma](https://tinyurl.com/image-feed-figma)
- [Unsplash API](https://unsplash.com/documentation)

## Описание приложения

- В приложении обязательна авторизация через OAuth Unsplash.
- Главный экран состоит из ленты с изображениями. Пользователь может просматривать ее, добавлять и удалять изображения из избранного.
- Пользователи могут просматривать каждое изображение отдельно и делиться ссылкой на них за пределами приложения.
- У пользователя есть профиль с избранными изображениями и краткой информацией о пользователе.
- У приложения есть две версии: расширенная и базовая. В расширенной версии добавляется механика избранного и возможность лайкать фотографии при просмотре изображения на весь экран.

## Стек технологий
- Swift
- UIKit
- MVP
- OAuth 2.0
- SPM
- KVO
- Kingfisher
- ProgressHUD
- WebKit
- SwiftKeychainWrapper
- AutoLayout programmatically
- REST API
- XCTest

## Технические требования

1. Авторизация работает через OAuth Unsplash и POST запрос для получения Auth Token.
2. Лента реализована с помощью UITableView.
3. В приложении использованы UImageView, UIButton, UILabel, TabBarController, NavigationController, NavigationBar, UITableView, UITableViewCell.
4. Приложение должно поддерживать устройства iPhone с iOS 13 или выше, предусмотрен только портретный режим.
5. Все шрифты в приложении — системные, не нужно их скачивать; в Interface Builder это шрифт «System» в выпадающем списке, а при вёрстке из кода — [`systemFont(ofSize:weight:)`](https://developer.apple.com/documentation/uikit/uifont/1619027-systemfont). В текущих версиях iOS (13—16) системный шрифт — это шрифт `SF Pro`, но в будущих версиях он может поменяться.

## Функциональные требования

- Авторизация через OAuth.
- Просмотр ленты (пользователь может просматривать изображения в ленте, переходить к просмотру отдельного изображения и добавлять их в избранное).
- Просмотр изображения на весь экран (из ленты пользователь может перейти к просмотру изображения на весь экран и поделиться им).
- Просмотр профиля пользователя (пользователь может перейти в свой профиль, чтобы посмотреть данные профиля или выйти из него).
