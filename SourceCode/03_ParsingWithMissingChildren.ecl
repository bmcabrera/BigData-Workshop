IMPORT STD;

/*
* airline record layouts
*/

AIRPORT_LAYOUT := RECORD
    UTF8 code {XPATH('Code')};
    UTF8 name {XPATH('Name')};
END;

TIME_LAYOUT := RECORD
    UTF8 f_label {XPATH('Label')};
    UNSIGNED month {XPATH('Month')};
    UTF8 month_name {XPATH('Month*Name')};
    UNSIGNED year {XPATH('Year')};
END;

F_OF_DELAYS_LAYOUT := RECORD
    UNSIGNED carrier {XPATH('Carrier')};
    UNSIGNED late_aircraft {XPATH('Late*Aircraft')};
    UNSIGNED national_aviation_system {XPATH('National*Aviation*System')};
    INTEGER security {XPATH('Security')};
    UNSIGNED weather {XPATH('Weather')};
END;

CARRIERS_LAYOUT := RECORD
    UTF8 names {XPATH('Names')};
    UNSIGNED total {XPATH('Total')};
END;

FLIGHTS_LAYOUT := RECORD
    UNSIGNED cancelled {XPATH('Cancelled')};
    UNSIGNED delayed {XPATH('Delayed')};
    UNSIGNED diverted {XPATH('Diverted')};
    UNSIGNED on_time {XPATH('On*Time')};
    UNSIGNED total {XPATH('Total')};
END;

MINUTES_DELAYED_LAYOUT := RECORD
    UNSIGNED carrier {XPATH('Carrier')};
    UNSIGNED late_aircraft {XPATH('Late*Aircraft')};
    UNSIGNED national_aviation_system {XPATH('National*Aviation*System')};
    UNSIGNED security {XPATH('Security')};
    UNSIGNED total {XPATH('Total')};
    UNSIGNED weather {XPATH('Weather')};
END;

STATISTICS_LAYOUT := RECORD
    DATASET(F_OF_DELAYS_LAYOUT) f_of_delays {XPATH('*of*Delays')};
    DATASET(CARRIERS_LAYOUT) carriers {XPATH('Carriers')};
    DATASET(FLIGHTS_LAYOUT) flights {XPATH('Flights')};
    DATASET(MINUTES_DELAYED_LAYOUT) minutes_delayed {XPATH('Minutes*Delayed')};
END;

AIRLINES_LAYOUT := RECORD
    DATASET(AIRPORT_LAYOUT) airport {XPATH('Airport')};
    DATASET(TIME_LAYOUT) time {XPATH('Time')};
    DATASET(STATISTICS_LAYOUT) statistics {XPATH('Statistics')};
END;


/*
* airline json file
*/
dataset1 := DATASET('~demo::airlines-2023_20230704.json', AIRLINES_LAYOUT, JSON);

/*
* duplicate of airline json file above with nested json properties missing
*/
dataset2 := DATASET('~demo::airlines-missing-children-2023_20230704.json', AIRLINES_LAYOUT, JSON);

/*
* Output to examine that both files are handled the same way
* due to ECL JSON natural parser
*/
OUTPUT(dataset1, NOXPATH, NAMED('AIRLINE_DELAYS'));
OUTPUT(dataset2, NOXPATH, NAMED('AIRLINE_DELAYS_NO_CHILD'));