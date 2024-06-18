CREATE DATABASE Занятость_актеров_театра
    WITH
    OWNER = pluttan
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

CREATE TABLE Актеры (
    КодАктера       SERIAL PRIMARY KEY,
    ФИО             VARCHAR(50) UNIQUE NOT NULL,
    ДатаРождения    DATE NOT NULL,
    Фото            BYTEA UNIQUE NOT NULL,
    СтажРаботы      VARCHAR(100) NOT NULL,
    ЗваниеНаграды   VARCHAR(50)[] NOT NULL
);

CREATE TABLE Спектакли (
    КодСпектакля            SERIAL PRIMARY KEY,
    Название                VARCHAR(50) UNIQUE NOT NULL,
    Бюджет                  INTEGER NOT NULL,
    ГодПостановки           INTEGER NOT NULL,
    ОграничениеПоВозрасту   VARCHAR(3) NOT NULL,
    КодПьесы                SERIAL NOT NULL
);

CREATE TABLE Контракт (
    КодКонтракта        SERIAL PRIMARY KEY,
    ДатаПриема          DATE NOT NULL,
    ДатаУвольнения      DATE,
    Ставка              INTEGER NOT NULL,
    КодАктера           SERIAL NOT NULL
);

CREATE TABLE ЗанятостьВСпектаклях (
    КодЗанятости    SERIAL PRIMARY KEY,
    КодСпектакля    SERIAL NOT NULL,
    КодАктера       SERIAL NOT NULL
);

CREATE TABLE Репетиции (
    КодРепетиции        SERIAL PRIMARY KEY,
    ДатаВремя           TIMESTAMP NOT NULL,
    Продолжительность   INTERVAL NOT NULL,
    Читка               BOOLEAN NOT NULL,
    КодСпектакля        SERIAL NOT NULL
);

CREATE TABLE СценыВРепетициях (
    КодСценыВРепетиции  SERIAL PRIMARY KEY,
    КодРепетиции        SERIAL NOT NULL,
    КодСцены            SERIAL NOT NULL
);

CREATE TABLE Пьесы (
    КодПьесы    SERIAL PRIMARY KEY,
    Название    VARCHAR(50) NOT NULL,
    ГодВыпуска  INTEGER NOT NULL,
    Автор       VARCHAR(50) NOT NULL
);

CREATE TABLE Сцены (
    КодСцены            SERIAL PRIMARY KEY,
    Название            VARCHAR(50) NOT NULL,
    Продолжительность   INTERVAL NOT NULL,
    КодПьесы            SERIAL NOT NULL
);

CREATE TABLE Роли (
    КодРоли         SERIAL PRIMARY KEY,
    НазваниеРоли    VARCHAR(50) NOT NULL,
    Главная         BOOLEAN NOT NULL,
    КодПьесы        SERIAL NOT NULL,
    КодАктера       SERIAL NOT NULL
);

CREATE TABLE ЗанятостьРолиВСценах (
    КодЗанятостиРоли    SERIAL PRIMARY KEY,
    КодРоли             SERIAL NOT NULL,
    КодСцены            SERIAL NOT NULL
);

ALTER TABLE Контракт
ADD CONSTRAINT fk_Контракт_Актеры FOREIGN KEY (КодАктера)
REFERENCES Актеры (КодАктера);

ALTER TABLE ЗанятостьВСпектаклях
ADD CONSTRAINT fk_ЗанятостьВСпектаклях_Актеры FOREIGN KEY (КодАктера)
REFERENCES Актеры (КодАктера);

ALTER TABLE ЗанятостьВСпектаклях
ADD CONSTRAINT fk_ЗанятостьВСпектаклях_Спектакли FOREIGN KEY (КодСпектакля)
REFERENCES Спектакли (КодСпектакля);

ALTER TABLE Репетиции
ADD CONSTRAINT fk_Репетиции_Спектакли FOREIGN KEY (КодСпектакля)
REFERENCES Спектакли (КодСпектакля);

ALTER TABLE СценыВРепетициях
ADD CONSTRAINT fk_СценыВРепетициях_Репетиции FOREIGN KEY (КодРепетиции)
REFERENCES Репетиции (КодРепетиции);

ALTER TABLE СценыВРепетициях
ADD CONSTRAINT fk_СценыВРепетициях_Сцены FOREIGN KEY (КодСцены)
REFERENCES Сцены (КодСцены);

