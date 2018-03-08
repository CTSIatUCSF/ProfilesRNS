Run ProfilesRNS_CreateDatabase.sql
Follow the basic install instructions for everything else and stop at "Loading Person Data". Keep DB as ProfilesRNS.

Run UCSF_Upgrade_Schema.sql
Run ORNG_FixUntilHarvardNextRelease.sql
Run UCSF_Upgrade_Data.sql
Run 2.10 to 2.10.1 upgrade!

IMPORT HR DATA

Run ProfilesRNS_DataLoad_Part3.sql


Run FixLabels.sql



TODO notes
To brand concept page add institution OR brand to [Profile.Module].[NetworkAuthorshipTimeline.Concept.GetData]
and [Profile.Data].[Concept.Mesh.GetPublications]

StateServer
http://www.beansoftware.com/ASP.NET-Tutorials/Store-Session-State-Server.aspx
https://technet.microsoft.com/en-us/library/cc732412(v=ws.10).aspx

RITM0095782 