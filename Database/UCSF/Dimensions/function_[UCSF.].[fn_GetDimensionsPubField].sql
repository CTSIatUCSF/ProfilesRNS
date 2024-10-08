USE [profilesRNS]
GO
/****** Object:  UserDefinedFunction [UCSF.].[fn_GetDimensionsPubField]    Script Date: 12/4/2019 6:43:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [UCSF.].[fn_GetDimensionsPubField]  
(
	@PubData varchar(max),
	@FieldName varchar(100)
)
RETURNS varchar(4000)
AS
BEGIN
	DECLARE @fieldValue varchar(4000)
	DECLARE @fieldPosition int
	set @fieldPosition=CHARINDEX('"'+@fieldName+'"',@pubData)+1
	IF ( LEN(@fieldName) =0 or @fieldPosition =0) return NULL
	set @FieldValue=SUBSTRING(@pubData,@fieldPosition+
		LEN(@fieldName)+3,
		charindex('",',SUBSTRING(@pubData,@fieldPosition+LEN(@fieldName)+3,1000))-1)
	return substring(@fieldValue,1,4000)
	
END


