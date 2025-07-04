USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spAplicarFiniquito]  --2561,1,1
(
	@IDFiniquito int ,
	@Value bit = 0,
	@IDUsuario int 
)
AS
BEGIN
	
	DECLARE 
		  @IDEStatusFiniquito int = case when @Value = 0 then 1 else 2 end
		, @IDPeriodo int
		, @IDEmpleado int 
		, @dtDetallePeriodoFiniquito Nomina.dtDetallePeriodo
		, @OldJSON	Varchar(Max) = ''
		, @NewJSON	Varchar(Max)
		, @NombreSP	varchar(max) = '[Nomina].[spAplicarFiniquito]'
		, @Tabla	varchar(max) = '[Nomina].[tblControlFiniquitos]'
		, @Accion	varchar(20)	 = 'UPDATE'
        ,@IDEstatusFiniquitoAplicado int = (Select IDEStatusFiniquito from Nomina.tblCatEstatusFiniquito where Descripcion = 'Aplicar')
	;
	--select @IDEStatusFiniquito

	select @OldJSON = a.JSON 
	from [Nomina].[tblControlFiniquitos] b with (nolock)
		join [Nomina].[tblCatEstatusFiniquito] e with (nolock) on b.IDEStatusFiniquito = e.IDEStatusFiniquito
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.IDFiniquito, b.IDEstatusFiniquito, e.Descripcion as Estatus For XML Raw)) ) a
	WHERE IDFiniquito = @IDFiniquito

	select 
		@IDPeriodo = IDPeriodo
		, @IDEmpleado = IDEmpleado 
	from Nomina.tblControlFiniquitos with (nolock) 
	where IDFiniquito = @IDFiniquito

	UPDATE Nomina.tblControlFiniquitos     
		set IDEStatusFiniquito = @IDEStatusFiniquito    
	Where IDFiniquito = @IDFiniquito 

	select @NewJSON = a.JSON 
	from [Nomina].[tblControlFiniquitos] b with (nolock)
		join [Nomina].[tblCatEstatusFiniquito] e with (nolock) on b.IDEStatusFiniquito = e.IDEStatusFiniquito
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.IDFiniquito, b.IDEstatusFiniquito, e.Descripcion as Estatus For XML Raw)) ) a
	WHERE IDFiniquito = @IDFiniquito

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		    
	IF(@IDEStatusFiniquito = @IDEstatusFiniquitoAplicado)    
	BEGIN 
        UPDATE Nomina.tblControlFiniquitos 
        SET FechaAplicado = GETDATE()
        WHERE IDFiniquito = @IDFiniquito

		insert into @dtDetallePeriodoFiniquito(IDDetallePeriodo    
		,IDEmpleado    
		,IDPeriodo    
		,IDConcepto    
		,CantidadMonto    
		,CantidadDias    
		,CantidadVeces    
		,CantidadOtro1    
		,CantidadOtro2    
		,ImporteGravado    
		,ImporteExcento    
		,ImporteOtro    
		,ImporteTotal1    
		,ImporteTotal2    
		,Descripcion    
		,IDReferencia    
		)    
		select IDDetallePeriodo    
		,IDEmpleado    
		,IDPeriodo    
		,IDConcepto    
		,CantidadMonto    
		,CantidadDias    
		,CantidadVeces    
		,CantidadOtro1    
		,CantidadOtro2    
		,ImporteGravado    
		,ImporteExcento    
		,ImporteOtro    
		,ImporteTotal1    
		,ImporteTotal2    
		,Descripcion    
		,IDReferencia     
		from Nomina.tblDetallePeriodoFiniquito with(nolock)    
		WHERE IDPeriodo = @IDPeriodo AND IDEmpleado = @IDEmpleado    
    
		--MERGE Nomina.tblDetallePeriodo AS TARGET    
		--USING @dtDetallePeriodoFiniquito AS SOURCE    
		--ON TARGET.IDPeriodo = SOURCE.IDPeriodo    
		--	and TARGET.IDConcepto = SOURCE.IDConcepto    
		--	and TARGET.IDEmpleado = SOURCE.IDEmpleado    
		--	and TARGET.Descripcion = SOURCE.Descripcion    
		--WHEN MATCHED Then    
		--update    
		--	Set TARGET.CantidadDias  = SOURCE.CantidadDias,    
		--	TARGET.CantidadMonto  = SOURCE.CantidadMonto,    
		--	TARGET.CantidadVeces  = SOURCE.CantidadVeces,    
		--	TARGET.CantidadOtro1  = SOURCE.CantidadOtro1,    
		--	TARGET.CantidadOtro2  = SOURCE.CantidadOtro2,    
		--	TARGET.ImporteGravado  = SOURCE.ImporteGravado,    
		--	TARGET.ImporteExcento  = SOURCE.ImporteExcento,    
		--	TARGET.ImporteTotal1  = SOURCE.ImporteTotal1,    
		--	TARGET.ImporteTotal2  = SOURCE.ImporteTotal2,    
		--	TARGET.Descripcion  = SOURCE.Descripcion,    
		--	TARGET.IDReferencia  = SOURCE.IDReferencia    
          
		--WHEN NOT MATCHED BY TARGET THEN     
		--INSERT(    
		--	IDEmpleado    
		--	,IDPeriodo    
		--	,IDConcepto    
		--	,CantidadMonto    
		--	,CantidadDias    
		--	,CantidadVeces    
		--	,CantidadOtro1    
		--	,CantidadOtro2    
		--	,ImporteGravado    
		--	,ImporteExcento    
		--	,ImporteOtro    
		--	,ImporteTotal1    
		--	,ImporteTotal2    
		--	,Descripcion    
		--	,IDReferencia    
		--)    
		--VALUES(    
		--	SOURCE.IDEmpleado    
		--	,SOURCE.IDPeriodo    
		--	,SOURCE.IDConcepto    
		--	,SOURCE.CantidadMonto    
		--	,SOURCE.CantidadDias    
		--	,SOURCE.CantidadVeces    
		--	,SOURCE.CantidadOtro1    
		--	,SOURCE.CantidadOtro2    
		--	,SOURCE.ImporteGravado    
		--	,SOURCE.ImporteExcento    
		--	,SOURCE.ImporteOtro    
		--	,SOURCE.ImporteTotal1    
		--	,SOURCE.ImporteTotal2    
		--	,SOURCE.Descripcion    
		--	,SOURCE.IDReferencia    
		--)    
		--WHEN NOT MATCHED BY SOURCE and TARGET.IDPeriodo = @IDPeriodo and TARGET.IDEmpleado = @IDEmpleado THEN     
		--DELETE;   
		
		RAISERROR ('Delete' , 0, 1) WITH NOWAIT	
		delete [TARGET]
		from Nomina.tblDetallePeriodo [TARGET]
			left join @dtDetallePeriodoFiniquito [SOURCE] on
					[TARGET].IDConcepto = [SOURCE].IDConcepto                   
				and [TARGET].IDEmpleado = [SOURCE].IDEmpleado                  
				and [TARGET].IDPeriodo = [SOURCE].IDPeriodo                  
				and [TARGET].Descripcion = [SOURCE].Descripcion                  
				and [TARGET].IDReferencia = [SOURCE].IDReferencia
		where [TARGET].IDPeriodo = @IDPeriodo and [SOURCE].IDDetallePeriodo is null 
			and [TARGET].IDEmpleado = @IDEmpleado
		
		RAISERROR ('update' , 0, 1) WITH NOWAIT
		update [TARGET]
			set [TARGET].CantidadMonto  = isnull([SOURCE].CantidadMonto ,0)                  
				,[TARGET].CantidadDias   = isnull([SOURCE].CantidadDias  ,0)                  
				,[TARGET].CantidadVeces  = isnull([SOURCE].CantidadVeces ,0)                  
				,[TARGET].CantidadOtro1  = isnull([SOURCE].CantidadOtro1 ,0)                  
				,[TARGET].CantidadOtro2  = isnull([SOURCE].CantidadOtro2 ,0)                  
				,[TARGET].ImporteGravado = isnull([SOURCE].ImporteGravado,0)                  
				,[TARGET].ImporteExcento = isnull([SOURCE].ImporteExcento,0)                  
				,[TARGET].ImporteOtro    = isnull([SOURCE].ImporteOtro   ,0)                  
				,[TARGET].ImporteTotal1  = isnull([SOURCE].ImporteTotal1 ,0)                  
				,[TARGET].ImporteTotal2  = isnull([SOURCE].ImporteTotal2 ,0)                  
				,[TARGET].Descripcion  = [SOURCE].Descripcion                  
				,[TARGET].IDReferencia  = [SOURCE].IDReferencia        
		from Nomina.tblDetallePeriodo [TARGET]
			join @dtDetallePeriodoFiniquito [SOURCE] on
					[TARGET].IDConcepto = [SOURCE].IDConcepto                   
				and [TARGET].IDEmpleado = [SOURCE].IDEmpleado                  
				and [TARGET].IDPeriodo = [SOURCE].IDPeriodo                  
				and [TARGET].Descripcion = [SOURCE].Descripcion                  
				and [TARGET].IDReferencia = [SOURCE].IDReferencia
		where [TARGET].IDPeriodo = @IDPeriodo and [TARGET].IDEmpleado = @IDEmpleado
		
		RAISERROR ('Insert' , 0, 1) WITH NOWAIT
		INSERT Nomina.tblDetallePeriodo(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)            
		select [TARGET].IDEmpleado
			,[TARGET].IDPeriodo
			,[TARGET].IDConcepto
			,[TARGET].CantidadMonto
			,[TARGET].CantidadDias
			,[TARGET].CantidadVeces
			,[TARGET].CantidadOtro1
			,[TARGET].CantidadOtro2
			,[TARGET].ImporteGravado
			,[TARGET].ImporteExcento
			,[TARGET].ImporteOtro
			,[TARGET].ImporteTotal1
			,[TARGET].ImporteTotal2
			,[TARGET].Descripcion
			,[TARGET].IDReferencia
		from @dtDetallePeriodoFiniquito [TARGET]
			left join Nomina.tblDetallePeriodo [SOURCE] on
					[TARGET].IDConcepto = [SOURCE].IDConcepto                   
				and [TARGET].IDEmpleado = [SOURCE].IDEmpleado                  
				and [TARGET].IDPeriodo = [SOURCE].IDPeriodo                  
				and [TARGET].Descripcion = [SOURCE].Descripcion                  
				and [TARGET].IDReferencia = [SOURCE].IDReferencia
		where [TARGET].IDPeriodo = @IDPeriodo and [SOURCE].IDDetallePeriodo is null 
			and [TARGET].IDEmpleado = @IDEmpleado
		
 
	END  
	ELSE
	BEGIN
		DELETE Nomina.tblDetallePeriodo where IDEmpleado = @IDEmpleado and IDPeriodo = @IDPeriodo
	END
	
	

END
GO
