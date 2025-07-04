USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-03-03
** Paremetros  :                  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROCEDURE [Transporte].[spBorrarRutaHorario]
(
	@IDRutaHorario int,
	@IDUsuario int
)
AS
BEGIN

    DECLARE @OldJSON Varchar(Max),
    @NewJSON Varchar(Max)
    
    select @OldJSON = a.JSON from [Transporte].[tblCatRutasHorarios] b
    Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
    WHERE b.IDRutaHorario = @IDRutaHorario
    

    BEGIN TRY  

        delete Transporte.tblCatRutasHorariosDetalle WHERE IDRutaHorario=@IDRutaHorario

	    Delete Transporte.tblCatRutasHorarios where IDRutaHorario = @IDRutaHorario	 

        --EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Transporte].[tblCatRutasHorarios]','[Transporte].[spBorrarRutaHorario]','DELETE','',@OldJSON

    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;

END
GO
