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
CREATE proc [Transporte].[spIURutaHorarios](
        @IDRutaHorario         INT =0,
        @IDRuta     INT =0,
        @HoraSalida time ,
        @HoraLlegada time,
        @StrIDHorarios varchar(max)
	)
AS  
BEGIN  

    DECLARE @OldJSON Varchar(Max),
	    @NewJSON Varchar(Max)		 

    IF(@IDRutaHorario = 0)  
    BEGIN  	

        select * from [Transporte].[tblCatRutasHorarios]
	    INSERT INTO [Transporte].[tblCatRutasHorarios]
			   (IDRuta,HoraSalida,HoraLlegada)
		        VALUES
			    (@IDRuta,@HoraSalida,@HoraLlegada)
 
	  	/*select @NewJSON = a.JSON from [Transporte].[tblCatRutasHorarios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRutaHorario = @IDRutaHorario
		--EXEC [Auditoria].[spIAuditoria] @IDVehiculo,'[Transporte].[tblCatRutasDetalle]','[Transporte].[spIURutaDetalle]','INSERT',@NewJSON,''*/
        set @IDRutaHorario=@@IDENTITY;

        
        INSERT INTO Transporte.tblCatRutasHorariosDetalle (IDRutaHorario,IDHorario)
        SELECT  @IDRutaHorario,item  from  App.Split(@StrIDHorarios,',')
        --select @IDRutaHorario  [IDRutaHorario]


    END  
 ELSE  
    BEGIN  	

        UPDATE [Transporte].[tblCatRutasHorarios]
        SET     [IDRuta] = @IDRuta,
                [HoraSalida]=@HoraSalida,
                [HoraLlegada]=@HoraLlegada                
        WHERE [IDRutaHorario] = @IDRutaHorario



        DELETE Transporte.tblCatRutasHorariosDetalle  WHERE IDRutaHorario=@IDRutaHorario
        
        INSERT INTO Transporte.tblCatRutasHorariosDetalle (IDRutaHorario,IDHorario)
        SELECT  @IDRutaHorario,item  from  App.Split(@StrIDHorarios,',')
    
        /*select @NewJSON = a.JSON from [Transporte].[tblCatRutasHorarios] b
        Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
        WHERE b.IDRutaHorario = @IDRutaHorario

		--EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Transporte].[tblCatRutasDetalle]','[Transporte].[spIURutaDetalle]','UPDATE',@NewJSON,''*/
        
    END   	
END
GO
