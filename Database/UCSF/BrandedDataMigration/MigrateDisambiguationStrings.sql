
/************* clear out the old ****************************************/
truncate table [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
truncate table [Profile.Data].[Funding.DisambiguationOrganizationMapping]

/********** For Publications ****************************************************************************************/
------------------------------ USC
DECLARE @Institution VARCHAR(50) = 'USC'
DECLARE @SourceDB VARCHAR(50) = 'profiles_usc' 
DECLARE @InstitutionID int 

SELECT @InstitutionID = InstitutionID FROM [Profile.Data].[Organization.Institution] WHERE InstitutionAbbreviation = @Institution
DECLARE @SQL NVARCHAR(MAX)

SELECT @SQL = N'
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID)
SELECT affiliation, ' + cast(@InstitutionID as varchar) + '  FROM [' + @SourceDB + '].[Profile.Data].[Publication.PubMed.DisambiguationAffiliation]'

--SELECT @SQL
EXEC dbo.sp_executesql @SQL

------------------------------ LBNL
SELECT @Institution = 'LBNL'
SELECT @SourceDB = 'profiles_lbnl' 

SELECT @InstitutionID = InstitutionID FROM [Profile.Data].[Organization.Institution] WHERE InstitutionAbbreviation = @Institution

SELECT @SQL = N'
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID)
SELECT affiliation, ' + cast(@InstitutionID as varchar) + '  FROM [' + @SourceDB + '].[Profile.Data].[Publication.PubMed.DisambiguationAffiliation]'

--SELECT @SQL
EXEC dbo.sp_executesql @SQL 

------------------------------ UCSD
SELECT @Institution = 'UCSD'
SELECT @SourceDB = 'profiles_ucsd' 

SELECT @InstitutionID = InstitutionID FROM [Profile.Data].[Organization.Institution] WHERE InstitutionAbbreviation = @Institution

SELECT @SQL = N'
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID)
SELECT affiliation, ' + cast(@InstitutionID as varchar) + '  FROM [' + @SourceDB + '].[Profile.Data].[Publication.PubMed.DisambiguationAffiliation]'

--SELECT @SQL
EXEC dbo.sp_executesql @SQL 

------------------------------ UCI
SELECT @Institution = 'UCI'
SELECT @SourceDB = 'profiles_uci' 

SELECT @InstitutionID = InstitutionID FROM [Profile.Data].[Organization.Institution] WHERE InstitutionAbbreviation = @Institution

SELECT @SQL = N'
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID)
SELECT affiliation, ' + cast(@InstitutionID as varchar) + '  FROM [' + @SourceDB + '].[Profile.Data].[Publication.PubMed.DisambiguationAffiliation]'

--SELECT @SQL
EXEC dbo.sp_executesql @SQL 

------------------------------ UCSF
SELECT @Institution = 'UCSF'
SELECT @SourceDB = 'profiles_ucsf' 

SELECT @InstitutionID = InstitutionID FROM [Profile.Data].[Organization.Institution] WHERE InstitutionAbbreviation = @Institution

SELECT @SQL = N'
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID)
SELECT affiliation, ' + cast(@InstitutionID as varchar) + '  FROM [' + @SourceDB + '].[Profile.Data].[Publication.PubMed.DisambiguationAffiliation]'

--SELECT @SQL
EXEC dbo.sp_executesql @SQL 

-- Davis, sort of
SELECT @Institution = 'UCD'

SELECT @InstitutionID = InstitutionID FROM [Profile.Data].[Organization.Institution] WHERE InstitutionAbbreviation = @Institution

INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID) values ('%University of California%Davis%', @InstitutionID)
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID) values ('%Davis%University of California%', @InstitutionID)
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID) values ('%Univ. of California%Davis%', @InstitutionID)
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID) values ('%Davis%Univ. of California%', @InstitutionID)
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID) values ('%Davis%Hospital%', @InstitutionID)
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID) values ('%Hospital%Davis%', @InstitutionID)
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID) values ('%UCD%', @InstitutionID)
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID) values ('%Medical Center%Davis%', @InstitutionID)
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID) values ('%Davis%Medical Center%', @InstitutionID)
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID) values ('%Davis%School of Medicine%', @InstitutionID)
INSERT INTO [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
           (affiliation, InstitutionID) values ('%Davis, California%', @InstitutionID)


/********** For Grants ****************************************************************************************/
SELECT @Institution = 'UCSD'
SELECT @SourceDB = 'profiles_ucsd' 

SELECT @InstitutionID = InstitutionID FROM [Profile.Data].[Organization.Institution] WHERE InstitutionAbbreviation = @Institution

SELECT @SQL = N'
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping]
           (InstitutionID, Organization)
SELECT ' + cast(@InstitutionID as varchar) + ', Organization  FROM [' + @SourceDB + '].[Profile.Data].[Funding.DisambiguationOrganizationMapping]'

--SELECT @SQL
EXEC dbo.sp_executesql @SQL 

SELECT @Institution = 'UCSF'
SELECT @SourceDB = 'profiles_ucsf' 

SELECT @InstitutionID = InstitutionID FROM [Profile.Data].[Organization.Institution] WHERE InstitutionAbbreviation = @Institution

SELECT @SQL = N'
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping]
           (InstitutionID, Organization)
SELECT ' + cast(@InstitutionID as varchar) + ', Organization  FROM [' + @SourceDB + '].[Profile.Data].[Funding.DisambiguationOrganizationMapping]'

--SELECT @SQL
EXEC dbo.sp_executesql @SQL 

--- UCI
SELECT @Institution = 'UCI'
SELECT @InstitutionID = InstitutionID FROM [Profile.Data].[Organization.Institution] WHERE InstitutionAbbreviation = @Institution

INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Bill Gross Stem Cell Core at UC Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Medical Cinic, University of California,Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Medical Clinic,University of California,Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'The University of California Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'uci.edu')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'UCI.EDU')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'UCI Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'UCI Medical Center Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Uc Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'U.C. Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'UC Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'UC-Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'UC, Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'UCIrvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'UCIRVINE')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'ucirvinehealth.org')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univeristy of California Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univeristy of California- Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univeristy of California, Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University CA Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University California Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University California, Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of CA at Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of CA Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of CA, Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of Califnornia-Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of Californai Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of Californai, Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of Californa, Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California at Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California - Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California -Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California / Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California (Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California (Irvine)')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California- Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California-Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California, Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University Of California Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University Of California, Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California Medical Center At Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California Medical Center - Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California\n      Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univ. of CA, Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univ of California / Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univ of California Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univ of California, Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Urology Clinic of the University of California, Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'urology - UC Irvine')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Urology | University of California, Irvine')

--- UCD
SELECT @Institution = 'UCD'
SELECT @InstitutionID = InstitutionID FROM [Profile.Data].[Organization.Institution] WHERE InstitutionAbbreviation = @Institution

INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'ucdavis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Uc Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, '/UC Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'U C Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'U.C. Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'UC Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'UC-Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'UC, Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'UCDavis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univeristy of California at Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univeristy of California Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University California Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University California, Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of CA Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of CA, Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of Califoria, Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California at Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of california, Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California - Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California- Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California-Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California, Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University Of California - Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University Of California Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University Of California-Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University Of California, Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California (UC Davis)')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California (UC) Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of California-UC Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'University of Callifornia, Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univesity of California Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univ of California - Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univ of California / Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univ of California Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univ of California, Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'Univ. of California Davis')
INSERT INTO [Profile.Data].[Funding.DisambiguationOrganizationMapping] (InstitutionID, Organization) VALUES (@InstitutionID, 'U, University of CAlifornia, Davis')
