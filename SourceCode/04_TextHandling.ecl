/*
* Text handling to find text/patterns in log file
* Sample log file: Windows_2k.log
*/

LOG_LAYOUT := RECORD
    STRING record_line;
END;

REGEX_FOUND_LAYOUT := RECORD
    LOG_LAYOUT;
    STRING diagnostic;
    STRING hexidecimal;
END;

logDataset := DATASET('~demo::windows_2k.log', 
                    LOG_LAYOUT, 
                    CSV(SEPARATOR(''))
                );

OUTPUT(logDataset, NAMED('LOG_FILE'));

/*
* TextSearch: applys REGEXFIND to search each record for 'Failed' or 'Warning'
*/
REGEX_FOUND_LAYOUT TextSearch(logDataset L) := TRANSFORM
    SELF.diagnostic := REGEXFIND('(Failed)|(Warning)', L.record_line, 0);
    SELF.hexidecimal := REGEXFIND('0x[0-9a-f]+', L.record_line, 0);
    SELF := L;
END;

/*
* Applys the TextSearch function across each record to flag for failed or warning messages as well as hexidecimal pattern
*/
regexedDataset := PROJECT(logDataset, TextSearch(LEFT));
OUTPUT(regexedDataset, NAMED('DATASET_SEARCH'));

/*
* dataset filtered down to only show records that were flagged
*/
flaggedRecordset := regexedDataset(regexedDataset.diagnostic='Failed' OR regexedDataset.diagnostic='Warning' OR regexedDataset.hexidecimal!='');
OUTPUT(flaggedRecordset, NAMED('FLAGGED_DATASET'));

/*
* filters for the records which contained 'Failed'
*/
failedRecordset := flaggedRecordset(diagnostic='Failed');
OUTPUT(failedRecordset, NAMED('FAILED'));

/*
* filters for the records which contained 'Warning'
*/
warningRecordset := flaggedRecordset(diagnostic='Warning');
OUTPUT(warningRecordset, NAMED('WARNING'));

/*
* filters for the records which contained string starting with '0x'
*/
regexPatternRecordset := flaggedRecordset(hexidecimal!='');
OUTPUT(regexPatternRecordset, NAMED('PATTERN_FOUND'));