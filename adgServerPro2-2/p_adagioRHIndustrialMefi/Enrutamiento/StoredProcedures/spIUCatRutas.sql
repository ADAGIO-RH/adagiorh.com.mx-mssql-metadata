USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA CREAR/ACTUALIZAR CATALOGO DE RUTAS
** Autor			: JOSE ROMAN
** Email			: JROMAN@ADAGIO.COM.MX
** FechaCreacion	: 2022-01-12
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [Enrutamiento].[spIUCatRutas]
(
	@IDCatRuta int = 0    
	,@Nombre Varchar(250)
	,@IDCatTipoProceso int
	,@IDCliente int
	,@IDUsuario int 
)
AS
BEGIN
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	SET @Nombre = UPPER(@Nombre)

	if (@Nombre is null)   
	begin  
		EXEC [App].[spObtenerError] @IDUsuario = 1, @CustomMessage = 'El campo Nombre es Obligatorio'  
		RETURN 0;  
	end;  

	if (ISNULL(@IDCatTipoProceso,0)= 0)   
	begin  
		EXEC [App].[spObtenerError] @IDUsuario = 1, @CustomMessage = 'El campo Tipo Proceso es Obligatorio'  
		RETURN 0;  
	end; 

	IF(isnull(@IDCatRuta,0) = 0)
	BEGIN
		INSERT INTO [Enrutamiento].[tblCatRutas](Nombre, IDCatTipoProceso, IDCliente)
		VALUES (@Nombre, @IDCatTipoProceso,@IDCliente)

		set @IDCatRuta = @@identity  

		select @NewJSON = a.JSON from [Enrutamiento].[tblCatRutas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatRuta = @IDCatRuta

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Enrutamiento].[tblCatRutas]','[Enrutamiento].[spIUCatRutas]','INSERT',@NewJSON,''
		
		EXEC Enrutamiento.spUIRutaStep
		@IDRutaStep  = 0,
		@IDCatRuta =@IDCatRuta,
		@IDCatTipoStep = 3,
		@Orden = 0,
		@IDUsuario = @IDUsuario 

	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from [Enrutamiento].[tblCatRutas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatRuta = @IDCatRuta


		UPDATE [Enrutamiento].[tblCatRutas]
			set Nombre = @Nombre
				,IDCatTipoProceso = @IDCatTipoProceso
		WHERE IDCatRuta = @IDCatRuta
		and IDCliente = @IDCliente
		
		select @NewJSON = a.JSON from [Enrutamiento].[tblCatRutas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatRuta = @IDCatRuta

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Enrutamiento].[tblCatRutas]','[Enrutamiento].[spIUCatRutas]','UPDATE',@NewJSON,@OldJSON
	END
END
GO
