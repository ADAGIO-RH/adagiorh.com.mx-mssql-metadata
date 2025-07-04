USE [p_adagioRHIndustrialMefi]
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
    ,@DomicilioFiscal varchar(50)  = null  
	,@IDRegimenFiscal     int    = null  
	,@IDTipoJornada     int    = null  
	,@Subsidio bit = 0
    ,@IDUsuario int  
) as   
    DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@AltaColaboradorSubsidioDefault bit,
		@tran int
	;
	
    set @tran = @@TRANCOUNT

	Select top 1 @AltaColaboradorSubsidioDefault = CAST(isnull(Valor,'0') as bit) 
	from App.tblConfiguracionesGenerales with(nolock) 
	where IDConfiguracion = 'AltaColaboradorSubsidioDefault'


	select   
		@IDTipoRegimen		= case when @IDTipoRegimen = 0 then null else @IDTipoRegimen end  
		,@IDRegimenFiscal	= case when @IDRegimenFiscal = 0 then null else @IDRegimenFiscal end  
		,@IDJornadaLaboral	= case when @IDJornadaLaboral = 0 then null else @IDJornadaLaboral end  
		,@IDTipoJornada		= case when @IDTipoJornada = 0 then null else @IDTipoJornada end  

	select @OldJSON = a.JSON from [RH].[TblEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDEmpleado = @IDEmpleado

	update [RH].[TblEmpleados]  
	set IDTipoRegimen    = @IDTipoRegimen     
		,IDJornadaLaboral   = @IDJornadaLaboral  
		,CuentaContable    = @CuentaContable  
		,DomicilioFiscal = @DomicilioFiscal
		,IDRegimenFiscal = @IDRegimenFiscal
		,IDTipoJornada   = @IDTipoJornada  
	where IDEmpleado = @IDEmpleado  
	
	select @NewJSON = a.JSON from [RH].[TblEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDEmpleado = @IDEmpleado

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblEmpleados]','[RH].[spUNominaCFDIEmpleado]','UPDATE',@NewJSON,@OldJSON
	
	EXEC [RH].[spIUPTUEmpleado]
			@IDEmpleado = @IDEmpleado    
			,@PTU  = @PTU   
			,@IDUsuario = @IDUsuario    

	if(@tran = 0)
	BEGIN
		EXEC [RH].[spIUSubsidioEmpleado]
			@IDEmpleado = @IDEmpleado    
			,@Subsidio  = @Subsidio   
			,@IDUsuario = @IDUsuario    
	END
	ELSE
	BEGIN
		EXEC [RH].[spIUSubsidioEmpleado]
			@IDEmpleado = @IDEmpleado    
			,@Subsidio  = @AltaColaboradorSubsidioDefault   
			,@IDUsuario = @IDUsuario    
	END
   
   if(@tran = 0)
   BEGIN
		exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado  
   END
GO
