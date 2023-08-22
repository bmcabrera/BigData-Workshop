IMPORT STD;

/* 
* For this demo superfile1 contains airlines-2023_20230703.json and we'll be clearing the data
* and finish our refresh by appending our new data file airlines-2023_20230704.json
*/
SUPERFILENAME := '~demo::superfile1';

/*
* Lists all sub-files currently in the superfile
*/
superfile1 := STD.File.SuperFileContents(SUPERFILENAME);

/*
* Remove existing data and continue adding new data (Refresh)
* StartSuperFileTransaction() and FinishSuperFileTransaction() surround SuperFile maintenance function calls
* as a sort of "lock" to prevent other SuperFile operations and avoid interruptions
*/
SEQUENTIAL(
    OUTPUT(superfile1, NAMED('SUPERFILE1_CONTENTS')),
    STD.File.StartSuperFileTransaction(),
    STD.File.ClearSuperFile('~demo::superfile1'),
    STD.File.AddSuperFile('~demo::superfile1', '~demo::airlines-2023_20230704.json'),
    STD.File.FinishSuperFileTransaction(),
    OUTPUT(superfile1, NAMED('NEW_SUPERFILE1_CONTENTS'));
);

