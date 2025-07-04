USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca matriz de control de acceso
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2023-08-01
** Paremetros		:              

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROCEDURE [RH].[spIUMatrizControlAcceso]
(
	@IDMatrizControlAcceso int = 0
	,@Nombre varchar(255)
    ,@Descripcion varchar(255)
    ,@Color varchar(15)
    ,@BackgroundColor varchar(15)
    ,@Icono varchar(15)
    ,@Parent int
	,@Orden int
    ,@Estatus bit =1
	,@IDUsuario int =1
)
AS
BEGIN


	SET @Nombre				= UPPER(@Nombre			)	

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF(@IDMatrizControlAcceso = 0 OR @IDMatrizControlAcceso Is null)
	BEGIN
	
		INSERT INTO [RH].[tblMatrizControlAcceso] ( [Nombre], [Descripcion], [Color], [BackgroundColor], [Icono], [Parent], [Orden],[Estatus])
            VALUES (@Nombre ,@Descripcion,@Color,@BackgroundColor,@Icono,@Parent,@Orden,1 )

		Set @IDMatrizControlAcceso= @@IDENTITY
	
		select @NewJSON = a.JSON from [RH].[tblMatrizControlAcceso] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMatrizControlAcceso = @IDMatrizControlAcceso

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblMatrizControlAcceso]','[RH].[spIUMatrizControlAcceso]','INSERT',@NewJSON,''


	END
	ELSE
	BEGIN
        -- IF EXISTS(Select Top 1 1 from RH.[tblMatrizControlAcceso] where  (Nombre = @Nombre and IDMatrizControlAcceso <> @IDMatrizControlAcceso)  or (Orden= @Orden AND IDMatrizControlAcceso <>@IDMatrizControlAcceso) )
        -- BEGIN
        --     EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
        --     RETURN 0;
        -- END
	    
		select @OldJSON = a.JSON from [RH].[tblMatrizControlAcceso] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMatrizControlAcceso = @IDMatrizControlAcceso

		UPDATE [RH].[tblMatrizControlAcceso]
		   SET 
                [Nombre]=@Nombre,
                [Descripcion]=@Descripcion,
                [Color]=@Color,
                [BackgroundColor]=@BackgroundColor,
                [Icono]=@Icono,
                [Parent]=@Parent,
                [Orden] =@Orden,
                [Estatus]=@Estatus

		 WHERE IDMatrizControlAcceso = @IDMatrizControlAcceso		 	

        UPDATE [RH].[tblMatrizControlAcceso]
		   SET 
                [Estatus]=@Estatus
        WHERE Parent = @IDMatrizControlAcceso		 	


		select @NewJSON = a.JSON from [RH].[tblMatrizControlAcceso] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMatrizControlAcceso = @IDMatrizControlAcceso

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblMatrizControlAcceso]','[RH].[spIUMatrizControlAcceso]','UPDATE',@NewJSON,@OldJSON
	END
    select @IDMatrizControlAcceso as IDMatrizControlAcceso
END
GO
