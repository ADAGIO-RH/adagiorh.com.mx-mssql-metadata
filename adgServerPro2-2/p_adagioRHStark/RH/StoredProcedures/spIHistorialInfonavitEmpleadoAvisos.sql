USE [p_adagioRHStark]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Inserta nuevos movimientos a los créditos de infonativ
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-09-18
** Paremetros		:              

** DataTypes Relacionados: 

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [RH].[spIHistorialInfonavitEmpleadoAvisos](
		@IDInfonavitEmpleado int = 0      
		,@IDEmpleado int      
		,@IDRegPatronal int      
		,@NumeroCredito varchar(10)      
		,@Fecha date      
		,@IDTipoDescuento int      
		,@ValorDescuento decimal(18,4)      
		,@AplicaDisminucion bit = 0 
		,@IDTipoAvisoInfonavit int
		,@FolioAviso varchar(50)
		,@IDUsuario int
) as

 declare @ActualIDInfonavitEmpleado	int
		,@ActualIDEmpleado			int
		,@ActualIDRegPatronal		int
		,@ActualNumeroCredito		nvarchar(20)
		,@ActualIDTipoMovimiento	int
		,@ActualFecha				date
		,@ActualIDTipoDescuento		int
		,@ActualValorDescuento		decimal
		,@ActualAplicaDisminucion	bit

		,@msgCambioNumeroCredito varchar(200)
		,@ID int
		,@IDTipoMovimiento int
	;

	 
		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);




	 --select 
		-- @ActualIDInfonavitEmpleado	=IDInfonavitEmpleado
		--,@ActualIDEmpleado			=IDEmpleado
		--,@ActualIDRegPatronal		=IDRegPatronal
		--,@ActualNumeroCredito		=NumeroCredito
		--,@ActualIDTipoMovimiento	=IDTipoMovimiento
		--,@ActualFecha				=Fecha
		--,@ActualIDTipoDescuento		=IDTipoDescuento
		--,@ActualValorDescuento		=ValorDescuento
		--,@ActualAplicaDisminucion	=AplicaDisminucion
	 --from RH.tblInfonavitEmpleado
	 --where IDInfonavitEmpleado = @IDInfonavitEmpleado

	 
	IF(@IDRegPatronal = 0) RETURN 0;

	IF(@IDEmpleado = 0) RETURN 0;

	IF(@IDTipoDescuento = 0) RETURN 0;

	IF(@IDTipoAvisoInfonavit = 0) RETURN 0;

	set @IDTipoMovimiento = CASE WHEN @IDTipoAvisoInfonavit in (5,6,7,9) THEN 3
								 WHEN @IDTipoAvisoInfonavit in (2,3) THEN 1
								 WHEN @IDTipoAvisoInfonavit in (4) THEN 4
								 WHEN @IDTipoAvisoInfonavit in ( 10,11,12,13,14,15) THEN 2
								 else null
								 END

								

	if not exists(select top 1 1 from RH.tblInfonavitEmpleado where NumeroCredito = @NumeroCredito and IDEmpleado = @IDEmpleado)
	BEGIN
		exec [RH].[spIUInfonavitEmpleados]      
					@IDInfonavitEmpleado  = @IDInfonavitEmpleado	
					,@IDEmpleado			= @IDEmpleado			
					,@IDRegPatronal		= @IDRegPatronal		
					,@NumeroCredito		= @NumeroCredito		
					,@Fecha				= @Fecha				
					,@IDTipoDescuento		= @IDTipoDescuento		
					,@ValorDescuento		= @ValorDescuento		
					,@AplicaDisminucion	= @AplicaDisminucion
					,@IDTipoMovimiento = @IDTipoMovimiento
					,@IDUsuario			= @IDUsuario
	END

	IF not exists(select top 1 1 from RH.tblHistorialAvisosInfonavitEmpleado where NumeroCredito = @NumeroCredito and IDEmpleado = @IDEmpleado and FolioAviso = @FolioAviso)
	BEGIN
		select @IDInfonavitEmpleado = IDInfonavitEmpleado 
			from RH.tblInfonavitEmpleado with(nolock)
			where NumeroCredito = @NumeroCredito
			and IDEmpleado = @IDEmpleado

		insert into rh.tblHistorialAvisosInfonavitEmpleado(IDInfonavitEmpleado,IDEmpleado,IDRegPatronal,NumeroCredito,Fecha,IDTipoDescuento,ValorDescuento,AplicaDisminucion,FolioAviso,FechaEntraVigor,IDTipoAvisoInfonavit)      
		values (@IDInfonavitEmpleado,@IDEmpleado,@IDRegPatronal,@NumeroCredito,@Fecha,@IDTipoDescuento,@ValorDescuento,@AplicaDisminucion,@FolioAviso
			,CASE WHEN @IDTipoAvisoInfonavit not in (4,8) THEN @Fecha 
				 else
					DATEADD(day,1,app.fngetFinBimestreByFecha(@Fecha))
				 END,@IDTipoAvisoInfonavit) 
			set @ID = @@IDENTITY  
		select @NewJSON = a.JSON from [RH].[tblHistorialInfonavitEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDHistorialInfonavitEmpleado = @ID

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblHistorialAvisosInfonavitEmpleado]','[RH].[spIHistorialInfonavitEmpleadoAvisos]','INSERT',@NewJSON,''
	END

	       if OBJECT_ID('tempdb..#tblTempHistorial1') is not null  
			drop table #tblTempHistorial1;  
  
			if OBJECT_ID('tempdb..#tblTempHistorial2') is not null  
			drop table #tblTempHistorial2;  
  
			select *, ROW_NUMBER()over(order by FechaEntraVigor asc) as [Row]  
			INTO #tblTempHistorial1  
			FROM rh.tblHistorialAvisosInfonavitEmpleado  
			WHERE IDEmpleado = @IDEmpleado  
				and NumeroCredito = @NumeroCredito
				and FechaEntraVigor is not null
			order by FechaEntraVigor asc  
  
			select   
			  t1.IDHistorialAvisosInfonavitEmpleado	
			, t1.IDInfonavitEmpleado  
			,t1.IDEmpleado  
			,t1.NumeroCredito  
			,t1.FechaEntraVigor  
			,FechaFinVigor = case when t2.FechaEntraVigor is not null then dateadd(day,-1,t2.FechaEntraVigor)   
								 else '9999-12-31' end   
			INTO #tblTempHistorial2  
			from #tblTempHistorial1 t1  
			left join (select *   
			from #tblTempHistorial1) t2 on t1.[Row] = (t2.[Row]-1)  
  
			update [TARGET]  
			set   
			[TARGET].FechaFinVigor = [SOURCE].FechaFinVigor  
			FROM RH.tblHistorialAvisosInfonavitEmpleado as [TARGET]  
			join #tblTempHistorial2 as [SOURCE] on [TARGET].IDHistorialAvisosInfonavitEmpleado = [SOURCE].IDHistorialAvisosInfonavitEmpleado  
			and [TARGET].IDEmpleado = [SOURCE].IDEmpleado
			and [TARGET].NumeroCredito = [SOURCE].NumeroCredito
			and [TARGET].IDInfonavitEmpleado = [SOURCE].IDInfonavitEmpleado
GO
