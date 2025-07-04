USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Insertar/Actualizar la sección de SUBSIDIO del colaborador    
** Autor   : Jose Roman   
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2024-05-02    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
  
***************************************************************************************************/    
CREATE proc [RH].[spIUSubsidioEmpleado](    
     @IDSubsidioEmpleado int  = 0  
    ,@IDEmpleado int    
	,@Subsidio bit = 0   
    ,@IDUsuario int    
) 
AS
BEGIN
    select @IDSubsidioEmpleado=isnull(IDSubsidioEmpleado,0)    
    from [Nomina].[TblSubsidioEmpleado] with (NOLOCK)    
    where IDEmpleado = @IDEmpleado   
	
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 
    
    if (@IDSubsidioEmpleado = 0 or @IDSubsidioEmpleado is null)    
    begin    
		insert into [Nomina].[TblSubsidioEmpleado](IDEmpleado,Subsidio)    
		select @IDEmpleado,isnull(@Subsidio,0)
    
		select @IDSubsidioEmpleado = @@identity;  
		
		select @NewJSON = a.JSON from [Nomina].[TblSubsidioEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDSubsidioEmpleado = @IDSubsidioEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[TblSubsidioEmpleado]','[RH].[spIUSubsidioEmpleado]','INSERT',@NewJSON,''
	  
    end else    
    begin    

		select @OldJSON = a.JSON from [Nomina].[TblSubsidioEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDSubsidioEmpleado = @IDSubsidioEmpleado

		update [Nomina].[TblSubsidioEmpleado] 
		set Subsidio = ISNULL(@Subsidio,0)    
		where IDSubsidioEmpleado = @IDSubsidioEmpleado

		select @NewJSON = a.JSON from [Nomina].[TblSubsidioEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDSubsidioEmpleado = @IDSubsidioEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[TblSubsidioEmpleado]','[RH].[spIUSubsidioEmpleado]','UDPATE',@NewJSON,@OldJSON
    end;    
    
    update [Nomina].[TblSubsidioEmpleado] 
    set Subsidio = ISNULL(@Subsidio,0)     
    where IDEmpleado = @IDEmpleado       
    
    exec [RH].[spBuscarSubsidioEmpleado] @IDSubsidioEmpleado = @IDSubsidioEmpleado    
    
END
GO
