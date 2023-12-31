USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spLayoutEmpleadosSantander] (
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

	select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaIni'
	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaFin'

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))

	set @Titulo = UPPER( 'REPORTE LAYOUT EMPLEADOS SANTANDER DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))
	--select @IDTipoVigente
	--insert into @dtFiltros(Catalogo,Value)
	--values('Clientes',@IDCliente)


	if object_id('tempdb..#tempDatosExtra')	is not null drop table #tempDatosExtra 
	if object_id('tempdb..#tempData')		is not null drop table #tempData
	if object_id('tempdb..#tempSalida')		is not null drop table #tempSalida
	if object_id('tempdb..##tempDatosExtraEmpleados')		is not null drop table ##tempDatosExtraEmpleados

	select distinct 
		c.IDDatoExtra,
		C.Nombre,
		C.Descripcion
	into #tempDatosExtra
	from (select 
			*
		from RH.tblCatDatosExtra
		) c 

	Select
		M.IDEmpleado
		,CDE.IDDatoExtra
		,CDE.Nombre
		,CDE.Descripcion
		,DE.Valor
	into #tempData
	from RH.tblEmpleadosMaster M
		inner join RH.tblDatosExtraEmpleados DE
			on M.IDEmpleado = DE.IDEmpleado
		inner join RH.tblCatDatosExtra CDE
			on DE.IDDatoExtra = CDE.IDDatoExtra
	


	DECLARE @cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Nombre)+',0) AS '+ QUOTENAME(c.Nombre)
				FROM #tempDatosExtra c
				ORDER BY c.IDDatoExtra
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Nombre)
				FROM #tempDatosExtra c
				ORDER BY c.IDDatoExtra
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');


	set @query1 = 'SELECT IDEmpleado, ' + @cols + ' 
					into ##tempDatosExtraEmpleados
					from 
				(
					select IDEmpleado
						,Nombre
						,Valor
					from #tempData
			   ) x'

	set @query2 = '
				pivot 
				(
					 MAX(Valor)
					for Nombre in (' + @colsAlone + ')
				) p 
				order by IDEmpleado
				'

	--select len(@query1) +len( @query2) 
	exec( @query1 + @query2) 

	--select * from ##tempDatosExtraEmpleados
	
	if OBJECT_ID('tempdb..#tblTempMov') is not null drop table #tblTempMov;
	select 
		IDEmpleado, 
		Fecha, 
		IDTipoMovimiento,
		ROW_NUMBER()over(partition by IDEmpleado order by fecha desc  ) as orden 
	INTO #tblTempMov
	from IMSS.tblMovAfiliatorios
	where IDTipoMovimiento in (1,3) and Fecha between @FechaIni and @FechaFin

   DELETE FROM #tblTempMov WHERE ORDEN <> 1

	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select 
			 m.ClaveEmpleado as [NUMERO DE EMPLEADO]
			,SUBSTRING(m.Paterno,1,20) AS [PRIMER APELLIDO]
			,SUBSTRING(isnull(m.Materno,''),1,20) AS [SEGUNDO APELLIDO]
			,substring (concat (m.Nombre,' ',isnull(m.SegundoNombre,'')),1,40) AS [NOMBRE(S)]
			,isnull(Suc.Codigo,'') as [NUMERO SUCURSAL]
			,isnull(m.RFC,'') AS [RFC ]
			,ISNULL(m.Sexo,'' ) AS [SEXO]
			,m.PaisNacimiento AS [NACIONALIDAD]
			,case when m.Sexo = 'FEMENINO' then 
				      CASE WHEN Mast.IDEstadoCivil = 1 THEN 'SOLTERA'
						   WHEN Mast.IDEstadoCivil = 2 THEN 'CASADA'
						   WHEN Mast.IDEstadoCivil = 3 THEN 'UNION LIBRE'
						   WHEN Mast.IDEstadoCivil = 4 THEN 'VIUDA'
						   WHEN Mast.IDEstadoCivil = 5 THEN 'DIVORCIADA'
						END
				  WHEN m.Sexo = 'MASCULINO' THEN
						CASE WHEN Mast.IDEstadoCivil = 1 THEN 'SOLTERO'
						     WHEN Mast.IDEstadoCivil = 2 THEN 'CASADO'
						     WHEN Mast.IDEstadoCivil = 3 THEN 'UNION LIBRE'
						     WHEN Mast.IDEstadoCivil = 4 THEN 'VIUDO'
						     WHEN Mast.IDEstadoCivil = 5 THEN 'DIVORCIADO'
						END 
			 ELSE ISNULL(m.EstadoCivil,'' ) END AS [ESTADO CIVIL]
			,ISNULL(CECelEmp.Value,'') as [CELULAR]
			,substring (isnull(CECorreo.Value,''),1,50) as [CORREO ELECTRONICO]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA DE INGRESO]
			,concat (RegPat.Calle, ' ',RegPat.Exterior) as [DOMICILIO DE OFICINA]
			,substring(colReg.NombreAsentamiento,1,30) as [COLONIA]
			,substring(CPRegPat.CodigoPostal,1,5) as [CODIGO POSTAL]
			,(m.SalarioDiario * 30) AS [INGRESO MENSUAL NETO]
			,'' AS [ID CENTRO DE TRABAJO]
			,m.CURP AS [CURP]
		from @dtEmpleados m
		inner join RH.tblEmpleadosMaster Mast with (nolock) 
			on m.IDEmpleado = mast.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  
			on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
		left join rh.tblCatSucursales Suc
			on Suc.IDSucursal = m.IDSucursal
		left join rh.tblContactoEmpleado CECelEmp
			on CECelEmp.IDEmpleado = m.IDEmpleado
				and CECelEmp.IDTipoContactoEmpleado = 2
		left join rh.tblContactoEmpleado CECorreo
			on CECorreo.IDEmpleado = m.IDEmpleado
				and CECorreo.IDTipoContactoEmpleado = 1
		left join rh.tblCatRegPatronal RegPat
			on RegPat.IDRegPatronal = m.IDRegPatronal
		left join SAT.tblCatColonias colReg with (nolock) 
			on RegPat.IDColonia = colReg.IDColonia
		left join SAT.tblCatCodigosPostales CPRegPat with (nolock) 
			on CPRegPat.IDCodigoPostal = RegPat.IDCodigoPostal
		left join #tblTempMov Mov
			on Mov.IdEmpleado = m.IDEmpleado
		where m.IDEmpleado in (select mov.IDEmpleado from #tblTempMov)
		order by M.ClaveEmpleado asc

	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		
			select 
			 m.ClaveEmpleado as [NUMERO DE EMPLEADO]
			,SUBSTRING(m.Paterno,1,20) AS [PRIMER APELLIDO]
			,SUBSTRING(isnull(m.Materno,''),1,20) AS [SEGUNDO APELLIDO]
			,substring (concat (m.Nombre,' ',isnull(m.SegundoNombre,'')),1,40) AS [NOMBRE(S)]
			,Suc.Codigo as [NUMERO DE SUCURSAL]
			,m.RFC AS [RFC ]
			,m.Sexo AS [SEXO]
			,m.PaisNacimiento AS [NACIONALIDAD]
			,case when m.Sexo = 'FEMENINO' then 
				      CASE WHEN Mast.IDEstadoCivil = 1 THEN 'SOLTERA'
						   WHEN Mast.IDEstadoCivil = 2 THEN 'CASADA'
						   WHEN Mast.IDEstadoCivil = 3 THEN 'UNION LIBRE'
						   WHEN Mast.IDEstadoCivil = 4 THEN 'VIUDA'
						   WHEN Mast.IDEstadoCivil = 5 THEN 'DIVORCIADA'
						END
				  WHEN m.Sexo = 'MASCULINO' THEN
						CASE WHEN Mast.IDEstadoCivil = 1 THEN 'SOLTERO'
						     WHEN Mast.IDEstadoCivil = 2 THEN 'CASADO'
						     WHEN Mast.IDEstadoCivil = 3 THEN 'UNION LIBRE'
						     WHEN Mast.IDEstadoCivil = 4 THEN 'VIUDO'
						     WHEN Mast.IDEstadoCivil = 5 THEN 'DIVORCIADO'
						END 
			 ELSE ISNULL(m.EstadoCivil,'' ) END AS [ESTADO CIVIL]
			,ISNULL(CECelEmp.Value,'') as [CELULAR]
			,substring (isnull(CECorreo.Value,''),1,50) as [CORREO ELECTRONICO]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA DE INGRESO]
			,concat (RegPat.Calle, ' ',RegPat.Exterior) as [DOMICILIO DE OFICINA]
			,substring(colReg.NombreAsentamiento,1,30) as [COLONIA]
			,substring(CPRegPat.CodigoPostal,1,5) as [CODIGO POSTAL]
			,(m.SalarioDiario * 30) AS [INGRESO MENSUAL NETO]
			,'' AS [ID CENTRO DE TRABAJO]
			,m.CURP AS [CURP]
		from @dtEmpleados m
		inner join RH.tblEmpleadosMaster Mast with (nolock) 
			on m.IDEmpleado = mast.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  
			on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
		left join rh.tblCatSucursales Suc
			on Suc.IDSucursal = m.IDSucursal
		left join rh.tblContactoEmpleado CECelEmp
			on CECelEmp.IDEmpleado = m.IDEmpleado
				and CECelEmp.IDTipoContactoEmpleado = 2
		left join rh.tblContactoEmpleado CECorreo
			on CECorreo.IDEmpleado = m.IDEmpleado
				and CECorreo.IDTipoContactoEmpleado = 1
		left join rh.tblCatRegPatronal RegPat
			on RegPat.IDRegPatronal = m.IDRegPatronal
		left join SAT.tblCatColonias colReg with (nolock) 
			on RegPat.IDColonia = colReg.IDColonia
		left join SAT.tblCatCodigosPostales CPRegPat with (nolock) 
			on CPRegPat.IDCodigoPostal = RegPat.IDCodigoPostal
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
		and ((M.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by M.ClaveEmpleado asc
	
	END ELSE IF(@IDTipoVigente = 3)
	BEGIN
		
		select 
			 m.ClaveEmpleado as [NUMERO DE EMPLEADO]
			,SUBSTRING(m.Paterno,1,20) AS [PRIMER APELLIDO]
			,SUBSTRING(isnull(m.Materno,''),1,20) AS [SEGUNDO APELLIDO]
			,substring (concat (m.Nombre,' ',isnull(m.SegundoNombre,'')),1,40) AS [NOMBRE(S)]
			,Suc.Codigo as [NUMERO DE SUCURSAL]
			,m.RFC AS [RFC ]
			,m.Sexo AS [SEXO]
			,m.PaisNacimiento AS [NACIONALIDAD]
			,case when m.Sexo = 'FEMENINO' then 
				      CASE WHEN Mast.IDEstadoCivil = 1 THEN 'SOLTERA'
						   WHEN Mast.IDEstadoCivil = 2 THEN 'CASADA'
						   WHEN Mast.IDEstadoCivil = 3 THEN 'UNION LIBRE'
						   WHEN Mast.IDEstadoCivil = 4 THEN 'VIUDA'
						   WHEN Mast.IDEstadoCivil = 5 THEN 'DIVORCIADA'
						END
				  WHEN m.Sexo = 'MASCULINO' THEN
						CASE WHEN Mast.IDEstadoCivil = 1 THEN 'SOLTERO'
						     WHEN Mast.IDEstadoCivil = 2 THEN 'CASADO'
						     WHEN Mast.IDEstadoCivil = 3 THEN 'UNION LIBRE'
						     WHEN Mast.IDEstadoCivil = 4 THEN 'VIUDO'
						     WHEN Mast.IDEstadoCivil = 5 THEN 'DIVORCIADO'
						END 
			 ELSE ISNULL(m.EstadoCivil,'' ) END AS [ESTADO CIVIL]
			,ISNULL(CECelEmp.Value,'') as [CELULAR]
			,substring (isnull(CECorreo.Value,''),1,50) as [CORREO ELECTRONICO]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA DE INGRESO]
			,concat (RegPat.Calle, ' ',RegPat.Exterior) as [DOMICILIO DE OFICINA]
			,substring(colReg.NombreAsentamiento,1,30) as [COLONIA]
			,substring(CPRegPat.CodigoPostal,1,5) as [CODIGO POSTAL]
			,(m.SalarioDiario * 30) AS [INGRESO MENSUAL NETO]
			,'' AS [ID CENTRO DE TRABAJO]
			,m.CURP AS [CURP]
		from @dtEmpleados m
		inner join RH.tblEmpleadosMaster Mast with (nolock) 
			on m.IDEmpleado = mast.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  
			on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
		left join rh.tblCatSucursales Suc
			on Suc.IDSucursal = m.IDSucursal
		left join rh.tblContactoEmpleado CECelEmp
			on CECelEmp.IDEmpleado = m.IDEmpleado
				and CECelEmp.IDTipoContactoEmpleado = 2
		left join rh.tblContactoEmpleado CECorreo
			on CECorreo.IDEmpleado = m.IDEmpleado
				and CECorreo.IDTipoContactoEmpleado = 1
		left join rh.tblCatRegPatronal RegPat
			on RegPat.IDRegPatronal = m.IDRegPatronal
		left join SAT.tblCatColonias colReg with (nolock) 
			on RegPat.IDColonia = colReg.IDColonia
		left join SAT.tblCatCodigosPostales CPRegPat with (nolock) 
			on CPRegPat.IDCodigoPostal = RegPat.IDCodigoPostal
		
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
		 and ((M.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by M.ClaveEmpleado asc
	END
END
GO
