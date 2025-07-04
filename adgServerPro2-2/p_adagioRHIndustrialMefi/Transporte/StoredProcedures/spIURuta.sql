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
CREATE proc [Transporte].[spIURuta](
        @IDRuta         INT =0,
        @Descripcion   VARCHAR (250)  ='',
        @ClaveRuta     VARCHAR (100)  ='',
        @Origen         VARCHAR (100)  ='',                              
        @Destino        VARCHAR (100)  ='',
        @KMRuta    INT          =0,        
        @IDUsuario int null	 		
	)
AS  
BEGIN  

	select
		@Descripcion = UPPER(@Descripcion),
		@ClaveRuta   = UPPER(@ClaveRuta  ),
		@Origen    	 = UPPER(@Origen     ),
		@Destino	 = UPPER(@Destino	 )

    DECLARE @OldJSON Varchar(Max),
	    @NewJSON Varchar(Max)		 

    IF(@IDRuta = 0)  
    BEGIN  	
        if exists (select top 1 1 from  Transporte.tblCatRutas  n where   n.IDRuta=@IDRuta)
        begin
            raiserror('El Código de la ruta se encuentra en uso.',16,1);
            return;
        end;

	    INSERT INTO [Transporte].[tblCatRutas]
			   (Origen,Destino,KMRuta,ClaveRuta,Descripcion,IDUsuario)
		        VALUES
			    (@Origen,@Destino,@KMRuta,@ClaveRuta,@Descripcion,@IDUsuario)
 
	  	select @NewJSON = a.JSON from [Transporte].[tblCatRutas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRuta = @IDRuta
        
        set @IDRuta=@@IDENTITY;
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Transporte].[tblCatRutas]','[Transporte].[spIURuta]','INSERT',@NewJSON,''

 END  
 ELSE  
    BEGIN  	

        select @OldJSON = a.JSON from [Transporte].[tblCatRutas] b
        Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
        WHERE b.IDRuta = @IDRuta

        UPDATE [Transporte].[tblCatRutas]
        SET     [Origen] = @Origen,
                [Destino]=@Destino,
                [KMRuta]=@KMRuta,
                [ClaveRuta]=@ClaveRuta,
                Descripcion=@Descripcion,                     
                IDUsuario = @IDUsuario           
        WHERE [IDRuta] = @IDRuta
    
        select @NewJSON = a.JSON from [Transporte].[tblCatRutas] b
        Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
        WHERE b.IDRuta = @IDRuta

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Transporte].[tblCatRutas]','[Transporte].[spIURuta]','UPDATE',@NewJSON,@OldJSON
    END   	

    select @IDRuta [IDRuta];
END
GO
