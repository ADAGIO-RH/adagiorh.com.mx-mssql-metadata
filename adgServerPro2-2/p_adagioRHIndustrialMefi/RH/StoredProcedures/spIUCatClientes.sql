USE [p_adagioRHIndustrialMefi]
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
	,@PathReciboNominaNoTimbrado varchar(max) = null
	,@IDUsuario int
	,@Traduccion nvarchar(max)

)
AS
BEGIN

	
	SET @Prefijo 			= UPPER(@Prefijo 			)
	SET @NombreComercial 	= UPPER(@NombreComercial 			)
	SET @Codigo 			= UPPER(@Codigo 			)


	
  DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	select @Traduccion=App.UpperJSONKeys(@Traduccion, 'NombreComercial')



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
				   ,[PathReciboNomina]
				   ,[PathReciboNominaNoTimbrado]
				   ,[Traduccion])
			 VALUES
				   (
				   @GenerarNoNomina
				   ,@LongitudNoNomina
				   ,@Prefijo
				   ,@NombreComercial
				   ,@Codigo
				   ,@PathReciboNomina
				   ,@PathReciboNominaNoTimbrado
				   ,case when ISJSON(@Traduccion) > 0 then @Traduccion else null end)
		  set @IDCliente = @@IDENTITY

		select @NewJSON =  (SELECT IDCliente
                    ,[GenerarNoNomina]
				   ,[LongitudNoNomina]
				   ,[Prefijo]		
				   ,[Codigo]
				   ,[PathReciboNomina]
				   ,[PathReciboNominaNoTimbrado]				
		         ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'NombreComercial')) as NombreComercial
              FROM [RH].[tblCatClientes]
                WHERE IDCliente = @IDCliente FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

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
			   	select @OldJSON = (SELECT IDCliente
                    ,[GenerarNoNomina]
				   ,[LongitudNoNomina]
				   ,[Prefijo]		
				   ,[Codigo]
				   ,[PathReciboNomina]
				   ,[PathReciboNominaNoTimbrado]				
		         ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'NombreComercial')) as NombreComercial
              FROM [RH].[tblCatClientes]
                WHERE IDCliente = @IDCliente FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

		UPDATE [RH].[tblCatClientes]
		   SET 
			  [GenerarNoNomina] = @GenerarNoNomina,
			  [LongitudNoNomina] = @LongitudNoNomina,
			  [Prefijo] = @Prefijo,
			  [NombreComercial] = @NombreComercial,
			  [Codigo] = @Codigo,
			  [PathReciboNomina] = @PathReciboNomina,
			  [PathReciboNominaNoTimbrado] = @PathReciboNominaNoTimbrado,
			  Traduccion			= case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
		 WHERE IDCliente = @IDCliente
		
		select @NewJSON =  (SELECT IDCliente
                    ,[GenerarNoNomina]
				   ,[LongitudNoNomina]
				   ,[Prefijo]		
				   ,[Codigo]
				   ,[PathReciboNomina]
				   ,[PathReciboNominaNoTimbrado]				
		         ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'NombreComercial')) as NombreComercial
              FROM [RH].[tblCatClientes]
                WHERE IDCliente = @IDCliente FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

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