ALTER TABLE Сцены
ADD CONSTRAINT fk_Сцены_Пьесы FOREIGN KEY (КодПьесы)
REFERENCES Пьесы (КодПьесы);

ALTER TABLE Роли
ADD CONSTRAINT fk_Роли_Пьесы FOREIGN KEY (КодПьесы)
REFERENCES Пьесы (КодПьесы);

ALTER TABLE Роли
ADD CONSTRAINT fk_Роли_Актеры FOREIGN KEY (КодАктера)
REFERENCES Актеры (КодАктера);

ALTER TABLE ЗанятостьРолиВСценах
ADD CONSTRAINT fk_ЗанятостьРолиВСценах_Роли FOREIGN KEY (КодРоли)
REFERENCES Роли (КодРоли);

ALTER TABLE ЗанятостьРолиВСценах
ADD CONSTRAINT fk_ЗанятостьРолиВСценах_Сцены FOREIGN KEY (КодСцены)
REFERENCES Сцены (КодСцены);

ALTER TABLE Спектакли
ADD CONSTRAINT fk_Спектакли_Пьесы FOREIGN KEY (КодПьесы)
REFERENCES Пьесы (КодПьесы);

ALTER TABLE "Актеры" DROP CONSTRAINT "Актеры_Фото_key";

SELECT a.ФИО, премии.Премии, subquery.NumberOfPlays, a.ЗваниеНаграды
    FROM Актеры a
    JOIN (
    	SELECT z.КодАктера, COUNT(z.КодСпектакля) AS NumberOfPlays
    	FROM ЗанятостьВСпектаклях z
    	GROUP BY z.КодАктера
    	HAVING COUNT(z.КодСпектакля) > 1
    ) AS subquery ON a.КодАктера = subquery.КодАктера
    JOIN LATERAL (
    	SELECT array_agg(award) AS Премии
    	FROM unnest(a.ЗваниеНаграды) AS award
    	WHERE award LIKE 'Премия%'
    ) AS премии ON true
    WHERE (
    	SELECT COUNT(*)
    	FROM unnest(a.ЗваниеНаграды) AS awards
    ) > 3
    AND EXISTS (
    	SELECT 1
    	FROM unnest(a.ЗваниеНаграды) AS award
    	WHERE award LIKE 'Премия%'
    )
    ORDER BY subquery.NumberOfPlays DESC;
SELECT DISTINCT s.Название AS НазваниеСпектакля,
                s.Бюджет, 
                a.ФИО,
                COUNT(r.КодРоли) AS КоличествоГлавныхРолей,
                сцены.КоличествоСцен
    FROM Спектакли s
    JOIN ЗанятостьВСпектаклях z ON s.КодСпектакля = z.КодСпектакля
    JOIN Актеры a ON z.КодАктера = a.КодАктера
    JOIN Роли r ON a.КодАктера = r.КодАктера 
                AND r.КодПьесы = s.КодПьесы
                AND r.Главная = TRUE
    JOIN (
   	    SELECT sr.КодРоли, COUNT(sr.КодСцены) AS КоличествоСцен
   	    FROM ЗанятостьРолиВСценах sr
   	    GROUP BY sr.КодРоли
   	    HAVING COUNT(sr.КодСцены) > 5
    ) AS сцены ON сцены.КодРоли = r.КодРоли
    WHERE s.Бюджет > (
   	    SELECT AVG(Бюджет)
   	    FROM Спектакли
    )
    GROUP BY s.Название, s.Бюджет, a.ФИО, сцены.КоличествоСцен
    ORDER BY s.Бюджет DESC, сцены.КоличествоСцен DESC;
WITH CurrentContracts AS (
    SELECT k.КодАктера, MAX(k.ДатаПриема) AS ДатаПриема
    FROM Контракт k
    WHERE k.ДатаУвольнения IS NULL OR k.ДатаУвольнения > CURRENT_DATE
    GROUP BY k.КодАктера), ActorPlays AS (
    SELECT z.КодАктера, ARRAY_AGG(s.Название) AS Спектакли
    FROM ЗанятостьВСпектаклях z
    JOIN Спектакли s ON z.КодСпектакля = s.КодСпектакля
    GROUP BY z.КодАктера)
