USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-14
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE proc [Transporte].[spIURutaDetalle](
        @IDRutaDetalle         INT =0,
        @IDRuta     INT =0,
        @Orden         INT =0,
        @Parada        VARCHAR (100)  ='',        
        @IDUsuario int null	 		
	)
AS  
BEGIN  

    DECLARE @OldJSON Varchar(Max),
	    @NewJSON Varchar(Max)		 

    IF(@IDRutaDetalle = 0)  
    BEGIN  	
	    INSERT INTO [Transporte].[tblCatRutasDetalle]
			   (IDRuta,Orden,Parada)
		        VALUES
			    (@IDRuta,@Orden,@Parada)
 
	  	select @NewJSON = a.JSON from [Transporte].[tblCatRutasDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRutaDetalle = @IDRutaDetalle
		--EXEC [Auditoria].[spIAuditoria] @IDVehiculo,'[Transporte].[tblCatRutasDetalle]','[Transporte].[spIURutaDetalle]','INSERT',@NewJSON,''*/

 END  
 ELSE  
    BEGIN  	

        UPDATE [Transporte].[tblCatRutasDetalle]
        SET     [IDRuta] = @IDRuta,
                [Orden]=@Orden,
                [Parada]=@Parada
        WHERE [IDRutaDetalle] = @IDRutaDetalle
    
        select @NewJSON = a.JSON from [Transporte].[tblCatRutasDetalle] b
        Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
        WHERE b.IDRutaDetalle = @IDRutaDetalle

		--EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Transporte].[tblCatRutasDetalle]','[Transporte].[spIURutaDetalle]','UPDATE',@NewJSON,''
    END   	
END
GO
