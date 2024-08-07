USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spReportePolizaMotiDigitalExcel](    
		@dtFiltros Nomina.dtFiltrosRH readonly    
		,@IDUsuario int    
) as   
BEGIN

	declare 
		@empleadosPeriodo [RH].[dtEmpleados]
		,@IDPeriodoInicial int 
		,@periodo [Nomina].[dtPeriodos]   
		,@fechaIniPeriodo  date        
		,@fechaFinPeriodo  date 
		,@Cerrado int
		,@Empleados [RH].[dtEmpleados]
		,@DescripcionPeriodo varchar(100)
	         
            
		Select @IDPeriodoInicial= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')
	       

		/* Se buscan el periodo seleccionado */    
		insert into @periodo  
		select *
			-- IDPeriodo  
			--,IDTipoNomina  
			--,Ejercicio  
			--,ClavePeriodo  
			--,Descripcion  
			--,FechaInicioPago  
			--,FechaFinPago  
			--,FechaInicioIncidencia  
			--,FechaFinIncidencia  
			--,Dias  
			--,AnioInicio  
			--,AnioFin  
			--,MesInicio  
			--,MesFin  
			--,IDMes  
			--,BimestreInicio  
			--,BimestreFin  
			--,Cerrado  
			--,General  
			--,Finiquito  
			--,isnull(Especial,0)  
		from Nomina.tblCatPeriodos  with (nolock) 
		where idperiodo = @IDPeriodoInicial     
		
		     
		select top 1 
		@fechaIniPeriodo = FechaInicioPago
		,@fechaFinPeriodo = FechaFinPago 
		,@Cerrado = Cerrado
		,@DescripcionPeriodo = Descripcion
	    from @periodo
	    where IDPeriodo = @IDPeriodoInicial


		/* Se buscan todos los empleados del periodo seleccionado */   
		insert into @empleadosPeriodo
		select distinct em.*
		from RH.tblEmpleadosMaster em with (nolock) 
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on dp.idempleado = em.idempleado


		/* Se  Busca y actualiza el Historial Organizacional y Empresarial de cada empleado*/  

	if (@Cerrado = 1)
	begin
		update e
			set 
				e.IDCentroCosto		= case when isnull(cc.IDCentroCosto,0)	<> 0 then cc.IDCentroCosto	else e.IDCentroCosto	end
				,e.CentroCosto		= case when isnull(cc.Descripcion,'')	<> '' then cc.Descripcion	else e.CentroCosto		end
				,e.IDDepartamento	= case when isnull(d.IDDepartamento,0)	<> 0 then d.IDDepartamento	else e.IDDepartamento	end
				,e.Departamento		= case when isnull(d.Descripcion,'')		<> '' then d.Descripcion		else e.Departamento		end
				,e.IDSucursal		= case when isnull(s.IDSucursal,0)		<> 0 then s.IDSucursal		else e.IDSucursal		end
				,e.Sucursal			= case when isnull(s.Descripcion,'')		<> '' then s.Descripcion		else e.Sucursal			end
				,e.IDPuesto			= case when isnull(p.IDPuesto,0)		<> 0 then p.IDPuesto		else e.IDPuesto			end
				,e.Puesto			= case when isnull(p.Descripcion,'')		<> '' then p.Descripcion		else e.Puesto			end
				,e.IDRegPatronal	= case when isnull(rp.IDRegPatronal,0)	<> 0 then rp.IDRegPatronal	else e.IDRegPatronal	end
				,e.RegPatronal		= case when isnull(rpNombre.RazonSocial,'')	<> '' then rpNombre.RazonSocial	else e.RegPatronal		end
				,e.IDCliente		= case when isnull(c.IDCliente,0)		<> 0 then c.IDCliente		else e.IDCliente		end
				,e.Cliente			= case when isnull(c.NombreComercial,'')		<> '' then c.NombreComercial	else e.Cliente			end
				,e.IDEmpresa		= case when isnull(emp.IdEmpresa,0)		<> 0 then emp.IdEmpresa		else e.IdEmpresa		end
				,e.Empresa			= case when isnull(emp.NombreComercial,'')		<> '' then emp.NombreComercial else e.Empresa		end
				,e.IDArea			= case when isnull(a.IDArea,0)			<> 0 then a.IDArea			else e.IDArea			end
				,e.Area				= case when isnull(a.Descripcion,'')			<> '' then a.Descripcion		else e.Area				end
				,e.IDDivision		= case when isnull(div.IDDivision,0)	<> 0 then div.IDDivision	else e.IDDivision		end
				,e.Division			= case when isnull(div.Descripcion,'')	<> '' then div.Descripcion	else e.Division			end
				,e.IDRegion			= case when isnull(r.IDRegion,0)		<> 0 then r.IDRegion		else e.IDRegion			end
				,e.Region			= case when isnull(r.Descripcion,'')		<> '' then r.Descripcion		else e.Region			end
				,e.IDRazonSocial	= case when isnull(rs.IDRazonSocial,0)	<> 0 then rs.IDRazonSocial	else e.IDRazonSocial	end
				,e.RazonSocial		= case when isnull(rs.RazonSocial,'')	<> '' then rs.RazonSocial	else e.RazonSocial		end

				,e.IDClasificacionCorporativa	= case when isnull(clasificacionC.IDClasificacionCorporativa,0)	<> 0 then clasificacionC.IDClasificacionCorporativa	else e.IDClasificacionCorporativa	end
				,e.ClasificacionCorporativa		= case when isnull(clasificacionC.Descripcion,'')	<> '' then clasificacionC.Descripcion				else e.ClasificacionCorporativa		end

		from @empleadosPeriodo e
			join ( select hep.*
					from Nomina.tblHistorialesEmpleadosPeriodos hep with (nolock)
						join @periodo p on hep.IDPeriodo = p.IDPeriodo
				) historiales on e.IDEmpleado = historiales.IDEmpleado
			left join RH.tblCatCentroCosto cc		with(nolock) on cc.IDCentroCosto = historiales.IDCentroCosto
		 	left join RH.tblCatDepartamentos d		with(nolock) on d.IDDepartamento = historiales.IDDepartamento
			left join RH.tblCatSucursales s			with(nolock) on s.IDSucursal		= historiales.IDSucursal
			left join RH.tblCatPuestos p			with(nolock) on p.IDPuesto			= historiales.IDPuesto
			left join RH.tblCatRegPatronal rp		with(nolock) on rp.IDRegPatronal	= historiales.IDRegPatronal
			
			left join RH.tblCatRegPatronal rpNombre		with(nolock) on rpNombre.IDRegPatronal	= rp.IDRegPatronal
			left join RH.tblCatClientes c			with(nolock) on c.IDCliente		= historiales.IDCliente
			left join RH.tblEmpresa emp				with(nolock) on emp.IDEmpresa	= historiales.IDEmpresa
			left join RH.tblCatArea a				with(nolock) on a.IDArea		= historiales.IDArea
			left join RH.tblCatDivisiones div		with(nolock) on div.IDDivision	= historiales.IDDivision
			left join RH.tblCatRegiones r			with(nolock) on r.IDRegion		= historiales.IDRegion
			left join RH.tblCatRazonesSociales rs	with(nolock) on rs.IDRazonSocial = historiales.IDRazonSocial
			left join RH.tblCatClasificacionesCorporativas clasificacionC with(nolock)	on clasificacionC.IDClasificacionCorporativa = historiales.IDClasificacionCorporativa
			

	end
	ELSE
	BEGIN
		update e set e.IDArea = Area.IDArea,
					 e.idCentroCosto = CentroC.IdCentroCosto
		from @empleadosPeriodo e
		inner join rh.tblAreaEmpleado Area  with (nolock)
			on Area.idempleado = e.idempleado and  Area.Fechaini <= @fechaFinPeriodo and Area.FechaFin >= @fechaFinPeriodo
		inner join rh.tblCentroCostoEmpleado CentroC  with (nolock)
			on CentroC.idCentroCosto = e.IDCentroCosto and CentroC.Fechaini <= @fechaFinPeriodo and CentroC.FechaFin >= @fechaFinPeriodo
	END
	
	/*En caso de existir filtro aqui llena los empleados trabajables*/
	insert @Empleados
	exec [RH].[spFiltrarEmpleadosDesdeLista]              
		@dtEmpleados	= @empleadosPeriodo,
		@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario   

	
	if object_id('tempdb..#TempPercepciones') is not null drop table #TempPercepciones 
	if object_id('tempdb..#TempDeducciones') is not null drop table #TempDeducciones 

	if object_id('tempdb..#Percepciones') is not null drop table #Percepciones 
	if object_id('tempdb..#Deducciones') is not null drop table #Deducciones

	/*Se obtienen todas las percepciones (Cargo)*/

	Select 'M1' as Movimiento, --Fijo personalizado del cliente
		    c.CuentaCargo as idCuenta, --Cuenta contable
			e.CentroCosto as Referencia,  --Descripcion Centro de costo 
			'0' as TipoMovto, --1 = Abono, 0 = Cargo
			case when c.codigo = '384' then isnull(dp.ImporteTotal1,0) * -1 else  isnull(dp.ImporteTotal1,0) end as Importe, 
			CASE WHEN CAST(SUBSTRING(c.CuentaCargo,1,1) as int)  = 5 THEN cc.CuentaContable
				 ELSE ''
			END as IDDiario, --Algunas cuentas van con cuenta contable del centro de costo, Cuentas pasivas van vacías,
			'0' as ImporteME, --Importe Moneda Extranjera siempre en $00.00
			p.Descripcion as 'Concepto',  
			CASE WHEN CAST(SUBSTRING(c.CuentaCargo,1,1) as int)  = 5 THEN Area.CuentaContable
				 ELSE ''
			END as IdSegNeg, --Algunas cuentas van con cuenta contable del Area, Cuentas pasivas van vacías,
			c.Codigo as CConcepto,
			c.Descripcion as DConcepto,
			e.NOMBRECOMPLETO,
			c.ordenCalculo
	into #TempPercepciones		
	from Nomina.tbldetalleperiodo dp  with (nolock)
		inner join @periodo p
			on p.idperiodo = dp.idperiodo
		inner join @Empleados e
			on e.idempleado = dp.idempleado
		inner join Nomina.tblcatconceptos c  with (nolock)
			on c.idconcepto = dp.idconcepto
		inner join Nomina.tblcattipoConcepto tipoC  with (nolock)
			on tipoC.IDTipoConcepto = c.IDTipoConcepto
		left join rh.tblCatCentroCosto CC  with (nolock)
			on CC.IDCentroCosto = e.IDCentroCosto
		left join rh.tblCatArea Area  with (nolock)
			on Area.IDArea = e.IDArea
	WHERE c.CuentaCargo is not null 

	/*Se suman y se agrupan todas las percepciones (Cargo)*/

	select Movimiento,
		   idCuenta,
		   Referencia,
		   TipoMovto,
		   SUM(Importe) as ImporteCargo,
		   0 as ImporteAbono, 
		   IDDiario,
		   ImporteME,
		   Concepto,
		   IdSegNeg,
		   CConcepto,
		   DConcepto,
		   OrdenCalculo
	into #Percepciones
	from #TempPercepciones
	group by Movimiento, idCuenta, Referencia, TipoMovto, IDDiario, ImporteME, Concepto, IdSegNeg,CConcepto,DConcepto, OrdenCalculo


	/*Se obtienen todas las Deducciones (Abono)*/
	Select 'M1' as Movimiento, 
		    c.CuentaAbono as idCuenta,
			e.CentroCosto as Referencia, 
			'1' as TipoMovto, --1 = Abono, 0 = Cargo
			case when c.codigo = '184' then (dp.ImporteTotal1 * -1) else isnull(dp.importetotal1,0) end as Importe, 
			CASE WHEN CAST(SUBSTRING(c.CuentaAbono,1,1) as int)  = 5 THEN isnull(cc.CuentaContable,0)
				 ELSE ''
			END as IDDiario,--Algunas cuentas van con cuenta contable del centro de costo, Cuentas pasivas van vacías,
			'0' as ImporteME, --Importe Moneda Extranjera siempre en $00.00
			p.Descripcion as 'Concepto',  
			CASE WHEN CAST(SUBSTRING(c.CuentaAbono,1,1) as int)  = 5 THEN isnull(Area.CuentaContable,0)
				 ELSE ''
			END as IdSegNeg	,--Algunas cuentas van con cuenta contable del Area, Cuentas pasivas van vacías,
			c.Codigo as CConcepto,
			c.Descripcion as DConcepto,
			c.ordenCalculo
	into #TempDeducciones
	from Nomina.tbldetalleperiodo dp  with (nolock)
		inner join @periodo p
			on p.idperiodo = dp.idperiodo
		inner join @Empleados e
			on e.idempleado = dp.idempleado
		inner join Nomina.tblcatconceptos c  with (nolock)
			on c.idconcepto = dp.idconcepto
		inner join Nomina.tblcattipoConcepto tipoC  with (nolock)
			on tipoC.IDTipoConcepto = c.IDTipoConcepto
		left join rh.tblCatCentroCosto CC  with (nolock)
			on CC.IDCentroCosto = e.IDCentroCosto
		left join rh.tblCatArea Area  with (nolock)
			on Area.IDArea = e.IDArea
	WHERE c.CuentaAbono is not null 

	
	/*Se suman y se agrupan todas las deducciones (Abono)*/
	select Movimiento,
		   idCuenta,
		   Referencia,
		   TipoMovto,
		   0 as ImporteCargo,
		   SUM(Importe) as ImporteAbono,
		   IDDiario,
		   ImporteME,
		   Concepto,
		   IdSegNeg,
		   CConcepto,
		   DConcepto,
		   OrdenCalculo
	into #Deducciones
	from #TempDeducciones
	group by Movimiento, idCuenta, Referencia, TipoMovto, IDDiario, ImporteME, Concepto, IdSegNeg, CConcepto, DConcepto,OrdenCalculo


	/*El primer select es una primer linea solicitada por el cliente*/

	select CONVERT(varchar,@fechaIniPeriodo,6) as 'No   ',
		   'Diario' as Referencia,
		  cast( (cast(@IDPeriodoInicial as int) + 1000) as varchar (10)) as Cuenta, --Consecutivo de su póliza interna
		   CONCAT('PROVISION ', @DescripcionPeriodo) as Nombre,
		   '' as Diario, 
		   '' as [Segmento  ], 
		   cast(0 as decimal(7,2)) as Cargo, 
		    cast(0 as decimal(7,2)) as Abono
	union all
	select  CAST((ROW_NUMBER() OVER(ORDER BY referencia, ordenCalculo  ASC)) as varchar(5)) as 'No',
			Referencia as Refer,
			idCuenta as Cuenta,
			DConcepto as Nombre,
			IDDiario as Diario,
			idSegNeg as [Seg  ],
			importeCargo  as Cargos,
			importeAbono  as Abono
	from (select * from #Percepciones
		union all
		select * from #Deducciones
		) x


		
END
GO
