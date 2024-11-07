﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	// регистр ОсновныеНачисления
	Движения.ОсновныеНачисления.Записывать = Истина;
	Для Каждого ТекСтрокаОснНачисления Из ОснНачисления Цикл
		Движение = Движения.ОсновныеНачисления.Добавить();
		Движение.Сторно = Ложь;
		Движение.ВидРасчета = ТекСтрокаОснНачисления.ВидНачисления;
		Движение.ПериодДействияНачало = ТекСтрокаОснНачисления.ДатаНачала;
		Движение.ПериодДействияКонец = ТекСтрокаОснНачисления.ДатаОкончания;
		Движение.ПериодРегистрации = ТекСтрокаОснНачисления.ДатаНачала;
		Движение.Сотрудник = ТекСтрокаОснНачисления.Сотрудник;
		//Движение.Результат = 0;
		//Движение.Факт = 0;
		//Движение.Размер = 0;
	КонецЦикла;
	
	// регистр ДополнительныеНачисления
	Движения.ДополнительныеНачисления.Записывать = Истина;
	Для Каждого ТекСтрокаДопНачисления Из ДопНачисления Цикл
		Движение = Движения.ДополнительныеНачисления.Добавить();
		Движение.Сторно = Ложь;
		Движение.ВидРасчета = ТекСтрокаДопНачисления.ВидНачисления;
		Движение.ПериодРегистрации = НачалоМесяца(Дата); 
		Если Движение.ВидРасчета = ПланыВидовРасчета.ДополнительныеНачисления.Премия Тогда
			Движение.БазовыйПериодНачало = НачалоМесяца(ДобавитьМесяц(Дата, -1));
			Движение.БазовыйПериодКонец = КонецМесяца(ДобавитьМесяц(Дата, -1));   
		Иначе
			Движение.БазовыйПериодНачало = НачалоМесяца(Дата);
			Движение.БазовыйПериодКонец = КонецМесяца(Дата);   
		КонецЕсли;
		Движение.Сотрудник = ТекСтрокаДопНачисления.Сотрудник;
		//Движение.Результат = 0;
		Движение.Размер = ТекСтрокаДопНачисления.Размер;
	КонецЦикла;
	
	// регистр Удержания
	Движения.Удержания.Записывать = Истина;
	Для Каждого ТекСтрокаУдержания Из Удержания Цикл
		Движение = Движения.Удержания.Добавить();
		Движение.Сторно = Ложь;
		Движение.ВидРасчета = ТекСтрокаУдержания.ВидНачисления;
		Движение.ПериодРегистрации = НачалоМесяца(Дата); 
		Движение.БазовыйПериодНачало = НачалоМесяца(Дата);
		Движение.БазовыйПериодКонец = КонецМесяца(Дата);
		Движение.Сотрудник = ТекСтрокаУдержания.Сотрудник;
		//Движение.Результат = 0;
	КонецЦикла; 
	
	Движения.Записать();
	
	//Оклад
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЕСТЬNULL(ОсновныеНачисленияДанныеГрафика.ЗначениеДниПериодДействия, 0) КАК ДниПлан,
	|	ЕСТЬNULL(ОсновныеНачисленияДанныеГрафика.ЗначениеДниФактическийПериодДействия, 0) КАК ДниФакт,
	|	ОсновныеНачисленияДанныеГрафика.Сотрудник КАК Сотрудник,
	|	ОсновныеНачисленияДанныеГрафика.НомерСтроки КАК НомерСтроки,
	|	ЕСТЬNULL(ОкладыСотрудниковСрезПоследних.Оклад, 0) КАК Оклад
	|ИЗ
	|	РегистрРасчета.ОсновныеНачисления.ДанныеГрафика(
	|			ВидРасчета = &ВидРасчета
	|				И Регистратор = &Ссылка) КАК ОсновныеНачисленияДанныеГрафика
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ОкладыСотрудников.СрезПоследних(&Дата, ) КАК ОкладыСотрудниковСрезПоследних
	|		ПО ОсновныеНачисленияДанныеГрафика.Сотрудник = ОкладыСотрудниковСрезПоследних.Сотрудник";
	
	Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.ОсновныеНачисления.Оклад);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Дата", НачалоМесяца(Дата)); 
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Для Каждого СтрДвижение Из Движения.ОсновныеНачисления Цикл
		Если СтрДвижение.ВидРасчета<>ПланыВидовРасчета.ОсновныеНачисления.Оклад Тогда
			Продолжить;    
		КонецЕсли; 
		ВыборкаДетальныеЗаписи.Сбросить();                                                
		ВыборкаДетальныеЗаписи.НайтиСледующий(СтрДвижение.НомерСтроки, "НомерСтроки");     
		Если ВыборкаДетальныеЗаписи.Оклад = 0  Тогда                        
			Отказ = Истина;
			Сообщить ("Оклад Сотруднику: " + ВыборкаДетальныеЗаписи.Сотрудник + " не установлен! Строка № " + СтрДвижение.НомерСтроки);
		КонецЕсли;	
		СтрДвижение.Размер = ВыборкаДетальныеЗаписи.Оклад;                                                     
		СтрДвижение.Факт =  ВыборкаДетальныеЗаписи.ДниФакт;                                                             
		СтрДвижение.Результат = ВыборкаДетальныеЗаписи.ДниФакт / ВыборкаДетальныеЗаписи.ДниПлан * СтрДвижение.Размер;  
	КонецЦикла;
	
	Движения.ОсновныеНачисления.Записать(,Истина);              
	
	//Подарок
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ДополнительныеНачисления.НомерСтроки КАК НомерСтроки,
	|	НачислениеЗаработнойПлатыДопНачисления.Размер КАК Размер
	|ИЗ
	|	Документ.НачислениеЗаработнойПлаты.ДопНачисления КАК НачислениеЗаработнойПлатыДопНачисления
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ДополнительныеНачисления КАК ДополнительныеНачисления
	|		ПО НачислениеЗаработнойПлатыДопНачисления.Сотрудник = ДополнительныеНачисления.Сотрудник
	|ГДЕ
	|	ДополнительныеНачисления.Регистратор = &Ссылка
	|	И ДополнительныеНачисления.ВидРасчета = &ВидРасчета";
	
	Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.ДополнительныеНачисления.Подарок);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Для Каждого СтрДвижение Из Движения.ДополнительныеНачисления Цикл
		Если СтрДвижение.ВидРасчета<>ПланыВидовРасчета.ДополнительныеНачисления.Подарок Тогда
			Продолжить;    
		КонецЕсли; 
		ВыборкаДетальныеЗаписи.Сбросить();                                                
		ВыборкаДетальныеЗаписи.НайтиСледующий(СтрДвижение.НомерСтроки, "НомерСтроки");     
		СтрДвижение.Результат = ВыборкаДетальныеЗаписи.Размер;  
	КонецЦикла;
	
	//Премия
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЕСТЬNULL(ДополнительныеНачисленияБазаОсновныеНачисления.НомерСтроки, ДополнительныеНачисленияБазаДополнительныеНачисления.НомерСтроки) КАК НомерСтроки,
	|	ЕСТЬNULL(ДополнительныеНачисленияБазаДополнительныеНачисления.РезультатБаза, 0) КАК РезультатБазаДоп,
	|	ЕСТЬNULL(ДополнительныеНачисленияБазаОсновныеНачисления.РезультатБаза, 0) КАК РезультатБазаОсн
	|ИЗ
	|	РегистрРасчета.ДополнительныеНачисления.БазаОсновныеНачисления(
	|			&МассивИзмерений,
	|			&МассивИзмерений,
	|			,
	|			Регистратор = &Ссылка
	|				И ВидРасчета = &ВидРасчета) КАК ДополнительныеНачисленияБазаОсновныеНачисления
	|		ПОЛНОЕ СОЕДИНЕНИЕ РегистрРасчета.ДополнительныеНачисления.БазаДополнительныеНачисления(
	|				&МассивИзмерений,
	|				&МассивИзмерений,
	|				,
	|				Регистратор = &Ссылка
	|					И ВидРасчета = &ВидРасчета) КАК ДополнительныеНачисленияБазаДополнительныеНачисления
	|		ПО ДополнительныеНачисленияБазаОсновныеНачисления.НомерСтроки = ДополнительныеНачисленияБазаДополнительныеНачисления.НомерСтроки";
	
	МассивИзмерений = Новый Массив;
	МассивИзмерений.Добавить("Сотрудник");
	
	Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.ДополнительныеНачисления.Премия);
	Запрос.УстановитьПараметр("МассивИзмерений", МассивИзмерений);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать(); 
	
	Для Каждого СтрДвижение Из Движения.ДополнительныеНачисления Цикл
		Если СтрДвижение.ВидРасчета<>ПланыВидовРасчета.ДополнительныеНачисления.Премия Тогда
			Продолжить;    
		КонецЕсли; 
		ВыборкаДетальныеЗаписи.Сбросить();                                                
		Если ВыборкаДетальныеЗаписи.НайтиСледующий(СтрДвижение.НомерСтроки, "НомерСтроки") Тогда
			СтрДвижение.Результат = (ВыборкаДетальныеЗаписи.РезультатБазаОсн + ВыборкаДетальныеЗаписи.РезультатБазаДоп)/100 * СтрДвижение.Размер;  
		Иначе	
			Сообщить ("Отсутствует база для начисления сотруднику! Дополнительные начисления, строка - " + СтрДвижение.НомерСтроки);	
			Отказ = Истина; 	
		КонецЕсли;	
	КонецЦикла; 
	
	Движения.ДополнительныеНачисления.Записать(,Истина);              
	
	 //НДФЛ
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЕСТЬNULL(УдержанияБазаОсновныеНачисления.РезультатБаза, 0) КАК РезультатБазаОсн,
	|	ЕСТЬNULL(УдержанияБазаДополнительныеНачисления.РезультатБаза, 0) КАК РезультатБазаДоп,
	|	ЕСТЬNULL(УдержанияБазаОсновныеНачисления.НомерСтроки, УдержанияБазаДополнительныеНачисления.НомерСтроки) КАК НомерСтроки
	|ИЗ
	|	РегистрРасчета.Удержания.БазаОсновныеНачисления(
	|			&МассивИзмерений,
	|			&МассивИзмерений,
	|			,
	|			Регистратор = &Ссылка
	|				И ВидРасчета = &ВидРасчета) КАК УдержанияБазаОсновныеНачисления
	|		ПОЛНОЕ СОЕДИНЕНИЕ РегистрРасчета.Удержания.БазаДополнительныеНачисления(
	|				&МассивИзмерений,
	|				&МассивИзмерений,
	|				,
	|				Регистратор = &Ссылка
	|					И ВидРасчета = &ВидРасчета) КАК УдержанияБазаДополнительныеНачисления
	|		ПО УдержанияБазаОсновныеНачисления.НомерСтроки = УдержанияБазаДополнительныеНачисления.НомерСтроки";
	
	МассивИзмерений = Новый Массив;
	МассивИзмерений.Добавить("Сотрудник");
	
	Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.Удержания.НДФЛ);
	Запрос.УстановитьПараметр("МассивИзмерений", МассивИзмерений);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать(); 
	
	Для Каждого СтрДвижение Из Движения.Удержания Цикл
		Если СтрДвижение.ВидРасчета<>ПланыВидовРасчета.Удержания.НДФЛ Тогда
			Продолжить;    
		КонецЕсли; 
		ВыборкаДетальныеЗаписи.Сбросить();                                                
		Если ВыборкаДетальныеЗаписи.НайтиСледующий(СтрДвижение.НомерСтроки, "НомерСтроки") Тогда
			СтрДвижение.Результат = (ВыборкаДетальныеЗаписи.РезультатБазаОсн + ВыборкаДетальныеЗаписи.РезультатБазаДоп)/100 * 13;  
		Иначе	
			Сообщить ("Отсутствует база для начисления сотруднику! Удержания, строка - " + СтрДвижение.НомерСтроки);	
			Отказ = Истина; 	
		КонецЕсли;	
	КонецЦикла; 
	
	Движения.Удержания.Записать(,Истина);              
	 
	
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
КонецПроцедуры
