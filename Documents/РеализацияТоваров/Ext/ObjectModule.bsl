﻿
Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
		Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказКлиента") Тогда
		// Заполнение шапки
		Валюта = ДанныеЗаполнения.Валюта;
		Договор = ДанныеЗаполнения.Договор;
		ИтогСумма = ДанныеЗаполнения.ИтогСумма;
		Покупатель = ДанныеЗаполнения.Покупатель;
		ВидЦены =  ДанныеЗаполнения.ВидЦены;
		Склад = ДанныеЗаполнения.Склад;
		Для Каждого ТекСтрокаТовары Из ДанныеЗаполнения.Товары Цикл
			НоваяСтрока = Товары.Добавить();
			НоваяСтрока.Количество = ТекСтрокаТовары.Количество;
			НоваяСтрока.Номенклатура = ТекСтрокаТовары.Номенклатура;
			НоваяСтрока.Стоимость = ТекСтрокаТовары.Стоимость;
			НоваяСтрока.Цена = ТекСтрокаТовары.Цена;
		КонецЦикла;
	КонецЕсли;
	
	//{{__КОНСТРУКТОР_ВВОД_НА_ОСНОВАНИИ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	//}}__КОНСТРУКТОР_ВВОД_НА_ОСНОВАНИИ
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
	УчетПоПартиям = ПолучитьФункциональнуюОпцию("УчетПоПартиям");
	Курс = РасчетыСервер.РасчетКурсаВалюты(Дата, Валюта);
	
	Если Курс = 0 Тогда
		Сообщить ("Курс валюты: " + Валюта + " на " + Дата + " не установлен.");
		Отказ = Истина;
	Иначе
		Движения.ТоварыНаСкладах.Записывать = Истина;
		Движения.ТоварыНаСкладах.Записать();
		
		//Получить текущий метод списания себестоимости
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	МетодыСписанияСебестоимостиСрезПоследних.МетодСписания КАК МетодСписания
		|ИЗ
		|	РегистрСведений.МетодыСписанияСебестоимости.СрезПоследних(&Дата, ) КАК МетодыСписанияСебестоимостиСрезПоследних";
		
		Запрос.УстановитьПараметр("Дата", Дата);
		
		РезультатЗапроса = Запрос.Выполнить();
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		ВыборкаДетальныеЗаписи.Следующий();	
		МетодСписания = ВыборкаДетальныеЗаписи.МетодСписания;
		
		// регистр ТоварыНаСкладах
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	РеализацияТоваровТовары.Номенклатура КАК Номенклатура,
		|	СУММА(РеализацияТоваровТовары.Количество) КАК Количество,
		|	СУММА(РеализацияТоваровТовары.Стоимость) КАК Стоимость
		|ПОМЕСТИТЬ ВТ_ДокТЧ
		|ИЗ
		|	Документ.РеализацияТоваров.Товары КАК РеализацияТоваровТовары
		|ГДЕ
		|	РеализацияТоваровТовары.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	РеализацияТоваровТовары.Номенклатура
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ДокТЧ.Номенклатура КАК Номенклатура,
		|	ВТ_ДокТЧ.Номенклатура.Представление КАК НоменклатураПредставление,
		|	ВТ_ДокТЧ.Количество КАК Количество,
		|	ВТ_ДокТЧ.Стоимость КАК Стоимость,
		|	ЕСТЬNULL(ТоварыНаСкладахОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток,
		|	ЕСТЬNULL(ТоварыНаСкладахОстатки.СтоимостьОстаток, 0) КАК СтоимостьОстаток,
		|	ЕСТЬNULL(ТоварыНаСкладахОстатки.Партия, 0) КАК Партия
		|ИЗ
		|	ВТ_ДокТЧ КАК ВТ_ДокТЧ
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыНаСкладах.Остатки(
		|				&МоментВремени,
		|				Номенклатура В
		|						(ВЫБРАТЬ
		|							ВТ_ДокТЧ.Номенклатура КАК Номенклатура
		|						ИЗ
		|							ВТ_ДокТЧ КАК ВТ_ДокТЧ)
		|					И Склад = &Склад) КАК ТоварыНаСкладахОстатки
		|		ПО ВТ_ДокТЧ.Номенклатура = ТоварыНаСкладахОстатки.Номенклатура
		|ГДЕ
		|	ТоварыНаСкладахОстатки.КоличествоОстаток > 0
		|
		|УПОРЯДОЧИТЬ ПО
		|	Партия УБЫВ
		|ИТОГИ
		|	МАКСИМУМ(Количество),
		|	МАКСИМУМ(Стоимость),
		|	СУММА(КоличествоОстаток),
		|	СУММА(СтоимостьОстаток)
		|ПО
		|	Номенклатура";
		
		Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
		Запрос.УстановитьПараметр("Склад", Склад);
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		
		Если МетодСписания = Перечисления.МетодыСписанияСебестоимости.FIFO Тогда  //Проверка способа списания
			Запрос.Текст = СтрЗаменить(Запрос.Текст,"Партия УБЫВ","Партия");
		КонецЕсли;
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		
		Пока ВыборкаНоменклатура.Следующий() Цикл
			
			Если ВыборкаНоменклатура.Количество > ВыборкаНоменклатура.КоличествоОстаток Тогда
				Сообщить ("ОУ: Недостаточно товара: " + ВыборкаНоменклатура.НоменклатураПредставление  + " на складе - " + Склад + "! Недостает " + (ВыборкаНоменклатура.Количество - ВыборкаНоменклатура.КоличествоОстаток) + "шт.");
				Отказ = Истина;
			КонецЕсли;
			
			Если НЕ Отказ Тогда  
				Если 	УчетПоПартиям = Истина Тогда        //Проверка учета по партиям
					ВыборкаДетальныеЗаписи = ВыборкаНоменклатура.Выбрать();
					
					ОсталосьСписать = ВыборкаНоменклатура.Количество; 
					
					Пока ВыборкаДетальныеЗаписи.Следующий() И ОсталосьСписать > 0 Цикл
						Движение = Движения.ТоварыНаСкладах.Добавить();
						Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
						Движение.Период = Дата;
						Движение.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура; 
						Движение.Склад = Склад; 
						Движение.Количество = Мин(ОсталосьСписать, ВыборкаДетальныеЗаписи.КоличествоОстаток); 
						Движение.Партия = ВыборкаДетальныеЗаписи.Партия; 
						Если Движение.Количество = ВыборкаДетальныеЗаписи.КоличествоОстаток Тогда
							Движение.Стоимость = ВыборкаДетальныеЗаписи.СтоимостьОстаток;
						Иначе	 
							Движение.Стоимость = ВыборкаДетальныеЗаписи.СтоимостьОстаток / ВыборкаДетальныеЗаписи.КоличествоОстаток * Движение.Количество; 
						КонецЕсли; 
						ОсталосьСписать = ОсталосьСписать - Движение.Количество;
					КонецЦикла;
				Иначе	
					Движение = Движения.ТоварыНаСкладах.Добавить();
					Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
					Движение.Период = Дата;
					Движение.Номенклатура = ВыборкаНоменклатура.Номенклатура; 
					Движение.Склад = Склад; 
					Движение.Количество = ВыборкаНоменклатура.Количество; 
					Если Движение.Количество = ВыборкаНоменклатура.КоличествоОстаток Тогда
						Движение.Стоимость = ВыборкаНоменклатура.СтоимостьОстаток;
					Иначе	 
						Движение.Стоимость = ВыборкаНоменклатура.СтоимостьОстаток / ВыборкаНоменклатура.КоличествоОстаток * ВыборкаНоменклатура.Количество; 
					КонецЕсли; 
				КонецЕсли;
			КонецЕсли;	
		КонецЦикла; 
		
		
		//БУ
		Движения.Хозрасчетный.Записывать = Истина;
		Движения.Хозрасчетный.Записать();
		
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	РеализацияТоваровТовары.Номенклатура КАК Номенклатура,
		|	СУММА(РеализацияТоваровТовары.Количество) КАК Количество,
		|	СУММА(РеализацияТоваровТовары.Стоимость) КАК Стоимость
		|ПОМЕСТИТЬ ВТ_ДокТЧ
		|ИЗ
		|	Документ.РеализацияТоваров.Товары КАК РеализацияТоваровТовары
		|ГДЕ
		|	РеализацияТоваровТовары.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	РеализацияТоваровТовары.Номенклатура
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ЕСТЬNULL(ХозрасчетныйОстаткиПоВсем.КоличествоОстатокДт, 0) КАК КоличествоОстатокПоВсем,
		|	ЕСТЬNULL(ХозрасчетныйОстаткиПоВсем.СуммаОстатокДт, 0) КАК СуммаОстатокПоВсем,
		|	ВТ_ДокТЧ.Номенклатура КАК Номенклатура,
		|	ВТ_ДокТЧ.Номенклатура.Представление КАК НоменклатураПредставление,
		|	ВТ_ДокТЧ.Количество КАК Количество,
		|	ВТ_ДокТЧ.Стоимость КАК Стоимость,
		|	ЕСТЬNULL(ХозрасчетныйОстаткиПоСкл.КоличествоОстатокДт, 0) КАК КоличествоОстатокПоСкл,
		|	ХозрасчетныйОстаткиПоСкл.Субконто3 КАК Субконто3
		|ИЗ
		|	ВТ_ДокТЧ КАК ВТ_ДокТЧ
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Хозрасчетный.Остатки(
		|				&МоментВремени,
		|				Счет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.ТоварыНаСкладах),
		|				&СубконтоТовары,
		|				Субконто1 В
		|					(ВЫБРАТЬ РАЗЛИЧНЫЕ
		|						ВТ_ДокТЧ.Номенклатура КАК Номенклатура
		|					ИЗ
		|						ВТ_ДокТЧ КАК ВТ_ДокТЧ)) КАК ХозрасчетныйОстаткиПоВсем
		|		ПО ВТ_ДокТЧ.Номенклатура = ХозрасчетныйОстаткиПоВсем.Субконто1
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Хозрасчетный.Остатки(
		|				&МоментВремени,
		|				Счет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.ТоварыНаСкладах),
		|				&СубконтоТовары,
		|				Субконто1 В
		|						(ВЫБРАТЬ РАЗЛИЧНЫЕ
		|							ВТ_ДокТЧ.Номенклатура КАК Номенклатура
		|						ИЗ
		|							ВТ_ДокТЧ КАК ВТ_ДокТЧ)
		|					И Субконто2 = &Склад) КАК ХозрасчетныйОстаткиПоСкл
		|		ПО ВТ_ДокТЧ.Номенклатура = ХозрасчетныйОстаткиПоСкл.Субконто1
		|ГДЕ
		|	ХозрасчетныйОстаткиПоСкл.КоличествоОстатокДт > 0
		|ИТОГИ
		|	МАКСИМУМ(КоличествоОстатокПоВсем),
		|	МАКСИМУМ(СуммаОстатокПоВсем),
		|	МАКСИМУМ(Количество),
		|	МАКСИМУМ(Стоимость),
		|	СУММА(КоличествоОстатокПоСкл)
		|ПО
		|	Номенклатура";
		
		СубконтоТовары = Новый Массив();
		СубконтоТовары.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура);
		СубконтоТовары.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Склады);
		СубконтоТовары.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Партии);
		
		Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
		Запрос.УстановитьПараметр("Склад", Склад);
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Запрос.УстановитьПараметр("СубконтоТовары", СубконтоТовары);
		
		РезультатЗапроса = Запрос.Выполнить(); 
		ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		
		Пока ВыборкаНоменклатура.Следующий() Цикл
			Если ВыборкаНоменклатура.Количество > ВыборкаНоменклатура.КоличествоОстатокПоСкл Тогда
				Сообщить ("БУ: Недостаточно товара " + ВыборкаНоменклатура.НоменклатураПредставление  + " на складе - " + Склад + "! Недостает "	+ (ВыборкаНоменклатура.Количество - ВыборкаНоменклатура.КоличествоОстатокПоСкл) + "шт.");
				Отказ = Истина;
			КонецЕсли;
			
			Себестоимость1шт = ВыборкаНоменклатура.СуммаОстатокПоВсем / ВыборкаНоменклатура.КоличествоОстатокПоВсем;
			
			Если НЕ Отказ Тогда 
				
				Если 	УчетПоПартиям = Истина Тогда        //Проверка учета по партиям
					ОсталосьСписать = ВыборкаНоменклатура.Количество;
					ВыборкаДетальныеЗаписи = ВыборкаНоменклатура.Выбрать();
					Пока ВыборкаДетальныеЗаписи.Следующий() И ОсталосьСписать > 0 Цикл 
						Движение = Движения.Хозрасчетный.Добавить();
						Движение.СчетДт = ПланыСчетов.Хозрасчетный.СебестоимостьПродаж;
						Движение.СчетКт = ПланыСчетов.Хозрасчетный.ТоварыНаСкладах;
						Движение.Период = Дата;
						Движение.КоличествоКт = мин(ОсталосьСписать,ВыборкаДетальныеЗаписи.КоличествоОстатокПоСкл);
						Если  Движение.КоличествоКт = ВыборкаДетальныеЗаписи.КоличествоОстатокПоВсем Тогда
							Движение.Сумма = ВыборкаДетальныеЗаписи.СуммаОстатокПоВсем;
						Иначе
							Движение.Сумма = Движение.КоличествоКт * Себестоимость1шт; 
						КонецЕсли; 
						Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаДетальныеЗаписи.Номенклатура;
						Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаДетальныеЗаписи.Номенклатура;
						Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Склады] = Склад;
						Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Партии] = ВыборкаДетальныеЗаписи.Субконто3; 
						ОсталосьСписать = ОсталосьСписать - Движение.КоличествоКт;
					КонецЦикла; 
				Иначе
					Движение = Движения.Хозрасчетный.Добавить();
					Движение.СчетДт = ПланыСчетов.Хозрасчетный.СебестоимостьПродаж;
					Движение.СчетКт = ПланыСчетов.Хозрасчетный.ТоварыНаСкладах;
					Движение.Период = Дата;
					Движение.КоличествоКт = ВыборкаНоменклатура.Количество;
					Если  Движение.КоличествоКт = ВыборкаНоменклатура.КоличествоОстатокПоВсем Тогда
						Движение.Сумма = ВыборкаНоменклатура.СуммаОстатокПоВсем;
					Иначе
						Движение.Сумма = Движение.КоличествоКт * Себестоимость1шт; 
					КонецЕсли; 
					Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаНоменклатура.Номенклатура;
					Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаНоменклатура.Номенклатура;
					Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Склады] = Склад;
				КонецЕсли;
			КонецЕсли;	
		КонецЦикла;
		Движение = Движения.Хозрасчетный.Добавить();
		Движение.СчетДт = ПланыСчетов.Хозрасчетный.РасчетыСПокупателями;
		Движение.СчетКт = ПланыСчетов.Хозрасчетный.Выручка;
		Движение.Период = Дата;
		Движение.Сумма = ИтогСумма * Курс;
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Контрагенты] = Покупатель;
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Договоры] = Договор;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Контрагенты] = Покупатель;
	КонецЕсли; 	
	
	//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	
	//}}КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	

	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!


	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
КонецПроцедуры
                                                                      