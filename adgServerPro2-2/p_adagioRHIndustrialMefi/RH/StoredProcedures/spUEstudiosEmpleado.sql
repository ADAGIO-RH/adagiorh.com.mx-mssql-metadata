USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Actualiza la sección Estúdios del colaborador
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-06-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
2018-07-06		Jose Roman			Se agrega Procedure para proceso de Sincronizacion
2018-07-09		Aneudy Abreu		Se agregó el parámetro IDUsuario
***************************************************************************************************/

CREATE proc [RH].[spUEstudiosEmpleado](
     @IDEmpleado			  int
    ,@IDEscolaridad		    int
    ,@DescripcionEscolaridad nvarchar(max)
    ,@IDInstitucion		    int
    ,@IDProbatorio		    int
    ,@IDUsuario int
) as 


	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	select @OldJSON = a.JSON from [RH].[TblEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleado = @IDEmpleado

    update [RH].[TblEmpleados]
    set  IDEscolaridad			 = case when @IDEscolaridad	= 0 then NULL else @IDEscolaridad END	   
	   ,DescripcionEscolaridad	 = @DescripcionEscolaridad
	   ,IDInstitucion			 = case when @IDInstitucion = 0 then null else @IDInstitucion END		   
	   ,IDProbatorio			 = case when @IDProbatorio	= 0 then null else @IDProbatorio END	   
    where IDEmpleado = @IDEmpleado


	
		select @NewJSON = a.JSON from [RH].[TblEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleado = @IDEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblEmpleados]','[RH].[spUEstudiosEmpleado]','UPDATE',@NewJSON,@OldJSON
  

 --   exec [Bk].[spIEmpleadoActualizado]
	--@IDEmpleado = @IDEmpleado
 --   ,@Tabla = '[RH].[TblEmpleados] Estudios'
 --   ,@IDUsuario = @IDUsuario
    
	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
GO
