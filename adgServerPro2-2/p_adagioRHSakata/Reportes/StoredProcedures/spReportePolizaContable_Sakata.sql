USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Reportes].[spReportePolizaContable_Sakata](    
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

	--select * from @empleadosPeriodo where ClaveEmpleado = '00082' return
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
		update e set e.IDClasificacionCorporativa = Clas.IdClasificacionCorporativa,
					 e.idCentroCosto = CentroC.IdCentroCosto,
					 e.IDEmpresa = Empresa.IDEmpresa
		from @empleadosPeriodo e
		inner join rh.tblClasificacioncorporativaempleado Clas  with (nolock)
			on Clas.idempleado = e.idempleado and  Clas.Fechaini <= @fechaFinPeriodo and Clas.FechaFin >= @fechaFinPeriodo
		inner join rh.tblCentroCostoEmpleado CentroC  with (nolock)
			on CentroC.idCentroCosto = e.IDCentroCosto and CentroC.Fechaini <= @fechaFinPeriodo and CentroC.FechaFin >= @fechaFinPeriodo
		inner join rh.tblEmpresaEmpleado Empresa  with (nolock)
			on Empresa.IdEmpresa = e.IDEmpresa and Empresa.Fechaini <= @fechaFinPeriodo and Empresa.FechaFin >= @fechaFinPeriodo
	END
	
	/*En caso de existir filtro aqui llena los empleados trabajables*/
	insert @Empleados
	exec [RH].[spFiltrarEmpleadosDesdeLista]              
		@dtEmpleados	= @empleadosPeriodo,
		@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario   

		--select * from @Empleados where ClaveEmpleado = '00087' return
	/*---------------------Inicia creación de cuenta contable por colaborador------------------------*/
	DECLARE @CuentaContable AS TABLE 
	(
		IDEmpelado INT NOT NULL PRIMARY KEY,
		ClaveEmpleado varchar(20),
		CuentaContable VarChar(20),
		Filial bit
	)

	/*----------------------Termina Creacion de cuenta contable por colaborador-----------------------*/

	--select * from @CuentaContable where IDEmpelado = 391 return

	if object_id('tempdb..#TempPercepciones') is not null drop table #TempPercepciones 
	if object_id('tempdb..#TempPercepcionesH') is not null drop table #TempPercepcionesH 
	if object_id('tempdb..#TempDeducciones') is not null drop table #TempDeducciones 

	if object_id('tempdb..#Percepciones') is not null drop table #Percepciones 
	if object_id('tempdb..#Deducciones') is not null drop table #Deducciones

	select --CARGO PERCEPCIONES DEBITO SIN HOMOLOGAR
		CONVERT(varchar,GETDATE(),23)  as [Date],
		'Ledger' as [Account type],
		'' as [Non-ledger account],
		c.CuentaCargo as [Main account],
		'' as [BU  ],
		'' as [COB ],
		'' as Department,
		CC.Descripcion as [Cost Center],
		'' as [Variety],
		'' as [MotherLot],
		p.Descripcion as [Description],
		'MXN' as Currency,
		SUM(dp.ImporteTotal1) as Debit,
		0 as Credit,
		'Ledger' as [Of account type],
		'' as [Subledger ac],
		'' as [Of GL ac],
		'' as [OF BU],
		'' as [Of COB],
		'' as [OF Department],
		'' as [Of CostCenter],
		'' as [Of Variety],
		'' as [Of Motherlot],
		'' as [Line number],
		'GSMX' as [Company],
		'Offset company' as [Offset company]
	into #TempPercepciones
	from Nomina.tbldetalleperiodo dp  with (nolock)
		inner join @periodo p on p.idperiodo = dp.idperiodo
		inner join @Empleados e on e.idempleado = dp.idempleado
		inner join Nomina.tblcatconceptos c  with (nolock) on c.idconcepto = dp.idconcepto
		inner join Nomina.tblcattipoConcepto tipoC  with (nolock) on tipoC.IDTipoConcepto = c.IDTipoConcepto
		left join rh.tblCatCentroCosto CC  with (nolock) on CC.IDCentroCosto = e.IDCentroCosto
		left join rh.tblCatCentroCosto CeCo on CeCo.IDCentroCosto = e.IDCentroCosto
	where c.CuentaCargo is not null and c.Codigo not in ('121','507','508','509','510','540')
	group by cc.Descripcion, c.CuentaCargo , p.Descripcion


	select --CARGO PERCEPCIONES DEBITO HOMOLOGADOS
		CONVERT(varchar,GETDATE(),23)  as [Date],
		'Ledger' as [Account type],
		'' as [Non-ledger account],
		c.CuentaCargo as [Main account],
		'' as [BU  ],
		'' as [COB ],
		'' as Department,
		'' as [Cost Center],
		'' as [Variety],
		'' as [MotherLot],
		p.Descripcion as [Description],
		'MXN' as Currency,
		SUM(dp.ImporteTotal1) as Debit,
		0 as Credit,
		'Ledger' as [Of account type],
		'' as [Subledger ac],
		'' as [Of GL ac],
		'' as [OF BU],
		'' as [Of COB],
		'' as [OF Department],
		'' as [Of CostCenter],
		'' as [Of Variety],
		'' as [Of Motherlot],
		'' as [Line number],
		'GSMX' as [Company],
		'Offset company' as [Offset company]
	into #TempPercepcionesH
	from Nomina.tbldetalleperiodo dp  with (nolock)
		inner join @periodo p on p.idperiodo = dp.idperiodo
		inner join @Empleados e on e.idempleado = dp.idempleado
		inner join Nomina.tblcatconceptos c  with (nolock) on c.idconcepto = dp.idconcepto
		inner join Nomina.tblcattipoConcepto tipoC  with (nolock) on tipoC.IDTipoConcepto = c.IDTipoConcepto
		left join rh.tblCatCentroCosto CC  with (nolock) on CC.IDCentroCosto = e.IDCentroCosto
		left join rh.tblCatCentroCosto CeCo on CeCo.IDCentroCosto = e.IDCentroCosto
	where c.CuentaCargo is not null and c.Codigo in  ('121','507','508','509','510','540')
	group by c.Codigo, c.CuentaCargo , p.Descripcion


	select --ABONO DEDUCCIONES CREDITO HOMOLOGADOS
		CONVERT(varchar,GETDATE(),23)  as [Date],
		'Ledger' as [Account type],
		'' as [Non-ledger account],
		c.CuentaAbono as [Main account],
		'' as [BU  ],
		'' as [COB ],
		'' as Department,
		'' as [Cost Center],
		'' as [Variety],
		'' as [MotherLot],
		p.Descripcion as [Description],
		'MXN' as Currency,
		0 as Debit,
		SUM(dp.ImporteTotal1) as Credit,
		'Ledger' as [Of account type],
		'' as [Subledger ac],
		'' as [Of GL ac],
		'' as [OF BU],
		'' as [Of COB],
		'' as [OF Department],
		'' as [Of CostCenter],
		'' as [Of Variety],
		'' as [Of Motherlot],
		'' as [Line number],
		'GSMX' as [Company],
		'Offset company' as [Offset company]
	into #Deducciones
	from Nomina.tbldetalleperiodo dp  with (nolock)
		inner join @periodo p on p.idperiodo = dp.idperiodo
		inner join @Empleados e on e.idempleado = dp.idempleado
		inner join Nomina.tblcatconceptos c  with (nolock) on c.idconcepto = dp.idconcepto
		inner join Nomina.tblcattipoConcepto tipoC  with (nolock) on tipoC.IDTipoConcepto = c.IDTipoConcepto
		left join rh.tblCatCentroCosto CC  with (nolock) on CC.IDCentroCosto = e.IDCentroCosto
		left join rh.tblCatCentroCosto CeCo on CeCo.IDCentroCosto = e.IDCentroCosto
	where c.CuentaAbono is not null 
	group by c.Codigo, c.CuentaAbono , p.Descripcion

	select * from #TempPercepciones
		UNION ALL
	select * from #TempPercepcionesH
		UNION ALL
	select * from #Deducciones





	--select --ABONO DEDUCCIONES CREDITO SIN HOMOLOGAR
	--	CONVERT(varchar,GETDATE(),23)  as Date,
	--	c.CuentaAbono as [Main account],
	--	CC.Descripcion as [Cost Center],
	--	0 as Debit,
	--	SUM(dp.ImporteTotal1) as Credit
	--from Nomina.tbldetalleperiodo dp  with (nolock)
	--	inner join @periodo p on p.idperiodo = dp.idperiodo
	--	inner join @Empleados e on e.idempleado = dp.idempleado
	--	inner join Nomina.tblcatconceptos c  with (nolock) on c.idconcepto = dp.idconcepto
	--	inner join Nomina.tblcattipoConcepto tipoC  with (nolock) on tipoC.IDTipoConcepto = c.IDTipoConcepto
	--	left join rh.tblCatCentroCosto CC  with (nolock) on CC.IDCentroCosto = e.IDCentroCosto
	--	left join rh.tblCatCentroCosto CeCo on CeCo.IDCentroCosto = e.IDCentroCosto
	--where c.CuentaAbono is not null and c.Codigo not in ('601','602','603','604','605','606','121','301','302','304','308','309','301A','311','303','507','508','509','510','540')
	--group by cc.Descripcion, c.CuentaAbono
	
	


END
GO
