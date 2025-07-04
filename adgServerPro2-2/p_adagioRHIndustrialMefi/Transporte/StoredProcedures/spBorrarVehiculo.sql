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
CREATE PROCEDURE [Transporte].[spBorrarVehiculo]
(
	@IDVehiculo int,
    @Status int,
	@IDUsuario int
)
AS
BEGIN
    DECLARE @NewJSON Varchar(Max)   
    UPDATE  [Transporte].[tblCatVehiculos]  set [Status]=@Status where IDVehiculo=@IDVehiculo;
    select @NewJSON = a.JSON from [Transporte].[tblCatVehiculos] b
    Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
    WHERE b.IDVehiculo = @IDVehiculo

    if @Status = 0
    begin 
        EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Transporte].[tblCatVehiculos]','[Transporte].[spBorrarVehiculo]','UPDATE-DISABLED',@NewJSON,''
    end 
    ELSE
    begin 
        EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Transporte].[tblCatVehiculos]','[Transporte].[spBorrarVehiculo]','UPDATE-ENABLED',@NewJSON,''
    end     
END
GO
