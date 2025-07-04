USE [p_adagioRHIndustrialMefi]
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
Fecha(yyyy-mm-dd)	Autor					Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00			NombreCompleto			¿Qué cambió?  
2018-07-06			Jose Roman				Se agrega Procedure para proceso de Sincronizacion  
2018-07-09			Aneudy Abreu			Se agregó el parámetro IDUsuario  
2022-05-21			Aneudy Abreu			Se agregó el parámetro CodigoLector  
***************************************************************************************************/  
CREATE proc [RH].[spUAsistenciaEmpleado](  
     @IDEmpleado     int  
	,@PermiteChecar bit
	,@RequiereChecar bit
	,@PagarTiempoExtra bit
	,@PagarPrimaDominical bit
	,@PagarDescansoLaborado bit
	,@PagarFestivoLaborado  bit
	,@CodigoLector varchar(50) = null
    ,@RequiereTransporte bit =null
    ,@OmitirGeolocalizacion bit=null
    ,@IDUsuario int  
) as   

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max),
    @tran int;

  set @tran = @@TRANCOUNT

	select @OldJSON = a.JSON from [RH].[TblEmpleados] b
		cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDEmpleado = @IDEmpleado

    update [RH].[TblEmpleados]  
		set  
			PermiteChecar		= @PermiteChecar       
			,RequiereChecar		= @RequiereChecar  
			,PagarTiempoExtra   = @PagarTiempoExtra       
			,PagarPrimaDominical	= @PagarPrimaDominical       
			,PagarDescansoLaborado  = @PagarDescansoLaborado       
			,PagarFestivoLaborado   = @PagarFestivoLaborado       
			,CodigoLector			= @CodigoLector     
            ,RequiereTransporte= isnull(@RequiereTransporte,RequiereTransporte)
    where IDEmpleado = @IDEmpleado  
	
	select @NewJSON = a.JSON from [RH].[TblEmpleados] b
		cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDEmpleado = @IDEmpleado

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblEmpleados]','[RH].[spUAsistenciaEmpleado]','UPDATE',@NewJSON,@OldJSON
  if(@tran = 0)
	BEGIN
		EXEC [RH].[spIUGeolocalizacionEmpleado]
			@IDEmpleado = @IDEmpleado    
			,@OmitirGeolocalizacion  = @OmitirGeolocalizacion   
			,@IDUsuario = @IDUsuario    
	END
	ELSE
	BEGIN
		EXEC [RH].[spIUGeolocalizacionEmpleado]
			@IDEmpleado = @IDEmpleado    
			,@OmitirGeolocalizacion  =0
			,@IDUsuario = @IDUsuario    
	END
   
   if(@tran = 0)
   BEGIN
		exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado  
   END

	--EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
GO
