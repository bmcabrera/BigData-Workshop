/*
* Fuzzy Join: Joining two datasets on none exact matching fields
* Dataset: Inline
*/

IMPORT STD;

HOTEL_LAYOUT := RECORD 
    STRING hotel_room;
    INTEGER beds;
END;

SPLITHOTEL_LAYOUT := RECORD
    HOTEL_LAYOUT;
    INTEGER split_count;
    STRING word1 := '';
    STRING word2 := '';
    STRING word3 := '';
    STRING word4 := '';
    STRING word5 := '';
    STRING word6 := '';
    STRING word7 := '';
    STRING word8 := '';
    STRING word9 := '';
END;

FUZZYJOIN_LAYOUT := RECORD
    STRING hotel_room1;
    STRING hotel_room2;
    INTEGER beds;
    INTEGER score;   
END;

dataset1 := DATASET([{'Deluxe Room, 1 King Bed', 1},
                    {'Grand Corner King Room, 1 King Bed', 1},
                    {'Suite, 1 King Bed (Parlor)', 1},
                    {'High-Floor Premium Room, 1 King Bed', 1},
                    {'Traditional Double Room, 2 Double Beds', 2},
                    {'Room, 1 King Bed, Accessible', 1},
                    {'Deluxe Room, 2 Queen Beds', 2},
                    {'Deluxe Room (Non Refundable)', 1},
                    {'Room, 2 Double Beds (19th to 25th Floors)', 2}], HOTEL_LAYOUT);

dataset2 := DATASET([{'Deluxe King Room', 1},
                    {'Standard King Roll-in Shower Accessible', 1},
                    {'Grand Corner King Room', 1},
                    {'King Parlor Suite', 1},
                    {'High-Floor Premium King Room', 1},
                    {'Double Room with Two Double Beds', 2},
                    {'Deluxe King Room', 1},
                    {'Deluxe Room (Non Refundable)', 1},
                    {'Two Double Beds - Location Room (19th to 25th Flrs)', 2}], HOTEL_LAYOUT);

// ------------------------------------------------------------------------------

NORMALIZE_REGEX_PATTERN := '[[:punct:]]';
/*
* normalize the dataset: convert all to lowercase, remove puncuation and split each record into individual words
*/
normalizedDS1 := PROJECT
    (
        dataset1,
        TRANSFORM
        (
            SPLITHOTEL_LAYOUT,
            SELF.hotel_room := REGEXREPLACE(NORMALIZE_REGEX_PATTERN, STD.Str.ToLowerCase(LEFT.hotel_room), ''),
            splits := STD.Str.SplitWords(SELF.hotel_room, ' ');
            
            SELF.split_count := COUNT(splits);
            SELF.beds := LEFT.beds;
            SELF.word1 := splits[1];
            SELF.word2 := splits[2];
            SELF.word3 := splits[3];
            SELF.word4 := splits[4];
            SELF.word5 := splits[5];
            SELF.word6 := splits[6];
            SELF.word7 := splits[7];
            SELF.word8 := splits[8];
            SELF.word9 := splits[9];
        )
    );

/*
* normalize the dataset: convert to lowercase, remove puncuation and split each record into individual words
*/
normalizedDS2 := PROJECT
    (
        dataset2,
        TRANSFORM
        (
            SPLITHOTEL_LAYOUT,
            SELF.hotel_room := REGEXREPLACE(NORMALIZE_REGEX_PATTERN, STD.Str.ToLowerCase(LEFT.hotel_room), ''),
            splits := STD.Str.SplitWords(SELF.hotel_room, ' ');

            SELF.split_count := COUNT(splits);
            SELF.beds := LEFT.beds;
            SELF.word1 := splits[1];
            SELF.word2 := splits[2];
            SELF.word3 := splits[3];
            SELF.word4 := splits[4];
            SELF.word5 := splits[5];
            SELF.word6 := splits[6];
            SELF.word7 := splits[7];
            SELF.word8 := splits[8];
            SELF.word9 := splits[9];
        )
    );

