USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spReporteBoletosComidas] (
	@FechaIni date, 
	@FechaFin date, 
	@TipoVigente varchar(max) = '1',  
	@TipoNomina varchar(max) = '0', 
	@ClaveEmpleadoInicial Varchar(20) = '0',    
	@ClaveEmpleadoFinal Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',    
	@Cliente Varchar(max) = '',
	@IDDepartamento int = 0,
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


 DECLARE  
	@IDIdioma Varchar(5)        
   ,@IdiomaSQL varchar(100) = null;   
 select top 1 @IDIdioma = dp.Valor        
 from Seguridad.tblUsuarios u        
  Inner join App.tblPreferencias p        
   on u.IDPreferencia = p.IDPreferencia        
  Inner join App.tblDetallePreferencias dp        
   on dp.IDPreferencia = p.IDPreferencia        
  Inner join App.tblCatTiposPreferencias tp        
   on tp.IDTipoPreferencia = dp.IDTipoPreferencia        
 where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'        
        
 select @IdiomaSQL = [SQL]        
 from app.tblIdiomas        
 where IDIdioma = @IDIdioma        
        
 if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
 begin        
  set @IdiomaSQL = 'Spanish' ;        
 end        
          
 SET LANGUAGE @IdiomaSQL;   

	Declare @dtFiltros [Nomina].[dtFiltrosRH]
			,@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int

	insert into @dtFiltros(Catalogo,Value)
	values('Sucursales',@Sucursales)
		,('Puestos',@Puestos)
		,('RazonesSociales',@RazonesSociales)
		,('RegPatronales',@RegPatronales)
		,('Divisiones',@Divisiones)
		,('Prestaciones',@Prestaciones)
		,('Clientes',@Cliente)
		,('TipoVigente',@TipoVigente)

	SET @ClaveEmpleadoInicial = CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	SET @ClaveEmpleadoFinal = CASE WHEN ISNULL(@ClaveEmpleadoFinal,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoVigente,'1'),','))

	declare  @Fechas2 [App].[dtFechas]  
		,@Fechas [App].[dtFechasFull]
	,@empleados [RH].[dtEmpleados];

	insert @Fechas2      
	exec app.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin 
	 insert into @Fechas 
    select * from @Fechas2

	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

	select 
	ROW_NUMBER() OVER(ORDER BY M.IDEmpleado ASC)-1 AS RowNum
	,M.IDEmpleado
	,Fecha.DiaSemana as [DiaSemana]
		,CASE 
			When Fecha.DiaSemana = 1 Then 'LUNES'
			When Fecha.DiaSemana = 2 Then 'MARTES'
			When Fecha.DiaSemana = 3 Then 'MIERCOLES'
			When Fecha.DiaSemana = 4 Then 'JUEVES'
			When Fecha.DiaSemana = 5 Then 'VIERNES'
			When Fecha.DiaSemana = 6 Then 'SABADO'
			When Fecha.DiaSemana = 7 Then 'DOMINGO'
		END AS [DiaSemanaLetra]
		,M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,M.Puesto
		,FORMAT(Fecha.Fecha ,'dd/MM/yyyy') as Fecha
		from @Fechas Fecha
		cross join RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
		Where 
		m.Vigente=1 and
		( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))     
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))   
			and 
			M.IDDepartamento = @IDDepartamento
		   and 
		   (M.ClaveEmpleado BETWEEN @ClaveEmpleadoInicial AND @ClaveEmpleadoFinal ) 
			order by 
            M.IDEmpleado,Fecha.DiaSemana

	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN

	select 
    ROW_NUMBER() OVER(ORDER BY M.IDEmpleado ASC)-1 AS RowNum
    ,M.IDEmpleado
    ,Fecha.DiaSemana as [DiaSemana]
        ,CASE 
            When Fecha.DiaSemana = 1 Then 'LUNES'
            When Fecha.DiaSemana = 2 Then 'MARTES'
            When Fecha.DiaSemana = 3 Then 'MIERCOLES'
            When Fecha.DiaSemana = 4 Then 'JUEVES'
            When Fecha.DiaSemana = 5 Then 'VIERNES'
            When Fecha.DiaSemana = 6 Then 'SABADO'
            When Fecha.DiaSemana = 7 Then 'DOMINGO'
        END AS [DiaSemanaLetra]
        ,M.ClaveEmpleado
        ,M.NOMBRECOMPLETO
        ,M.Puesto
        ,FORMAT(Fecha.Fecha ,'dd/MM/yyyy') as Fecha
			
		from @Fechas Fecha
		cross join RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
		Where 
		M.Vigente =0 and
		( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))                     
		   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))     
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))  
			and 
			 M.IDDepartamento = @IDDepartamento
			and        
			 (M.ClaveEmpleado BETWEEN @ClaveEmpleadoInicial AND @ClaveEmpleadoFinal ) 
			order by 
            M.IDEmpleado,Fecha.DiaSemana

	END ELSE IF(@IDTipoVigente = 3)
	BEGIN
		
	select 
    ROW_NUMBER() OVER(ORDER BY M.IDEmpleado ASC)-1 AS RowNum
    ,M.IDEmpleado
    ,Fecha.DiaSemana as [DiaSemana]
        ,CASE 
            When Fecha.DiaSemana = 1 Then 'LUNES'
            When Fecha.DiaSemana = 2 Then 'MARTES'
            When Fecha.DiaSemana = 3 Then 'MIERCOLES'
            When Fecha.DiaSemana = 4 Then 'JUEVES'
            When Fecha.DiaSemana = 5 Then 'VIERNES'
            When Fecha.DiaSemana = 6 Then 'SABADO'
            When Fecha.DiaSemana = 7 Then 'DOMINGO'
        END AS [DiaSemanaLetra]
        ,M.ClaveEmpleado
        ,M.NOMBRECOMPLETO
        ,M.Puesto
        ,FORMAT(Fecha.Fecha ,'dd/MM/yyyy') as Fecha
		from @Fechas Fecha
		cross join RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			
		Where 
		( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))     
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))   
			and 
			 M.IDDepartamento = @IDDepartamento
		 	and        
			 (M.ClaveEmpleado BETWEEN @ClaveEmpleadoInicial AND @ClaveEmpleadoFinal )  
			order by 
            M.IDEmpleado,Fecha.DiaSemana
	END

END
GO
