USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Actualiza la sección Asistencia del colaborador  
** Autor   : Jose Roman
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 2018-10-25  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
2018-07-06  Jose Roman   Se agrega Procedure para proceso de Sincronizacion  
2018-07-09  Aneudy Abreu  Se agregó el parámetro IDUsuario  
***************************************************************************************************/  
  
CREATE proc [RH].[spUAsistenciaEmpleado](  
     @IDEmpleado     int  
	,@PermiteChecar bit
	,@RequiereChecar bit
	,@PagarTiempoExtra bit
	,@PagarPrimaDominical bit
	,@PagarDescansoLaborado bit
	,@PagarFestivoLaborado  bit
    ,@IDUsuario int  
) as   

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	select @OldJSON = a.JSON from [RH].[TblEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleado = @IDEmpleado

    update [RH].[TblEmpleados]  
    set  PermiteChecar    = @PermiteChecar       
    ,RequiereChecar  = @RequiereChecar  
    ,PagarTiempoExtra    = @PagarTiempoExtra       
    ,PagarPrimaDominical    = @PagarPrimaDominical       
    ,PagarDescansoLaborado    = @PagarDescansoLaborado       
    ,PagarFestivoLaborado    = @PagarFestivoLaborado       
    where IDEmpleado = @IDEmpleado  

	
		select @NewJSON = a.JSON from [RH].[TblEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleado = @IDEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblEmpleados]','[RH].[spUAsistenciaEmpleado]','UPDATE',@NewJSON,@OldJSON
  
 --   exec [Bk].[spIEmpleadoActualizado]  
 --@IDEmpleado = @IDEmpleado  
 --   ,@Tabla = '[RH].[TblEmpleados] Estudios'  
 --   ,@IDUsuario = @IDUsuario  
      
 EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
GO
