USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Actualiza los datos principales del colaborador
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-06-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
2018-07-06		Jose Roman		Se agrega Procedure para proceso de Sincronizacion
2018-07-09		Aneudy Abreu		Se agrega el parámetro IDUsuario
***************************************************************************************************/

CREATE proc [RH].[spUPrincipalesEmpleado](
    @IDEmpleado int
    ,@Nombre		  varchar(50)
    ,@SegundoNombre	  varchar(50)
    ,@Paterno		  varchar(50)
    ,@Materno		  varchar(50)
    ,@FechaAntiguedad date
    ,@FechaIngreso	    date
    ,@IDUsuario int
) as 

	 DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

			select @OldJSON = a.JSON from [RH].[TblEmpleados] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDEmpleado = @IDEmpleado


    update [RH].[TblEmpleados]
    set Nombre		   = @Nombre		  
	   ,SegundoNombre	   = @SegundoNombre	  
	   ,Paterno		   = @Paterno		  
	   ,Materno		   = @Materno		  
	   ,FechaAntiguedad   = @FechaAntiguedad 
	   ,FechaIngreso	   = @FechaIngreso	  
    where IDEmpleado = @IDEmpleado

	select @NewJSON = a.JSON from [RH].[TblEmpleados] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDEmpleado = @IDEmpleado

			--select @NewJSON,@OldJSON

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblEmpleados]','[RH].[spUPrincipalesEmpleado]','UPDATE',@NewJSON,@OldJSON
		   
  

 --   exec [Bk].[spIEmpleadoActualizado]
	--@IDEmpleado = @IDEmpleado
 --   ,@Tabla = '[RH].[TblEmpleados] Principales'
 --   ,@IDUsuario = @IDUsuario
    	
    exec RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
GO
