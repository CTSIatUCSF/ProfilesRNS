USE [ProfilesRNS_Dev]
GO
/****** Object:  StoredProcedure [UCSF.].[AddRemoveProxyByInstitutionID]    Script Date: 11/13/2020 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [UCSF.].[AddRemoveProxyByInstitutionID]
	@InstitutionAbbreviation varchar(10),
	@delegate varchar(255),
	@faculty varchar(255),
	@removeFlag int=0
AS
BEGIN
	DECLARE @facultyID int =0
	DECLARE @delegateID int =0
	DECLARE @facultyInternalUserName varchar(30) ='Unrecognized'
	DEclare @delegateInternalUserName varchar(30)='Unrecognized'
	DECLARE @ErrMsg varchar(300)=''
	Declare @checkerr int=-1
	DECLARE @nameInURL varchar(100)

	if CHARINDEX('https://',@faculty) >-1
	BEGIN
		set @nameInURL=reverse(left(reverse(@faculty), charindex('/', reverse(@faculty)) -1))
print @faculty+'used like '+'https://%/'+@nameInURL
		select @facultyInternalUserName= internalusername from  [UCSF.].[NameAdditions]
		where PrettyURL like 'https://%/'+@nameInURL
	END
	ELSE
	BEGIN 
		set @facultyInternalUserName=[import_profiles].[UCSF.Import].[fn_ScopeInternalusername] (@faculty,@InstitutionAbbreviation)
	END
	set @checkerr=charindex('Unrecognized',@facultyInternalUserName)
	if @checkerr>0
	begin
		set @ErrMsg='InternalUserName for '+@faculty +'is '+@facultyInternalUserName
	end
	if @checkerr =0
	begin
		set @delegateInternalUserName=[import_profiles].[UCSF.Import].[fn_ScopeInternalusername] (@delegate,@InstitutionAbbreviation)
		SELECT @delegateID = UserID FROM [User.Account].[User] WHERE InternalUserName = @delegateInternalUserName
		if (@delegateID=0)
		begin
			set @ErrMsg=@ErrMsg
			+CHAR(13)+CHAR(10)+
			'Cannot find InternalUsername for delegate ID '''+@delegate+''' in Institution '''+@InstitutionAbbreviation+''
			set @checkerr=1;
		end
		SELECT @facultyID = UserID FROM [User.Account].[User] WHERE InternalUserName = @facultyInternalUserName
		if (@facultyID =0)
		begin
			set @ErrMsg=@ErrMsg
			+CHAR(13)+CHAR(10)+
			'Cannot find InternalUsername for faculty ID '''+@faculty+''' in Institution '''+@InstitutionAbbreviation+''
			set @checkerr=1;
		end
	end
	if len(@ErrMsg)=0
	begin
		if @removeFlag=0
		BEGIN
			 
			print 'inserting into DesignatedProxy values ('+cast(ISNULL(@delegateID,0) as varchar)+','+cast(isNULL(@facultyID,0) as varchar)+')'
			INSERT INTO [User.Account].DesignatedProxy values (@delegateID, @facultyID)
		END
		else
			delete from [User.Account].DesignatedProxy
			where [UserId]=@delegateID and ProxyForuserID=@facultyId;
	end
	else
		RAISERROR(@ErrMsg, 16, 1);
END