SELECT a.ФИО, cc.ДатаПриема AS ДатаПодписанияДействующегоКонтракта, ap.Спектакли
    FROM Актеры a
    JOIN CurrentContracts cc ON a.КодАктера = cc.КодАктера
    JOIN ActorPlays ap ON a.КодАктера = ap.КодАктера
    ORDER BY a.КодАктера;
SELECT  p.Название AS НазваниеПьесы,
    	s.Название AS НазваниеСпектакля,
    	COUNT(DISTINCT nagr.Звание) AS КоличествоНаград,
    	COUNT(DISTINCT rep.КодРепетиции) AS КоличествоРепетиций
    FROM Пьесы p
    JOIN Спектакли s ON p.КодПьесы = s.КодПьесы
    JOIN Роли r ON p.КодПьесы = r.КодПьесы
    JOIN Актеры a ON r.КодАктера = a.КодАктера
    LEFT JOIN
    	Репетиции rep ON s.КодСпектакля = rep.КодСпектакля,
    	UNNEST(a.ЗваниеНаграды) AS nagr(Звание)
    GROUP BY p.Название, s.Название
    HAVING COUNT(nagr.Звание) > 0
    ORDER BY КоличествоРепетиций DESC;
CREATE OR REPLACE FUNCTION обновить_стаж_работы() RETURNS TRIGGER AS $$
    DECLARE
        начальная_дата DATE;
        конечная_дата DATE;
        стаж INTERVAL := INTERVAL '0 days';
    BEGIN
        SELECT MIN(ДатаПриема) INTO начальная_дата
        FROM Контракт
        WHERE КодАктера = NEW.КодАктера;
        SELECT MAX(COALESCE(ДатаУвольнения, CURRENT_DATE)) 
        INTO конечная_дата
        FROM Контракт
        WHERE КодАктера = NEW.КодАктера;
        IF начальная_дата IS NOT NULL AND
           конечная_дата IS NOT NULL THEN
        	стаж := age(конечная_дата, начальная_дата);
        END IF;
        UPDATE Актеры
        SET СтажРаботы = стаж
        WHERE КодАктера = NEW.КодАктера;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
CREATE TRIGGER обновить_стаж_работы_триггер
    AFTER INSERT OR UPDATE OR DELETE ON Контракт
    FOR EACH ROW
    EXECUTE FUNCTION обновить_стаж_работы();
SELECT s.Название AS НазваниеСпектакля, s.Бюджет, COUNT(DISTINCT z.КодАктера) AS КоличествоАктеров, 
        (SELECT COUNT(DISTINCT сц.КодСцены) 
        FROM Сцены сц 
        JOIN СценыВРепетициях ср ON сц.КодСцены = ср.КодСцены
        JOIN Репетиции р ON ср.КодРепетиции = р.КодРепетиции
        WHERE р.КодСпектакля = s.КодСпектакля) AS КоличествоСцен
    FROM Спектакли s
    JOIN ЗанятостьВСпектаклях z ON s.КодСпектакля = z.КодСпектакля
    GROUP BY s.КодСпектакля, s.Бюджет, s.Название
    ORDER BY КоличествоАктеров DESC;
SELECT  a.ФИО AS Актер,
        s.Название AS Спектакль,
        r.НазваниеРоли AS Роль,
        r.Главная AS ГлавнаяРоль,
        реп.ДатаВремя AS ДатаВремяРепетиции,
        сц.Название AS Сцена,
        сц.Продолжительность AS ПродолжительностьСцены
    FROM Актеры a
    JOIN ЗанятостьВСпектаклях zvs ON a.КодАктера = zvs.КодАктера
    JOIN Спектакли s ON zvs.КодСпектакля = s.КодСпектакля
    LEFT JOIN Роли r ON a.КодАктера = r.КодАктера AND r.КодПьесы = s.КодПьесы
    LEFT JOIN Репетиции реп ON s.КодСпектакля = реп.КодСпектакля
    LEFT JOIN СценыВРепетициях свр ON реп.КодРепетиции = свр.КодРепетиции
    LEFT JOIN Сцены сц ON свр.КодСцены = сц.КодСцены
    WHERE r.КодРоли IS NOT NULL AND сц.КодСцены IS NOT NULL
    ORDER BY a.ФИО, s.Название, реп.ДатаВремя;
