USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spBuscarEmpleadosRotacion](    
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
	 @Prestaciones Varchar(max) = '',
	 @IDUsuario int    
)    
AS    
BEGIN    
    
--@TipoVigentes = 1 Vigentes    
--@TipoVigentes = 2 No Vigentes    
--@TipoVigentes = 3 Ambos    
    
-- @TipoRotacion = 1  - Vista sólo de Nuevos Ingresos    
-- @TipoRotacion = 2  - Vista sólo de Reingresos    
-- @TipoRotacion = 3  - Vista de Nuevos Ingresos y Reingresos    
-- @TipoRotacion = 4  - Vista sólo de Bajas    
-- @TipoRotacion = 5  - Vista de Nuevos Ingresos, Reingresos y Bajas    
    
	Declare 
		@dtFiltros [Nomina].[dtFiltrosRH]    
		,@dtEmpleados [RH].[dtEmpleados]    
		,@TiposMovimientos Varchar(MAX) = ''  
		,@IDTipoMovimientoBaja int
		,@IDTipoNomina int
		,@IDTipoVigente int
		,@IDTipoRotacion int
		,@IDIdioma Varchar(5)        
		,@IdiomaSQL varchar(100) = null  
	;

	set @IDTipoMovimientoBaja = (select top 1 IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo = 'B')
   
	insert into @dtFiltros(Catalogo,Value)
	values('Departamentos',@Departamentos)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)
		,('RazonesSociales',@RazonesSociales)
		,('RegPatronales',@RegPatronales)
		,('Divisiones',@Divisiones)
		,('Prestaciones',@Prestaciones)
		,('Clientes',@Cliente)   
    
	-- @TipoRotacion = 1  - Vista sólo de Nuevos Ingresos    
	-- @TipoRotacion = 2  - Vista sólo de Reingresos    
	-- @TipoRotacion = 3  - Vista de Nuevos Ingresos y Reingresos    
	-- @TipoRotacion = 4  - Vista sólo de Bajas    
	-- @TipoRotacion = 5  - Vista de Nuevos Ingresos, Reingresos y Bajas    
   
   
	SET DATEFIRST 7;   
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	SET @ClaveEmpleadoInicial = CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	SET @ClaveEmpleadoFinal = CASE WHEN ISNULL(@ClaveEmpleadoFinal,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoVigente,'1'),','))
	SET @IDTipoRotacion = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoRotacion,'1'),','))
	SET @TipoRotacion = CASE WHEN isnull(@TipoRotacion,'') = '' THEN '1,2,3,4' ELSE @TipoRotacion END

    
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

 if(@IDTipoVigente = 1)    
 BEGIN    
  insert into @dtEmpleados    
  Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario  
  --select * from @dtEmpleados    
   print 'aqui' 
  select e.ClaveEmpleado    
     ,e.NOMBRECOMPLETO as NombreCompleto 
	 ,e.RFC as RFC
	 ,e.RegPatronal 
	 ,e.Departamento
	 ,e.Puesto
	 ,e.IMSS as NSS
	 ,Mov.SalarioDiario   
	 ,Mov.SalarioVariable   
	 ,Mov.SalarioIntegrado   
	 ,Mov.SalarioDiarioReal   
     ,tMov.Codigo as CodigoMovimiento    
     ,tMov.Descripcion as Movimiento    
     ,Mov.Fecha as FechaMovimiento    
     ,rMov.Descripcion RazonMovimiento  
	 ,(select top 1 Fecha from IMSS.tblMovAfiliatorios where IDEmpleado = e.IDEmpleado and Fecha Between @FechaIni and @FechaFin and IDTipoMovimiento = @IDTipoMovimientoBaja order by Fecha desc )  as FechaBaja
	 ,Titulo = UPPER( 'REPORTE DE MOVIMIENTOS AFILIATORIOS DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))
  from IMSS.tblMovAfiliatorios Mov    
   inner join IMSS.tblCatTipoMovimientos tMov    
    on Mov.IDTipoMovimiento = tMov.IDTipoMovimiento  
	and tMov.IDTipoMovimiento in (Select item from app.Split(@TipoRotacion,','))  
	and mov.Fecha Between @FechaIni and @FechaFin 
   left join IMSS.tblCatRazonesMovAfiliatorios rMov    
    on mov.IDRazonMovimiento = rMov.IDRazonMovimiento    
   inner join @dtEmpleados e    
    on e.IDEmpleado = mov.IDEmpleado    
  where    
  
   E.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0'  
  order by e.ClaveEmpleado asc, mov.Fecha asc    
 END    
 ELSE IF(@IDTipoVigente = 2)    
 BEGIN    
  insert into @dtEmpleados    
  Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario    
    
    select e.ClaveEmpleado    
     ,e.NOMBRECOMPLETO as NombreCompleto  
	  ,e.RFC as RFC   
	 ,e.RegPatronal  
	 ,e.Departamento
	 ,e.Puesto
	 ,e.IMSS as NSS
	 ,Mov.SalarioDiario   
	 ,Mov.SalarioVariable   
	 ,Mov.SalarioIntegrado   
	 ,Mov.SalarioDiarioReal  
     ,tMov.Codigo as CodigoMovimiento    
     ,tMov.Descripcion as Movimiento    
     ,Mov.Fecha as FechaMovimiento    
     ,rMov.Descripcion RazonMovimiento    
	  ,(select top 1 Fecha from IMSS.tblMovAfiliatorios where IDEmpleado = e.IDEmpleado and Fecha Between @FechaIni and @FechaFin and IDTipoMovimiento = @IDTipoMovimientoBaja order by Fecha desc )  as FechaBaja
	 ,Titulo = UPPER( 'REPORTE DE MOVIMIENTOS AFILIATORIOS DEL ' + FORMAT(@FechaIni,'dd/MMMM/yyyy') + ' AL '+  FORMAT(@FechaFin,'dd/MMMM/yyyy'))
  from IMSS.tblMovAfiliatorios Mov    
   inner join IMSS.tblCatTipoMovimientos tMov    
    on Mov.IDTipoMovimiento = tMov.IDTipoMovimiento 
	and tMov.IDTipoMovimiento in (Select item from app.Split(@TipoRotacion,','))   
	and mov.Fecha Between @FechaIni and @FechaFin     
   left join IMSS.tblCatRazonesMovAfiliatorios rMov    
    on mov.IDRazonMovimiento = rMov.IDRazonMovimiento    
   inner join RH.tblEmpleadosMaster e    
    on e.IDEmpleado = mov.IDEmpleado    
  where 
   (E.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')         
      order by e.ClaveEmpleado asc, mov.Fecha asc  
    
    
 END ELSE IF(@IDTipoVigente = 3)    
 BEGIN    
  print @TiposMovimientos    
  select M.ClaveEmpleado    
     ,M.NOMBRECOMPLETO as NombreCompleto    
	 ,M.RFC as RFC 
	 ,M.IMSS as NSS
	 ,M.RegPatronal 
	 ,M.Departamento
	 ,M.Puesto
	 ,Mov.SalarioDiario   
	 ,Mov.SalarioVariable   
	 ,Mov.SalarioIntegrado   
	 ,Mov.SalarioDiarioReal 
     ,tMov.Codigo as CodigoMovimiento    
,tMov.Descripcion as Movimiento    
     ,Mov.Fecha as FechaMovimiento    
     ,rMov.Descripcion RazonMovimiento   
	  ,(select top 1 Fecha from IMSS.tblMovAfiliatorios where IDEmpleado = M.IDEmpleado and Fecha Between @FechaIni and @FechaFin and IDTipoMovimiento = @IDTipoMovimientoBaja order by Fecha desc )  as FechaBaja 
	  ,Titulo = UPPER( 'REPORTE DE MOVIMIENTOS AFILIATORIOS DEL ' + FORMAT(@FechaIni,'dd/MMMM/yyyy') + ' AL '+  FORMAT(@FechaFin,'dd/MMMM/yyyy'))
  from IMSS.tblMovAfiliatorios Mov    
   inner join IMSS.tblCatTipoMovimientos tMov    
    on Mov.IDTipoMovimiento = tMov.IDTipoMovimiento    
	and tMov.IDTipoMovimiento in (Select item from app.Split(@TipoRotacion,','))    
   inner join RH.tblEmpleadosMaster M    
    on M.IDEmpleado = mov.IDEmpleado    
 --inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU  
 -- on M.IDEmpleado = FEU.IDEmpleado  
 -- and FEU.IDUsuario = @IDUsuario  
   left join IMSS.tblCatRazonesMovAfiliatorios rMov    
    on mov.IDRazonMovimiento = rMov.IDRazonMovimiento    
      
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
