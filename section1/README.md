# Задание по теории тестирования

## Предварительные слова

В данном документе описана стратегия тестирования web интернет-магазина. 
Основная цель - обеспечить высокое качество продукта, 
минимизировать риски и соответствовать требованиям пользователей.

Для наглядности использовались UML-диаграммы, сгенерированные такой доброй
программой как [plantuml](https://plantuml.com/).

### Архитектура приложения

**Фукнционал**:
- каталог товаров
- корзина
- оформление заказа
- выбор способа доставки
- оплата (сторонний сервис API)

<!--
@startuml architecture.svg

skinparam monochrome true
skinparam shadowing false
skinparam defaultFontName "Arial"
skinparam defaultFontSize 12

database "База данных" as db {
    folder "Товары" as products
        folder "Пользователи" as users
        folder "Заказы" as orders
}

package "Внешние сервисы" {
    cloud "Платежный шлюз" as payment
    cloud "Служба доставки" as delivery
}

package "frontend" {
    component "Пользовательский интерфейс" as ui
}

package "backend"{
    component "Бизнес логика" as server
    component "Система аутентификации" as auth
    
    ui \-\-> server : HTTP/HTTPS
    server \-\-> db : SQL
    server \-\-> payment : API
    server \-\-> delivery : API
    ui \-\-> auth : Auth request
    auth \-\-> db : Verify credentials
}

note bottom of db
  <b>Структура БД:</b>
  - Товары (Артикул, цена, описание)
  - Пользователи (логин, хеш пароля)
  - Заказы (статус, история)
end note

note bottom of payment
  <b>Интеграция:</b>
  Поддержка МИР и других систем
  через REST API
end note

note right of delivery
    <b>Интеграция:</b>
    Почта России, ПВЗ маркетплейсов,
    5posts, CDEK
end note

@enduml
-->

![Схема приложения](UML/architecture.svg)

### Схема интеграции с платежной системой

<!--
```plantuml
skinparam monochrome true
skinparam shadowing false
skinparam defaultFontName "Arial"
skinparam defaultFontSize 12

@startuml payment_integration_schema.svg
actor Пользователь as user
participant "Интернет-магазин" as app
participant "Платёжная система" as payment
participant Банк as bank

user -> app: Оплата заказа
app -> payment: Запрос на транзакцию
payment -> bank: Проверка карты
bank -> payment: Ответ
payment -> app: Статус оплаты
app -> user: Подтверждение

@enduml
```
-->

![Схема интеграции](UML/payment_integration_schema.svg)

#### Жизненный цикл заказа

<!--
@startuml order_lifecycle.svg

skinparam monochrome false
skinparam shadowing true
skinparam defaultFontName "Segoe UI"
skinparam defaultFontSize 13
skinparam roundcorner 15
skinparam ArrowColor #444444
skinparam ArrowFontStyle bold
skinparam ArrowFontSize 11

start
: **1. Добавление товаров**;
note right #FFEBCD
  <b>Действия пользователя:</b>
  - Выбор товаров
  - Указание количества
  - Просмотр итоговой суммы
end note

: **2. Оформление заказа**;
note right #E6F3FF
  <b>Заполняемые данные:</b>
  - Контактная информация
  - Адрес доставки
  - Способ оплаты
  - Комментарии к заказу
end note

if (**3. Оплата успешна?**) then (Да)
  : **4. Подтверждение заказа**;
  note right #D5E8D4
    <b>Системные действия:</b>
    - Генерация номера заказа
    - Отправка email-уведомления
    - Создание записи в БД
  end note
  
  : **5. Передача в доставку**;
  note right #CCE5FF
    <b>Интеграция:</b>
    - Формирование транспортной накладной
    - Синхронизация с API службы доставки
    - Обновление статуса в системе
  end note
  
  : **6. Доставка клиенту**;
  note right #E5FFCC
    <b>Варианты:</b>
    - Курьерская доставка
    - Пункт выдачи
    - Постамат
    - Самовывоз
  end note
  
  stop
else (Нет)
  : **4. Ошибка оплаты**;
  note right #F8CECC
    <b>Возможные причины:</b>
    - Недостаточно средств
    - Отказ банка
    - Техническая ошибка
    - Истек срок действия карты
  end note
  
  : **5. Возврат в корзину**;
  note right #FFDDCC
    <b>Состояние:</b>
    - Товары сохранены
    - Данные формы частично заполнены
    - Предложение альтернативных способов оплаты
  end note
  
  stop
endif

@enduml
-->

![Жизненный цикл заказа](UML/order_lifecycle.svg)

### Сроки

**Альфа-версия**: через 2 недели.

**Релиз**: через 12 недель.

**Поддержка**: в течение 4 недель после релиза.

### Методология разработки и тестирования

Судя по всему, команда разработки данного приложения состоит из
небольшого числа специалистов и, видимо, одного QA-инженера, в роли
которого я и выступаю. В связи с весьма сжатыми сроками разработки
и видимой скромностью проекта, можно избрать
такую методологию разработки, как `Scrum`. `Scrum` в данном случае хорошо 
подходит, так как он позволяет весьма уверенно планировать сроки релиза,
а наличие лишь одной команды разработчиков нивелирует главные минусы `Scrum`.

Наиболее подходящая длина итерации 2 недели. После первой итерации -
релиз Альфа-версии. В течение итерации разработчиками создаются Unit-тесты, 
покрывающий новый функционал. QA-инженер в соотвествии с целями на спринт
разрабатывает тесты более высоких уровней (по пирамиде тестирования), а также
прорабатывает регрессионные тесты, `new-bug-fix` и `olg-bug-fix`. На разных 
этапах разработки тестирование будет отличаться, но об этом мы поговорим далее.

### Стратегия тестирования.

**Пирамида тестирования**:
1. *Unit-тесты* (`White box`): реализуются разработчиками, начиная с самых ранних
этапов разработки приложения.
2. *Интеграционные тесты* (`Gray box`): взаимодействие внутренних 
компонент приложения.
3. *System-тесты* (`Gray/Black box`): `API`, взаимодействие с сервисами 
оплаты и доставки.
4. *End-to-End тесты* (`Black box`): ручные + автоматизация.

<!--
```plantuml
@startuml testing_components.svg
rectangle "Unit тесты" as unit
rectangle "Интеграционные тесты" as integration
rectangle "Системные тесты" as system
rectangle "E2E тесты" as e2e

unit \-\-> integration
integration \-\-> system
system \-\-> e2e

note right of unit: Разрабатываются программистами
note right of integration: Mock-объекты для внешних сервисов.
note right of e2e: Автоматизация + ручное тестирование
@enduml
```
-->

![Пирамида тестирования](UML/testing_components.svg)

## Тестирование понедельно

### Недели 1-2. Подготовка. (Спринт 1)

**Цели**:
- **Разработка**: выпустить MVP (Minimal Viable Product).
- **Тестировка**: проанализировать требования, выстроить приоритеты, сформулировать
стретегию тестирования, разработать тесты для альфа-версии.

#### Анализ требований и тестовая документация

Для выстраивания тестирования будет недостаточно списка функционала
приложения, следовательно, требуется уточнение у команды разработчиков
и у закзчика:
- На чём специализируется интернет-магазин?
- Какие конкретно действия могут производить админ, модератор
и пользователь сайта в каталоге товаров?
- Какие функции доступны в каталоге (например, фильтрация, поиск,
сортировка)?
- Что можно делать с конкретным товаром (удаление, доабвление в 
корзину/избранное оценка, отзыв и т.д.)
- Какой сервис используется для оплаты?
- Строгость валидации данных пользователя?
- С какими сервисами доставки планируется интеграция?

Писать поноценную спецификацию требований затратно и в условиях
столь сжатых сроков для выпуска альфа-версии может быть невыполнимо.
Поэтому в качестве основы можно избрать формат `User Stories`. Но 
в чистом виде такой формат имеет существенные недостатки:
- чисто технические требования останутся непокрытыми
- граничные случаи могут быть нерассмотрены
- тестировщикам придётся зачастую додумывать требования, что увеличивает
число потенциальных багов
- проблемы с масштабированием.
Также такие критические аспекты, как оплата и доставка, определенно
должны быть хорошо задукоментированными.

Поэтому к `User Stories` необходимо добавить `Acceptance Criteria`, то есть
конкретные условия, при которых US как сценарий считается исполненной.
В подкреплении к AC могут идти BDD-сценарии (Given-When-Then) 
и диаграммы процессов.

Очевидно осуществить всё это к выпуску Альфа-версии сложно, да 
и нет необходимости, поэтому будем осуществлять уточнение документации
постепенно (в целом не очень строгое, следуя философии `Agile`):
1. Альфа-версия(1-2 недели): US + немного CA.
2. Релиз (3-12 недели): Технические спецификации для интеграция,
формализация требований.
3. Поддержка (13-16 недели): обновление документации при добавлении функционала.

Пример документации:

```
1. User Story:  
Как покупатель, я хочу оплатить заказ картой, чтобы завершить покупку.  
AC:  
- Поддерживаются карты Мир, Mastercard.  
- При ошибке оплаты корзина сохраняется.  
- Данные карты передаются через HTTPS.  

2. Технические требования к платежному шлюзу:  
- API-метод: POST /api/payment.
- Поля запроса: card_number, expiry_date, cvv.  
- Ожидаемые коды ответов: 500 (успех), 600 (невалидные данные), 700 (ошибка сервера).  

3. Нефункциональные требования:  
- Время обработки платежа ≤ 6 сек.  
- Совместимость с Chrome, Firefox, Safari, Arc, Yandex Browser, Opera.
```

#### Приоритезация 

1. Сервис оплаты.
2. Оформление заказа.
3. Корзина.
4. Каталог товаров.

Продвинутый пользовательский интерфейс и расширенный функционал корзины пока 
остаеются за кадром.

#### Проектирование тестов

1. Со стороны разработчиков должны предоставляться Unit-тесты
для всего функционала, но мы не звери, поэтому сразу полного тестового
покрытия просить не будем.
2. Smoke-тестирование хорошо подойдёт для проверки минимальной 
работоспособности альфа-версии. Corner-кейсы и UI имеют второстепенное значение.
3. Интеграционные тесты (API корзины, каталога, оформление заказа, оплата с
использованием mock-объектов)
4. Системные тесты включают в себя на данном этапе только проверку
работоспособности оплаты товаров. В качестве инструмента можно использовать
`Postman`.

#### Тест-дизайн

Здесь применимы базовые методы тест-дизайна, такие как 
эквивалентное разделение (например, на валидные и невалидные номера карт в оплате
или то же самое для личных данных пользователя), проверка граничных значений
(например, максимальное и минимальное количество одного товара в корзине или то же
самое для количества товаров в корзине в целом), техника "причина и следствие".

#### Управление рисками

- требования могут не столь быстро стать чёткими, придётся много общаться с командой
и заказчиком.
- нестабильность API платежной системы и API проекта в целом, особенно
на первых порах. Из-за этого часть написанных тестов, возможно, будет в итоге
неактуальными. Произойдёт это или нет зависит от того, насколько хорошо
будет прописана документация.

### Недели 3-12 (спринты 2-6). Подготовка к релизу.

#### Цели и акценты

Целью, очевидно, является доведение проекта до релизного состояния, то есть 
нужно проработать UI и в целом безопастность и 
удобство пользования сайтом, адаптировать его под разные браузеры и разные
устройства. А это всё связано напрямую с минимизацией
количества багов, быстродействием и обработкой критических ситуаций. С точки зрения
тестировщика необходимо обеспечить достойное тестовое покрытие всего функционала,
проработанную пирамиду тестирования и полную документацию.

#### Функциональное тестирование

1. **Unit-тесты** всего функционала:

    + *Каталог*:
        - Вывод по категориям
        - Поиск
        - Фильтрация
        - Рекомендации
        - Корректное разделение на страницы

    + *Корзина*:
        - Удаление
        - Дубликация товара
        - Сохранение
        - Выбор всех/части товаров
2. **Регрессионное тестирование** производится после очередной итерации для проверки
корректности работы всего старого функционала. 

3. **Интеграционное и системное тестирование** нового функционала, а также нового
и старого функционала вместе. Сверх того, на более поздних этапах разработки
можно тестировать работу приложения в различных браузерах.

- Поведение корзины после оплаты (некоректной)
- Валидация данных карты/кошелька
- Выбор и валидация выбора способа доставки (сообщение с сервисами доставки)

4. **Тестирование UI и E2E тесты** проводятся для проверки корректности работы
приложения в целом. Здесь можно применять как ручной подход, так и автоматизацию
с использованием, например, `Selenium`.

- Обработка ошибок
- Адаптивность дизайна
- Регистрация нового пользователа
- Авторизация
- Проверка поиска товара по ключевому слову
- Восстановление пароля

#### Нефункциональное тестирование

1. **Нагрузочное тестирование** крайне важно для нашего приложения, так как
потенциально его будут ежедневно посещать тысячи, сотни тысяч и т.д. пользователей.
Для нагрузки приложения можно использовать Apache Jmeter, Gatling, Locust и многое
другое. Необходимо ещё тестировать скорость взаимодействия с банковской системой.

2. **Тесты безопасности** должны проверить приложение на уязвимости к SQL-инъекциям,
DDoS-атакам платёжных систем.

3. **Usabilty-аудит** как способ оценить удобство использования UI.

#### Подготовка плана отката

Необходимо подготовить реплики баз данных с системой автоматического резервного
копирования, а также проработать сценарии отключения платёжного шлюза. Здесь
требуется работа DevOps-специалиста. Данные решения также необходимо
провести функциональное, а также нагрузочное тестирование.

### Недели 13-16. После релиза.

**Цели**: быстрое реагирование на выявляющиеся дефекты, сбор и анализ данных
по работе приложения и по действиям пользователей.

#### Методология

На данном этапе можно отказаться от методологии `Scrum` в пользу
`Kanban`, как гибкой методолгии, допускающей быстрое реагирование на баги.

Время реагирования на критические ошибки, такие как систематические сбои оплаты
или утечки данных пользователей, должны решаться в сроки порядка часа.

#### Мониторинг и анализ UX.

Для мониторинга приложения можно использовать такой сервис, как Senry, который
позволяет собирать данные об ошибках пользовательского интерфейса, API и платежной
системы, и Lighthouese, с помощью которого можно произвести аудит
производительности и доступности web-ресурса. Для расчёта конверсии сайта можно
использовать Google Analytics.

Для повышения показателей конверсии сайта можно использовать
A/B-тестирование на элементах графического интерфейса приложения.

Помимо этого можно использовать формы обратной связи, а также Usability-тесты.

#### Тестирование

1. Регрессионные тесты. `old/new-bug-fix` при исправлении возникающих на данном
этапе ошибок.
2. Ведение базы данных багов в Jira.

