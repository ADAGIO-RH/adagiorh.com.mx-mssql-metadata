USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
		NO MOVER ESTE SP ***( DIANA )
		STORE PROCEDURE IMPORTANTE
*/
CREATE PROCEDURE [Reportes].[spReciboFiniquitoThangos] --0,100,390,1 
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
		--,e.FechaAntiguedad        
		,e.TipoNomina        
		,e.SalarioDiario        
		,e.SalarioIntegrado     
		,cf.FechaAntiguedad    
		,cf.FechaAntiguedad as FechaIngreso       
		,cf.FechaBaja     
		,Asistencia.fnBuscarAniosDiferencia(cf.FechaAntiguedad,cf.FechaBaja) as AniosAntiguedad    
		,e.Puesto    
		,e.Departamento
		,e.Sucursal
		,e.IDDivision
		,e.Division
		,e.Empresa  
		,Es.NombreEstado as EstadoSucursal
		,M.Descripcion as MunicipioSucursal
		,Co.NombreAsentamiento as ColoniaSucursal
		,e.Cliente  
		,isnull(@TotalAPagar,0.00) as TotalAPagar
		,Utilerias.fnConvertNumerosALetras(isnull(@TotalAPagar,0.00)) +' M.N' as TotalAPagarEnLetras

		,isnull(@TotalFondoAhorro,0.00) as TotalFondoAhorro
		,Utilerias.fnConvertNumerosALetras(isnull(@TotalFondoAhorro,0.00)) +' M.N' as TotalFondoAhorroEnLetras

		,TipoDePago = 'T R A N S F E R E N C I A' /*case when @TotalAPagar >= 500.00 then ' C H E Q U E ' else ' E F E C T I V O ' end*/
	from Nomina.tblControlFiniquitos cf with(nolock)    
		inner join @empleados e    
			on cf.IDEmpleado = e.IDEmpleado    
		Inner join @periodo p     
			on cf.IDPeriodo = p.IDPeriodo  
		inner join rh.tblCatSucursales S 
			on S.idSucursal = e.idsucursal   
		inner join sat.tblCatEstados Es
			on Es.IDEstado = S.IDEstado
		inner join sat.tblCatMunicipios M
			on M.IDMunicipio = S.IDMunicipio
		inner join sat.tblCatColonias Co
			on Co.IDColonia = S.IDColonia
	where CF.IDEmpleado = @IDEmpleado    
		and cf.IDPeriodo = @IDPeriodo    
		and ((cf.IDFiniquito = @IDFiniquito) or   (@IDFiniquito = 0))
END
GO
