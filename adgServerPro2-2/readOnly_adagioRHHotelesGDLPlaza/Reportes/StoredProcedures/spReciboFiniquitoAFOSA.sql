USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spReciboFiniquitoAFOSA] --0,100,390,1 
(        
	@IDFiniquito int = 0,          
	@IDPeriodo int,    
	@IDEmpleado int,
	@IDUsuario int          
)        
AS        
BEGIN        
         
	DECLARE         
		@empleados [RH].[dtEmpleados]        
		,@periodo [Nomina].[dtPeriodos]        
		,@Conceptos [Nomina].[dtConceptos]        
		,@dtFiltros [Nomina].[dtFiltrosRH]        
		,@fechaIniPeriodo  date        
		,@fechaFinPeriodo  date   
		,@Estatus varchar(max)     
		,@TotalAPagar decimal(18,2)
		,@TotalFondoAhorro decimal(18,2)

		,@ConceptoTotalDevAhorro varchar(10) = '533'
		,@IDTotalDevFondoAhorro int
		,@CurrentDate datetime
		,@CurrentHour int
		
	;		

      


	select top 1 @IDTotalDevFondoAhorro=IDConcepto from Nomina.tblCatConceptos where Codigo=@ConceptoTotalDevAhorro; 

	select top 1 @Estatus = ef.Descripcion 
		from Nomina.tblControlFiniquitos cf with (nolock)
			inner join Nomina.tblCatEstatusFiniquito ef with (nolock)
				on cf.IDEStatusFiniquito = ef.IDEStatusFiniquito
	where IDFiniquito = @IDFiniquito  	
	
	set @TotalAPagar = 
		case when @Estatus = 'Aplicar' then (select top 1 SUM(ImporteTotal1) 
											 from Nomina.tblDetallePeriodo dp with (nolock) 
												join Nomina.tblCatConceptos cc with (nolock) on dp.IDConcepto = cc.IDConcepto
											 where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and cc.IDTipoConcepto = 5
											)
			else 
				(select top 1 SUM(ImporteTotal1) 
				from Nomina.tblDetallePeriodoFiniquito dp with (nolock) 
				join Nomina.tblCatConceptos cc with (nolock) on dp.IDConcepto = cc.IDConcepto
				where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and cc.IDTipoConcepto = 5
			)
			end


	set @TotalFondoAhorro = 
		case when @Estatus = 'Aplicar' then (select top 1 SUM(ImporteTotal1) 
											 from Nomina.tblDetallePeriodo dp with (nolock) 
												 
											 where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto = @IDTotalDevFondoAhorro
											)
			else 
				(select top 1 SUM(ImporteTotal1) 
				from Nomina.tblDetallePeriodoFiniquito dp with (nolock) 
				 where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto = @IDTotalDevFondoAhorro
			)
			end
        
	if(isnull(@IDEmpleado,'')<>'')        
	BEGIN        
		insert into @dtFiltros(Catalogo,Value)        
		values('Empleados',case when @IDEmpleado is null then '' else @IDEmpleado end)        
	END;        
        
    Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Especial,Cerrado)        
    select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,isnull(Especial,0),Cerrado     
    from Nomina.TblCatPeriodos with(nolock)       
    where IDPeriodo = @IDPeriodo        
        
    select @fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago        
	from Nomina.TblCatPeriodos with(nolock)       
    where IDPeriodo = @IDPeriodo        
        
    insert into @empleados        
    exec [RH].[spBuscarEmpleadosMaster] @dtFiltros = @dtFiltros, @IDUsuario =  @IDUsuario      

	   SET @CurrentDate = GetDate();
       SET @CurrentHour = DATEPART(HOUR, @CurrentDate);

    select         
		p.IDPeriodo        
		,p.ClavePeriodo        
		,p.Descripcion as Periodo        
		,p.FechaInicioPago         
		,p.FechaFinPago        
		,e.IDEmpleado        
		,e.ClaveEmpleado        
		,e.NOMBRECOMPLETO        
		,e.RFC as RFCEmpleado        
		,e.CURP         
		,coalesce(e.IMSS,'') IMSS        
		,e.JornadaLaboral              
		,e.TipoNomina        
		,e.SalarioDiario  
		,FORMAT((e.SalarioDiario * 7), 'c') as SalarioSemanal
		,Utilerias.fnConvertNumerosALetras(isnull((e.SalarioDiario * 7),0.00)) +' M.N' as SalarioSemanalEnLetras
		,e.SalarioIntegrado     
		,cf.FechaAntiguedad    
		,e.FechaIngreso       
		,cf.FechaBaja     
		,Asistencia.fnBuscarAniosDiferencia(cf.FechaAntiguedad,cf.FechaBaja) as AniosAntiguedad    
		,e.Puesto    
		,e.Departamento
		,e.Sucursal
		,e.IDDivision
		,e.Division
		,e.Empresa    
		,FORMAT(isnull(@TotalAPagar,0.00), 'c') as TotalAPagar
		,Utilerias.fnConvertNumerosALetras(isnull(@TotalAPagar,0.00)) +' M.N' as TotalAPagarEnLetras

		,isnull(@TotalFondoAhorro,0.00) as TotalFondoAhorro
		,Utilerias.fnConvertNumerosALetras(isnull(@TotalFondoAhorro,0.00)) +' M.N' as TotalFondoAhorroEnLetras

		,TipoDePago = case when @TotalAPagar >= 500.00 then ' C H E Q U E ' else ' E F E C T I V O ' end
	    ,CONCAT(
			IIF (@CurrentHour = 01 or @CurrentHour = 13, 'la ','las ')
			,CASE
				WHEN @CurrentHour = 01 THEN 'una'
				WHEN @CurrentHour = 02 THEN 'dos'
				WHEN @CurrentHour = 03 THEN 'tres'
				WHEN @CurrentHour = 04 THEN 'cuatro'
				WHEN @CurrentHour = 05 THEN 'cinco'
				WHEN @CurrentHour = 06 THEN 'seis'
				WHEN @CurrentHour = 07 THEN 'siete'
				WHEN @CurrentHour = 08 THEN 'ocho'
				WHEN @CurrentHour = 09 THEN 'nueve'
				WHEN @CurrentHour = 10 THEN 'diez'
				WHEN @CurrentHour = 11 THEN 'once'
				WHEN @CurrentHour = 12 THEN 'doce'
				WHEN @CurrentHour = 13 THEN 'una'
				WHEN @CurrentHour = 14 THEN 'dos'
				WHEN @CurrentHour = 15 THEN 'tres'
				WHEN @CurrentHour = 16 THEN 'cuatro'
				WHEN @CurrentHour = 17 THEN 'cinco'
				WHEN @CurrentHour = 18 THEN 'seis'
				WHEN @CurrentHour = 19 THEN 'siete'
				WHEN @CurrentHour = 20 THEN 'ocho'
				WHEN @CurrentHour = 21 THEN 'nueve'
				WHEN @CurrentHour = 22 THEN 'diez'
				WHEN @CurrentHour = 23 THEN 'once'
				WHEN @CurrentHour = 00 THEN 'doce'
				ELSE 'Error al obtener la hora'
			END
			,IIF(@CurrentHour > 11, ' de la tarde',' de la mañana'))  as HoraEnLetras
	        ,FORMAT (@CurrentDate, 'dd \de MMMM \de yyyy', 'es-es') as Fecha
	from Nomina.tblControlFiniquitos cf with(nolock)    
		inner join @empleados e    
			on cf.IDEmpleado = e.IDEmpleado    
		Inner join @periodo p     
			on cf.IDPeriodo = p.IDPeriodo     
	where CF.IDEmpleado = @IDEmpleado    
		and cf.IDPeriodo = @IDPeriodo    
		and ((cf.IDFiniquito = @IDFiniquito) or   (@IDFiniquito = 0))
END
GO