/*
* Output normalized and split datasets
*/
OUTPUT(normalizedDS1, NAMED('NORMALIZED_DATASET1'));
OUTPUT(normalizedDS2, NAMED('NORMALIZED_DATASET2'));

//-------------------------------------------------------------

/*
* Perform JOIN of normalizedDS1 and normalizedDS2 on the specified join condition
* JOIN clause specifies using records where at least one word to word comparison has a Levenshtein score of <= 1
* For all records that pass these conditions, we then calculate the strings' EditDistance and assign the word comparison a score
* The scores for the record are summed up to get a total score
*/
FuzzyJoin := JOIN
(
    normalizedDS1,
    normalizedDS2,

    // Join Condition
    (LEFT.word1 != '' AND RIGHT.word1 != '' AND STD.Str.EditDistance(LEFT.word1, RIGHT.word1) <= 1) OR
    (LEFT.word2 != '' AND RIGHT.word2 != '' AND STD.Str.EditDistance(LEFT.word2, RIGHT.word2) <= 1) OR
    (LEFT.word3 != '' AND RIGHT.word3 != '' AND STD.Str.EditDistance(LEFT.word3, RIGHT.word3) <= 1) OR
    (LEFT.word4 != '' AND RIGHT.word4 != '' AND STD.Str.EditDistance(LEFT.word4, RIGHT.word4) <= 1) OR
    (LEFT.word5 != '' AND RIGHT.word5 != '' AND STD.Str.EditDistance(LEFT.word5, RIGHT.word5) <= 1) OR
    (LEFT.word6 != '' AND RIGHT.word6 != '' AND STD.Str.EditDistance(LEFT.word6, RIGHT.word6) <= 1) OR
    (LEFT.word7 != '' AND RIGHT.word7 != '' AND STD.Str.EditDistance(LEFT.word7, RIGHT.word7) <= 1) OR
    (LEFT.word8 != '' AND RIGHT.word8 != '' AND STD.Str.EditDistance(LEFT.word8, RIGHT.word8) <= 1) OR
    (LEFT.word9 != '' AND RIGHT.word9 != '' AND STD.Str.EditDistance(LEFT.word9, RIGHT.word9) <= 1),
    
    TRANSFORM
        (
            FUZZYJOIN_LAYOUT,

            // Function to get word match score
            score(STRING word1, STRING word2) := MAP(
                word1 = '' OR word2 = '' => 0,
                STD.Str.EditDistance(word1, word2) = 0 => 100,
                STD.Str.EditDistance(word1, word2) = 1 => 50,
                0
            );

            // Get the string counts of the string with most words
            LONGER_RECORD_COUNT := MAX(LEFT.split_count, RIGHT.split_count);

            // Sum of all of the Levenshtein scores in the record
            TOTAL_SCORE :=  score(LEFT.word1, RIGHT.word1) +
                            score(LEFT.word2, RIGHT.word2) +
                            score(LEFT.word3, RIGHT.word3) +
                            score(LEFT.word4, RIGHT.word4) +
                            score(LEFT.word5, RIGHT.word5) +
                            score(LEFT.word6, RIGHT.word6) +
                            score(LEFT.word7, RIGHT.word7) +
                            score(LEFT.word8, RIGHT.word8) +
                            score(LEFT.word9, RIGHT.word9);
                        
            // AVG score: sum of all scores DIVIDED BY the count of words in the longer string
            AVG_SCORE := TOTAL_SCORE/LONGER_RECORD_COUNT;
            
            /*
            * chosen by inspection of your dataset and what best suits your needs.
            * dictates what scores will be joined.
            */
            MY_THRESHOLD := 40;
            
            SELF.score := IF(AVG_SCORE >= MY_THRESHOLD, AVG_SCORE, SKIP);
            SELF.hotel_room1 := LEFT.hotel_room;
            SELF.hotel_room2 := RIGHT.hotel_room;
            SELF.beds := LEFT.beds;
        ),
        ALL
);

OUTPUT(SORT(FuzzyJoin, -score), NAMED('FUZZY_JOIN'));

