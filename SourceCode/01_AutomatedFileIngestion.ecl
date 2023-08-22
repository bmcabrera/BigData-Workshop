/*
* Automated file ingestion from Landing Zone directory 
* Schedule via cron job or Tombolo 
*/

IMPORT STD;
IMPORT Libs; // Libs folder: contains Config and LZ_CHECK

/*
* Use the config file to configure landing zone information such as IP address and directory paths
* Edit LZ_CHECK file to configure file type extensions 
* PendingFilesInLandingZone returns newer files in the landing zone (depending on naming convention <name>-yyyy_YYYYMMDD.json)
* Accepted Parameter: string formatted like YYYY-MM-DD // returns newest files starting from the string date passed
* Accepted Parameter: empty string // returns newest files for all files in directory
*/

/*
* Today's Date YYYY-MM-DD
* TODAYS_DATE can be used as the PendingFilesInLandingZone() parameter when automating
*/
// TODAYS_DATE := STD.Date.ConvertDateFormat((STRING)STD.Date.Today(), '%Y%m%d', '%Y-%m-%d');

/*
* new JSON filenames in the New directory
*/
newLZFiles := Libs.LZ_CHECK.PendingFilesInLandingZone('');
OUTPUT(newLZFiles, NAMED('NEW_LZ_FILES'));

/*
// Sprays|Imports files from the New folder and moves them to the Sprayed folder
*/
IF(COUNT(newLZFiles) > 0, 
		NOTHOR(APPLY(GLOBAL(newLZFiles, FEW),
			// Spray
			STD.File.SprayJSON(
				Libs.Config.LANDING_ZONE_IP_ADDRESS,
				Libs.Config.NEW_FILE_DIRECTORY + name,,
				'/',,
				'mythor',
				'~DEMO::' + name
			),
			// Move
			STD.File.MoveExternalFile(Libs.Config.LANDING_ZONE_IP_ADDRESS, Libs.Config.NEW_FILE_DIRECTORY + name, Libs.Config.SPRAYED_FILE_DIRECTORY + name)
	)));

