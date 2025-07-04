USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUICatDatosExtra]
(
	@IDDatoExtra int = 0
	,@Nombre varchar(100)
	,@Descripcion varchar(255)
	,@TipoDato varchar(255)
	,@IDUsuario int
)
AS
BEGIN
	set @Nombre = REPLACE(@Nombre,' ','_')

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	if CHARINDEX(' ',@Nombre) > 0   
	begin  
	   raiserror('Se ha producido un error. El Nombre no puede contener espacios.',16,1);
	   return
	end;  

	IF(@IDDatoExtra = 0)
	BEGIN
		INSERT INTO RH.tblCatDatosExtra(Nombre,Descripcion,TipoDato)
		VALUES(UPPER(@Nombre),UPPER(@Descripcion),@TipoDato)
		
		set @IDDatoExtra = @@IDENTITY

			
		select @NewJSON = a.JSON from [RH].[tblCatDatosExtra] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDatoExtra = @IDDatoExtra

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDatosExtra]','[RH].[spUICatDatosExtra]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from [RH].[tblCatDatosExtra] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDatoExtra = @IDDatoExtra

		UPDATE RH.tblCatDatosExtra
			set Nombre = UPPER(@Nombre),
				Descripcion = UPPER(@Descripcion),
				TipoDato = @TipoDato
		WHERE IDDatoExtra = @IDDatoExtra

		select @NewJSON = a.JSON from [RH].[tblCatDatosExtra] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDatoExtra = @IDDatoExtra

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDatosExtra]','[RH].[spUICatDatosExtra]','UPDATE',@NewJSON,@OldJSON
	END

	EXEC RH.spBuscarCatDatosExtra @IDDatoExtra

END
GO
