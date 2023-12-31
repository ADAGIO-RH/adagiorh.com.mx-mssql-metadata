USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spAplicarFiniquito]  --366,1
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
		    
	IF(@IDEStatusFiniquito = 2)    
	BEGIN    
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
		from Nomina.tblDetallePeriodoFiniquito    
		WHERE IDPeriodo = @IDPeriodo AND IDEmpleado = @IDEmpleado    
    
		MERGE Nomina.tblDetallePeriodo AS TARGET    
		USING @dtDetallePeriodoFiniquito AS SOURCE    
		ON TARGET.IDPeriodo = SOURCE.IDPeriodo    
			and TARGET.IDConcepto = SOURCE.IDConcepto    
			and TARGET.IDEmpleado = SOURCE.IDEmpleado    
			and TARGET.Descripcion = SOURCE.Descripcion    
		WHEN MATCHED Then    
		update    
			Set TARGET.CantidadDias  = SOURCE.CantidadDias,    
			TARGET.CantidadMonto  = SOURCE.CantidadMonto,    
			TARGET.CantidadVeces  = SOURCE.CantidadVeces,    
			TARGET.CantidadOtro1  = SOURCE.CantidadOtro1,    
			TARGET.CantidadOtro2  = SOURCE.CantidadOtro2,    
			TARGET.ImporteGravado  = SOURCE.ImporteGravado,    
			TARGET.ImporteExcento  = SOURCE.ImporteExcento,    
			TARGET.ImporteTotal1  = SOURCE.ImporteTotal1,    
			TARGET.ImporteTotal2  = SOURCE.ImporteTotal2,    
			TARGET.Descripcion  = SOURCE.Descripcion,    
			TARGET.IDReferencia  = SOURCE.IDReferencia    
          
		WHEN NOT MATCHED BY TARGET THEN     
		INSERT(    
			IDEmpleado    
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
		VALUES(    
			SOURCE.IDEmpleado    
			,SOURCE.IDPeriodo    
			,SOURCE.IDConcepto    
			,SOURCE.CantidadMonto    
			,SOURCE.CantidadDias    
			,SOURCE.CantidadVeces    
			,SOURCE.CantidadOtro1    
			,SOURCE.CantidadOtro2    
			,SOURCE.ImporteGravado    
			,SOURCE.ImporteExcento    
			,SOURCE.ImporteOtro    
			,SOURCE.ImporteTotal1    
			,SOURCE.ImporteTotal2    
			,SOURCE.Descripcion    
			,SOURCE.IDReferencia    
		)    
		WHEN NOT MATCHED BY SOURCE and TARGET.IDPeriodo = @IDPeriodo and TARGET.IDEmpleado = @IDEmpleado THEN     
		DELETE;    
	END  
	ELSE
	BEGIN
		DELETE Nomina.tblDetallePeriodo where IDEmpleado = @IDEmpleado and IDPeriodo = @IDPeriodo
	END
	
	

END
GO
