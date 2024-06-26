USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Actualiza la sección Nómina CFDI del colaborador  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2018-06-19  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
2018-07-06  Jose Roman   Se agrega Procedure para proceso de Sincronizacion  
2018-07-09  Aneudy Abreu  Se agregó el parámetro IDUsuario  
2019-08-30  Jose Roman  Se agregó el parámetro PTU  
***************************************************************************************************/  
  
CREATE proc [RH].[spUNominaCFDIEmpleado](  
     @IDEmpleado     int  
    ,@IDTipoRegimen     int    = null  
    ,@IDJornadaLaboral int    = null  
    ,@CuentaContable varchar(50)  = null  
	,@PTU bit = 0
    ,@IDUsuario int  
) as   
   
 select   
  @IDTipoRegimen = case when @IDTipoRegimen = 0 then null else @IDTipoRegimen end  
  ,@IDJornadaLaboral = case when @IDJornadaLaboral = 0 then null else @IDJornadaLaboral end  
  
   
  	 DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

			select @OldJSON = a.JSON from [RH].[TblEmpleados] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDEmpleado = @IDEmpleado

		 

    update [RH].[TblEmpleados]  
    set IDTipoRegimen    = @IDTipoRegimen     
        ,IDJornadaLaboral   = @IDJornadaLaboral  
        ,CuentaContable    = @CuentaContable  
    where IDEmpleado = @IDEmpleado  

	
			select @NewJSON = a.JSON from [RH].[TblEmpleados] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDEmpleado = @IDEmpleado

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblEmpleados]','[RH].[spUNominaCFDIEmpleado]','UPDATE',@NewJSON,@OldJSON
		   
  
 EXEC [RH].[spIUPTUEmpleado]
    @IDEmpleado = @IDEmpleado    
	,@PTU  = @PTU   
    ,@IDUsuario = @IDUsuario    

    
	
	--exec [Bk].[spIEmpleadoActualizado]  
 --@IDEmpleado = @IDEmpleado  
 --   ,@Tabla = '[RH].[TblEmpleados] NominaCFDI'  
 --   ,@IDUsuario = @IDUsuario  
      


    EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
GO
