USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Procedimiento para Guardar los finiquitos    
** Autor   : Jose Roman    
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 14-08-2018    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
0000-00-00  NombreCompleto  ¿Qué cambió?    
***************************************************************************************************/    
CREATE PROCEDURE [Nomina].[spIUFiniquito](     
	@IDFiniquito int = 0    
	,@IDPeriodo int    
	,@IDEmpleado int    
	,@FechaAntiguedad date    
	,@FechaBaja date    
	,@DiasVacaciones Decimal(18,2)    
	,@DiasAguinaldo Decimal(18,2)    
	,@DiasIndemnizacion90Dias Decimal(18,2)    
	,@DiasIndemnizacion20Dias Decimal(18,2)    
	,@IDEStatusFiniquito int  
	,@DiasDePago decimal(18,2)
	,@DiasPorPrimaAntiguedad Decimal(18,2)    
	,@SueldoFiniquito	decimal(18,2)
	,@IDUsuario int    
	,@IDMovAfiliatorio int
)    
AS    
BEGIN    
	DECLARE @dtDetallePeriodoFiniquito [Nomina].[dtDetallePeriodo]    
		,@dtFiltros [Nomina].[dtFiltrosRH]    
		,@empleados [RH].[dtEmpleados]    
		,@Fecha date    
		,@IDTipoMovimiento int    
		,@FechaIMSS date = null    
		,@FechaIDSE date = null    
		,@IDRazonMovimiento int    
		,@SalarioDiario decimal(9,2)    
		,@SalarioIntegrado decimal(9,2)    
		,@SalarioVariable decimal(9,2)    
		,@SalarioDiarioReal decimal(9,2)    
		,@IDRegPatronal int    
		,@RegPatronal varchar(50)    
        ,@IDEstatusFiniquitoAplicado int = (Select IDEStatusFiniquito from Nomina.tblCatEstatusFiniquito where Descripcion = 'Aplicar')
    ;

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spIUFiniquito]',
		@Tabla		varchar(max) = '[Nomina].[tblControlFiniquitos]',
		@Accion		varchar(20)	= 'DELETE'

	insert into @dtFiltros(Catalogo,Value)    
	values('Empleados',@IDEmpleado)    
    
	insert into @empleados    
	exec [RH].[spBuscarEmpleados]@dtFiltros = @dtFiltros    
    
	IF(@IDFiniquito = 0)    
	BEGIN    
		IF EXISTS(Select Top 1 1 from Nomina.tblControlFiniquitos where IDEmpleado = @IDEmpleado and IDPeriodo = @IDPeriodo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003',@CustomMessage = 'Ya existe un finiquito para este colaborador en este periodo.'
			RETURN 0;
		END;

		INSERT INTO Nomina.tblControlFiniquitos(     
			IDPeriodo    
			,IDEmpleado    
			,FechaBaja    
			,DiasVacaciones    
			,DiasAguinaldo    
			,DiasIndemnizacion90Dias    
			,DiasIndemnizacion20Dias    
			,IDEStatusFiniquito    
			,FechaAntiguedad
			,DiasDePago				
			,DiasPorPrimaAntiguedad	
			,SueldoFiniquito	
			,IDMovAfiliatorio
		)    
		VALUES(      
			@IDPeriodo    
			,@IDEmpleado    
			,@FechaBaja    
			,@DiasVacaciones    
			,@DiasAguinaldo    
			,@DiasIndemnizacion90Dias    
			,@DiasIndemnizacion20Dias    
			,@IDEStatusFiniquito    
			,@FechaAntiguedad
			,@DiasDePago				
			,@DiasPorPrimaAntiguedad	
			,@SueldoFiniquito			
			,@IDMovAfiliatorio
		)  
	  
		SET @IDFiniquito = @@IDENTITY  
		
		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].tblControlFiniquitos b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDFiniquito = @IDFiniquito
	END    
	ELSE    
	BEGIN
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Nomina].tblControlFiniquitos b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDFiniquito = @IDFiniquito

		UPDATE Nomina.tblControlFiniquitos     
			set IDPeriodo = @IDPeriodo,    
			IDEmpleado = @IDEmpleado,    
			FechaBaja = @FechaBaja,    
			DiasVacaciones = @DiasVacaciones,    
			DiasAguinaldo = @DiasAguinaldo,    
			DiasIndemnizacion90Dias = @DiasIndemnizacion90Dias,    
			DiasIndemnizacion20Dias = @DiasIndemnizacion20Dias,    
			IDEStatusFiniquito = @IDEStatusFiniquito,    
			FechaAntiguedad = @FechaAntiguedad,
			DiasDePago				= @DiasDePago,				
			DiasPorPrimaAntiguedad	= @DiasPorPrimaAntiguedad,	
			SueldoFiniquito			= @SueldoFiniquito,		
			IDMovAfiliatorio		= @IDMovAfiliatorio
		Where IDFiniquito = @IDFiniquito
		
		select @NewJSON = a.JSON
		from [Nomina].tblControlFiniquitos b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDFiniquito = @IDFiniquito
	END
	
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
		select 
			IDDetallePeriodo    
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

	EXEC Nomina.spBuscarFiniquitos @IDFiniquito= @IDFiniquito,@IDPeriodo=0,@IDUsuario=@IDUsuario    
END
GO
