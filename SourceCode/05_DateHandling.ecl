/*
* Date Handling: Transforming order_date field ('Year-Month-Day Hour:Minute:Second') to various formats
* Dataset: Inline
*/

IMPORT STD;

/*
* Layout for sales inline dataset
*/
SALES_LAYOUT := RECORD 
    INTEGER order_number;
    STRING item;
    INTEGER quantity;
    STRING price;
    STRING order_date;
END;

/*
* Result layout 
*/
NEWSALES_LAYOUT := RECORD
    SALES_LAYOUT;
    INTEGER date_reformat;
    STRING time;
    INTEGER time_seconds;
    INTEGER month;
    INTEGER day;
    INTEGER year;
    STRING day_of_week;
    INTEGER quarter;
    UNSIGNED monthstart;
    UNSIGNED monthend;
END;

/* sales inline dataset
*
*/
salesDataset := DATASET([{1, 'item A', 1, '1.12', '2023-06-27 23:27:12.986'},
                    {2, 'item B', 1, '$5.25', '2022-10-27 20:23:04.345'},
                    {3, 'item C', 2, '11.30', '2022-07-17 15:34:25.542'},
                    {4, 'item D', 1, '2.20', '2023-01-02 02:06:13.312'},
                    {5, 'item E', 3, '$6.12', '2023-04-19 16:33:21.148'}], SALES_LAYOUT);

/* 
*calculate quarter of the year that the month is in
*/
GetDateQuarter(INTEGER month) := FUNCTION
    quarter := ROUNDUP(month/3);
    return quarter;
END;


/*
* Transform function to manipulate the original order_date column in our sales dataset
*/
NEWSALES_LAYOUT TransformDates(salesDataset L) := TRANSFORM
    dateFormat := '%Y-%m-%d %H:%M:%S';

    SELF.price := IF(STD.Str.Contains(L.price, '$', TRUE), L.price, '$' + L.price);
    SELF.date_reformat := (INTEGER)STD.Date.ConvertDateFormat(L.order_date[..10],'%Y-%m-%d', '%Y%m%d');
    SELF.month := STD.Date.Month(SELF.date_reformat);
    SELF.day := STD.Date.Day(SELF.date_reformat);
    SELF.year := STD.Date.Year(SELF.date_reformat);
    SELF.time := L.order_date[11..];
    SELF.time_seconds := STD.Date.FromStringToSeconds((STRING)L.order_date, dateFormat);
    SELF.day_of_week := CASE(
                            STD.Date.DayOfWeek(SELF.date_reformat), 
                            1 => 'Sunday', 
                            2 => 'Monday', 
                            3 => 'Tuesday', 
                            4 => 'Wednesday', 
                            5 => 'Thursday', 
                            6 => 'Friday',
                            7 => 'Saturday',
                        'Error');
    SELF.quarter := GetDateQuarter(SELF.month);
    SELF.monthstart := STD.Date.DatesForMonth(SELF.date_reformat).startDate;
    SELF.monthend := STD.Date.DatesForMonth(SELF.date_reformat).endDate;
    SELF := L;
END;

dateTransformations := PROJECT(salesDataset, TransformDates(LEFT));

ORDERED(
    OUTPUT(dateTransformations,,'~demo::dateTransformations::thor', OVERWRITE,THOR, NAMED('DATE_TRANSFORMATIONS')),
    STD.File.CreateSuperFile('~demo::dateTransformations:superfile', allowExist:=TRUE),
    STD.File.StartSuperFileTransaction(),
    STD.File.AddSuperFile('~demo::dateTransformations:superfile', '~demo::dateTransformations::thor'),
    STD.File.FinishSuperFileTransaction();
);