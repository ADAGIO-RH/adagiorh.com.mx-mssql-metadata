USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarEmpleadosRotacionTablaMoti] --@IDPeriodo = 1    
(      
	@dtFiltros [Nomina].[dtFiltrosRH]  readonly,   
	@IDUsuario int    
)    
AS    
BEGIN    
    
	Declare 
		@IDIdioma Varchar(5),        
		@IdiomaSQL varchar(100) = null,  
		@FechaIni date,     
		@FechaFin date,     
		--@TipoVigente varchar(max) = '1',       
		@TipoRotacion varchar(max) = '1,2,3,4',     
		@TipoNomina varchar(max) = '0',    
		@ClaveEmpleadoInicial Varchar(20) = '0',    
		@ClaveEmpleadoFinal Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',        
		@Cliente Varchar(max) = '',
		@Departamentos Varchar(max) = '',
		@Sucursales Varchar(max) = '',
		@Puestos Varchar(max) = '',
		@RazonesSociales Varchar(max) = '',
		@RegPatronales Varchar(max) = '',
		@Divisiones Varchar(max) = '',
		@Prestaciones Varchar(max) = ''
	;
 
	SET DATEFIRST 7;        
        
	select top 1 @IDIdioma = dp.Valor        
	from Seguridad.tblUsuarios u with(nolock)       
		Inner join App.tblPreferencias p with(nolock)
			on u.IDPreferencia = p.IDPreferencia        
		Inner join App.tblDetallePreferencias dp with(nolock)       
			on dp.IDPreferencia = p.IDPreferencia        
		Inner join App.tblCatTiposPreferencias tp with(nolock)        
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia        
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'        
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with(nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	SET @FechaIni = cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')) as date)       
	SET @FechaFin = cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')) as date)      
	--SET @TipoVigente = ((Select top 1 Value from @dtFiltros where Catalogo = 'TipoVigente'))
	SET @TipoRotacion = ((Select top 1 Value from @dtFiltros where Catalogo = 'TipoRotacion')) 
	SET @TipoNomina = ((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'))   
 
	SET @ClaveEmpleadoInicial = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')      
	SET @ClaveEmpleadoFinal = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')       
     
	declare --@dtFiltros [Nomina].[dtFiltrosRH]    
		@dtEmpleados [RH].[dtEmpleados]    
		,@TiposMovimientos Varchar(MAX) = ''  
		,@IDTipoMovimientoBaja int
		,@IDTipoNomina int
		--,@IDTipoVigente int
		,@IDTipoRotacion int
		,@IDDatoExtraOptimoMensual int
	;

	select @IDDatoExtraOptimoMensual = IDDatoExtra from RH.tblCatDatosExtra with(nolock) where Nombre = 'OPTIMO_MENSUAL'

	set @IDTipoMovimientoBaja = (select top 1 IDTipoMovimiento 
									from IMSS.tblCatTipoMovimientos with (nolock) 
									where Codigo = 'B')
   
	--insert into @dtFiltros(Catalogo,Value)
	--values('Departamentos',@Departamentos)
	--,('Sucursales',@Sucursales)
	--,('Puestos',@Puestos)
	--,('RazonesSociales',@RazonesSociales)
	--,('RegPatronales',@RegPatronales)
	--,('Divisiones',@Divisiones)
	--,('Prestaciones',@Prestaciones)
	--,('Clientes',@Cliente)   
    
	-- @TipoRotacion = 1  - Vista sólo de Nuevos Ingresos    
	-- @TipoRotacion = 2  - Vista sólo de Reingresos    
	-- @TipoRotacion = 3  - Vista de Nuevos Ingresos y Reingresos    
	-- @TipoRotacion = 4  - Vista sólo de Bajas    
	-- @TipoRotacion = 5  - Vista de Nuevos Ingresos, Reingresos y Bajas    
    

	SET @ClaveEmpleadoInicial	= CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	SET @ClaveEmpleadoFinal		= CASE WHEN ISNULL(@ClaveEmpleadoFinal,'')  = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END

	SET @IDTipoNomina	= (Select top 1 CAST(item as int) from App.Split(isnull(@TipoNomina,'0'),','))
  --SET @IDTipoVigente	= (Select top 1 CAST(item as int) from App.Split(isnull(@TipoVigente,'1'),','))
	SET @IDTipoRotacion = (Select top 1 CAST(item as int) from App.Split(isnull(@TipoRotacion,'1'),','))
	SET @TipoRotacion	= CASE WHEN isnull(@TipoRotacion,'') = '' THEN '1,2,3,4' ELSE @TipoRotacion END

	--Select item from app.Split(@TipoRotacion,',')
    
	--if(@TipoRotacion = 1)    
	--BEGIN    
	-- set @TiposMovimientos = 'A'    
	--END    
	--if(@TipoRotacion = 2)    
	--BEGIN    
	-- set @TiposMovimientos = 'R'    
	--END    
	--if(@TipoRotacion = 3)    
	--BEGIN    
	-- set @TiposMovimientos = 'A,R'    
	--END    
	--if(@TipoRotacion = 4)    
	--BEGIN    
	-- set @TiposMovimientos = 'B'    
	--END    
	--if(@TipoRotacion = 5)    
	--BEGIN    
	-- set @TiposMovimientos = 'A,R,B'    
	--END    
    
	--insert into @dtFiltros(Catalogo,Value)    
	--values('Clientes',@IDCliente)    

	--select @IDTipoVigente , @TipoRotacion, @TiposMovimientos, @FechaIni, @FechaFin

	--if(@IDTipoVigente = 1)  
	--IF (@IDTipoRotacion = 1)
	--BEGIN    
		insert into @dtEmpleados    
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario  
	
		select 
			 ROW_NUMBER() over(order by e.ClaveEmpleado) as [Numero]
			,e.ClaveEmpleado as [Codigo Empleado]   
			,e.NOMBRECOMPLETO as [Nombre Completo] 
			,FORMAT(Mov.Fecha,'dd/MM/yyyy')as [Fecha del Movimiento]
			,ISNULL(e.Empresa,'') as [Empresa]
			,ISNULL(e.Puesto,'') as [Puesto]
			,ISNULL(e.Departamento,'') as [Departamento]
			,ISNULL(E.CentroCosto,'') as [Centro de Costo]
			,case when Mov.IDTipoMovimiento = 2 then 0 else
			 ISNULL(Mov.SalarioDiarioReal,0) * 30 end as [Nomina]
			,case when Mov.IDTipoMovimiento = 2 then 0 else 
			 isnull(cast (dee.Valor as decimal (18,2)) ,0) end as [Optimo]
			,case when Mov.IDTipoMovimiento = 2 then 0 else 
			(ISNULL(Mov.SalarioDiarioReal,0) * 30) + isnull(dee.Valor,0) end as [Total]
			,tMov.Descripcion as Movimiento 
			,rMov.Descripcion RazonMovimiento
			,rp.RazonSocial as [Razon Social]
			,mov.SalarioDiario as [Salario Diario]
			,mov.SalarioIntegrado as [Salario integrado]
		from IMSS.tblMovAfiliatorios Mov with (nolock)    
			inner join IMSS.tblCatTipoMovimientos tMov with (nolock)    
				on Mov.IDTipoMovimiento = tMov.IDTipoMovimiento  
					and tMov.IDTipoMovimiento in (Select item from app.Split(@TipoRotacion,','))  
					and mov.Fecha Between @FechaIni and @FechaFin 
			left join IMSS.tblCatRazonesMovAfiliatorios rMov with (nolock)    
				on mov.IDRazonMovimiento = rMov.IDRazonMovimiento    
			inner join RH.tblEmpleadosMaster e    
				on e.IDEmpleado = mov.IDEmpleado  
			left join RH.tblCatTiposPrestaciones tp with (nolock)
				on e.IDTipoPrestacion = tp.IDTipoPrestacion 
			left join RH.tblDatosExtraEmpleados dee with(nolock) 
				on dee.IDEmpleado = e.IDEmpleado
				and dee.IDDatoExtra = @IDDatoExtraOptimoMensual
			left join rh.tblCatRegPatronal rp 
				on rp.IDRegPatronal=Mov.IDRegPatronal
		where E.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0' 
			--AND TRY_CAST (ISNULL (DEE.Valor,0) AS decimal (18,2)) >= 0 
		order by e.ClaveEmpleado asc, mov.Fecha asc , Mov.IDTipoMovimiento 
	END    
	/*ELSE IF (@IDTipoRotacion = 3) 
	--IF(@IDTipoVigente = 2)    
	BEGIN    
		insert into @dtEmpleados    
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario    
    
		select 
			 e.ClaveEmpleado    
			,e.NOMBRECOMPLETO as NombreCompleto 
			,E.RFC as [RFC  ]
			,E.IMSS as [IMSS]
			,e.Departamento
			,e.Puesto
			,FORMAT(Mov.Fecha,'dd/MM/yyyy')as FechaMovimiento 
			--,tMov.Codigo as CodigoMovimiento 
			,tMov.Descripcion as Movimiento 
			,Mov.SalarioDiario as [Salario_Diario]   
			,Mov.SalarioVariable  as [Salario_Variable]  
			,Mov.SalarioIntegrado as [Salario_Integrado]  
			,Mov.SalarioDiarioReal as [Salario_Diario_Real]  
			,rMov.Descripcion RazonMovimiento   
			,tp.Descripcion as [Tipo_Prestación] 
			,e.TipoNomina as [Tipo_Nomina]   
			,e.ClasificacionCorporativa as [Clasificación_Corporativa]   
			,e.RegPatronal as [Registro_Patronal]   
			,e.Cliente as [Cliente]   
			,e.CentroCosto as [Centro_Costo]   
			,e.Sucursal as [Sucursal]   
			,e.Division as [División]   
			,isnull(dee.Valor,'SIN DATOS') as [Medio_Reclutamiento]
			-- CUSTOMIZADO PRINCESS
		from IMSS.tblMovAfiliatorios Mov with(nolock)    
			inner join IMSS.tblCatTipoMovimientos tMov with(nolock)    
				on Mov.IDTipoMovimiento = tMov.IDTipoMovimiento 
					and tMov.IDTipoMovimiento in (Select item from app.Split(@TipoRotacion,','))   
					and mov.Fecha Between @FechaIni and @FechaFin     
			left join IMSS.tblCatRazonesMovAfiliatorios rMov with(nolock)    
				on mov.IDRazonMovimiento = rMov.IDRazonMovimiento    
			inner join RH.tblEmpleadosMaster e with(nolock)    
				on e.IDEmpleado = mov.IDEmpleado    
			left join RH.tblCatTiposPrestaciones tp with(nolock)
				on e.IDTipoPrestacion = tp.IDTipoPrestacion  
			-- CUSTOMIZADO PRINCESS
			left join RH.tblDatosExtraEmpleados dee with(nolock) 
				on dee.IDEmpleado = e.IDEmpleado
				and dee.IDDatoExtra = @IDDatoExtraOptimoMensual 
			-- CUSTOMIZADO PRINCESS

		where 
		(E.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
		or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')         
		order by e.ClaveEmpleado asc, mov.Fecha asc  
    
	END */
	/*ELSE IF (@IDTipoRotacion = 2) 
	--IF(@IDTipoVigente = 3)    
	BEGIN    
		select 
			M.ClaveEmpleado    
			,M.NOMBRECOMPLETO as NombreCompleto 
			,M.RFC as RFC
			,M.IMSS as [IMSS]
			,M.Departamento
			,M.Puesto
			,FORMAT(Mov.Fecha,'dd/MM/yyyy')as FechaMovimiento 
			--,tMov.Codigo as CodigoMovimiento 
			,tMov.Descripcion as Movimiento 
			,Mov.SalarioDiario as [Salario_Diario]   
			,Mov.SalarioVariable  as [Salario_Variable]  
			,Mov.SalarioIntegrado as [Salario_Integrado]  
			,Mov.SalarioDiarioReal as [Salario_Diario_Real]  
			,rMov.Descripcion RazonMovimiento   
			,tp.Descripcion as [Tipo_Prestación] 
			,M.TipoNomina as [Tipo_Nomina]   
			,M.ClasificacionCorporativa as [Clasificación_Corporativa]   
			,M.RegPatronal as [Registro_Patronal]   
			,M.Cliente as [Cliente]   
			,M.CentroCosto as [Centro_Costo]   
			,M.Sucursal as [Sucursal]   
			,M.Division as [División]  
			-- CUSTOMIZADO PRINCESS
			,isnull(dee.Valor,'SIN DATOS') as [Medio_Reclutamiento] 
			-- CUSTOMIZADO PRINCESS

		from IMSS.tblMovAfiliatorios Mov with(nolock)   
			inner join IMSS.tblCatTipoMovimientos tMov with(nolock)    
				on Mov.IDTipoMovimiento = tMov.IDTipoMovimiento    
					and tMov.IDTipoMovimiento in (Select item from app.Split(@TipoRotacion,','))    
			inner join RH.tblEmpleadosMaster M with(nolock)    
				on M.IDEmpleado = mov.IDEmpleado   
			left join RH.tblCatTiposPrestaciones tp with(nolock)
				on M.IDTipoPrestacion = tp.IDTipoPrestacion   
			--inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU  
			-- on M.IDEmpleado = FEU.IDEmpleado  
			-- and FEU.IDUsuario = @IDUsuario  
			left join IMSS.tblCatRazonesMovAfiliatorios rMov with(nolock)    
				on mov.IDRazonMovimiento = rMov.IDRazonMovimiento    

					-- CUSTOMIZADO PRINCESS
			left join RH.tblDatosExtraEmpleados dee with(nolock) 
				on dee.IDEmpleado = m.IDEmpleado
				and dee.IDDatoExtra = @IDDatoExtraOptimoMensual 
			-- CUSTOMIZADO PRINCESS

		where mov.Fecha Between @FechaIni and @FechaFin    
			and (M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')         
			and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))                 
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))                
			and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))                 
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))                
			and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))                 
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))                
			and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))                 
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))             
			and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))                 
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))                    
			and ((M.IDEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))                 
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))          
			and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))                 
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))         
			and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))                 
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))                   
		order by M.ClaveEmpleado asc, mov.Fecha asc  
	END   */ 
--END
GO
