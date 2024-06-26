USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spReciboFiniquitoHGP] --0,100,390,1 
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

		,@SumaPerc decimal(18,2)
		,@TotalPercepiones decimal(18,2)

		,@SumaDedu decimal(18,2)
		,@TotalDeducciones decimal(18,2)
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

	
	set @SumaPerc =	
					case when @Estatus = 'Aplicar' then (select top 1 SUM(ImporteTotal1) 
											 from Nomina.tblDetallePeriodo dp with (nolock) 
												join Nomina.tblCatConceptos cc with (nolock) on dp.IDConcepto =  cc.IDConcepto 
											 --where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto in (37,87,90,98,107,110)
                                             where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto in (37,87,90,98,107)
											)
					else 
						(select top 1 SUM(ImporteTotal1) 
								from Nomina.tblDetallePeriodoFiniquito dp with (nolock) 
									join Nomina.tblCatConceptos cc with (nolock) on dp.IDConcepto = cc.IDConcepto
								--where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto in (37,87,90,98,107,110)
                                where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto in (37,87,90,98,107)
						)
					end	
					
     set @TotalPercepiones = 
				case when @Estatus = 'Aplicar' then (select top 1 SUM(ImporteTotal1) 
											 from Nomina.tblDetallePeriodo dp with (nolock) 
												join Nomina.tblCatConceptos cc with (nolock) on dp.IDConcepto =  cc.IDConcepto 
											 where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto = 18
											)
					else 
						(select top 1 SUM(ImporteTotal1) 
								from Nomina.tblDetallePeriodoFiniquito dp with (nolock) 
									join Nomina.tblCatConceptos cc with (nolock) on dp.IDConcepto = cc.IDConcepto
								where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto = 18
						)
					end	


	set @SumaDedu =	
					case when @Estatus = 'Aplicar' then (select top 1 SUM(ImporteTotal1) 
											 from Nomina.tblDetallePeriodo dp with (nolock) 
												join Nomina.tblCatConceptos cc with (nolock) on dp.IDConcepto =  cc.IDConcepto 
											 where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto in (57,58,124)
											)
					else 
						(select top 1 SUM(ImporteTotal1) 
								from Nomina.tblDetallePeriodoFiniquito dp with (nolock) 
									join Nomina.tblCatConceptos cc with (nolock) on dp.IDConcepto = cc.IDConcepto
								where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto in (57,58,124)
						)
					end	
					
     set @TotalDeducciones = 
				case when @Estatus = 'Aplicar' then (select top 1 SUM(ImporteTotal1) 
											 from Nomina.tblDetallePeriodo dp with (nolock) 
												join Nomina.tblCatConceptos cc with (nolock) on dp.IDConcepto =  cc.IDConcepto 
											 where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto = 19
											)
					else 
						(select top 1 SUM(ImporteTotal1) 
								from Nomina.tblDetallePeriodoFiniquito dp with (nolock) 
									join Nomina.tblCatConceptos cc with (nolock) on dp.IDConcepto = cc.IDConcepto
								where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto = 19
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
		,e.RegPatronal as RegistroPatronal  
		,isnull(@TotalAPagar,0.00) as TotalAPagar
		,Utilerias.fnConvertNumerosALetras(isnull(@TotalAPagar,0.00)) +' M.N' as TotalAPagarEnLetras

		,isnull(@TotalFondoAhorro,0.00) as TotalFondoAhorro
		,Utilerias.fnConvertNumerosALetras(isnull(@TotalFondoAhorro,0.00)) +' M.N' as TotalFondoAhorroEnLetras

		,Es.NombreEstado as RegPatronalEstado
		,M.Descripcion   as RegPatronalMunicipio
		,isnull (@SumaPerc,0.00) as SumaPercepciones
		,ISNULL (@TotalPercepiones,0.00) as TotalPercepiones
		,ISNULL (@TotalPercepiones,0.00) - isnull (@SumaPerc,0.00) as Otros
		,isnull(cf.DiasDePago,0.00) as DiasPagados 
		,isnull(@TotalDeducciones,0.00) - ISNULL(@SumaDedu,0.00) as OtrosDedu

		,TipoDePago = ' C H E Q U E '
	from Nomina.tblControlFiniquitos cf with(nolock)    
		inner join @empleados e    
			on cf.IDEmpleado = e.IDEmpleado   
		inner join RH.tblCatRegPatronal R
			on R.IDRegPatronal = e.IDRegpatronal
		inner join Sat.tblCatEstados Es
			on ES.IDEstado = R.IDEstado
		inner join Sat.tblCatMunicipios M
			on M.IDMunicipio = R.IDMunicipio
		Inner join @periodo p     
			on cf.IDPeriodo = p.IDPeriodo     
	where CF.IDEmpleado = @IDEmpleado    
		and cf.IDPeriodo = @IDPeriodo    
		and ((cf.IDFiniquito = @IDFiniquito) or   (@IDFiniquito = 0))
END
GO
