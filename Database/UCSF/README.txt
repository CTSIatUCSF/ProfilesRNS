To create a UCSF version of Profiles for the first time, run UCSF_Upgrade_Schema.sql then UCSF_Upgrade_Data.sql

If there are any *.sql files with "FixUntil" in the title, run those as well. 

To upgrade an existing UCSF version of Profiles, just run the ones in VersionUpgrade_* that are specific to your upgrade or target version, paying attention to any README.txt that is in that directory.
