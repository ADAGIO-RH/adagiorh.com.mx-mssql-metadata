USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoDeNominaPolizaContableProvisionANS](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
--select * from Nomina.tblCatPeriodos
	--declare	
	--	@dtFiltros Nomina.dtFiltrosRH
	--	,@IDUsuario int
	--insert @dtFiltros
	--values ('TipoNomina',4)
	--	  ,('IDPeriodoInicial',29)

	declare 
		@empleados [RH].[dtEmpleados]      
		,@empleadosTemp [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0      
		,@periodo [Nomina].[dtPeriodos]      
		,@configs [Nomina].[dtConfiguracionNomina]      
		,@Conceptos [Nomina].[dtConceptos]      
		,@IDTipoNomina int   
		,@fechaIniPeriodo  date      
		,@fechaFinPeriodo  date     
		,@IDPeriodoInicial int
		,@PeriodicidadPago Varchar(100)
		,@IDCliente int
		,@Cerrado bit = 1
		,@minRN int
		,@maxRN int
		,@QtyEmpleados decimal(18,2)
	;  

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END


	Select @IDPeriodoInicial= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')
	Select @IDCliente	= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')
	
	insert into @periodo
	select *
	from Nomina.tblCatPeriodos with (nolock)
	where IDTipoNomina = @IDTipoNomina and IDPeriodo = @IDPeriodoInicial

	select @PeriodicidadPago = pp.Descripcion 
	from Nomina.tblCatTipoNomina TN
		inner join Sat.tblCatPeriodicidadesPago pp
			on TN.IDPeriodicidadPago = PP.IDPeriodicidadPago
	where TN.IDTipoNomina = @IDTipoNomina


	select 
		@fechaIniPeriodo = FechaInicioPago
		,@fechaFinPeriodo = FechaFinPago 
		,@IDTipoNomina = IDTipoNomina 
		,@Cerrado = Cerrado 
	from @periodo
	where IDPeriodo = @IDPeriodoInicial

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */      
	insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp with (nolock)
				where dp.IDPeriodo = @IDPeriodoInicial
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
order by IDEmpleado


	--		select e.*
	--from RH.tblEmpleadosMaster e with (nolock)
	--	join ( select distinct dp.IDEmpleado
	--			from Nomina.tblDetallePeriodo dp with (nolock)
	--			where dp.IDPeriodo = @IDPeriodoInicial
	--	) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
		
    --insert into @empleados      
    --exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   

	if (@Cerrado = 1)
	begin
		update e
			set 
				e.IDCentroCosto		= isnull(cc.IDCentroCosto	,e.IDCentroCosto)
				,e.CentroCosto		= isnull(cc.Descripcion		,e.CentroCosto	)
				,e.IDDepartamento	= isnull(d.IDDepartamento	,e.IDDepartamento)
				,e.Departamento		= isnull(d.Descripcion		,e.Departamento	)
				,e.IDSucursal		= isnull(s.IDSucursal		,e.IDSucursal	)
				,e.Sucursal			= isnull(s.Descripcion		,e.Sucursal		)
				,e.IDPuesto			= isnull(p.IDPuesto			,e.IDPuesto		)
				,e.Puesto			= isnull(p.Descripcion		,e.Puesto		)
				,e.IDRegPatronal	= isnull(rp.IDRegPatronal	,e.IDRegPatronal)
				,e.RegPatronal		= isnull(rp.RazonSocial		,e.RegPatronal	)
				,e.IDCliente		= isnull(c.IDCliente		,e.IDCliente	)
				,e.Cliente			= isnull(c.NombreComercial	,e.Cliente		)
				,e.IDEmpresa		= isnull(emp.IdEmpresa		,e.IdEmpresa	)
				,e.Empresa			= isnull(substring(emp.NombreComercial,1,50),substring(e.Empresa,1,50))
				,e.IDArea			= isnull(a.IDArea			,e.IDArea		)
				,e.Area				= isnull(a.Descripcion		,e.Area			)
				,e.IDDivision		= isnull(div.IDDivision		,e.IDDivision	)
				,e.Division			= isnull(div.Descripcion	,e.Division		)
				,e.IDRegion			= isnull(r.IDRegion			,e.IDRegion		)
				,e.Region			= isnull(r.Descripcion		,e.Region		)
				,e.IDRazonSocial	= isnull(rs.IDRazonSocial	,e.IDRazonSocial)
				,e.RazonSocial		= isnull(rs.RazonSocial		,e.RazonSocial	)

				,e.IDClasificacionCorporativa	= isnull(clasificacionC.IDClasificacionCorporativa,e.IDClasificacionCorporativa)
				,e.ClasificacionCorporativa		= isnull(clasificacionC.Descripcion, e.ClasificacionCorporativa)

		from @empleadosTemp e
			join ( select hep.*
					from Nomina.tblHistorialesEmpleadosPeriodos hep with (nolock)
						join @periodo p on hep.IDPeriodo = p.IDPeriodo
				) historiales on e.IDEmpleado = historiales.IDEmpleado
			left join RH.tblCatCentroCosto cc		with(nolock) on cc.IDCentroCosto = historiales.IDCentroCosto
		 	left join RH.tblCatDepartamentos d		with(nolock) on d.IDDepartamento = historiales.IDDepartamento
			left join RH.tblCatSucursales s			with(nolock) on s.IDSucursal		= historiales.IDSucursal
			left join RH.tblCatPuestos p			with(nolock) on p.IDPuesto			= historiales.IDPuesto
			left join RH.tblCatRegPatronal rp		with(nolock) on rp.IDRegPatronal	= historiales.IDRegPatronal
			left join RH.tblCatClientes c			with(nolock) on c.IDCliente		= historiales.IDCliente
			left join RH.tblEmpresa emp				with(nolock) on emp.IDEmpresa	= historiales.IDEmpresa
			left join RH.tblCatArea a				with(nolock) on a.IDArea		= historiales.IDArea
			left join RH.tblCatDivisiones div		with(nolock) on div.IDDivision	= historiales.IDDivision
			left join RH.tblCatRegiones r			with(nolock) on r.IDRegion		= historiales.IDRegion
			left join RH.tblCatRazonesSociales rs	with(nolock) on rs.IDRazonSocial = historiales.IDRazonSocial
			left join RH.tblCatClasificacionesCorporativas clasificacionC with(nolock)	on clasificacionC.IDClasificacionCorporativa = historiales.IDClasificacionCorporativa

	end;
	
	insert @Empleados
	exec [RH].[spFiltrarEmpleadosDesdeLista]              
		@dtEmpleados	= @empleadosTemp,
		@IDTipoNomina	= @IDTipoNomina,
		@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario

	if object_id('tempdb..#tempConceptos') is not null drop table #tempConceptos 
	if object_id('tempdb..#tempRespuesta') is not null drop table #tempRespuesta
	if object_id('tempdb..#tempData') is not null drop table #tempData
	if object_id('tempdb..#tempdataFormat') is not null drop table #tempdataFormat
	if object_id('tempdb..#tempdataTotales') is not null drop table #tempdataTotales
	if object_id('tempdb..#tempdatapago') is not null drop table #tempdatapago

	
	select @QtyEmpleados = count(*) from @empleados


	create table #tempRespuesta(Respuesta nvarchar(max) null, RN int identity(1,1))

		insert into #tempRespuesta
	
		select '                                     TELECT DE MEXICO S DE RL DE CV '
		union all
		select '                                            Nomina '+@PeriodicidadPago+' '
		union all
		select '                                      del  '+FORMAT(@fechaIniPeriodo,'dd/MM/yyyy')+' al '+FORMAT(@fechaFinPeriodo,'dd/MM/yyyy')+' '
		union all
		select '============================================================================================================== '
		union all
		select 'Com.  C.C  Cuenta              Descripción                         Cargo       Abono          Departamento '
			union all
		select '-------------------------------------------------------------------------------------------------------------- '
	


	select 10 as COM
		,RTRIM(LTRIM(CC.Codigo)) as [C.C]
		,RTRIM(LTRIM(isnull(C.CuentaCargo,c.CuentaAbono))) as Cuenta
		,RTRIM(LTRIM(D.CuentaContable)) as CuentaContable
		,RTRIM(LTRIM(c.Codigo)) as CodigoConcepto
		,RTRIM(LTRIM(C.Descripcion))  as ConceptoDescripcion
		,RTRIM(LTRIM(CAST(format(SUM(dp.ImporteTotal1),'N','en-US') as varchar(100)) )) as CARGO 
		,RTRIM(LTRIM(CASE WHEN isnull(c.CuentaAbono,'') <> '' THEN '' else '' END)) as ABONO
		,RTRIM(LTRIM(D.Descripcion)) as Departamento
		,RTRIM(LTRIM(s.Codigo)) as CodigoSucursal
		,RTRIM(LTRIM(s.Descripcion)) as DescripcionSucursal
		,c.OrdenCalculo
		--,Row_Number()over(Order by s.Codigo,d.CuentaContable,d.Descripcion,c.OrdenCalculo ) RN
	into #tempData
	from Nomina.tblDetallePeriodo dp
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		inner join rh.tblCatCentroCosto CC
			on CC.IDCentroCosto = e.IDCentroCosto
		inner join Nomina.tblCatConceptos C
			on dp.IDConcepto = C.IDConcepto
		inner join RH.tblCatDepartamentos D
			on e.IDDepartamento = D.IDDepartamento
		inner join RH.tblCatSucursales S
			on S.IDSucursal = e.IDSucursal
	where dp.IDPeriodo = @IDPeriodoInicial	
	and c.Codigo in (
		'161'
		,'510'
		,'507'
		,'508'
		,'509'
		,'530'
		,'540'
	) 
	
	Group by 
		CC.Codigo
		,C.CuentaCargo
		,c.CuentaAbono
		,D.CuentaContable
		,c.Codigo
		,C.Descripcion
		,D.Descripcion
		,s.Codigo
		,s.Descripcion
		,c.OrdenCalculo
	--order by cast(s.Codigo as int) asc, cast(cc.Codigo as int) asc, d.CuentaContable asc,d.Descripcion asc ,c.OrdenCalculo asc
	
	select * , Row_number()OVER(ORDER by CodigoSucursal asc, [C.C] asc, CuentaContable asc, Departamento asc, OrdenCalculo asc) as RN 
	into #tempdataFormat
	from #tempData	
	ORDER BY CodigoSucursal asc, [C.C] asc, CuentaContable asc, Departamento asc, OrdenCalculo asc

	--select * from #tempdataFormat
	
	select 
	@minRN = min(RN)
	,@maxRN = max(RN)
	from #tempdataFormat

	DECLARE @Departamento varchar(100) = '',
			@DepartamentoNext varchar(100)= '',
			@codigoSucursal varchar(100) = '',
			@DescripcionSucursal varchar(100) = '',
			@DescripcionSucursalNext varchar(100) = ''
			

	While (@minRN <= @maxRN) 
	BEGIN
		select @DepartamentoNext = departamento, @codigoSucursal = CodigoSucursal, @DescripcionSucursalNext = DescripcionSucursal from #tempdataFormat where RN = @minRN
	
		IF(@DescripcionSucursal <> @DescripcionSucursalNext)
		BEGIN
			IF(@minRN = 1)
			BEGIN
			insert into #tempRespuesta
			values (CHAR(13))
					,('*****  '+@DescripcionSucursalNext+'  *****   SUCURSAL  '+@codigoSucursal+' ' )
					,(CHAR(13))
			set @DescripcionSucursal = @DescripcionSucursalNext
			set @Departamento = @DepartamentoNext
			END ELSE
			BEGIN
				insert into #tempRespuesta
				values (CHAR(13))
						,('*****  '+@DescripcionSucursalNext+'  *****   SUCURSAL  '+@codigoSucursal+' ' )
						,(CHAR(10))
				set @DescripcionSucursal = @DescripcionSucursalNext
			END

		END

		IF(@Departamento <> @DepartamentoNext )
		BEGIN
			insert into #tempRespuesta
			values (CHAR(10))
			set @Departamento = @DepartamentoNext
		END
		
		insert into #tempRespuesta
		select [App].[fnAddString](3,COM,'',1) 
			+[App].[fnAddString](6,[C.C],'',1) 
			+[App].[fnAddString](6,Cuenta,'',1) 
			+[App].[fnAddString](3,CuentaContable,'',1) 
			+[App].[fnAddString](17,CodigoConcepto,'',1) 
			+[App].[fnAddString](2,'','',1) 
			+[App].[fnAddString](20,conceptoDescripcion,'',2) 
			+[App].[fnAddString](15,CARGO ,'',1) 
			+[App].[fnAddString](15,ABONO,'',1) 
			+[App].[fnAddString](2,'','',1) 
			+[App].[fnAddString](31,Departamento,'',2) 

		from #tempdataFormat 
		where RN = @minRN

	

	

		--	select * from #tempRespuesta
		select @minRN = MIN(RN) from #tempdataFormat where RN > @minRN
		
	END

	insert into #tempRespuesta
	values (CHAR(13))
			,(CHAR(13))
			,('        *****  TOTALES GENERALES  ***** ' )
			,(CHAR(13))
			,(CHAR(13))
			,(CHAR(13))



select 10 as COM
		,'0000'as [C.C]
		,CASE WHEN c.Codigo = '161' THEN '3630' 
			  WHEN c.Codigo = '510' THEN '3625' 
			  WHEN c.Codigo = '507' THEN '3627' 
			  WHEN c.Codigo = '508' THEN '3627' 
			  WHEN c.Codigo = '509' THEN '3626' 
			  WHEN c.Codigo = '530' THEN '3530' 
			  WHEN c.Codigo = '540' THEN '3628' 
			  ELSE ''
			  END
		as Cuenta
		,CASE WHEN isnull(C.CuentaCargo,'') <> '' THEN '75' ELSE '75' END CuentaContable
		,c.Codigo as CodigoConcepto
		,C.Descripcion  as ConceptoDescripcion
		,CAST(format(SUM(dp.ImporteTotal1),'N','en-US') as varchar(100)) as CARGO 
		,'' as ABONO
		
		,c.OrdenCalculo
		--,Row_Number()over(Order by s.Codigo,d.CuentaContable,d.Descripcion,c.OrdenCalculo ) RN
	into #tempdataTotales
	from Nomina.tblDetallePeriodo dp
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		inner join rh.tblCatCentroCosto CC
			on CC.IDCentroCosto = e.IDCentroCosto
		inner join Nomina.tblCatConceptos C
			on dp.IDConcepto = C.IDConcepto
		inner join RH.tblCatDepartamentos D
			on e.IDDepartamento = D.IDDepartamento
		inner join RH.tblCatSucursales S
			on S.IDSucursal = e.IDSucursal
	where dp.IDPeriodo = @IDPeriodoInicial	
	and c.Codigo in (
		'161'
		,'510'
		,'507'
		,'508'
		,'509'
		,'530'
		,'540'
	) 
	Group by 
		C.CuentaCargo
		,c.CuentaAbono
		,c.Codigo
		,C.Descripcion
		,c.OrdenCalculo


insert into #tempRespuesta
		select [App].[fnAddString](3,COM,'',1) 
			+[App].[fnAddString](6,[C.C],'',1) 
			+[App].[fnAddString](6,Cuenta,'',1) 
			+[App].[fnAddString](3,CuentaContable,'',1) 
			+[App].[fnAddString](17,CodigoConcepto,'',1) 
			+[App].[fnAddString](2,'','',1) 
			+[App].[fnAddString](20,conceptoDescripcion,'',2) 
			+[App].[fnAddString](15,'' ,'',1) 
			+[App].[fnAddString](15,CARGO ,'',1) 
			+[App].[fnAddString](15,'','',1) 
			--+[App].[fnAddString](1,'','',1) 
		from #tempdataTotales 



select 10 as COM
		,'0000'as [C.C]
		,'3610' as Cuenta
		,'0000' CuentaContable
		,'' as CodigoConcepto
		,''  as ConceptoDescripcion
		,CAST(format(SUM(isnull(dp.ImporteTotal1,0)),'N','en-US') as varchar(100)) as TOTAL 
		,0 as OrdenCalculo
		--,Row_Number()over(Order by s.Codigo,d.CuentaContable,d.Descripcion,c.OrdenCalculo ) RN
	into #tempdatapago
	from Nomina.tblCatConceptos C 
		left join Nomina.tblDetallePeriodo dp
			on dp.IDConcepto = C.IDConcepto
			and dp.IDPeriodo = @IDPeriodoInicial	
		left join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		
	where  
	  c.Codigo in (
		'161'
		,'510'
		,'507'
		,'508'
		,'509'
		,'530'
		,'540'
	) 
	
	
--	select * from #tempdatapago

		
insert into #tempRespuesta
		select [App].[fnAddString](3,COM,'',1) 
			+[App].[fnAddString](6,[C.C],'',1) 
			+[App].[fnAddString](6,Cuenta,'',1) 
			+[App].[fnAddString](10,CuentaContable,'',1) 
			+[App].[fnAddString](10,'','',1) 
			+[App].[fnAddString](2,'','',1) 
			+[App].[fnAddString](20,conceptoDescripcion,'',2) 
			+[App].[fnAddString](15,'' ,'',1) 
			+[App].[fnAddString](15,TOTAL ,'',1) 
			+[App].[fnAddString](1,'','',1) 
		from #tempdatapago 

	insert into #tempRespuesta
	values ('               Total de Empleados : ' +cast( @QtyEmpleados as varchar(20)))
			

	insert into #tempRespuesta
	values (CHAR(13))
			,(CHAR(13))
			,(CHAR(13))
			,('--------------------------------- FIN DE REPORTE ---------------------------' )


	select Respuesta from #tempRespuesta order by RN asc


GO
