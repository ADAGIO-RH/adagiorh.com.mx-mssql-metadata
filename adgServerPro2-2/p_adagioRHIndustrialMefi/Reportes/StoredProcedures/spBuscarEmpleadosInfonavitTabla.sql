USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--declare 
--	@dtFiltros [Nomina].[dtFiltrosRH]  
--	;
--	insert @dtFiltros
--	values('TipoVigente','1')
--exec [Reportes].[spBuscarEmpleadosInfonavitTabla] @IDUsuario = 1,@dtFiltros=@dtFiltros
--GO

CREATE procedure [Reportes].[spBuscarEmpleadosInfonavitTabla] (
	@dtFiltros [Nomina].[dtFiltrosRH] readonly,
	@IDUsuario int  
)
AS
BEGIN

	DECLARE  
		@IDIdioma Varchar(5)        
		,@IdiomaSQL varchar(100) = null
		,@UMA Decimal(18,2)
   
		,@FechaIni date 
		,@FechaFin date 
		,@TipoVigente varchar(max) = '1'  
		,@TipoNomina varchar(max) = '0' 
		,@ClaveEmpleadoInicial Varchar(20) = '0'    
		,@ClaveEmpleadoFinal Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ'    
		,@Cliente Varchar(max) = ''
		,@Departamentos Varchar(max) = ''
		,@Sucursales Varchar(max) = ''
		,@Puestos Varchar(max) = ''
		,@RazonesSociales Varchar(max) = ''
		,@RegPatronales Varchar(max) = ''
		,@Divisiones Varchar(max) = ''
		,@Prestaciones Varchar(max) = ''
   ;   
   
	set @FechaIni	 = isnull((SELECT top 1 cast( value as date) from @dtFiltros where Catalogo = 'FechaIni'			)   ,'1990-01-01')
	set @FechaFin	 = isnull((SELECT top 1 cast( value as date) from @dtFiltros where Catalogo = 'FechaFin'			)   ,'9999-12-31')
	set @TipoNomina	 = isnull((SELECT top 1 cast( value as varchar(100)) from @dtFiltros where Catalogo = 'TipoNomina'  ),'0')
	set @TipoVigente = isnull((SELECT top 1 cast( value as varchar(100)) from @dtFiltros where Catalogo = 'TipoVigente' ),'1')
	SET @ClaveEmpleadoInicial = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @ClaveEmpleadoFinal = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     

	select TOP 1 @UMA = UMA
	from Nomina.tblSalariosMinimos with (nolock)
	ORDER BY Fecha desc


	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')     
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	Declare 
		--@dtFiltros [Nomina].[dtFiltrosRH]
		@dtEmpleados [RH].[dtEmpleados]
		,@IDTipoNomina int
		,@IDTipoVigente int
		,@Titulo VARCHAR(MAX) = UPPER( 'REPORTE DE COLABORADORES CON INFONAVIT DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))
	;

	--insert into @dtFiltros(Catalogo,Value)
	--values('Departamentos',@Departamentos)
	--	,('Sucursales',@Sucursales)
	--	,('Puestos',@Puestos)
	--	,('RazonesSociales',@RazonesSociales)
	--	,('RegPatronales',@RegPatronales)
	--	,('Divisiones',@Divisiones)
	--	,('Prestaciones',@Prestaciones)
	--	,('Clientes',@Cliente)

	SET @ClaveEmpleadoInicial = CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	SET @ClaveEmpleadoFinal = CASE WHEN ISNULL(@ClaveEmpleadoFinal,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoVigente,'1'),','))

	--insert into @dtFiltros(Catalogo,Value)
	--values('Clientes',@IDCliente)

   
	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select 
			 m.ClaveEmpleado as CLAVE
			,m.NOMBRECOMPLETO as NOMBRE
			,m.IMSS AS IMSS
			,m.SalarioDiario AS [SALARIO DIARIO]
			,m.SalarioIntegrado AS [SALARIO INTEGRADO]
			,m.RegPatronal  as [REGISTRO PATRONAL]
			,m.Puesto AS PUESTO
			,m.Departamento AS DEPARTAMENTO
			,m.RazonSocial AS [RAZON SOCIAL]
			,m.Division AS DIVISION
			,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
			,m.CentroCosto AS [CENTRO COSTO]
			,m.Departamento AS DEPARTAMENTO
			,m.Sucursal AS SUCURSAL
			,m.Puesto AS PUESTO
			,m.TiposPrestacion AS [TIPO PRESTACION]
			--,@Titulo as Titulo
			,Format(IE.Fecha,'dd/MM/yyyy') as [FECHA CREDITO]
			,IE.NumeroCredito as [NUMERO CREDITO]
			,TD.Descripcion as [TIPO DESCUENTO]
			,TM.Descripcion as [TIPO MOVIMIENTO]
			,IE.ValorDescuento as [VALOR DESCUENTO]
			,CASE WHEN TD.Descripcion = 'Porcentaje'   THEN  (((M.SalarioIntegrado/100) * IE.ValorDescuento) * 30.4)    
				  WHEN TD.Descripcion = 'Factor de Descuento'   THEN (((@UMA/100) * IE.ValorDescuento) * 30.4)    
				  WHEN TD.Descripcion = 'Cuota Fija Monetaria'   THEN IE.ValorDescuento    
				 ELSE IE.ValorDescuento    
				 END as [DESCUENTO MENSUAL]
			,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA HOY]
			,case when mas.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]
		 from @dtEmpleados m
		 	join RH.tblInfonavitEmpleado IE with (nolock)
				on M.IDEmpleado = IE.IDEmpleado
			join RH.tblCatInfonavitTipoDescuento TD with (nolock)
				on TD.IDTipoDescuento = IE.IDTipoDescuento
			join RH.tblCatInfonavitTipoMovimiento TM with (nolock)
				on TM.IDTipoMovimiento = IE.IDTipoMovimiento
            join rh.tblEmpleadosMaster mas with (nolock) 
                ON m.IDEmpleado = mas.IDEmpleado
		--where IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
		--	or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0'
		order by m.ClaveEmpleado
	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select 
			 m.ClaveEmpleado as CLAVE
			,m.NOMBRECOMPLETO as NOMBRE
			,m.IMSS AS IMSS
			,m.SalarioDiario AS [SALARIO DIARIO]
			,m.SalarioIntegrado AS [SALARIO INTEGRADO]
			,m.RegPatronal  as [REGISTRO PATRONAL]
			,m.Puesto AS PUESTO
			,m.Departamento AS DEPARTAMENTO
			,m.RazonSocial AS [RAZON SOCIAL]
			,m.Division AS DIVISION
			,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
			,m.CentroCosto AS [CENTRO COSTO]
			,m.Departamento AS DEPARTAMENTO
			,m.Sucursal AS SUCURSAL
			,m.Puesto AS PUESTO
			,m.TiposPrestacion AS [TIPO PRESTACION]
			--,@Titulo as Titulo
			,Format(IE.Fecha,'dd/MM/yyyy') as [FECHA CREDITO]
			,IE.NumeroCredito as [NUMERO CREDITO]
			,TD.Descripcion as [TIPO DESCUENTO]
			,TM.Descripcion as [TIPO MOVIMIENTO]
			,IE.ValorDescuento as [VALOR DESCUENTO]
			,CASE WHEN TD.Descripcion = 'Porcentaje'   THEN  (((M.SalarioIntegrado/100) * IE.ValorDescuento) * 30.4)    
				  WHEN TD.Descripcion = 'Factor de Descuento'   THEN (((@UMA/100) * IE.ValorDescuento) * 30.4)    
				  WHEN TD.Descripcion = 'Cuota Fija Monetaria'   THEN IE.ValorDescuento    
				 ELSE IE.ValorDescuento    
				 END as [DESCUENTO MENSUAL]
			,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA HOY]
			,case when m.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]
		from RH.tblEmpleadosMaster M with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			join RH.tblInfonavitEmpleado IE with (nolock)
				on M.IDEmpleado = IE.IDEmpleado
			join RH.tblCatInfonavitTipoDescuento TD with (nolock)
				on TD.IDTipoDescuento = IE.IDTipoDescuento
			join RH.tblCatInfonavitTipoMovimiento TM with (nolock)
				on TM.IDTipoMovimiento = IE.IDTipoMovimiento
		where  
		 M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0'  
		and M.IDEmpleado not in (Select IDEmpleado from @dtEmpleados)
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
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))     
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
		order by ClaveEmpleado

	END ELSE IF(@IDTipoVigente = 3)
	BEGIN
		select
			 m.ClaveEmpleado as CLAVE
			,m.NOMBRECOMPLETO as NOMBRE
			,m.IMSS AS IMSS
			,m.SalarioDiario AS [SALARIO DIARIO]
			,m.SalarioIntegrado AS [SALARIO INTEGRADO]
			,m.RegPatronal  as [REGISTRO PATRONAL]
			,m.Puesto AS PUESTO
			,m.Departamento AS DEPARTAMENTO
			,m.RazonSocial AS [RAZON SOCIAL]
			,m.Division AS DIVISION
			,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
			,m.CentroCosto AS [CENTRO COSTO]
			,m.Departamento AS DEPARTAMENTO
			,m.Sucursal AS SUCURSAL
			,m.Puesto AS PUESTO
			,m.TiposPrestacion AS [TIPO PRESTACION]
			--,@Titulo as Titulo
			,Format(IE.Fecha,'dd/MM/yyyy') as [FECHA CREDITO]
			,IE.NumeroCredito as [NUMERO CREDITO]
			,TD.Descripcion as [TIPO DESCUENTO]
			,TM.Descripcion as [TIPO MOVIMIENTO]
			,IE.ValorDescuento as [VALOR DESCUENTO]
			,CASE WHEN TD.Descripcion = 'Porcentaje'   THEN  (((M.SalarioIntegrado/100) * IE.ValorDescuento) * 30.4)    
				  WHEN TD.Descripcion = 'Factor de Descuento'   THEN (((@UMA/100) * IE.ValorDescuento) * 30.4)    
				  WHEN TD.Descripcion = 'Cuota Fija Monetaria'   THEN IE.ValorDescuento    
				 ELSE IE.ValorDescuento    
				 END as [DESCUENTO MENSUAL]
			,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA HOY]
			,case when m.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]
		from RH.tblEmpleadosMaster M with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			join RH.tblInfonavitEmpleado IE with (nolock)
				on M.IDEmpleado = IE.IDEmpleado
			join RH.tblCatInfonavitTipoDescuento TD with (nolock)
				on TD.IDTipoDescuento = IE.IDTipoDescuento
			join RH.tblCatInfonavitTipoMovimiento TM with (nolock)
				on TM.IDTipoMovimiento = IE.IDTipoMovimiento
		Where 
		( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
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
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))     
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by ClaveEmpleado
	END
END
GO
