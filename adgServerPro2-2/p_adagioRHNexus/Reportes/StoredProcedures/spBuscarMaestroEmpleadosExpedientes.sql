USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarMaestroEmpleadosExpedientes] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
	;   

	select 
		top 1 @IDIdioma = dp.Valor        
	from Seguridad.tblUsuarios u with (nolock)       
		Inner join App.tblPreferencias p with (nolock)        
			on u.IDPreferencia = p.IDPreferencia        
		Inner join App.tblDetallePreferencias dp with (nolock)        
			on dp.IDPreferencia = p.IDPreferencia        
		Inner join App.tblCatTiposPreferencias tp with (nolock)        
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia        
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'        
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	Declare --@dtFiltros [Nomina].[dtFiltrosRH]
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) 
			--,@FechaIni date 
			--,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)
	--insert into @dtFiltros(Catalogo,Value)
	--values('Departamentos',@Departamentos)
	--	,('Sucursales',@Sucursales)
	--	,('Puestos',@Puestos)
	--	,('RazonesSociales',@RazonesSociales)
	--	,('RegPatronales',@RegPatronales)
	--	,('Divisiones',@Divisiones)
	--	,('Prestaciones',@Prestaciones)
	--	,('Clientes',@Cliente)

	
	select @TipoNomina = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'TipoNomina'

	select @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'
	select @ClaveEmpleadoFinal = CASE WHEN ISNULL(Value,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'

	--select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
	--	from @dtFiltros where Catalogo = 'FechaIni'
	--select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
	--	from @dtFiltros where Catalogo = 'FechaFin'

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))
--	set @Titulo = UPPER( 'REPORTE TRAINING 10. NexU ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))

	--select @IDTipoVigente
	--insert into @dtFiltros(Catalogo,Value)
	--values('Clientes',@IDCliente)


	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] 
			@IDTipoNomina = @IDTipoNomina,	
			@EmpleadoIni = @ClaveEmpleadoInicial,
			@EmpleadoFin = @ClaveEmpleadoFinal,
			@dtFiltros = @dtFiltros,
			@IDUsuario = @IDUsuario

		--select m.ClaveEmpleado as CLAVE
		--    ,cte.[Value] as [Email Empresarial]
		--	,CONCAT(m.nombre,+' '+m.SegundoNombre) AS NOMBRE
		--	,CONCAT(m.Paterno, +' '+ m.Materno) AS Apellidos
		--	,m.Departamento AS DEPARTAMENTO
  --  	    ,m.Puesto AS PUESTO
		--	,m.Region AS REGION
		--	,m.Sucursal AS SUCURSAL
		--	,m.Area AS AREA
  --          ,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
		--		inner join RH.tblEmpleadosMaster emp with(nolock)
		--			on je.IDJefe = emp.IDEmpleado
		--		where je.IDEmpleado = m.IDEmpleado
		--		) as Supervisor
				
		--	,(Select top 1 cte.Value  from RH.tblJefesEmpleados je with(nolock)
		--		left join RH.tblEmpleadosMaster emp with(nolock)
		--			on je.IDJefe = emp.IDEmpleado
		--		left join rh.tblContactoEmpleado cte
		--			on cte.IDEmpleado = je.IDJefe
		--				where je.IDEmpleado = m.IDEmpleado
		--				and cte.IDTipoContactoEmpleado = 5
		--		) as [Correo Supervisor]
		--		,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
		--SELECT
		--	 [m].[ClaveEmpleado]
		--	,[m].[NOMBRECOMPLETO]
		--	,[m].[Region]
		--	,[m].[Sucursal]
		--	,[m].[CentroCosto]
		--	,[m].[Departamento]
		--	,[m].[Puesto]
		--	,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA_ANTIGUEDAD]
		--	 ,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
		--		inner join RH.tblEmpleadosMaster emp with(nolock)
		--			on je.IDJefe = emp.IDEmpleado
		--		where je.IDEmpleado = m.IDEmpleado
		--		) as [Supervisor]
		--	,[CED].[Codigo]
		--	,[CED].[Descripcion]
		--	,[CED].[Requerido]
		--	,[EDE].[Name] AS [ARCHIVO]
		--	,[CED].[IDExpedienteDigital]
		--	,[EDE].[IDExpedienteDigital]
		--	--,[EDE].[ContentType]
		--	--,ROW_NUMBER()over(ORDER BY [IDExpedienteDigitalEmpleado])as ROWNUMBER
		--from @dtEmpleados m		
		--JOIN [RH].[ExpedienteDigitalEmpleado] EDE on EDE.IDEmpleado = m.IDEmpleado
		--RIGHT JOIN [RH].[tblCatExpedientesDigitales] CED ON EDE.IDExpedienteDigital = CED.IDExpedienteDigital	
		--WHERE ClaveEmpleado ='0000005'
		--	order by M.ClaveEmpleado asc


