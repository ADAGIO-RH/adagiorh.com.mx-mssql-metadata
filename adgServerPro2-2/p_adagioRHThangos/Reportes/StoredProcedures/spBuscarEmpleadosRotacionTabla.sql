USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Retación de empleados - tabla
** Autor			: Aneudy Abreu
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              

** DataTypes Relacionados: 
	-- @TipoRotacion = 1  - Vista sólo de Nuevos Ingresos    
	-- @TipoRotacion = 2  - Vista sólo de Reingresos    
	-- @TipoRotacion = 3  - Vista de Nuevos Ingresos y Reingresos    
	-- @TipoRotacion = 4  - Vista sólo de Bajas    
	-- @TipoRotacion = 5  - Vista de Nuevos Ingresos, Reingresos y Bajas  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE procedure [Reportes].[spBuscarEmpleadosRotacionTabla](      
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
		@TipoVigente varchar(max) = '1',       
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
        
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')       
        
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
	SET @TipoVigente = ((Select top 1 Value from @dtFiltros where Catalogo = 'TipoVigente'))
	SET @TipoRotacion = ((Select top 1 Value from @dtFiltros where Catalogo = 'TipoRotacion')) 
	SET @TipoNomina = ((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'))   
 
	SET @ClaveEmpleadoInicial = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')      
	SET @ClaveEmpleadoFinal = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')       
     
	declare
		@dtEmpleados [RH].[dtEmpleados]    
		,@TiposMovimientos Varchar(MAX) = ''  
		,@IDTipoMovimientoBaja int
		,@IDTipoNomina int
		,@IDTipoVigente int
		,@IDTipoRotacion int
		,@IDDatoExtraMedioReclutamiento int
	;

	select @IDDatoExtraMedioReclutamiento = IDDatoExtra from RH.tblCatDatosExtra with(nolock) where Nombre = 'MEDIO_RECLUTAMIENTO'

	set @IDTipoMovimientoBaja = (select top 1 IDTipoMovimiento 
									from IMSS.tblCatTipoMovimientos with (nolock) 
									where Codigo = 'B')
   
	SET @ClaveEmpleadoInicial	= CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	SET @ClaveEmpleadoFinal		= CASE WHEN ISNULL(@ClaveEmpleadoFinal,'')  = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END

	SET @IDTipoNomina	= (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
	SET @IDTipoVigente	= (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoVigente,'1'),','))
	SET @IDTipoRotacion = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoRotacion,'1'),','))
	SET @TipoRotacion	= CASE WHEN isnull(@TipoRotacion,'') = '' THEN '1,2,3,4' ELSE @TipoRotacion END
    
	if(@IDTipoVigente = 1)    
	BEGIN    
		insert into @dtEmpleados    
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario  
	
		select 
			e.ClaveEmpleado as [Clave Empleado]
			,e.NOMBRECOMPLETO as [Nombre Completo] 
			,E.RFC as [RFC ]
			,e.Departamento
			,e.Puesto
			,e.IMSS as [NSS ]
			,FORMAT(Mov.Fecha,'dd/MM/yyyy')as [Fecha Movimiento] 
			--,tMov.Codigo as CodigoMovimiento 
			,tMov.Descripcion as Movimiento 
			,Mov.SalarioDiario as [Salario Diario]   
			,Mov.SalarioVariable  as [Salario Variable]  
			,Mov.SalarioIntegrado as [Salario Integrado]  
			,Mov.SalarioDiarioReal as [Salario Diario Real]  
			,rMov.Descripcion [Razon Movimiento]   
			,tipoRazonMov.Descripcion as [Tipo Razón Movimiento]
			,Mov.Comentario as [Comentario Adicional]
			,FORMAT(Mov.FechaUltimoDiaLaborado,'dd/MM/yyyy') as [fecha Último Día Laborado]
			,JSON_VALUE(tp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [Tipo Prestación] 
			,e.TipoNomina as [Tipo Nomina]   
			,e.ClasificacionCorporativa as [Clasificación Corporativa]   
			,CREG.RazonSocial as [Registro Patronal]   
			,e.Cliente as [Cliente]   
			,e.CentroCosto as [Centro Costo]   
			,e.Sucursal as [Sucursal]   
			,e.Division as [División]   
			,isnull(dee.Valor,'SIN DATOS') as [Medio de reclutamiento]
		from IMSS.tblMovAfiliatorios Mov with (nolock)    
			inner join IMSS.tblCatTipoMovimientos tMov with (nolock) on Mov.IDTipoMovimiento = tMov.IDTipoMovimiento  
					and tMov.IDTipoMovimiento in (Select item from app.Split(@TipoRotacion,','))  
					and mov.Fecha Between @FechaIni and @FechaFin 
			left join IMSS.tblCatRazonesMovAfiliatorios rMov with (nolock) on mov.IDRazonMovimiento = rMov.IDRazonMovimiento  
			left join IMSS.tblCatTiposRazonesMovimientos tipoRazonMov on tipoRazonMov.IDCatTipoRazonMovimiento = Mov.IDTipoRazonMovimiento
			inner join @dtEmpleados e on e.IDEmpleado = mov.IDEmpleado  
			left join RH.tblCatTiposPrestaciones tp with (nolock) on e.IDTipoPrestacion = tp.IDTipoPrestacion  
			left join RH.tblDatosExtraEmpleados dee with(nolock) on dee.IDEmpleado = e.IDEmpleado
				and dee.IDDatoExtra = @IDDatoExtraMedioReclutamiento 
            left join RH.tblCatRegPatronal CREG with (nolock) on CREG.IDRegPatronal=MOV.IDRegPatronal
		where E.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0'  
		order by e.ClaveEmpleado asc, mov.Fecha asc    
	END    
	ELSE IF(@IDTipoVigente = 2)    
	BEGIN    
		insert into @dtEmpleados    
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario    
    
		select 
			e.ClaveEmpleado as [Clave Empleado]  
			,e.NOMBRECOMPLETO as [Nombre Completo] 
			,E.RFC as RFC
			,e.IMSS as [NSS ]
			,e.Departamento
			,e.Puesto
			,FORMAT(Mov.Fecha,'dd/MM/yyyy')as [Fecha Movimiento] 
			--,tMov.Codigo as CodigoMovimiento 
			,tMov.Descripcion as Movimiento 
			,Mov.SalarioDiario as [Salario Diario]   
			,Mov.SalarioVariable  as [Salario Variable]  
			,Mov.SalarioIntegrado as [Salario Integrado]  
			,Mov.SalarioDiarioReal as [Salario Diario Real]  
			,rMov.Descripcion RazonMovimiento   
			,tipoRazonMov.Descripcion as [Tipo Razón Movimiento]
			,Mov.Comentario as [Comentario Adicional]
			,FORMAT(Mov.FechaUltimoDiaLaborado,'dd/MM/yyyy') as [fecha Último Día Laborado]
			,JSON_VALUE(tp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [Tipo Prestación] 
			,e.TipoNomina as [Tipo Nomina]   
			,e.ClasificacionCorporativa as [Clasificación Corporativa]   
			,CREG.RazonSocial as [Registro Patronal]   
			,e.Cliente as [Cliente]   
			,e.CentroCosto as [Centro Costo]   
			,e.Sucursal as [Sucursal]   
			,e.Division as [División]   
			,isnull(dee.Valor,'SIN DATOS') as [Medio de reclutamiento]
		from IMSS.tblMovAfiliatorios Mov with(nolock)    
			inner join IMSS.tblCatTipoMovimientos tMov with(nolock) on Mov.IDTipoMovimiento = tMov.IDTipoMovimiento 
					and tMov.IDTipoMovimiento in (Select item from app.Split(@TipoRotacion,','))   
					and mov.Fecha Between @FechaIni and @FechaFin     
			left join IMSS.tblCatRazonesMovAfiliatorios rMov with(nolock) on mov.IDRazonMovimiento = rMov.IDRazonMovimiento   			
			left join IMSS.tblCatTiposRazonesMovimientos tipoRazonMov on tipoRazonMov.IDCatTipoRazonMovimiento = Mov.IDTipoRazonMovimiento
			inner join RH.tblEmpleadosMaster e with(nolock) on e.IDEmpleado = mov.IDEmpleado    
			left join RH.tblCatTiposPrestaciones tp with(nolock) on e.IDTipoPrestacion = tp.IDTipoPrestacion
			left join RH.tblDatosExtraEmpleados dee with(nolock) on dee.IDEmpleado = e.IDEmpleado
				and dee.IDDatoExtra = @IDDatoExtraMedioReclutamiento 
            left join RH.tblCatRegPatronal CREG with (nolock) on CREG.IDRegPatronal=MOV.IDRegPatronal     
		where 
		(E.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
		or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')         
		order by e.ClaveEmpleado asc, mov.Fecha asc  
    
	END ELSE IF(@IDTipoVigente = 3)    
	BEGIN    
		select 
			M.ClaveEmpleado as [Clave Empleado]
			,M.NOMBRECOMPLETO as NombreCompleto 
			,M.RFC as [RFC ]
			,M.IMSS as [NSS ]
			,M.Departamento
			,M.Puesto
			,FORMAT(Mov.Fecha,'dd/MM/yyyy')as [Fecha Movimiento] 
			--,tMov.Codigo as CodigoMovimiento 
			,tMov.Descripcion as Movimiento 
			,Mov.SalarioDiario as [Salario Diario]   
			,Mov.SalarioVariable  as [Salario Variable]  
			,Mov.SalarioIntegrado as [Salario Integrado]  
			,Mov.SalarioDiarioReal as [Salario Diario Real]  
			,rMov.Descripcion RazonMovimiento   
			,tipoRazonMov.Descripcion as [Tipo Razón Movimiento]
			,Mov.Comentario as [Comentario Adicional]
			,FORMAT(Mov.FechaUltimoDiaLaborado,'dd/MM/yyyy') as [fecha Último Día Laborado]
			,tp.Descripcion as [Tipo Prestación] 
			,M.TipoNomina as [Tipo Nomina]   
			,M.ClasificacionCorporativa as [Clasificación Corporativa]   
			,CREG.RazonSocial as [Registro Patronal]   
			,M.Cliente as [Cliente]   
			,M.CentroCosto as [Centro Costo]   
			,M.Sucursal as [Sucursal]   
			,M.Division as [División]   
			,isnull(dee.Valor,'SIN DATOS') as [Medio de reclutamiento] 
		from IMSS.tblMovAfiliatorios Mov with(nolock)   
			inner join IMSS.tblCatTipoMovimientos tMov with(nolock) on Mov.IDTipoMovimiento = tMov.IDTipoMovimiento    
					and tMov.IDTipoMovimiento in (Select item from app.Split(@TipoRotacion,','))    
			inner join RH.tblEmpleadosMaster M with(nolock) on M.IDEmpleado = mov.IDEmpleado   
			left join RH.tblCatTiposPrestaciones tp with(nolock) on M.IDTipoPrestacion = tp.IDTipoPrestacion   
			left join IMSS.tblCatRazonesMovAfiliatorios rMov with(nolock) on mov.IDRazonMovimiento = rMov.IDRazonMovimiento   			
			left join IMSS.tblCatTiposRazonesMovimientos tipoRazonMov on tipoRazonMov.IDCatTipoRazonMovimiento = Mov.IDTipoRazonMovimiento
			left join RH.tblDatosExtraEmpleados dee with(nolock) on dee.IDEmpleado = m.IDEmpleado
				and dee.IDDatoExtra = @IDDatoExtraMedioReclutamiento 
            left join RH.tblCatRegPatronal CREG with (nolock) on CREG.IDRegPatronal=MOV.IDRegPatronal                
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
			and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))                 
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))          
			and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))                 
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))         
			and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))                 
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))                   
		order by M.ClaveEmpleado asc, mov.Fecha asc  
	END    
END
GO
