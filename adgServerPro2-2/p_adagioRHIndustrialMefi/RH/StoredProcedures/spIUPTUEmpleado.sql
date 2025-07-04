USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Insertar/Actualizar la sección de PTU del colaborador    
** Autor   : Jose Roman   
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2019-04-29    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
  
***************************************************************************************************/    
CREATE proc [RH].[spIUPTUEmpleado](    
     @IDEmpleadoPTU int  = 0  
    ,@IDEmpleado int    
	,@PTU bit = 0   
    ,@IDUsuario int    
) as     
    select @IDEmpleadoPTU=isnull(IDEmpleadoPTU,0)    
    from [RH].[tblEmpleadoPTU] with (NOLOCK)    
    where IDEmpleado = @IDEmpleado   
	
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 
    
    if (@IDEmpleadoPTU = 0 or @IDEmpleadoPTU is null)    
    begin    
		insert into [RH].[tblEmpleadoPTU](IDEmpleado,PTU)    
		select @IDEmpleado,@PTU
    
		select @IDEmpleadoPTU = @@identity;  
		
		select @NewJSON = a.JSON from [RH].[tblEmpleadoPTU] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleadoPTU = @IDEmpleadoPTU

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblEmpleadoPTU]','[RH].[spIUPTUEmpleado]','INSERT',@NewJSON,''
	  
    end else    
    begin    

		select @OldJSON = a.JSON from [RH].[tblEmpleadoPTU] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDEmpleadoPTU = @IDEmpleadoPTU

		update [RH].[tblEmpleadoPTU]    
		set PTU = ISNULL(@PTU,0)    
		where IDEmpleadoPTU = @IDEmpleadoPTU    

		select @NewJSON = a.JSON from [RH].[tblEmpleadoPTU] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleadoPTU = @IDEmpleadoPTU

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblEmpleadoPTU]','[RH].[spIUPTUEmpleado]','UDPATE',@NewJSON,@OldJSON
    end;    
    
    update [RH].[tblEmpleadoPTU]    
    set PTU = @PTU    
    where IDEmpleado = @IDEmpleado       
    
    --exec [Bk].[spIEmpleadoActualizado]    
    -- @IDEmpleado = @IDEmpleado    
    --,@Tabla = '[RH].[TblSaludEmpleado]'    
    --,@IDUsuario = @IDUsuario    
    
    exec [RH].[spBuscarPTUEmpleado] @IDEmpleadoPTU = @IDEmpleadoPTU    
    --exec [Bk].[spIEmpleadoActualizado]    
    -- @IDEmpleado = @IDEmpleado    
    --,@Tabla = '[RH].[tblBrigadasEmpleado]'    
    --,@IDUsuario = @IDUsuario    
    
 EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
GO
