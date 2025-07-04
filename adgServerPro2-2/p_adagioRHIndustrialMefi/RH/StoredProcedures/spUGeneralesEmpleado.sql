USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Actualiza la sección  Datos Generales del colaborador
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
2018-07-09		Aneudy Abreu		Se agrega el parámetro IDUsuario
***************************************************************************************************/

CREATE proc [RH].[spUGeneralesEmpleado](
    @IDEmpleado int
    ,@RFC					  varchar(20)
    ,@CURP				  varchar(20)
    ,@IMSS				  varchar(20)
    ,@IDLocalidadNacimiento  int 
    ,@IDMunicipioNacimiento  int 
    ,@IDEstadoNacimiento	    int 
    ,@IDPaisNacimiento	    int 
	,@LocalidadNacimiento  Varchar(255) 
    ,@MunicipioNacimiento  Varchar(255) 
    ,@EstadoNacimiento	   Varchar(255) 
    ,@PaisNacimiento	    Varchar(255) 
    ,@FechaNacimiento	   date
    ,@IDEstadoCivil		   int
    ,@Sexo			   char(1)
    ,@IDAfore			   int
    ,@IDUsuario int
) as 
    if (@IDAfore = 0) set @IDAfore = null;

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	select @OldJSON = a.JSON from [RH].[TblEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleado = @IDEmpleado

    update [RH].[TblEmpleados]
    set RFC				   = @RFC				
	   ,CURP				   = @CURP			
	   ,IMSS				   = @IMSS		
	   ,IDLocalidadNacimiento  = CASE WHEN @IDLocalidadNacimiento = 0 THEN NULL ELSE @IDLocalidadNacimiento END 	
	   ,IDMunicipioNacimiento  = CASE WHEN @IDMunicipioNacimiento  = 0 THEN NULL ELSE @IDMunicipioNacimiento END 
	   ,IDEstadoNacimiento	   = CASE WHEN @IDEstadoNacimiento  = 0 THEN NULL ELSE @IDEstadoNacimiento END  
	   ,IDPaisNacimiento	   = CASE WHEN @IDPaisNacimiento  = 0 THEN NULL ELSE @IDPaisNacimiento END  
	   ,LocalidadNacimiento    = @LocalidadNacimiento	
	   ,MunicipioNacimiento    = @MunicipioNacimiento
	   ,EstadoNacimiento	   = @EstadoNacimiento	  
	   ,PaisNacimiento		   = @PaisNacimiento	  
	   ,FechaNacimiento	  	   = @FechaNacimiento	  
	   ,IDEstadoCivil		   = CASE WHEN @IDEstadoCivil  = 0 THEN NULL ELSE @IDEstadoCivil END   
	   ,Sexo			  	   = @Sexo			  
	   ,IDAfore			   = CASE WHEN @IDAfore  = 0 THEN NULL ELSE @IDAfore END  	  
    where IDEmpleado = @IDEmpleado


		select @NewJSON = a.JSON from [RH].[TblEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleado = @IDEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblEmpleados]','[RH].[spUGeneralesEmpleado]','UPDATE',@NewJSON,@OldJSON
  


 --   exec [Bk].[spIEmpleadoActualizado]
	--@IDEmpleado = @IDEmpleado
 --   ,@Tabla = '[RH].[TblEmpleados] Generales'
 --   ,@IDUsuario = @IDUsuario
	
	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
GO
