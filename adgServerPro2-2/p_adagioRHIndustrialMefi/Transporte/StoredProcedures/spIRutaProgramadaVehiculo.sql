USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-22
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE proc [Transporte].[spIRutaProgramadaVehiculo](
        @IDRutaProgramadaVehiculo         INT =0,
        @IDRutaProgramada         INT =0,
        @IDVehiculo         INT =0
        
	)
AS  
BEGIN  

    DECLARE @OldJSON Varchar(Max),
	    @NewJSON Varchar(Max)		 

    declare @IDTipoCosto int ,
    @CostoUnidad DECIMAL ,
    @Capacidad int 
    
    select @IDTipoCosto = IDTipoCosto,
            @CostoUnidad = CostoUnidad,
            @Capacidad = v.CantidadPasajeros
    from Transporte.tblCatVehiculos v where v.IDVehiculo= @IDVehiculo

	    INSERT INTO [Transporte].tblRutasProgramadasVehiculos
			   (IDRutaProgramada,IDVehiculo,IDTipoCosto,CostoUnidad,Capacidad)
		        VALUES
			    (@IDRutaProgramada,@IDVehiculo,@IDTipoCosto,@CostoUnidad,@Capacidad)

        set @IDRutaProgramada=@@IDENTITY;
 
	  	select @NewJSON = a.JSON from [Transporte].[tblRutasProgramadasVehiculos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRutaProgramada = @IDRutaProgramada        

		EXEC [Auditoria].[spIAuditoria] @IDVehiculo,'[Transporte].[spIURutaProgramadaVehiculo]','[Transporte].[tblRutasProgramadasVehiculos]','INSERT',@NewJSON,''
     
END
GO
