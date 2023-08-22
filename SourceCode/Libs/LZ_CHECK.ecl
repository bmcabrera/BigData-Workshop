IMPORT $.^.Libs.Config;
IMPORT STD;

EXPORT LZ_CHECK := MODULE

    // Dynamically find newer files sitting in the landing zone that need to be sprayed;
    // earliestDate should be a string in YYYY-MM-DD format, or an empty string
    EXPORT PendingFilesInLandingZone(STRING earliestDate) := FUNCTION
        allLZFiles := NOTHOR(STD.File.RemoteDirectory(Config.LANDING_ZONE_IP_ADDRESS, Config.NEW_FILE_DIRECTORY, '*'));
        filteredFiles := allLZFiles(modified > earliestDate AND size > 0);

        // Filenames are in a format like <name>-yyyy_YYYYMMDD.json where YYYYMMDD is the date the file
        // was transferred to the landing zone; there may be many files for the same yyyy value; deduplicate,
        // leaving only the latest
        sortedFiltered := SORT(filteredFiles, -name);
        rolledUp := ROLLUP
            (
                sortedFiltered,
                STD.Str.SplitWords(LEFT.name, '_')[1] = STD.Str.SplitWords(RIGHT.name, '_')[1],
                TRANSFORM(LEFT)
            ) : ONWARNING(4542, IGNORE);
        RETURN rolledUp;
    END;

END;