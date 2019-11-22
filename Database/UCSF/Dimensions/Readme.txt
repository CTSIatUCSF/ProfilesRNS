In order to add publications from Dimensions DB, you have to:
- obtain access to Dimensions API from Dimensions
- created Dimensions import tables using  script createTablesForDimensionsImport.sql
- add DOI to Ontology executing script AddDOIToRDF.sql
- modify existing ProfilesRNS view from files:
 1)view_[Profile.Data].[vwPublication.Entity.InformationResource].sql
- modify existing ProfilesRNS procedures from files:
 1)proc_[Profile.Data].[Publication.Pubmed.LoadDisambiguationResults].sql
 2)proc_[Profile.Data].[Publication.Entity.UpdateEntity].sql
 3)proc_[Profile.Module].[CustomViewAuthorInAuthorship.GetList].sql
 4)proc_[Profile.Module].[CustomViewAuthorInAuthorship.GetGroupList].sql
- add new procedures from files:
 1)proc_[UCSF.].[CleanDimensionsImport].sql
 2)proc_[UCSF.].[LoadDimensionsIntoProfiles]
- create Dimensions XML settings file:
   <?xml version="1.0"?>  
   <Settings>
	<WebService>
		<URL>https://app.dimensions.ai/api</URL>
		<WSUser><Dimensions API name></WSUser>
		<WSPassword><Dimensions API password></WSPassword>
	</WebService>
	<Database>
		<DBServer><DB Server name></DBServer>
		<DBName><Your DB name></DBName>
		<DBUser><DB autorized user name></DBUser>
		<DBPassword><DB authorized user's password></DBPassword>
	</Database>
   </Settings>
- prepared job to find Dimensions IDs for Profiles owners with step:
 1) CmdExec FindDimensionsIDs.bat <Your XML Settings file>
- prepare job to add publications from Dimensions into profiles with steps:
 1) exec [UCSF.].[LoadDimensionsIntoProfiles]
 2) CmdExec GetDimensionsPubs.bat <Your XML Settings file>
 3) exec [UCSF.].[LoadDimensionsIntoProfiles]

   