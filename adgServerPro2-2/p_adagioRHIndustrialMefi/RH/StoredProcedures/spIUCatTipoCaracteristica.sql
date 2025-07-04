USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spIUCatTipoCaracteristica](
	@IDTipoCaracteristica int,
	@TipoCaracteristica varchar(255) = null,
	@Activo bit,
	@IDUsuario int,
	@Traduccion varchar(max)
) as
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	select @Traduccion=App.UpperJSONKeys(@Traduccion, 'TipoCaracteristica')

	--SET @TipoCaracteristica= UPPER(@TipoCaracteristica)

	if (ISNULL(@IDTipoCaracteristica, 0) = 0)
	begin
		insert RH.tblCatTiposCaracteristicas(Activo, Traduccion)
		values (ISNULL(@Activo, 0), case when ISJSON(@Traduccion) > 0 then @Traduccion else null end)

		set @IDTipoCaracteristica = @@IDENTITY

		select @NewJSON = a.JSON from RH.tblCatTiposCaracteristicas b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoCaracteristica = @IDTipoCaracteristica;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposCaracteristicas]','[RH].[spIUCatTipoCaracteristica]','INSERT',@NewJSON,''

	end else 
	begin

		select @OldJSON = a.JSON from RH.tblCatTiposCaracteristicas b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoCaracteristica = @IDTipoCaracteristica;

		update RH.tblCatTiposCaracteristicas
		set Activo = ISNULL(@Activo, 0),
			Traduccion = case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
		where IDTipoCaracteristica = @IDTipoCaracteristica

		select @NewJSON = a.JSON from RH.tblCatTiposCaracteristicas b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoCaracteristica = @IDTipoCaracteristica;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposCaracteristicas]','[RH].[spIUCatTipoCaracteristica]','UPDATE',@NewJSON,@OldJSON
	end
GO
