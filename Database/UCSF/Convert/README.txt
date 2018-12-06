NOTE. THIS IS OUT OF DATE!!!!
This might work to convert a 2.9 or 2.10, but after that you need to instead run the scripts in 
../UCSF/Upgrade/VersionUpgrade_2.10.x_2.11.1 AFTER you run the Harvard equivalent.

Use these files to convert a standard ProfilesRNS Installation from Harvard to one from UCSF.

Do NOT use these to upgrade an existing UCSF version!

Run them in this order to convert to a UCSF style installation:
1) UCSF_Upgrade_Schema.sql
2) UCSF_UPgrade_Data.sql

To go back to a standard Harvard install, run:
1) UCSF_Undo_Upgrade_Schema.sql

Note that in doing this you will remove data such as PrettyURL's!



