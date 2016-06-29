/***
* Move to new ActivtyLog mechnism
**/


-- Move any installation related activities to the side
SELECT * into #InstallLogActivity FROM [Framework.].[Log.Activity]

-- drop the moved ones
TRUNCATE TABLE [Framework.].[Log.Activity]; 

-- add the old ones
SET IDENTITY_INSERT [Framework.].[Log.Activity] ON;

INSERT [Framework.].[Log.Activity] (activityLogId, userId, personId, methodName, property, privacyCode, param1, param2, createdDT) 
	SELECT activityLogId, userId, personId, methodName, property, privacyCode, param1, param2, createdDT FROM [UCSF.].[ActivityLog];

SET IDENTITY_INSERT [Framework.].[Log.Activity] OFF;

-- now add any new ones that may have popped up 
INSERT [Framework.].[Log.Activity] (userId, personId, methodName, property, privacyCode, param1, param2, createdDT) 
	SELECT userId, personId, methodName, property, privacyCode, param1, param2, createdDT FROM #InstallLogActivity

DROP TABLE #InstallLogActivity;

DROP TABLE [UCSF.].[ActivityLog];

GO

-- change the UCSF sites only ReadActivityLog sp to use the new table
ALTER PROCEDURE [UCSF.].[ReadActivityLog] @methodName nvarchar(255), @afterDT datetime
AS   

IF @methodName is not null
	SELECT p.personid, p.displayname, p.urlname, p.emailaddr, l.createdDT, l.methodName, l.param1, l.param2
	  FROM [Framework.].[Log.Activity] l  join [UCSF.].[vwPerson] p on l.personId = p.PersonID
	  where l.methodName = @methodName and l.createdDT >= isnull(@afterDT, '01/01/1970') 
	   order by activityLogId desc;
ELSE
	SELECT p.personid, p.displayname, p.urlname, p.emailaddr, l.createdDT, l.methodName, l.param1, l.param2
	  FROM [Framework.].[Log.Activity] l  join [UCSF.].[vwPerson] p on l.personId = p.PersonID
	  where l.createdDT >= isnull(@afterDT, '01/01/1970') 
	   order by activityLogId desc;
GO
