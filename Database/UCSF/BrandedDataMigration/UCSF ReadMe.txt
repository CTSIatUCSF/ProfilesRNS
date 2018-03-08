Run in order, for each institution (UCSF, UCSD, USC, LBNL) before proceeding to the next step.
For 02, run the godzilla_import job to bring in people, 

After 02 run ProfilesRNS_DataLoad_Part3.sql
Then run the rest 

Clean up [Profile.Data].[Person.Filter] at some point


-------------  from UCB server ------------------
After finishing the data load up to page 13 in the documentation (ProfilesRNS_DataLoad_Part1), next run ORNG_InternalTypeBugFix
Then convert to UCSF schema
Next Convert to UCSF data 
(make sure you have set secret Baa Ram Ewe in parameter table)
Migrate Pretty URLs 
Then load HR data (import_godzilla)
ProfilesRNS_DataLoad_Part3
Migrate remaining data

Ordering of Gadgets 
Fix Labels

