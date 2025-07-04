USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-02  
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROCEDURE [Transporte].[spBorrarRutaProgramadaVehiculo]
(
	@IDRutaProgramadaVehiculo int,
	@IDUsuario int
)
AS
BEGIN

    DECLARE @OldJSON Varchar(Max),
    @NewJSON Varchar(Max)
    
    select @OldJSON = a.JSON from [Transporte].[tblRutasProgramadasVehiculos] b
    Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
    WHERE b.IDRutaProgramadaVehiculo = IDRutaProgramadaVehiculo
    

    BEGIN TRY  

        Delete Transporte.tblRutasProgramadasVehiculos
	    where IDRutaProgramadaVehiculo = @IDRutaProgramadaVehiculo	 

	    
        EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Transporte].[tblRutasProgramadasVehiculos]','[Transporte].[spBorrarRutaProgramadaVehiculo]','DELETE','',@OldJSON

    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;

END
GO
