USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spReciboFiniquitoOEModa] 
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
		,@ultimoLunes DATE
		,@ultimoDomingo DATE
		,@diasDescanso int


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
	

	


	select  top 1
    @ultimoDomingo = Fecha
	from @empleados e
	join [Asistencia].[tblIncidenciaEmpleado] ie on e.IDEmpleado = ie.IDEmpleado
	WHERE IDIncidencia = 'D' and (((DATEPART(DW, Fecha) - 1 ) + @@DATEFIRST ) % 7) IN (0,6)
	ORDER BY IDIncidenciaEmpleado DESC;

	SET @ultimoLunes = ( DATEADD(DAY,-6,@ultimoDomingo))

	SET @diasDescanso = (select count(*) from [Asistencia].[tblIncidenciaEmpleado] where IDIncidencia = 'D' and IDEmpleado = 471
	and Fecha Between @ultimoLunes and  @ultimoDomingo);

	SET LANGUAGE Spanish;  

    select top(1)
		p.IDPeriodo        
		,p.ClavePeriodo  
		,e.RegPatronal
		,e.ClaveEmpleado
		,e.Paterno + ' ' + e.Materno + ' ' + e.Nombre + ' ' + e.SegundoNombre as NOMBRECOMPLETOAPF
		,e.Puesto   
		,e.Departamento
		,e.Sucursal
		,e.RFC
		,FORMAT(cf.FechaAntiguedad, 'dddd-MMMM-yyyy')  as FechaAntiguedad
		,FORMAT(cf.FechaBaja, 'dddd-MMMM-yyyy')  as FechaBaja
		,e.SalarioDiario
		,e.SalarioIntegrado
		,CASE WHEN e.RegPatronal = 'CLOE PERSONALE SA DE CV' THEN  e.RegPatronal
			  ELSE CONCAT(e.RegPatronal, ' Y/O CLOE PERSONALE SA DE CV') END AS regPatronalYOCLOE
		,FORMAT(cf.FechaBaja, 'dd/MM/yyyy')  as FechaBajaGuion
		,isnull(@TotalAPagar,0) as TotalAPagar
		,Utilerias.fnConvertNumerosALetras(isnull(@TotalAPagar,0)) +' M.N' as TotalAPagarEnLetras
		,FORMAT (cf.FechaBaja, 'dddd, dd \DE MMMM DEL yyyy') as fechaBajaLetras
		,ch.HoraEntrada
		,ch.HoraDescanso as HoraSalidaComer --Este es el campo que se tiene que añadir, tabla Asistencia.tblCatHorarios,  checar con cliente si es necesario en
		,dateadd(second,datediff(second,0,ch.HoraDescanso),ch.TiempoDescanso) as HoraEntradaComer
		,ch.HoraSalida
		,ch.TiempoDescanso
		,@diasDescanso as diasDescanso

	from Nomina.tblControlFiniquitos cf with(nolock)    
		inner join @empleados e    
			on cf.IDEmpleado = e.IDEmpleado    
		Inner join @periodo p     
			on cf.IDPeriodo = p.IDPeriodo  
		Left join Asistencia.tblHorariosEmpleados he on e.IDEmpleado = he.IDEmpleado
		Left join Asistencia.tblCatHorarios ch on he.IDHorario =  ch.IDHorario

	where CF.IDEmpleado = @IDEmpleado    
		and cf.IDPeriodo = @IDPeriodo    
		and ((cf.IDFiniquito = @IDFiniquito) or   (@IDFiniquito = 0))

		
	SET LANGUAGE us_english;  

END
GO
