USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc App.spIUDriverTour(
	@IDDriverTour varchar(255),
	@Type varchar(20),
	@IDAplicacion nvarchar(100) = null,
	@Url varchar(max) = null,
	@JSONConfiguration varchar(max),
	@Active bit,
	@IDUsuario int
) as
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	select 
		@IDAplicacion = case when isnull(@IDAplicacion, '') = '' then null else @IDAplicacion end
		,@Url		  = case when isnull(@Url, '') = '' then null else @Url end

	if not exists(select top 1 1 
				from App.tblDriversTours 
				where IDDriverTour = @IDDriverTour)
	begin
		insert [App].[tblDriversTours](IDDriverTour,[Type],IDAplicacion,[Url],JSONConfiguration,Active)
		values (@IDDriverTour, @Type, @IDAplicacion, @Url, @JSONConfiguration, @Active)

		select @NewJSON = a.JSON from [App].[tblDriversTours] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDriverTour=@IDDriverTour;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[App].[tblDriversTours]','[App].[spIUDriverTour]','INSERT',@NewJSON,''
	end else
	begin
		select @OldJSON = a.JSON from [App].[tblDriversTours] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDriverTour=@IDDriverTour;

		update [App].[tblDriversTours]
			set 
				[Type] = @Type,
				IDAplicacion = @IDAplicacion,
				[Url] = @Url,
				JSONConfiguration = @JSONConfiguration,
				Active = @Active
		where IDDriverTour = @IDDriverTour

		select @NewJSON = a.JSON from [App].[tblDriversTours] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDriverTour=@IDDriverTour;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[App].[tblDriversTours]','[App].[spIUDriverTour]','UPDATE',@NewJSON,@OldJSON
	end
GO
