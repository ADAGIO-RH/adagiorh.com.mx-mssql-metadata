USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatTipoContactoEmpleado]
(
	@IDTipoContacto int = 0
	,@Descripcion varchar(100)
	,@Mask varchar(100)
	,@IDMedioNotificacion varchar(50) = null
	,@Traduccion varchar(max)
	,@IDUsuario int
)
AS
BEGIN
	SET @Descripcion = UPPER(@Descripcion)
	SET @Mask		 = UPPER(@Mask		)

     DECLARE  
		@IDIdioma varchar(225)
	;
    select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))
    
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF (@IDTipoContacto = 0 or @IDTipoContacto is null)
	BEGIN
		INSERT INTO [RH].[tblCatTipoContactoEmpleado] (
			[Descripcion]
			,[Mask]
			,[IDMedioNotificacion]
			,Traduccion
		)
		VALUES (
			@Descripcion
			,@Mask
			,@IDMedioNotificacion
			,@Traduccion
		)

		set @IDTipoContacto = @@IDENTITY

		select @NewJSON = (SELECT IDTipoContacto
                        ,Mask
                        ,IDMedioNotificacion
                        ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
                        FROM [RH].[tblCatTipoContactoEmpleado]                  
                    WHERE IDTipoContacto = @IDTipoContacto FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTipoContactoEmpleado]','[RH].[spIUCatTipoContactoEmpleado]','INSERT',@NewJSON,''
	END
	ELSE
	BEGIN
		select @OldJSON = (SELECT IDTipoContacto
                        ,Mask
                        ,IDMedioNotificacion
                        ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
                        FROM [RH].[tblCatTipoContactoEmpleado]                  
                    WHERE IDTipoContacto = @IDTipoContacto FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		UPDATE [RH].[tblCatTipoContactoEmpleado]
		   SET   [Descripcion] = @Descripcion
				,[Mask] = @Mask
				,[IDMedioNotificacion] = @IDMedioNotificacion
				,Traduccion = @Traduccion
		 WHERE [IDTipoContacto] = @IDTipoContacto

		select @NewJSON =(SELECT IDTipoContacto
                        ,Mask
                        ,IDMedioNotificacion
                        ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
                        FROM [RH].[tblCatTipoContactoEmpleado]                  
                    WHERE IDTipoContacto = @IDTipoContacto FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTipoContactoEmpleado]','[RH].[spIUCatTipoContactoEmpleado]','UPDATE',@NewJSON,@OldJSON

	END
END
GO
