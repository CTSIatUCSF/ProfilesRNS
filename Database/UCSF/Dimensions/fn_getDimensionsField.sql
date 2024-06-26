USE [profilesRNS]
GO
/****** Object:  UserDefinedFunction [UCSF.].[fn_GetDimensionsPubField]    Script Date: 4/2/2020 10:24:59 PM ******/
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
	DECLARE @fieldValue varchar(4000)=''
	DECLARE @fieldPosition int
	DECLARE @fieldValuePosition int 
	if LEN(@fieldName) >0 
	BEGIN
		set @fieldPosition=CHARINDEX('"'+@fieldName+'"',@pubData)+1
		if  @fieldPosition>0
		BEGIN
			set @fieldValuePosition=@fieldPosition+LEN(@fieldName)+3
			set @FieldValue=SUBSTRING(@pubData,@fieldValuePosition,
				charindex('"',SUBSTRING(@pubData,@fieldValuePosition,1000))-1)
		END
	end
	return substring(@fieldValue,1,4000)
END


