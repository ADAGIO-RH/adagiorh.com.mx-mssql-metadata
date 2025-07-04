USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatClasificacionesCorporativas]
(
	@IDClasificacionCorporativa int,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE @IDIdioma VARCHAR(MAX);
	SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx');

	Select 
	   IDClasificacionCorporativa
	   ,Codigo
	   --,Descripcion
	   , ISNULL(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS Descripcion
	   ,CuentaContable
	   ,ROW_NUMBER()over(ORDER BY IDClasificacionCorporativa)as ROWNUMBER
    FROM RH.tblCatClasificacionesCorporativas
    Where IDClasificacionCorporativa = @IDClasificacionCorporativa

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = (SELECT  IDClasificacionCorporativa
                            ,Codigo                         
                            ,CuentaContable
		                    ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
              FROM [RH].[tblCatClasificacionesCorporativas]
                WHERE IDClasificacionCorporativa=@IDClasificacionCorporativa FOR JSON PATH,WITHOUT_ARRAY_WRAPPER)


		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatClasificacionesCorporativas]','[RH].[spBorrarCatClasificacionesCorporativas]','DELETE','',@OldJSON


    BEGIN TRY  
	   Delete RH.tblCatClasificacionesCorporativas
	   where IDClasificacionCorporativa = @IDClasificacionCorporativa

	  EXEC [Seguridad].[spBorrarFiltrosUsuariosMasivoCatalogo] 
	 @IDFiltrosUsuarios  = 0  
	 ,@IDUsuario  = @IDUsuario   
	 ,@Filtro = 'ClasificacionesCorporativas'  
	 ,@ID = @IDClasificacionCorporativa   
	 ,@Descripcion = ''
	 ,@IDUsuarioLogin = @IDUsuario 

    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;


END
GO
