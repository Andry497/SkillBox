﻿
&НаСервере
Процедура СоздатьДокументПоступлениеНаСервере() 
	
	Если Объект.Контрагент.Пустая() 
		ИЛИ Объект.Договор.Пустая() 
		ИЛИ Объект.Склад.Пустая() 
		ИЛИ Объект.Валюта.Пустая()
		ИЛИ ИтогСумма = 0 Тогда
		Сообщить("Документ не может быть создан! Данные не заполнены!");
	Иначе
		НовыйДокумент = Документы.ПоступлениеТоваров.СоздатьДокумент();
		НовыйДокумент.Дата = ТекущаяДата();
		НовыйДокумент.Поставщик = Объект.Контрагент; 
		НовыйДокумент.Договор   = Объект.Договор; 
		НовыйДокумент.Склад     = Объект.Склад; 
		НовыйДокумент.Валюта    = Объект.Валюта; 
		НовыйДокумент.ВидЦены   = ВидЦены; 
		НовыйДокумент.ИтогСумма = ИтогСумма;  
		
		Для Каждого ТекСтрокаТовары ИЗ  ТаблицаНоменклатуры Цикл
			Строка = НовыйДокумент.Товары.Добавить(); 
			Строка.Номенклатура = ТекСтрокаТовары.Номенклатура;
			Строка.Количество   = ТекСтрокаТовары.Количество;
			Строка.Цена         = ТекСтрокаТовары.Цена;
			Строка.Стоимость    = ТекСтрокаТовары.Стоимость;
		КонецЦикла;
		
		Если СразуПроводитьДокумент Тогда
			НовыйДокумент.Записать(РежимЗаписиДокумента.Проведение);
		Иначе
			НовыйДокумент.Записать();
		КонецЕсли;
		
		ТаблицаНоменклатуры.Очистить();
		ИтогСумма = 0;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СоздатьДокументРеализацияНаСервере() 
	
	Если Объект.Контрагент.Пустая() 
		ИЛИ Объект.Договор.Пустая() 
		ИЛИ Объект.Склад.Пустая() 
		ИЛИ Объект.Валюта.Пустая()
		ИЛИ ИтогСумма = 0 Тогда
		Сообщить("Документ не может быть создан! Данные не заполнены!");
	Иначе
		НовыйДокумент = Документы.РеализацияТоваров.СоздатьДокумент();
		НовыйДокумент.Дата = ТекущаяДата();
		НовыйДокумент.Покупатель = Объект.Контрагент; 
		НовыйДокумент.Договор   = Объект.Договор; 
		НовыйДокумент.Склад     = Объект.Склад; 
		НовыйДокумент.Валюта    = Объект.Валюта; 
		НовыйДокумент.ВидЦены   = ВидЦены; 
		НовыйДокумент.ИтогСумма = ИтогСумма;  
		
		Для Каждого ТекСтрокаТовары ИЗ  ТаблицаНоменклатуры Цикл
			Строка = НовыйДокумент.Товары.Добавить(); 
			Строка.Номенклатура = ТекСтрокаТовары.Номенклатура;
			Строка.Количество   = ТекСтрокаТовары.Количество;
			Строка.Цена         = ТекСтрокаТовары.Цена;
			Строка.Стоимость    = ТекСтрокаТовары.Стоимость;
		КонецЦикла;
		
		Если СразуПроводитьДокумент Тогда
			НовыйДокумент.Записать(РежимЗаписиДокумента.Проведение);
		Иначе
			НовыйДокумент.Записать();
		КонецЕсли;
		
		ТаблицаНоменклатуры.Очистить();;
		ИтогСумма = 0;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СоздатьДокумент(Команда) 
	
	Если ПоступлениеТоваров = Истина Тогда
		СоздатьДокументПоступлениеНаСервере();
	ИначеЕсли 	
		РеализацияТоваров = Истина Тогда
		СоздатьДокументРеализацияНаСервере();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНаСервере()
	
	ТаблицаНоменклатуры.Очистить();
	
	//Получить текстовый документ
	Документ = Новый ТекстовыйДокумент;
	Документ.Прочитать(Объект.ПутьКФайлу); 
	
	//Построчный обход текстового документа со второй строки (исключая шапку) по последнюю строку документа
	Для НомерСтроки = 2 По Документ.КоличествоСтрок() Цикл
		
		//Получить строку документа
		СтрокаДокумента = Документ.ПолучитьСтроку(НомерСтроки);
		
		//Разложим каждое значение разделенное ; в массив (разделим строку на элементы)
		МассивЗначенийСтроки = СтрРазделить(СтрокаДокумента, ";");
		
		//Получить значения массива
		Номенклатура  = МассивЗначенийСтроки [0];
		Количество    = МассивЗначенийСтроки [1];
		Цена          = МассивЗначенийСтроки [2];
		Стоимость     = МассивЗначенийСтроки [3];
		
		//Проверяем есть ли такая номенклатура в справочнике    Если склад есть, возвнащается ссылка иначе Не заполнено
		СсылкаНаНоменклатуру = Справочники.Номенклатура.НайтиПоНаименованию(Номенклатура);  
		
		//если номенклатура есть - Добавляем в таблицу, иначе выводим сообщение и пропускаем
		Если ЗначениеЗаполнено(СсылкаНаНоменклатуру) Тогда 
			
			Строка = ТаблицаНоменклатуры.Добавить(); 
			Строка.Номенклатура = СсылкаНаНоменклатуру;
			Строка.Количество   = Количество;
			Строка.Цена         = Цена;
			Строка.Стоимость    = Стоимость;
		Иначе 
			Сообщить ("Номенклатура - " + Номенклатура + ", строка CSV файла - " + (НомерСтроки - 1) + ", отсутствует в справочнике!");
			Продолжить; //Возвращаем выполнение кода в начало цикла. (переходим к следующей строке)
		КонецЕсли;
	КонецЦикла; 
	
	ИтогСумма = ТаблицаНоменклатуры.Итог("Стоимость");
	ВидЦены   = Справочники.ВидыЦен.ИзЗагрузки;

КонецПроцедуры

&НаКлиенте
Процедура Заполнить(Команда)
	ЗаполнитьНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ПутьКФайлуНачалоВыбора(Элемент, ДанныеВыбора, ВыборДобавлением, СтандартнаяОбработка)
	
	Режим = РежимДиалогаВыбораФайла.Открытие;
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(Режим); 
	ДиалогОткрытияФайла.ПолноеИмяФайла = "";
	Фильтр = НСтр("ru = 'Выберите CSV файл'")
	+ "(*.csv)|*.csv";
	ДиалогОткрытияФайла.Фильтр = Фильтр; 
	ДиалогОткрытияФайла.МножественныйВыбор = Ложь;
	ДиалогОткрытияФайла.Заголовок = "Выберите CSV файл";
	
	Если ДиалогОткрытияФайла.Выбрать() Тогда
		Объект.ПутьКФайлу = ДиалогОткрытияФайла.ПолноеИмяФайла;	
	КонецЕсли;		
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ПоступлениеТоваров = Истина;
	РеализацияТоваров = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ПоступлениеТоваровПриИзменении(Элемент)  
	Если ПоступлениеТоваров = Истина Тогда
		РеализацияТоваров = Ложь;
	Иначе	
		РеализацияТоваров = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура РеализацияТоваровПриИзменении(Элемент) 
	Если РеализацияТоваров = Истина Тогда
		ПоступлениеТоваров = Ложь;
	Иначе	
		ПоступлениеТоваров = Истина;
	КонецЕсли;
КонецПроцедуры

