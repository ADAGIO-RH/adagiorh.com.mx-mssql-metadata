USE [p_adagioRHIndustrialMefi]
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


/*
	@IDTipoMovimiento = 1 Inicio crédito de Vivienda (Fecha, Tipo de descuento, Valor de descuento, Número del crédito)
						2 Suspención de descuento (Fecha de Suspención)
						3 Reinicio de descuento (Fecha, Tipo de descuento, Valor de descuento, Número del crédito)
						4 Modificar tipo de descuento (Fecha, Tipo de descuento, Valor de descuento, Número del crédito)
						5 Modificar valor de descuento (Fecha, Valor de descuento)
						6 Modificar número de crédito (Fecha, Tipo de descuento, Valor de descuento, Número del crédito)

*/
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [RH].[spIHistorialInfonavitEmpleado](
		@IDInfonavitEmpleado int = 0      
		,@IDEmpleado int      
		,@IDRegPatronal int      
		,@NumeroCredito varchar(10)      
		,@IDTipoMovimiento int      
		,@Fecha date      
		,@IDTipoDescuento int      
		,@ValorDescuento decimal(18,4)      
		,@AplicaDisminucion bit = 0      
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
	;

	 
		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);




	 select 
		 @ActualIDInfonavitEmpleado	=IDInfonavitEmpleado
		,@ActualIDEmpleado			=IDEmpleado
		,@ActualIDRegPatronal		=IDRegPatronal
		,@ActualNumeroCredito		=NumeroCredito
		,@ActualIDTipoMovimiento	=IDTipoMovimiento
		,@ActualFecha				=Fecha
		,@ActualIDTipoDescuento		=IDTipoDescuento
		,@ActualValorDescuento		=ValorDescuento
		,@ActualAplicaDisminucion	=AplicaDisminucion
	 from RH.tblInfonavitEmpleado
	 where IDInfonavitEmpleado = @IDInfonavitEmpleado

	 if (@IDTipoMovimiento  = 2) 
	 begin
		exec [RH].[spIUInfonavitEmpleados]      
				  @IDInfonavitEmpleado  = @ActualIDInfonavitEmpleado	
				 ,@IDEmpleado			= @ActualIDEmpleado			
				 ,@IDRegPatronal		= @ActualIDRegPatronal		
				 ,@NumeroCredito		= @ActualNumeroCredito		
				 ,@IDTipoMovimiento		= @IDTipoMovimiento	
				 ,@Fecha				= @ActualFecha				
				 ,@IDTipoDescuento		= @ActualIDTipoDescuento		
				 ,@ValorDescuento		= @ActualValorDescuento		
				 ,@AplicaDisminucion	= @ActualAplicaDisminucion	
				 ,@IDUsuario			= @IDUsuario

		insert into rh.tblHistorialInfonavitEmpleado(IDInfonavitEmpleado,IDEmpleado,IDRegPatronal,NumeroCredito,IDTipoMovimiento,Fecha,IDTipoDescuento,ValorDescuento,AplicaDisminucion)      
		values (@IDInfonavitEmpleado,@IDEmpleado,@IDRegPatronal,@NumeroCredito,@IDTipoMovimiento,@Fecha,@IDTipoDescuento,@ValorDescuento,@AplicaDisminucion)    
		set @ID = @@IDENTITY  

		select @NewJSON = a.JSON from [RH].[tblHistorialInfonavitEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDHistorialInfonavitEmpleado = @ID

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblHistorialInfonavitEmpleado]','[RH].[spIHistorialInfonavitEmpleado]','INSERT',@NewJSON,''

	 end else
	 if (@IDTipoMovimiento = 3)
	 begin
		exec [RH].[spIUInfonavitEmpleados]      
				  @IDInfonavitEmpleado  = @ActualIDInfonavitEmpleado	
				 ,@IDEmpleado			= @ActualIDEmpleado			
				 ,@IDRegPatronal		= @ActualIDRegPatronal		
				 ,@NumeroCredito		= @ActualNumeroCredito		
				 ,@IDTipoMovimiento		= @IDTipoMovimiento	
				 ,@Fecha				= @ActualFecha				
				 ,@IDTipoDescuento		= @IDTipoDescuento		
				 ,@ValorDescuento		= @ValorDescuento		
				 ,@AplicaDisminucion	= @ActualAplicaDisminucion	
				 ,@IDUsuario			= @IDUsuario

		insert into rh.tblHistorialInfonavitEmpleado(IDInfonavitEmpleado,IDEmpleado,IDRegPatronal,NumeroCredito,IDTipoMovimiento,Fecha,IDTipoDescuento,ValorDescuento,AplicaDisminucion)      
		values (@IDInfonavitEmpleado,@IDEmpleado,@IDRegPatronal,@NumeroCredito,@IDTipoMovimiento,@Fecha,@IDTipoDescuento,@ValorDescuento,@AplicaDisminucion)      
			set @ID = @@IDENTITY  

		select @NewJSON = a.JSON from [RH].[tblHistorialInfonavitEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDHistorialInfonavitEmpleado = @ID

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblHistorialInfonavitEmpleado]','[RH].[spIHistorialInfonavitEmpleado]','INSERT',@NewJSON,''
	 end else
	 if (@IDTipoMovimiento = 4)
	 begin
		exec [RH].[spIUInfonavitEmpleados]      
				  @IDInfonavitEmpleado  = @ActualIDInfonavitEmpleado	
				 ,@IDEmpleado			= @ActualIDEmpleado			
				 ,@IDRegPatronal		= @ActualIDRegPatronal		
				 ,@NumeroCredito		= @ActualNumeroCredito		
				 ,@IDTipoMovimiento		= @IDTipoMovimiento	
				 ,@Fecha				= @ActualFecha				
				 ,@IDTipoDescuento		= @IDTipoDescuento		
				 ,@ValorDescuento		= @ValorDescuento		
				 ,@AplicaDisminucion	= @ActualAplicaDisminucion	
				 ,@IDUsuario			= @IDUsuario

		insert into rh.tblHistorialInfonavitEmpleado(IDInfonavitEmpleado,IDEmpleado,IDRegPatronal,NumeroCredito,IDTipoMovimiento,Fecha,IDTipoDescuento,ValorDescuento,AplicaDisminucion)      
		values (@IDInfonavitEmpleado,@IDEmpleado,@IDRegPatronal,@NumeroCredito,@IDTipoMovimiento,@Fecha,@IDTipoDescuento,@ValorDescuento,@AplicaDisminucion)   
			set @ID = @@IDENTITY  

		select @NewJSON = a.JSON from [RH].[tblHistorialInfonavitEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDHistorialInfonavitEmpleado = @ID

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblHistorialInfonavitEmpleado]','[RH].[spIHistorialInfonavitEmpleado]','INSERT',@NewJSON,''   
	 end else
	 if (@IDTipoMovimiento = 5)
	 begin
		exec [RH].[spIUInfonavitEmpleados]      
				  @IDInfonavitEmpleado  = @ActualIDInfonavitEmpleado	
				 ,@IDEmpleado			= @ActualIDEmpleado			
				 ,@IDRegPatronal		= @ActualIDRegPatronal		
				 ,@NumeroCredito		= @ActualNumeroCredito		
				 ,@IDTipoMovimiento		= @IDTipoMovimiento	
				 ,@Fecha				= @ActualFecha				
				 ,@IDTipoDescuento		= @ActualIDTipoDescuento		
				 ,@ValorDescuento		= @ValorDescuento		
				 ,@AplicaDisminucion	= @ActualAplicaDisminucion	
				 ,@IDUsuario			= @IDUsuario

		insert into rh.tblHistorialInfonavitEmpleado(IDInfonavitEmpleado,IDEmpleado,IDRegPatronal,NumeroCredito,IDTipoMovimiento,Fecha,IDTipoDescuento,ValorDescuento,AplicaDisminucion)      
		values (@IDInfonavitEmpleado,@IDEmpleado,@IDRegPatronal,@NumeroCredito,@IDTipoMovimiento,@Fecha,@IDTipoDescuento,@ValorDescuento,@AplicaDisminucion)      
			set @ID = @@IDENTITY  

		select @NewJSON = a.JSON from [RH].[tblHistorialInfonavitEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDHistorialInfonavitEmpleado = @ID

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblHistorialInfonavitEmpleado]','[RH].[spIHistorialInfonavitEmpleado]','INSERT',@NewJSON,''
	 end else
	 if (@IDTipoMovimiento = 6)
	 begin
		set @msgCambioNumeroCredito = 'Para este movimiento debe ingresar un númoer de crédito distinto a '+coalesce(@ActualNumeroCredito,'');

		if (@NumeroCredito = @ActualNumeroCredito)
		begin
			raiserror(@msgCambioNumeroCredito,16,1)
			return
		end;

		exec [RH].[spIUInfonavitEmpleados]      
				  @IDInfonavitEmpleado  = @ActualIDInfonavitEmpleado	
				 ,@IDEmpleado			= @ActualIDEmpleado			
				 ,@IDRegPatronal		= @ActualIDRegPatronal		
				 ,@NumeroCredito		= @NumeroCredito		
				 ,@IDTipoMovimiento		= @IDTipoMovimiento	
				 ,@Fecha				= @ActualFecha				
				 ,@IDTipoDescuento		= @ActualIDTipoDescuento		
				 ,@ValorDescuento		= @ValorDescuento		
				 ,@AplicaDisminucion	= @ActualAplicaDisminucion	
				 ,@IDUsuario			= @IDUsuario

		insert into rh.tblHistorialInfonavitEmpleado(IDInfonavitEmpleado,IDEmpleado,IDRegPatronal,NumeroCredito,IDTipoMovimiento,Fecha,IDTipoDescuento,ValorDescuento,AplicaDisminucion)      
		values (@IDInfonavitEmpleado,@IDEmpleado,@IDRegPatronal,@NumeroCredito,@IDTipoMovimiento,@Fecha,@IDTipoDescuento,@ValorDescuento,@AplicaDisminucion)  
			set @ID = @@IDENTITY  

		select @NewJSON = a.JSON from [RH].[tblHistorialInfonavitEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDHistorialInfonavitEmpleado = @ID

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblHistorialInfonavitEmpleado]','[RH].[spIHistorialInfonavitEmpleado]','INSERT',@NewJSON,''    
	 end;


	    if OBJECT_ID('tempdb..#tblTempHistorial1') is not null  
			drop table #tblTempHistorial1;  
  
			if OBJECT_ID('tempdb..#tblTempHistorial2') is not null  
			drop table #tblTempHistorial2;  
  
			select *, ROW_NUMBER()over(order by FechaEntraVigor asc) as [Row]  
			INTO #tblTempHistorial1  
			FROM rh.tblHistorialInfonavitEmpleado  
			WHERE IDEmpleado = @IDEmpleado  
				and NumeroCredito = @NumeroCredito
				and FechaEntraVigor is not null
			order by FechaEntraVigor asc  
  
			select   
			  t1.IDHistorialInfonavitEmpleado	
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
			FROM RH.tblHistorialInfonavitEmpleado as [TARGET]  
			join #tblTempHistorial2 as [SOURCE] on [TARGET].IDHistorialInfonavitEmpleado = [SOURCE].IDHistorialInfonavitEmpleado  
			and [TARGET].IDEmpleado = [SOURCE].IDEmpleado
			and [TARGET].NumeroCredito = [SOURCE].NumeroCredito
			and [TARGET].IDInfonavitEmpleado = [SOURCE].IDInfonavitEmpleado
GO
