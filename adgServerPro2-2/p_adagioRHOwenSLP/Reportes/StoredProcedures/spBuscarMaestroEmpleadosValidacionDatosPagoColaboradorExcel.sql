USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarMaestroEmpleadosValidacionDatosPagoColaboradorExcel] (
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
			,@FechaIni date 
			,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)


	
	select @TipoNomina = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'TipoNomina'

	select @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'
	select @ClaveEmpleadoFinal = CASE WHEN ISNULL(Value,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'

	--por ahorita no quiero fechas
	--select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
	--	from @dtFiltros where Catalogo = 'FechaIni'
	--select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
	--	from @dtFiltros where Catalogo = 'FechaFin'
	select @FechaIni = CAST('1900-01-01' as date)
	select @FechaFin = CAST('9999-12-31' as date)


	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))
	

	--set @Titulo = UPPER( 'REPORTE MAESTRO DE COLABORADORES VIGENTES DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))
	set @Titulo = UPPER( 'REPORTE MAESTRO DE COLABORADORES MUESTRA DATOS DE PAGOS DE COLABORADOR')

	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario
  
		select m.ClaveEmpleado as CLAVE
			,m.Nombre AS NOMBRE
			,m.SegundoNombre AS [SEGUNDO NOMBRE]
			,m.Paterno AS PATERNO
			,m.Materno AS MATERNO
			,m.RFC AS [RFC ]
			,m.CURP AS CURP
			,m.IMSS AS IMSS
			,FORMAT(m.FechaPrimerIngreso,'dd/MM/yyyy') as [FECHA PRIMER INGRESO]
			,FORMAT(m.FechaIngreso,'dd/MM/yyyy') as [FECHA INGRESO]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
            ,TCD.Codigo AS [CODIGO DEPARTAMENTO]
			,m.Departamento AS DEPARTAMENTO
			,m.Sucursal AS SUCURSAL
			,CATP.Codigo [CODIGO PUESTO]
			,m.Puesto AS PUESTO
			,m.Cliente AS CLIENTE
			,m.Empresa AS EMPRESA
			,m.CentroCosto AS [CENTRO COSTO]
			,m.Area AS AREA
			,m.Division AS DIVISION
			,m.Region AS REGION
			,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
			,m.RegPatronal AS [REGISTRO PATRONAL]
			,m.RazonSocial AS [RAZON SOCIAL]
			,m.TipoNomina AS [TIPO NOMINA]
			,[FECHA ULTIMA BAJA] = (select top 1 FORMAT(mov.Fecha,'dd/MM/yyyy') 
								from IMSS.tblMovAfiliatorios mov with (nolock)  
									join IMSS.tblCatTipoMovimientos ctm with (nolock)  
										on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
								where mov.IDEmpleado = m.IDEmpleado and ctm.Codigo = 'B' 
								order by mov.Fecha desc ) 
			
			,tp.Descripcion as [TIPO PRESTACION]
			,LP.Descripcion AS [LAYOUT PAGO]
			,CONN.Descripcion as [CONCEPTO]
			,Bancos.Descripcion as BANCO -- Banco de la cuenta del Empleado
			,PE.Interbancaria as [CLABE INTERBANCARIA]
			,PE.Cuenta as [NUMERO CUENTA]
			,PE.Tarjeta as [NUMERO TARJETA]
			,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA HOY]
			,case when m.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]
		from RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
			left join RH.tblPagoEmpleado PE with (nolock) 
				on PE.IDEmpleado = M.IDEmpleado	--and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) 
				on LP.IDLayoutPago = PE.IDLayoutPago and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) 
				on bancos.IDBanco = PE.IDBanco
            left join Nomina.tblCatConceptos CONN with (nolock)  
			    on CONN.IDConcepto = LP.IDConcepto
			left join rh.tblCatDepartamentos TCD with (nolock)
			    on  TCD.IDDepartamento = M.IDDepartamento
            left join rh.tblCatPuestos CATP with (nolock)
			    on CATP.IDPuesto = M.IDPuesto

		Where 
		m.Vigente=1 and
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
				order by M.ClaveEmpleado asc

	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		
			select m.ClaveEmpleado as CLAVE
			,m.Nombre AS NOMBRE
			,m.SegundoNombre AS [SEGUNDO NOMBRE]
			,m.Paterno AS PATERNO
			,m.Materno AS MATERNO
			,m.RFC AS [RFC ]
			,m.CURP AS CURP
			,m.IMSS AS IMSS
			,FORMAT(m.FechaPrimerIngreso,'dd/MM/yyyy') as [FECHA PRIMER INGRESO]
			,FORMAT(m.FechaIngreso,'dd/MM/yyyy') as [FECHA INGRESO]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
            ,TCD.Codigo AS [CODIGO DEPARTAMENTO]
			,m.Departamento AS DEPARTAMENTO
			,m.Sucursal AS SUCURSAL
			,CATP.Codigo [CODIGO PUESTO]
			,m.Puesto AS PUESTO
			,m.Cliente AS CLIENTE
			,m.Empresa AS EMPRESA
			,m.CentroCosto AS [CENTRO COSTO]
			,m.Area AS AREA
			,m.Division AS DIVISION
			,m.Region AS REGION
			,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
			,m.RegPatronal AS [REGISTRO PATRONAL]
			,m.RazonSocial AS [RAZON SOCIAL]
			,m.TipoNomina AS [TIPO NOMINA]
			,[FECHA ULTIMA BAJA] = (select top 1 FORMAT(mov.Fecha,'dd/MM/yyyy') 
								from IMSS.tblMovAfiliatorios mov with (nolock)  
									join IMSS.tblCatTipoMovimientos ctm with (nolock)  
										on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
								where mov.IDEmpleado = m.IDEmpleado and ctm.Codigo = 'B' 
								order by mov.Fecha desc ) 
			
			,tp.Descripcion as [TIPO PRESTACION]
			,LP.Descripcion AS [LAYOUT PAGO]
			,CONN.Descripcion as [CONCEPTO]
			,Bancos.Descripcion as BANCO -- Banco de la cuenta del Empleado
			,PE.Interbancaria as [CLABE INTERBANCARIA]
			,PE.Cuenta as [NUMERO CUENTA]
			,PE.Tarjeta as [NUMERO TARJETA]
			,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA HOY]
			,case when m.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]
		from RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
			left join RH.tblPagoEmpleado PE with (nolock) 
				on PE.IDEmpleado = M.IDEmpleado	--and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) 
				on LP.IDLayoutPago = PE.IDLayoutPago and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) 
				on bancos.IDBanco = PE.IDBanco
            left join Nomina.tblCatConceptos CONN with (nolock)  
			    on CONN.IDConcepto = LP.IDConcepto
			left join rh.tblCatDepartamentos TCD with (nolock)
			    on  TCD.IDDepartamento = M.IDDepartamento
            left join rh.tblCatPuestos CATP with (nolock)
			    on CATP.IDPuesto = M.IDPuesto
		Where 
		M.Vigente =0 and
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
				order by M.ClaveEmpleado asc
	END ELSE IF(@IDTipoVigente = 3)
	BEGIN
		
			select m.ClaveEmpleado as CLAVE
			,m.Nombre AS NOMBRE
			,m.SegundoNombre AS [SEGUNDO NOMBRE]
			,m.Paterno AS PATERNO
			,m.Materno AS MATERNO
			,m.RFC AS [RFC ]
			,m.CURP AS CURP
			,m.IMSS AS IMSS
			,FORMAT(m.FechaPrimerIngreso,'dd/MM/yyyy') as [FECHA PRIMER INGRESO]
			,FORMAT(m.FechaIngreso,'dd/MM/yyyy') as [FECHA INGRESO]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
            ,TCD.Codigo AS [CODIGO DEPARTAMENTO]
			,m.Departamento AS DEPARTAMENTO
			,m.Sucursal AS SUCURSAL
			,CATP.Codigo [CODIGO PUESTO]
			,m.Puesto AS PUESTO
			,m.Cliente AS CLIENTE
			,m.Empresa AS EMPRESA
			,m.CentroCosto AS [CENTRO COSTO]
			,m.Area AS AREA
			,m.Division AS DIVISION
			,m.Region AS REGION
			,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
			,m.RegPatronal AS [REGISTRO PATRONAL]
			,m.RazonSocial AS [RAZON SOCIAL]
			,m.TipoNomina AS [TIPO NOMINA]
			,[FECHA ULTIMA BAJA] = (select top 1 FORMAT(mov.Fecha,'dd/MM/yyyy') 
								from IMSS.tblMovAfiliatorios mov with (nolock)  
									join IMSS.tblCatTipoMovimientos ctm with (nolock)  
										on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
								where mov.IDEmpleado = m.IDEmpleado and ctm.Codigo = 'B' 
								order by mov.Fecha desc ) 
			
			,tp.Descripcion as [TIPO PRESTACION]
			,LP.Descripcion AS [LAYOUT PAGO]
			,CONN.Descripcion as [CONCEPTO]
			,Bancos.Descripcion as BANCO -- Banco de la cuenta del Empleado
			,PE.Interbancaria as [CLABE INTERBANCARIA]
			,PE.Cuenta as [NUMERO CUENTA]
			,PE.Tarjeta as [NUMERO TARJETA]
			,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA HOY]
			,case when m.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]
		from RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
			left join RH.tblPagoEmpleado PE with (nolock) 
				on PE.IDEmpleado = M.IDEmpleado	--and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) 
				on LP.IDLayoutPago = PE.IDLayoutPago and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) 
				on bancos.IDBanco = PE.IDBanco
            left join Nomina.tblCatConceptos CONN with (nolock)  
			    on CONN.IDConcepto = LP.IDConcepto
			left join rh.tblCatDepartamentos TCD with (nolock)
			    on  TCD.IDDepartamento = M.IDDepartamento
            left join rh.tblCatPuestos CATP with (nolock)
			    on CATP.IDPuesto = M.IDPuesto
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
				order by M.ClaveEmpleado asc
	END
END
GO
