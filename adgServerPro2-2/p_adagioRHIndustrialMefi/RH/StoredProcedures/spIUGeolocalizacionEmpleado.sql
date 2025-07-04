USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Insertar/Actualizar la sección de PTU del colaborador    
** Autor   : Andrea Zainos   
** Email   : azainosn@adagio.com.mx    
** FechaCreacion : 2024-12-04    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
  
***************************************************************************************************/    
CREATE proc [RH].[spIUGeolocalizacionEmpleado](    
     @IDEmpleadoGeolocalizacion int  = 0  
    ,@IDEmpleado int    
	,@OmitirGeolocalizacion bit = 0   
    ,@IDUsuario int    
) as     
    select @IDEmpleadoGeolocalizacion=isnull(IDEmpleadoGeolocalizacion,0)    
    from [RH].[tblEmpleadoGeolocalizacion] with (NOLOCK)    
    where IDEmpleado = @IDEmpleado   
	
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 
    
    if (@IDEmpleadoGeolocalizacion = 0 or @IDEmpleadoGeolocalizacion is null)    
    begin    
		insert into [RH].[tblEmpleadoGeolocalizacion](IDEmpleado,OmitirGeolocalizacion)    
		select @IDEmpleado,@OmitirGeolocalizacion
    
		select @IDEmpleadoGeolocalizacion = @@identity;  
		
		select @NewJSON = a.JSON from [RH].[tblEmpleadoGeolocalizacion] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleadoGeolocalizacion = @IDEmpleadoGeolocalizacion

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblEmpleadoGeolocalizacion]','[RH].[spIUPTUEmpleado]','INSERT',@NewJSON,''
	  
    end else    
    begin    

		select @OldJSON = a.JSON from [RH].[tblEmpleadoGeolocalizacion] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDEmpleadoGeolocalizacion = @IDEmpleadoGeolocalizacion

		update [RH].[tblEmpleadoGeolocalizacion]    
		set OmitirGeolocalizacion = ISNULL(@OmitirGeolocalizacion,0)    
		where IDEmpleadoGeolocalizacion = @IDEmpleadoGeolocalizacion    

		select @NewJSON = a.JSON from [RH].[tblEmpleadoGeolocalizacion] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleadoGeolocalizacion = @IDEmpleadoGeolocalizacion

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblEmpleadoGeolocalizacion]','[RH].[spIUPTUEmpleado]','UDPATE',@NewJSON,@OldJSON
    end;    
    
 
    
 
    --exec [RH].[spBuscarPTUEmpleado] @IDEmpleadoPTU = @IDEmpleadoPTU    

    
 EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
GO
