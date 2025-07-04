USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************
** Descripción     : 
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2024-05-08
** Parámetros      :    
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE   PROCEDURE [FirmaDigital].[spBorrarDocumentosFirmantes](    	
    @IDFirmante varchar(max)
    ,@IDUsuario int = 0    
)
AS
BEGIN
    
    declare 
        @OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[FirmaDigital].[spBorrarDocumentosFirmantes]',
		@Tabla		varchar(max) = '[FirmaDigital].[tblDocumentosFirmantes]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)

	;


    BEGIN TRY  
            
            DELETE FROM FirmaDigital.tblDocumentosFirmantes WHERE IDFirmante=@IDFirmante
    

			EXEC [Auditoria].[spIAuditoria]
				@IDUsuario		= @IDUsuario
				,@Tabla			= @Tabla
				,@Procedimiento	= @NombreSP
				,@Accion		= @Accion
				,@NewData		= @NewJSON
				,@OldData		= @OldJSON
				,@Mensaje		= @Mensaje
				,@InformacionExtra		= @InformacionExtra
        
		  
    END TRY  
    BEGIN CATCH  
	  EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   
    END CATCH ;

    

END
GO
