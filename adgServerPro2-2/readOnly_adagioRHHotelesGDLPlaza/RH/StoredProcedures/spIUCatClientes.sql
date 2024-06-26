USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatClientes]
(
	@IDCliente int = 0
	,@GenerarNoNomina bit = 0
	,@LongitudNoNomina int = null
	,@Prefijo varchar(10) = null
	,@NombreComercial varchar(max) = null
	,@Codigo varchar(20) = null
	,@PathReciboNomina varchar(max) = null
	,@IDUsuario int

)
AS
BEGIN

	
	SET @Prefijo 			= UPPER(@Prefijo 			)
	SET @NombreComercial 	= UPPER(@NombreComercial 			)
	SET @Codigo 			= UPPER(@Codigo 			)


	
  DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);


	IF(@IDCliente = 0 OR @IDCliente Is null)
	BEGIN

			
		IF EXISTS(Select Top 1 1 from RH.tblCatClientes where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO [RH].[tblCatClientes]
				   ([GenerarNoNomina]
				   ,[LongitudNoNomina]
				   ,[Prefijo]
				   ,[NombreComercial]
				   ,[Codigo]
				   ,[PathReciboNomina])
			 VALUES
				   (
				   @GenerarNoNomina
				   ,@LongitudNoNomina
				   ,@Prefijo
				   ,@NombreComercial
				   ,@Codigo
				   ,@PathReciboNomina)
		  set @IDCliente = @@IDENTITY

		   	select @NewJSON = a.JSON from [RH].[tblCatClientes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCliente=@IDCliente;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatClientes]','[RH].[spIUCatClientes]','INSERT',@NewJSON,''

		  EXEC App.spIUConfiguracionCatalogos @IDCliente = @IDCliente
	END
	ELSE
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.tblCatClientes where Codigo = @Codigo and IDCliente <> @IDCliente)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END
			   	select @OldJSON = a.JSON from [RH].[tblCatClientes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCliente=@IDCliente;
		UPDATE [RH].[tblCatClientes]
		   SET 
			  [GenerarNoNomina] = @GenerarNoNomina,
			  [LongitudNoNomina] = @LongitudNoNomina,
			  [Prefijo] = @Prefijo,
			  [NombreComercial] = @NombreComercial,
			  [Codigo] = @Codigo,
			  [PathReciboNomina] = @PathReciboNomina
		 WHERE IDCliente = @IDCliente
		
		select @NewJSON = a.JSON from [RH].[tblCatClientes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCliente=@IDCliente;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatClientes]','[RH].[spIUCatClientes]','UPDATE',@NewJSON,@OldJSON
	END

	 EXEC [Seguridad].[spIUFiltrosUsuarios] 
	 @IDFiltrosUsuarios  = 0  
	 ,@IDUsuario  = @IDUsuario   
	 ,@Filtro = 'Clientes'  
	 ,@ID = @IDCliente   
	 ,@Descripcion = @NombreComercial
	 ,@IDUsuarioLogin = @IDUsuario 

 exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuario 
END
GO
