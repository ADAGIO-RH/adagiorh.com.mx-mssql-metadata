USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc RH.spIUCatTipoCaracteristica(
	@IDTipoCaracteristica int,
	@TipoCaracteristica varchar(255),
	@Activo bit,
	@IDUsuario int
) as
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	if (ISNULL(@IDTipoCaracteristica, 0) = 0)
	begin
		insert RH.tblCatTiposCaracteristicas(TipoCaracteristica, Activo)
		values (@TipoCaracteristica, ISNULL(@Activo, 0))

		set @IDTipoCaracteristica = @@IDENTITY

		select @NewJSON = a.JSON from RH.tblCatTiposCaracteristicas b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoCaracteristica = @IDTipoCaracteristica;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'RH.tblCatTiposCaracteristicas','[RH].[spIUCatArea]','INSERT',@NewJSON,''

	end else 
	begin

		select @OldJSON = a.JSON from RH.tblCatTiposCaracteristicas b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoCaracteristica = @IDTipoCaracteristica;

		update RH.tblCatTiposCaracteristicas
		set TipoCaracteristica = @TipoCaracteristica,
			Activo = ISNULL(@Activo, 0)
		where IDTipoCaracteristica = @IDTipoCaracteristica

		select @NewJSON = a.JSON from RH.tblCatTiposCaracteristicas b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoCaracteristica = @IDTipoCaracteristica;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'RH.tblCatTiposCaracteristicas','RH.spIUCatTipoCaracteristica','UPDATE',@NewJSON,@OldJSON
	end
GO
