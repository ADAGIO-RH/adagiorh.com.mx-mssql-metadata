USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spCalculoNominaDetalleGeneralGruposSubReportesX]--4114,17,'5'      
(      
	@IDDepartamento varchar(max) = '',      
	@IDSucursal  varchar(max) = '',         
	@IDRazonSocial  varchar(max) = '',  
	@IDPuesto varchar(max) = '',     
	@IDPrestaciones varchar(max) = '',   
	@IDClientes varchar(max) = '',   
	@IDRegPatronales varchar(max) = '',   
	@IDDivisiones varchar(max) = '',    
	@IDCentrosCostos varchar(max) = '',    
	@IDClasificacionesCorporativas varchar(max) = '',     
	@IDPeriodo int,      
	@IDTipoConcepto varchar(50) = null,      
	@ConceptosPago varchar(50) = null ,  
	@Include varchar(MAX) = null,    
	@Exclude varchar(MAX) = null,   
	@IDUsuario int     
)      
AS      
BEGIN      
    --SET NOCOUNT ON;  
	IF 1=0 BEGIN  
		SET FMTONLY OFF  
	END  
    
	DECLARE         
		@empleados [RH].[dtEmpleados]  
		,@empleadosTemp [RH].[dtEmpleados]      
		,@IDPeriodoSeleccionado int=0        
		,@periodo [Nomina].[dtPeriodos]        
		,@configs [Nomina].[dtConfiguracionNomina]        
		,@Conceptos [Nomina].[dtConceptos]        
		,@dtFiltros [Nomina].[dtFiltrosRH]       
		,@IDTipoNomina int   
		,@fechaIniPeriodo  date        
		,@fechaFinPeriodo  date  
		,@Cerrado bit = 1    
        ,@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
       
	IF OBJECT_ID('tempdb..#tempResultado') IS NOT NULL DROP TABLE #tempResultado      
      
	if(isnull(@IDDepartamento,'')<>'')        
	BEGIN        
		insert into @dtFiltros(Catalogo,Value)        
		values('Departamentos',case when @IDDepartamento is null then '' else @IDDepartamento end)        
	END;
	
	if(isnull(@IDSucursal,'')<>'')        
	BEGIN        
		insert into @dtFiltros(Catalogo,Value)        
		values('Sucursales',case when @IDSucursal is null then '' else @IDSucursal end)        
	END;    
   
	if(isnull(@IDPuesto,'')<>'')        
	BEGIN        
		insert into @dtFiltros(Catalogo,Value)        
		values('Puestos',case when @IDPuesto is null then '' else @IDPuesto end)        
	END;    
   
	if(isnull(@IDPrestaciones,'')<>'')        
	BEGIN        
		insert into @dtFiltros(Catalogo,Value)        
		values('Prestaciones',case when @IDPrestaciones is null then '' else @IDPrestaciones end)        
	END;     
  
	if(isnull(@IDClientes,'')<>'')        
	BEGIN        
		insert into @dtFiltros(Catalogo,Value)        
		values('Clientes',case when @IDClientes is null then '' else @IDClientes end)        
	END;   
    
	if(isnull(@IDRazonSocial,'')<>'')        
	BEGIN        
		insert into @dtFiltros(Catalogo,Value)        
		values('RazonesSociales',case when @IDRazonSocial is null then '' else @IDRazonSocial end)        
	END;    
      
	if(isnull(@IDRegPatronales,'')<>'')        
	BEGIN        
		insert into @dtFiltros(Catalogo,Value)        
		values('RegPatronales',case when @IDRegPatronales is null then '' else @IDRegPatronales end)        
	END;    
	
	if(isnull(@IDDivisiones,'')<>'')        
	BEGIN        
		insert into @dtFiltros(Catalogo,Value)        
		values('Divisiones',case when @IDDivisiones is null then '' else @IDDivisiones end)        
	END;  
	
	if(isnull(@IDClasificacionesCorporativas,'')<>'')        
	BEGIN        
		insert into @dtFiltros(Catalogo,Value)        
		values('ClasificacionesCorporativas',case when @IDClasificacionesCorporativas is null then '' else @IDClasificacionesCorporativas end)        
	END;  

	if(isnull(@IDCentrosCostos,'')<>'')        
	BEGIN        
		insert into @dtFiltros(Catalogo,Value)        
		values('CentrosCostos',case when @IDCentrosCostos is null then '' else @IDCentrosCostos end)        
	END;  

	--if(isnull(@ConceptosPago,'')<>'')        
	--BEGIN        
	--	insert into @dtFiltros(Catalogo,Value)        
	--	values('ConceptosPago',case when @ConceptosPago is null then '' else @ConceptosPago end)        
	--END;  
     
     
	Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Especial,Cerrado)        
    select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,isnull(Especial,0),Cerrado        
    from Nomina.TblCatPeriodos   with (nolock)        
    where IDPeriodo = @IDPeriodo        
        
         
    select @fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago   , @IDTipoNomina = IDTipoNomina     
    from @periodo       
    where IDPeriodo = @IDPeriodo     
  
	select top 1 @Cerrado = ISNULL(Cerrado,0) from @periodo

	insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp
				where dp.IDPeriodo = @IDPeriodo
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado

	if (@Cerrado = 1)
	begin
		update e
			set 
				e.IDCentroCosto		= isnull(cc.IDCentroCosto	,e.IDCentroCosto)
				,e.CentroCosto		= isnull(JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) ,e.CentroCosto		)
				,e.IDDepartamento	= isnull(d.IDDepartamento	,e.IDDepartamento)
				,e.Departamento		= isnull(JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) 	,e.Departamento	)
				,e.IDSucursal		= isnull(s.IDSucursal		,e.IDSucursal	)
				,e.Sucursal			= isnull(s.Descripcion		,e.Sucursal		)
				,e.IDPuesto			= isnull(p.IDPuesto			,e.IDPuesto		)
				,e.Puesto			= isnull(JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) ,e.Puesto		)
				,e.IDRegPatronal	= isnull(rp.IDRegPatronal	,e.IDRegPatronal)
				,e.RegPatronal		= isnull(rp.RazonSocial		,e.RegPatronal	)
				,e.IDCliente		= isnull(c.IDCliente		,e.IDCliente	)
				,e.Cliente			= isnull(c.NombreComercial	,e.Cliente		)
				,e.IDEmpresa		= isnull(emp.IdEmpresa		,e.IdEmpresa	)
				,e.Empresa			= isnull(substring(emp.NombreComercial,1,50),substring(e.Empresa,1,50))
				,e.IDArea			= isnull(a.IDArea			,e.IDArea		)
				,e.Area				= isnull(JSON_VALUE(a.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) ,		e.Area		)
				,e.IDDivision		= isnull(div.IDDivision		,e.IDDivision	)
				,e.Division			= isnull(JSON_VALUE(div.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) ,	e.Division		)
				,e.IDRegion			= isnull(r.IDRegion			,e.IDRegion		)
				,e.Region			= isnull(JSON_VALUE(r.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.Region		)
				,e.IDRazonSocial	= isnull(rs.IDRazonSocial	,e.IDRazonSocial)
				,e.RazonSocial		= isnull(rs.RazonSocial		,e.RazonSocial	)

				,e.IDClasificacionCorporativa	= isnull(clasificacionC.IDClasificacionCorporativa,e.IDClasificacionCorporativa)
				--,e.ClasificacionCorporativa	= isnull(clasificacionC.Descripcion, e.ClasificacionCorporativa)
				,e.ClasificacionCorporativa		= isnull(JSON_VALUE(clasificacionC.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Descripcion')), e.ClasificacionCorporativa)
				

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
      
	select   
		dp.IDConcepto      
		,ccp.Codigo      
		,ccp.Descripcion as Concepto      
		,ccp.IDTipoConcepto      
		,tc.Descripcion as TipoConcepto      
		,ccp.OrdenCalculo       
		,SUM(dp.ImporteGravado) as ImporteGravado      
		,SUM(dp.ImporteExcento) as ImporteExcento      
		,SUM(dp.ImporteOtro) as ImporteOtro      
		,SUM(dp.ImporteTotal1) as ImporteTotal1      
		,SUM(dp.ImporteTotal2) ImporteTotal2          
		,SUM(dp.ImporteAcumuladoTotales) as ImporteAcumuladoTotales      
	INTO #tempResultado      
	from [Nomina].[tblDetallePeriodo] dp with (nolock)      
		LEFT join @periodo cp  on dp.IDPeriodo = cp.IDPeriodo      
		LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina      
		INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto         
		INNER join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto      
		inner join @empleados e  on e.IDEmpleado = dp.IDEmpleado  
	where cp.IDPeriodo = @IDPeriodo      
		and ccp.Impresion = 1          
		and ((tc.IDTipoConcepto in (select ITEM from App.Split(@IDTipoConcepto,','))) OR (isnull(@IDTipoConcepto,'') = ''))      
		and ((ccp.IDConcepto= @ConceptosPago) OR (ISNULL(@ConceptosPago,'') = '') )     
		and ((ccp.Codigo in (select ITEM from App.Split(@Include,',')) OR (ISNULL(@Include,'') = '') ))    
		and ((ccp.Codigo not in (select ITEM from App.Split(@Exclude,','))) OR (ISNULL(@Exclude,'') = '') )    
	GROUP BY  
		dp.IDConcepto      
		,ccp.Codigo      
		,ccp.Descripcion   
		,ccp.IDTipoConcepto      
		,tc.Descripcion   
		,ccp.OrdenCalculo       
	ORDER BY ccp.OrdenCalculo ASC      
      
	--select * from #tempResultado      
	if (@Exclude is not null and @ConceptosPago is not null)
	begin
		update #tempResultado
			set ImporteTotal1 = ImporteTotal1 - (select SUM(ImporteTotal1)
					from [Nomina].[tblDetallePeriodo] dp with (nolock) 
						INNER join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto     
					where dp.IDPeriodo = @IDPeriodo and ccp.Codigo in (select ITEM from App.Split(@Exclude,','))
				) 
	end

	IF(@IDTipoConcepto = '5')      
	BEGIN      
		SELECT * FROM #tempResultado      
		WHERE ImporteTotal1 > 0      
		ORDER BY OrdenCalculo ASC    
	END      
	ELSE      
	BEGIN      
		SELECT * FROM #tempResultado      
		ORDER BY OrdenCalculo ASC    
	END 
	
    DROP TABLE #tempResultado;  
END
GO