SELECT 
			 [e].[ClaveEmpleado]
			,[e].[NOMBRECOMPLETO]
			,[e].[Region]
			,[e].[Sucursal]
			,[e].[CentroCosto]
			,[e].[Departamento]
			,[e].[Puesto]
			,FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as [FECHA_ANTIGUEDAD]
			,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = e.IDEmpleado
				) as [Supervisor]
			,ed.Codigo
			,ed.Descripcion
			,case when EXISTE.IDExpedienteDigital<>0 then 'CON ARCHIVO' else 'SIN ARCHIVO' end as [TIENE ARCHIVO]
    FROM rh.tblEmpleadosMaster E
    CROSS JOIN RH.tblCatExpedientesDigitales ED
    LEFT JOIN RH.ExpedienteDigitalEmpleado EXISTE
        ON E.IDEmpleado=EXISTE.IDEmpleado AND ED.IDExpedienteDigital=EXISTE.IDExpedienteDigital

	where E.Vigente=1
		order by e.ClaveEmpleado asc
   --where e.IDEmpleado = 1284



	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		SELECT 
			 [e].Vigente
			,[e].[ClaveEmpleado]
			,[e].[NOMBRECOMPLETO]
			,[e].[Region]
			,[e].[Sucursal]
			,[e].[CentroCosto]
			,[e].[Departamento]
			,[e].[Puesto]
			,FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as [FECHA_ANTIGUEDAD]
			,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = e.IDEmpleado
				) as [Supervisor]
			,ed.Codigo
			,ed.Descripcion, 
			case when EXISTE.IDExpedienteDigital<>0 then 'CON ARCHIVO' else 'SIN ARCHIVO' end as [TIENE ARCHIVO]
    FROM rh.tblempleadosmaster E
    CROSS JOIN RH.tblCatExpedientesDigitales ED
    LEFT JOIN RH.ExpedienteDigitalEmpleado EXISTE
        ON E.IDEmpleado=EXISTE.IDEmpleado AND ED.IDExpedienteDigital=EXISTE.IDExpedienteDigital
   --where e.IDEmpleado = 1284
	Where 
		E.Vigente =0 and
		( E.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((E.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		   and ((E.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))             
			   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		   and ((E.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((E.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((E.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((E.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((E.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((E.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((E.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))   
		and ((E.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
		   and ((E.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(E.ClaveEmpleado,'')+' '+ COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by E.ClaveEmpleado asc
	END ELSE IF(@IDTipoVigente = 3)
	BEGIN
		
		SELECT 
			 [e].Vigente			
			,[e].[ClaveEmpleado]
			,[e].[NOMBRECOMPLETO]
			,[e].[Region]
			,[e].[Sucursal]
			,[e].[CentroCosto]
			,[e].[Departamento]
			,[e].[Puesto]
			,FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as [FECHA_ANTIGUEDAD]
			,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = e.IDEmpleado
				) as [Supervisor]
			,ed.Codigo
			,ed.Descripcion
			,case when EXISTE.IDExpedienteDigital<>0 then 'CON ARCHIVO' else 'SIN ARCHIVO' end as [TIENE ARCHIVO]
    FROM rh.tblempleadosmaster E
    CROSS JOIN RH.tblCatExpedientesDigitales ED
    LEFT JOIN RH.ExpedienteDigitalEmpleado EXISTE
        ON E.IDEmpleado=EXISTE.IDEmpleado AND ED.IDExpedienteDigital=EXISTE.IDExpedienteDigital
		Where 
		( E.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((E.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		   and ((E.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))             
			   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		   and ((E.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((E.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((E.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((E.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((E.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((E.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((E.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>''))) 
		 and ((E.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
		   and ((E.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(E.ClaveEmpleado,'')+' '+ COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by E.ClaveEmpleado asc
	END
END
GO
