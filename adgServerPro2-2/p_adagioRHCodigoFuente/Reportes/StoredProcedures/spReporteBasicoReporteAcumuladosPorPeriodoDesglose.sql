USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoReporteAcumuladosPorPeriodoDesglose](    
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
	
) as    
	SET FMTONLY OFF 
	declare 
		@empleados [RH].[dtEmpleados]        
		,@empleadosTemp [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0        
		,@periodo [Nomina].[dtPeriodos]        
		,@configs [Nomina].[dtConfiguracionNomina]        
		,@Conceptos [Nomina].[dtConceptos] 
		,@dtDetallePeriodo [Nomina].[dtDetallePeriodo]
		,@fechaIniPeriodo  date        
		,@fechaFinPeriodo  date 
		,@IDTipoNomina   int    
		,@Cerrado bit = 1
		,@MesInicio varchar(MAX)
		,@MesFin varchar(MAX)
		,@Titulo Varchar(max),
        @Cliente int,  
	    @TipoNomina int,   
	    @Ejercicio Varchar(max),  
	    @IDMesInicio int = 0,
	    @IDMesFin int = 0,
	    @IDDepartamento varchar(max) = '',    
	    @IDSucursal  varchar(max) = '',       
	    @IDRazonSocial  varchar(max) = '',
	    @IDPuesto varchar(max) = '',   
	    @IDPrestaciones varchar(max) = '', 
	    @IDClientes varchar(max) = '', 
	    @IDRegPatronales varchar(max) = '', 
	    @IDDivisiones varchar(max) = '',  
	    @IDCentrosCosto varchar(max) = '',  
	    @IDClasificacionesCorporativas varchar(max) = ''  
	;    
    declare @p2 Nomina.dtFiltrosRH
    insert into @p2 values(N'Ejercicio',N'2022')
    insert into @p2 values(N'RazonesSociales',NULL)
    insert into @p2 values(N'RegPatronales',NULL)
    insert into @p2 values(N'Regiones',NULL)
    insert into @p2 values(N'Divisiones',NULL)
    insert into @p2 values(N'ClasificacionesCorporativas',NULL)
    insert into @p2 values(N'CentrosCostos',NULL)
    insert into @p2 values(N'Departamentos',NULL)
    insert into @p2 values(N'Areas',NULL)
    insert into @p2 values(N'Sucursales',NULL)
    insert into @p2 values(N'Puestos',NULL)
    insert into @p2 values(N'Prestaciones',NULL)
    insert into @p2 values(N'Clientes',N'1')
    insert into @p2 values(N'Cliente',N'1')
    insert into @p2 values(N'TipoNomina',N'8')
    insert into @p2 values(N'IDMes',N'1')
    insert into @p2 values(N'IDMesFin',N'1')
    insert into @p2 values(N'IDUsuario',N'1')

    --exec [Reportes].[spEjecutaReporteBasico] @IDReporteBasico=1015,@dtFiltros=@p2,@IDUsuario=1
	
    set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END
    set @IDMesInicio=case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),','))
						else 0 END
	set @IDMesFin=case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMesFin'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMesFin'),','))
						else 0 END
    set @Ejercicio=case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))
						else 0 END  

    set @IDPeriodoSeleccionado=case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))
						else 0 END  
                                     

	/* Se buscan el periodo seleccionado */    
        declare 
        @query NVARCHAR(MAX)='',
        @simbolo NVARCHAR(MAX)=''

        if (@IDTipoNomina=0)
        BEGIN
            set @simbolo='<>'
        END
        ELSE
        BEGIN
            set @simbolo='='
        END

    --     SET @query='  
    --     select   
	-- 	IDPeriodo  
	-- 	,IDTipoNomina  
	-- 	,Ejercicio  
	-- 	,ClavePeriodo  
	-- 	,Descripcion  
	-- 	,FechaInicioPago  
	-- 	,FechaFinPago  
	-- 	,FechaInicioIncidencia  
	-- 	,FechaFinIncidencia  
	-- 	,Dias  
	-- 	,AnioInicio  
	-- 	,AnioFin  
	-- 	,MesInicio  
	-- 	,MesFin  
	-- 	,IDMes  
	-- 	,BimestreInicio  
	-- 	,BimestreFin  
	-- 	,Cerrado  
	-- 	,General  
	-- 	,Finiquito  
	-- 	,isnull(Especial,0)  
	-- from Nomina.tblCatPeriodos with (nolock)  
	-- where IDMes between CASE WHEN isnull('+CONVERT(VARCHAR,@IDMesInicio)+',0) = 0 THEN 1 ELSE isnull('+CONVERT(VARCHAR,@IDMesInicio)+',0) END and CASE WHEN isnull('+CONVERT(VARCHAR,@IDMesFin)+',0) = 0 THEN 12 ELSE isnull('+CONVERT(VARCHAR,@IDMesFin)+',0) END
	-- and IDTipoNomina '+@simbolo+CONVERT(VARCHAR,@IDTipoNomina)+'and Ejercicio = '+CONVERT(VARCHAR,@Ejercicio)+'and Cerrado = 1'
    insert into @periodo
    select   *
		--IDPeriodo  
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
	from Nomina.tblCatPeriodos with (nolock)  
	where IDPeriodo=@IDPeriodoSeleccionado
	and IDTipoNomina=@IDTipoNomina and Ejercicio =@Ejercicio and Cerrado = 1



	insert into @Conceptos
	select c.* from Nomina.tblCatConceptos c with(nolock)
	where
	 c.Codigo not like '0%'
	and c.Codigo not like '6%'
	and c.Codigo not in ('550','560')
	

	-- Guardamos en la variable @Cerrado el estatus del período para determinar si actualizamos o no los historiales de los colaboradres de la tabla Nomina.tblHistorialesEmpleadosPeriodos
	select top 1 @Cerrado = ISNULL(Cerrado,0) from @periodo

	select @MesInicio = (Select Descripcion from nomina.tblCatMeses where IDMes = (CASE WHEN isnull(@IDMesInicio,0) = 0 THEN 1 ELSE isnull(@IDMesInicio,0) END))
	select @MesFin = (Select Descripcion from nomina.tblCatMeses where IDMes = (CASE WHEN isnull(@IDMesFin,0) = 0 THEN 12 ELSE isnull(@IDMesFin,0) END))


	SET @Titulo = 'Resumen de percepciones, deducciones y obligaciones del mes ' +@MesInicio+' al '+@MesFin+' del '+@Ejercicio+'.'
  
  
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
    insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp
				where dp.IDPeriodo in(select IDPeriodo from @periodo)
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
    --exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario     
    
	--delete @empleados
	--where IDEmpleado not in (Select IDEmpleado from Nomina.tblDetallePeriodo where IDPeriodo = @IDPeriodoInicial )  
	
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
		@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario

	


	Insert into @dtDetallePeriodo
	SELECT 
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
	FROM Nomina.tblDetallePeriodo 
	where IDPeriodo in (SELECT IDPeriodo FROM @periodo)


 

	Select 
		-- E.ClaveEmpleado AS Clave
		-- , E.NOMBRECOMPLETO as Nombre
		-- , Depto.Codigo as [CODIGO DEPARTAMENTO]
		-- , E.Departamento
		  C.Codigo as Codigo
		, C.Descripcion as Concepto
		, Percepcion = CASE WHEN C.IDTipoConcepto = 1 THEN SUM(isnull(dp.ImporteTotal1,0)) ELSE 0 END
		, [Percepcion Gravada]  = CASE WHEN C.IDTipoConcepto = 1 THEN SUM(isnull(dp.ImporteGravado,0)) ELSE 0 END 
		, [Percepcion exento] = CASE WHEN C.IDTipoConcepto = 1 THEN SUM(isnull(dp.ImporteExcento,0)) ELSE 0 END
		, [Otros Tipos de Pago] = CASE WHEN C.IDTipoConcepto = 4 THEN SUM(isnull(dp.ImporteTotal1,0)) ELSE 0 END
		, Deducciones = CASE WHEN C.IDTipoConcepto = 2 THEN SUM(isnull(dp.ImporteTotal1,0)) ELSE 0 END
		, Obligaciones = CASE WHEN C.IDTipoConcepto = 3 THEN SUM(isnull(dp.ImporteTotal1,0)) ELSE 0 END
	from @empleados E
		LEFT join RH.tblCatDepartamentos depto with(nolock)
			on e.IDDepartamento = depto.IDDepartamento
		INNER join Nomina.tblDetallePeriodo dp WITH(NOLOCK)
			on dp.IDEmpleado = E.IDEmpleado
		INNER JOIN @periodo p
			on p.IDPeriodo = dp.IDPeriodo
		LEFT JOIN Nomina.tblCatMeses M
			on P.IDMes = M.IDMes
		inner join @Conceptos c
			on c.IDConcepto = dp.IDConcepto
		inner join Nomina.tblCatTipoConcepto tc with(nolock)
		on c.IDTipoConcepto = tc.IDTipoConcepto
	where isnull(dp.ImporteTotal1,0) > 0

	GROUP BY 
		  C.IDConcepto
		, C.Codigo
		, C.Descripcion
		, C.IDTipoConcepto
    ORDER BY C.IDTipoConcepto
		

        
	-- GROUP BY E.IDEmpleado
	-- 	, E.ClaveEmpleado
	-- 	, E.NOMBRECOMPLETO
	-- 	, E.Departamento
	-- 	, C.IDConcepto
	-- 	, C.Codigo
	-- 	, C.Descripcion
	-- 	, C.IDTipoConcepto
	-- 	, Depto.Codigo
	-- 	, C.OrdenCalculo
	-- 	, E.Cliente
    
    



GO
