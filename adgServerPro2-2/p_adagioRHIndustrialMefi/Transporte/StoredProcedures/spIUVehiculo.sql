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
CREATE proc [Transporte].[spIUVehiculo](
        @IDVehiculo         INT =0,
        @ClaveVehiculo     VARCHAR (20)  ='',
        @IDMarcaVehiculo   INT          =0,
        @IDTipoVehiculo       INT          =0,
        @IDTipoCombustible    INT          =0,
        @IDTipoCosto    INT          =0,
        @CantidadPasajeros    INT          =0,
        @NumeroEconomico    INT          =0,
        @CostoUnidad  decimal (10,2) =0.00,
        @IDUsuario int null	 		
	)
AS  
BEGIN  

    DECLARE @OldJSON Varchar(Max),
	    @NewJSON Varchar(Max)		 

    

    IF(@IDVehiculo = 0)  
    BEGIN  	
        if exists (select top 1 1 from  Transporte.tblCatVehiculos  n where   n.ClaveVehiculo=@ClaveVehiculo)
        begin
            raiserror('El Código del vehículo se encuentra en uso.',16,1);
            return;
        end;
	    INSERT INTO [Transporte].[tblCatVehiculos]
			   (ClaveVehiculo,IDMarcaVehiculo,IDTipoCosto,IDTipoVehiculo,IDTipoCombustible,CantidadPasajeros,NumeroEconomico,CostoUnidad)
		        VALUES
                ( @ClaveVehiculo,@IDMarcaVehiculo,@IDTipoCosto,@IDTipoVehiculo,@IDTipoCombustible,@CantidadPasajeros,@NumeroEconomico,@CostoUnidad)
 
	  	select @NewJSON = a.JSON from [Transporte].[tblCatVehiculos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDVehiculo = @IDVehiculo

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Transporte].[tblCatVehiculos]','[Transporte].[spIUVehiculo]','INSERT',@NewJSON,''

 END  
 ELSE  
    BEGIN  	

        select @OldJSON = a.JSON from [Transporte].[tblCatVehiculos] b
        Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
        WHERE b.IDVehiculo = @IDVehiculo

        UPDATE [Transporte].[tblCatVehiculos]
        SET     
                [IDMarcaVehiculo] = @IDMarcaVehiculo,
                [IDTipoCosto] = @IDTipoCosto,
                [ClaveVehiculo]=@ClaveVehiculo,
                [IDTipoVehiculo]=@IDTipoVehiculo,
                [IDTipoCombustible]=@IDTipoCombustible,
                [CantidadPasajeros]=@CantidadPasajeros,
                [CostoUnidad]=@CostoUnidad,
                [NumeroEconomico]=@NumeroEconomico	   
        WHERE [IDVehiculo] = @IDVehiculo        

        select @NewJSON = a.JSON from [Transporte].[tblCatVehiculos] b
        Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
        WHERE b.IDVehiculo = @IDVehiculo

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Transporte].[tblCatVehiculos]','[Transporte].[spIUVehiculo]','UPDATE',@NewJSON,@OldJSON

    END   	
END
GO
