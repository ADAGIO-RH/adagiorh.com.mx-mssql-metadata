USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarMaestroEmpleadosVigentesExcelCOLIBRI_SinSueldos] (
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

	set @Titulo = UPPER( 'REPORTE MAESTRO DE COLABORADORES VIGENTES DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))
	--select @IDTipoVigente
	--insert into @dtFiltros(Catalogo,Value)
	--values('Clientes',@IDCliente)

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

		if object_id('tempdb..#tempDatosBenerifiarios')		is not null drop table #tempDatosBenerifiarios

		IF OBJECT_ID('tempdb..#notasTemporal') is not null drop table #notasTemporal

	SELECT 
		be.IDFamiliarBenificiarioEmpleado
	,be.IDEmpleado
	,be.NombreCompleto
	,be.FechaNacimiento
	,be.Sexo
	,be.TelefonoMovil
	,be.TelefonoCelular
	,be.Emergencia
	,be.Beneficiario
	,be.Dependiente
	,be.Porcentaje
	,p.Descripcion as Parentesco
	,ROW_NUMBER()OVER(PARTITION BY be.IDEmpleado,p.IDParentesco order by be.FechaNacimiento asc) RN
		into #tempDatosBenerifiarios
	from RH.TblFamiliaresBenificiariosEmpleados be
		inner join RH.tblcatparentescos p	
		on be.IDParentesco = p.IDParentesco

	select distinct idempleado,
	STUFF 
	(
		(select ', ' + nota from RH.tblNotasEmpleados N where N.IDEmpleado = b.idEmpleado for xml path('') ),1,2,''
	) as Notas
	into #notasTemporal
	FROM Rh.tblNotasEmpleados b group by IDEmpleado



	if(@IDTipoVigente = 1)
	BEGIN

		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select 
             m.ClaveEmpleado as [CLAVE EMPLEADO]
			,m.Sucursal AS SUCURSAL
			,m.Area as RUBRO
			,m.NombreCompleto as [NOMBRE]
			,m.Departamento AS DEPARTAMENTO
			,m.Puesto AS PUESTO
			,m.Division as DIVISION
			,FORMAT(m.FechaIngreso,'dd/MM/yyyy') as [FECHA INGRESO]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
			,m.tipoTrabajadorEmpleado as [STATUS]
			, --FLOOR(DATEDIFF(DAY, m.FechaAntiguedad, GETDATE()) / 365.25)AS [ANTIGÜEDAD]
			--FLOOR(((( 
			--CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25)) * 12 - FLOOR((CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25))* 12)) * (365.25 / 12)) ) + 1 AS dias, 
			--FLOOR((CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, @fecha,GETDATE()) AS float) / 365.25)) * 12) AS meses,
			--FLOOR(CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25) AS años
			--https://calculator-online.net/es/date-calculator/
				CONCAT(
				FLOOR(CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25), ' Años ',
				FLOOR((CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, m.FechaIngreso,GETDATE()) AS float) / 365.25)) * 12) , ' Meses ' ,
				FLOOR((((CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25)) * 12 - FLOOR((CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25))* 12)) * (365.25 / 12)) ) + 1 , ' Dias ') as Antiguedad
			,(SELECT top 1 Duracion from RH.tblContratoEmpleado ce
				inner join RH.tblCatDocumentos d
					on ce.IDDocumento = d.IDDocumento
					and d.EsContrato = 1
				where IDEmpleado = m.IDEmpleado 
				order by ce.FechaIni desc
				) as [DÍAS DE CONTRATO]
			,(SELECT top 1 FORMAT(ce.FechaIni,'dd/MM/yyyy') from RH.tblContratoEmpleado ce
				inner join RH.tblCatDocumentos d
					on ce.IDDocumento = d.IDDocumento
					and d.EsContrato = 1
				where IDEmpleado = m.IDEmpleado 
				order by ce.FechaIni desc
				) as [INICIO DE CONTRATO]
				,(SELECT top 1 FORMAT(ce.FechaFin,'dd/MM/yyyy') from RH.tblContratoEmpleado ce
				inner join RH.tblCatDocumentos d
					on ce.IDDocumento = d.IDDocumento
					and d.EsContrato = 1
				where IDEmpleado = m.IDEmpleado 
				order by ce.FechaIni desc
				) as [VENCIMIENTO DE CONTRATO]
				,(SELECT count(*) from RH.tblContratoEmpleado ce
				inner join RH.tblCatDocumentos d
					on ce.IDDocumento = d.IDDocumento
					and d.EsContrato = 1
				where IDEmpleado = m.IDEmpleado 
			) as [NÚMERO DE CONTRATO]
				,(SELECT top 1 FORMAT(Fecha,'dd/MM/yyyy')  from IMSS.tblMovAfiliatorios WHERE IDEmpleado = m.IDEmpleado and IDTipoMovimiento = 2 order by Fecha desc) as [FECHA DE BAJA]
				,(SELECT TOP  1 rm.Codigo
					from IMSS.tblMovAfiliatorios mov
						inner join imss.tblCatRazonesMovAfiliatorios rm
							on mov.IDRazonMovimiento = rm.IDRazonMovimiento
					WHERE mov.IDEmpleado = m.IDEmpleado and mov.IDTipoMovimiento = 2
					order by mov.Fecha desc) as [TIPO BAJA]
				,(SELECT TOP  1 rm.Descripcion
					from IMSS.tblMovAfiliatorios mov
						inner join imss.tblCatRazonesMovAfiliatorios rm
							on mov.IDRazonMovimiento = rm.IDRazonMovimiento
					WHERE mov.IDEmpleado = m.IDEmpleado and mov.IDTipoMovimiento = 2
					order by mov.Fecha desc) as [MOTIVO DE BAJA]
				,case when mas.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]
				,m.Paterno AS [PRIMER APELLIDO]
				,m.Materno AS [SEGUNDO APELLIDO]
				,ISNULL(m.Nombre,'') + ' ' + ISNULL(m.SegundoNombre,'') AS [NOMBRES]
				,m.PaisNacimiento as NACIONALIDAD
				,m.CURP AS CURP
				,m.RFC AS [RFC ]
				,m.IMSS AS IMSS
				,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
				,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA ACTUAL]
				,FLOOR(DATEDIFF(DAY, m.FechaNacimiento, GETDATE()) / 365.25) as [EDAD]
				,m.EstadoNacimiento +', '+ m.MunicipioNacimiento AS [LUGAR NACIMIENTO]
				,m.Sexo AS SEXO
				,m.EstadoCivil AS [ESTADO CIVIL]
				,ce.Descripcion as [Nivel De Estudios]
				,(SELECT TOP 1 master.NOMBRECOMPLETO FROM RH.tblJefesEmpleados JE
					inner join RH.tblEmpleadosMaster master
						on JE.IDJefe = master.IDEmpleado
					WHERE JE.IDEmpleado = m.IDEmpleado
				) AS [JEFE QUE EVALÚA]
				,CONVERT(VARCHAR ,coalesce (Y.Value, '')) as [CORREO]
				,CONVERT(VARCHAR ,coalesce (Z.Value, '')) as [TELEFONO 1]
				,CONVERT(varchar,coalesce(TelefonoMovil.value,'')) as [TELEFONO MOVIL]
				,(select top 1 NombreCompleto from RH.TblFamiliaresBenificiariosEmpleados where IDEmpleado = m.IDEmpleado and Emergencia = 1 order by IDFamiliarBenificiarioEmpleado asc) as [AVISAR EN CASO DE EMERGENCIA]
				,(select top 1 p.Descripcion 
					from RH.TblFamiliaresBenificiariosEmpleados be
						inner join RH.TblCatParentescos p
							on be.IDParentesco = p.IDParentesco
					where IDEmpleado = m.IDEmpleado and Emergencia = 1 
					order by IDFamiliarBenificiarioEmpleado asc) as [PARENTESCO]
				,(select top 1 TelefonoMovil from RH.TblFamiliaresBenificiariosEmpleados where IDEmpleado = m.IDEmpleado and Emergencia = 1 order by IDFamiliarBenificiarioEmpleado asc) as [TELEFONO]				
				,m.Empresa as [RAZON SOCIAL]
				,'' as [VACANTE] -- se viene de reclutamiento
				,'' as [A SUSTITUIR] -- se viene de reclutamiento
				,'' as [VACANTE NO PS] -- se viene de reclutamiento poscision temporal en plaza
                ,puesto.DescripcionPuesto as [DESCRIPCION ACTIVIDAD]
                ,UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')) + ', ' + c.NombreAsentamiento as DIRECCION
                ,Muni.Descripcion as [DIRECCION MUNICIPIO]			
			    ,CP.CodigoPostal as [DIRECCION POSTAL]
                ,'' AS [DIRECCION EMPRESA]
                ,'' AS [HORARIO]
                ,'' AS [CUENTA INFONAVIT]
                ,'' AS [NUMERO CREDITO]
                ,'' AS [FACTOR DE DESCUENTO]
                ,'' AS [IMPORTE FACTOR DE DESCUENTO]
                ,'' AS [CREDITO FONACOT] -- SOLO ACTIVOS CONCATENADOS
                ,'' AS [IMPORTE DESCUENTO] -- SUMADE IMPORTE			    
			    ,TC.Descripcion as [TIPO CONTRATO SAT]
                ,M.NOMBRECOMPLETO AS [SUSTITUYE]
                ,'' AS [NUMERO DE HIJOS]
				,(SELECT top 1 NombreCompleto FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 1) [NOMBRE DEL PRIMER HIJO]
				,(SELECT top 1 FORMAT(FechaNacimiento,'dd/MM/yyyy')  FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 1) [FECHA DE NACIMIENTO 1]
				,(SELECT top 1 NombreCompleto FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 2) [NOMBRE DEL SEGUNDO HIJO]
				,(SELECT top 1 FORMAT(FechaNacimiento,'dd/MM/yyyy')  FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 2) [FECHA DE NACIMIENTO 2]
				,(SELECT top 1 NombreCompleto FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 3) [NOMBRE DEL TERCER HIJO]
				,(SELECT top 1 FORMAT(FechaNacimiento,'dd/MM/yyyy')  FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 3) [FECHA DE NACIMIENTO 3]
				,(SELECT top 1 NombreCompleto FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 4) [NOMBRE DEL CUARTO HIJO]
				,(SELECT top 1 FORMAT(FechaNacimiento,'dd/MM/yyyy')  FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 4) [FECHA DE NACIMIENTO 4]
				,temporalNotas.Notas as Observaciones
				,case when isnull(induccion.Valor,'False') = 'False' then '' else 'SI' end as [Tomo Induccion]
							
		from @dtEmpleados M
			inner join RH.tblEmpleadosMaster Mas with (nolock) 
				on m.IDEmpleado = Mas.IDEmpleado
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
			left join [RH].[tblEmpleadoPTU] PTU with (nolock) 
				on m.IDEmpleado = PTU.IDEmpleado
			left join RH.tblSaludEmpleado SE with (nolock) 
				on SE.IDEmpleado = M.IDEmpleado
			left join RH.tblDireccionEmpleado direccion with (nolock) 
				on direccion.IDEmpleado = M.IDEmpleado
				AND direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
			left join SAT.tblCatColonias c with (nolock) 
				on direccion.IDColonia = c.IDColonia
			left join SAT.tblCatMunicipios Muni with (nolock) 
				on muni.IDMunicipio = direccion.IDMunicipio
			left join SAT.tblCatEstados EST with (nolock) 
				on EST.IDEstado = direccion.IDEstado 
			left join SAT.tblCatLocalidades localidades with (nolock) 
				on localidades.IDLocalidad = direccion.IDLocalidad 
			left join SAT.tblCatCodigosPostales CP with (nolock) 
				on CP.IDCodigoPostal = direccion.IDCodigoPostal
			left join RH.tblCatRutasTransporte rutas with (nolock) 
				on direccion.IDRuta = rutas.IDRuta
			left join RH.tblInfonavitEmpleado Infonavit with (nolock) 
				on Infonavit.IDEmpleado = m.IDEmpleado
					and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
			left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) 
				on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
			left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) 
				on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
			left join RH.tblPagoEmpleado PE with (nolock) 
				on PE.IDEmpleado = M.IDEmpleado
					and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) 
				on LP.IDLayoutPago = PE.IDLayoutPago
					and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) 
				on bancos.IDBanco = PE.IDBanco
			left join RH.tblDatosExtraEmpleados CompVariable
				on CompVariable.IDEmpleado = M.IDEmpleado
					AND CompVariable.IDDatoExtra = 6
			Left Join RH.tblDatosExtraEmpleados pagoDolares
				on m.IDEmpleado = pagoDolares.IDEmpleado
					and pagoDolares.IDDatoExtra = 4
			--left join RH.tblTipoTrabajadorEmpleado TTE
			--	on TTE.IDEmpleado = m.IDEmpleado
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
			left join IMSS.tblCatTipoTrabajador TT with (nolock) 
				on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
			left join SAT.tblCatTiposContrato TC with (nolock) 
				on TC.IDTipoContrato = TTE.IDTipoContrato
            left join RH.tblDatosExtraEmpleados DE with (nolock) 
				on M.IDEmpleado = DE.IDEmpleado and DE.IDDatoExtra = 4
			left join RH.tblContactoEmpleado Z with (nolock) 
				on M.IDEmpleado = Z.IDEmpleado --OR Z.IDTipoContactoEmpleado = 1 
					AND Z.IDTipoContactoEmpleado = 4
			Left join RH.tblContactoEmpleado Y with (nolock) 
				on M.IDEmpleado = Y.IDEmpleado --OR Z.IDTipoContactoEmpleado = 1 
					AND Y.IDTipoContactoEmpleado = 1
			left join RH.tblContactoEmpleado TelefonoMovil with (nolock) 
				on M.IDEmpleado = TelefonoMovil.IDEmpleado 
					AND TelefonoMovil.IDTipoContactoEmpleado = 2
            left join rh.tblCatPuestos puesto 
                on puesto.IDPuesto = m.IDPuesto
			left join #notasTemporal temporalNotas
				on M.IDEmpleado = temporalNotas.IDEmpleado
			left join STPS.tblcatestudios ce
				on ce.idestudio = mas.IDEscolaridad
			left join rh.tbldatosextraempleados induccion with (nolock)
				on induccion.IDEmpleado = M.IDEmpleado and induccion.IDDatoExtra = 12
			
		--Where 
		--( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
		--	or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		--   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		--   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		--   and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))             
		--	   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		--   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
		--	  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		--   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		--   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		--   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		--   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		--   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		-- and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))     
		--   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		--   and ((            
		--	((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
		--		) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by M.ClaveEmpleado asc
				--Where 
		--M.Vigente =1 and
		--( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
		--	or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		--   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		--   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		--   and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))             
		--	   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		--   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
		--	  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		--   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		--   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		--   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		--   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		--   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		-- and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))     
		--   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		--   and ((            
		--	((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
		--		) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
		--		order by M.ClaveEmpleado asc

	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		
			select 
             m.ClaveEmpleado as [CLAVE EMPLEADO]
			,m.Sucursal AS SUCURSAL
			,m.Area as RUBRO
			,m.NombreCompleto as [NOMBRE]
			,m.Departamento AS DEPARTAMENTO
			,m.Puesto AS PUESTO
			,m.Division as DIVISION
			,FORMAT(m.FechaIngreso,'dd/MM/yyyy') as [FECHA INGRESO]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
			,m.tipoTrabajadorEmpleado as [STATUS]
			, --FLOOR(DATEDIFF(DAY, m.FechaAntiguedad, GETDATE()) / 365.25)AS [ANTIGÜEDAD]
			--FLOOR(((( 
			--CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25)) * 12 - FLOOR((CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25))* 12)) * (365.25 / 12)) ) + 1 AS dias, 
			--FLOOR((CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, @fecha,GETDATE()) AS float) / 365.25)) * 12) AS meses,
			--FLOOR(CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25) AS años
			--https://calculator-online.net/es/date-calculator/
				CONCAT(
				FLOOR(CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25), ' Años ',
				FLOOR((CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, m.FechaIngreso,GETDATE()) AS float) / 365.25)) * 12) , ' Meses ' ,
				FLOOR((((CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25)) * 12 - FLOOR((CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25))* 12)) * (365.25 / 12)) ) + 1 , ' Dias ') as Antiguedad
			,(SELECT top 1 Duracion from RH.tblContratoEmpleado ce
				inner join RH.tblCatDocumentos d
					on ce.IDDocumento = d.IDDocumento
					and d.EsContrato = 1
				where IDEmpleado = m.IDEmpleado 
				order by ce.FechaIni desc
				) as [DÍAS DE CONTRATO]
			,(SELECT top 1 FORMAT(ce.FechaIni,'dd/MM/yyyy') from RH.tblContratoEmpleado ce
				inner join RH.tblCatDocumentos d
					on ce.IDDocumento = d.IDDocumento
					and d.EsContrato = 1
				where IDEmpleado = m.IDEmpleado 
				order by ce.FechaIni desc
				) as [INICIO DE CONTRATO]
				,(SELECT top 1 FORMAT(ce.FechaFin,'dd/MM/yyyy') from RH.tblContratoEmpleado ce
				inner join RH.tblCatDocumentos d
					on ce.IDDocumento = d.IDDocumento
					and d.EsContrato = 1
				where IDEmpleado = m.IDEmpleado 
				order by ce.FechaIni desc
				) as [VENCIMIENTO DE CONTRATO]
				,(SELECT count(*) from RH.tblContratoEmpleado ce
				inner join RH.tblCatDocumentos d
					on ce.IDDocumento = d.IDDocumento
					and d.EsContrato = 1
				where IDEmpleado = m.IDEmpleado 
			) as [NÚMERO DE CONTRATO]
				,(SELECT top 1 FORMAT(Fecha,'dd/MM/yyyy')  from IMSS.tblMovAfiliatorios WHERE IDEmpleado = m.IDEmpleado and IDTipoMovimiento = 2 order by Fecha desc) as [FECHA DE BAJA]
				,(SELECT TOP  1 rm.Codigo
					from IMSS.tblMovAfiliatorios mov
						inner join imss.tblCatRazonesMovAfiliatorios rm
							on mov.IDRazonMovimiento = rm.IDRazonMovimiento
					WHERE mov.IDEmpleado = m.IDEmpleado and mov.IDTipoMovimiento = 2
					order by mov.Fecha desc) as [TIPO BAJA]
				,(SELECT TOP  1 rm.Descripcion
					from IMSS.tblMovAfiliatorios mov
						inner join imss.tblCatRazonesMovAfiliatorios rm
							on mov.IDRazonMovimiento = rm.IDRazonMovimiento
					WHERE mov.IDEmpleado = m.IDEmpleado and mov.IDTipoMovimiento = 2
					order by mov.Fecha desc) as [MOTIVO DE BAJA]
				,case when m.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]
				,m.Paterno AS [PRIMER APELLIDO]
				,m.Materno AS [SEGUNDO APELLIDO]
				,ISNULL(m.Nombre,'') + ' ' + ISNULL(m.SegundoNombre,'') AS [NOMBRES]
				,m.PaisNacimiento as NACIONALIDAD
				,m.CURP AS CURP
				,m.RFC AS [RFC ]
				,m.IMSS AS IMSS
				,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
				,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA ACTUAL]
				,FLOOR(DATEDIFF(DAY, m.FechaNacimiento, GETDATE()) / 365.25) as [EDAD]
				,m.EstadoNacimiento +', '+ m.MunicipioNacimiento AS [LUGAR NACIMIENTO]
				,m.Sexo AS SEXO
				,m.EstadoCivil AS [ESTADO CIVIL]
				,ce.Descripcion as [Nivel De Estudios]
				,(SELECT TOP 1 master.NOMBRECOMPLETO FROM RH.tblJefesEmpleados JE
					inner join RH.tblEmpleadosMaster master
						on JE.IDJefe = master.IDEmpleado
					WHERE JE.IDEmpleado = m.IDEmpleado
				) AS [JEFE QUE EVALÚA]
				,CONVERT(VARCHAR ,coalesce (Y.Value, '')) as [CORREO]
				,CONVERT(VARCHAR ,coalesce (Z.Value, '')) as [TELEFONO 1]
				,CONVERT(varchar,coalesce(TelefonoMovil.value,'')) as [TELEFONO MOVIL]
				,(select top 1 NombreCompleto from RH.TblFamiliaresBenificiariosEmpleados where IDEmpleado = m.IDEmpleado and Emergencia = 1 order by IDFamiliarBenificiarioEmpleado asc) as [AVISAR EN CASO DE EMERGENCIA]
				,(select top 1 p.Descripcion 
					from RH.TblFamiliaresBenificiariosEmpleados be
						inner join RH.TblCatParentescos p
							on be.IDParentesco = p.IDParentesco
					where IDEmpleado = m.IDEmpleado and Emergencia = 1 
					order by IDFamiliarBenificiarioEmpleado asc) as [PARENTESCO]
				,(select top 1 TelefonoMovil from RH.TblFamiliaresBenificiariosEmpleados where IDEmpleado = m.IDEmpleado and Emergencia = 1 order by IDFamiliarBenificiarioEmpleado asc) as [TELEFONO]				
				,m.Empresa as [RAZON SOCIAL]
				,'' as [VACANTE] -- se viene de reclutamiento
				,'' as [A SUSTITUIR] -- se viene de reclutamiento
				,'' as [VACANTE NO PS] -- se viene de reclutamiento poscision temporal en plaza
                ,puesto.DescripcionPuesto as [DESCRIPCION ACTIVIDAD]
                ,UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')) + ', ' + c.NombreAsentamiento as DIRECCION
                ,Muni.Descripcion as [DIRECCION MUNICIPIO]			
			    ,CP.CodigoPostal as [DIRECCION POSTAL]
                ,'' AS [DIRECCION EMPRESA]
                ,'' AS [HORARIO]
                ,'' AS [CUENTA INFONAVIT]
                ,'' AS [NUMERO CREDITO]
                ,'' AS [FACTOR DE DESCUENTO]
                ,'' AS [IMPORTE FACTOR DE DESCUENTO]
                ,'' AS [CREDITO FONACOT] -- SOLO ACTIVOS CONCATENADOS
                ,'' AS [IMPORTE DESCUENTO] -- SUMADE IMPORTE			    
			    ,TC.Descripcion as [TIPO CONTRATO SAT]
                ,M.NOMBRECOMPLETO AS [SUSTITUYE]
                ,'' AS [NUMERO DE HIJOS]
				,(SELECT top 1 NombreCompleto FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 1) [NOMBRE DEL PRIMER HIJO]
				,(SELECT top 1 FORMAT(FechaNacimiento,'dd/MM/yyyy')  FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 1) [FECHA DE NACIMIENTO 1]
				,(SELECT top 1 NombreCompleto FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 2) [NOMBRE DEL SEGUNDO HIJO]
				,(SELECT top 1 FORMAT(FechaNacimiento,'dd/MM/yyyy')  FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 2) [FECHA DE NACIMIENTO 2]
				,(SELECT top 1 NombreCompleto FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 3) [NOMBRE DEL TERCER HIJO]
				,(SELECT top 1 FORMAT(FechaNacimiento,'dd/MM/yyyy')  FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 3) [FECHA DE NACIMIENTO 3]
				,(SELECT top 1 NombreCompleto FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 4) [NOMBRE DEL CUARTO HIJO]
				,(SELECT top 1 FORMAT(FechaNacimiento,'dd/MM/yyyy')  FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 4) [FECHA DE NACIMIENTO 4]
				,temporalNotas.Notas as Observaciones
				,case when isnull(induccion.Valor,'False') = 'False' then '' else 'SI' end as [Tomo Induccion]


		from RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
			left join [RH].[tblEmpleadoPTU] PTU with (nolock) 
				on m.IDEmpleado = PTU.IDEmpleado
			left join RH.tblSaludEmpleado SE with (nolock) 
				on SE.IDEmpleado = M.IDEmpleado
			left join RH.tblDireccionEmpleado direccion with (nolock) 
				on direccion.IDEmpleado = M.IDEmpleado
				AND direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
			left join SAT.tblCatColonias c with (nolock) 
				on direccion.IDColonia = c.IDColonia
			left join SAT.tblCatMunicipios Muni with (nolock) 
				on muni.IDMunicipio = direccion.IDMunicipio
			left join SAT.tblCatEstados EST with (nolock) 
				on EST.IDEstado = direccion.IDEstado 
			left join SAT.tblCatLocalidades localidades with (nolock) 
				on localidades.IDLocalidad = direccion.IDLocalidad 
			left join SAT.tblCatCodigosPostales CP with (nolock) 
				on CP.IDCodigoPostal = direccion.IDCodigoPostal
			left join RH.tblCatRutasTransporte rutas with (nolock) 
				on direccion.IDRuta = rutas.IDRuta
			left join RH.tblInfonavitEmpleado Infonavit with (nolock) 
				on Infonavit.IDEmpleado = m.IDEmpleado
					and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
			left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) 
				on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
			left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) 
				on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
			left join RH.tblPagoEmpleado PE with (nolock) 
				on PE.IDEmpleado = M.IDEmpleado
					and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) 
				on LP.IDLayoutPago = PE.IDLayoutPago
					and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) 
				on bancos.IDBanco = PE.IDBanco
			left join RH.tblDatosExtraEmpleados CompVariable
				on CompVariable.IDEmpleado = M.IDEmpleado
					AND CompVariable.IDDatoExtra = 6
			Left Join RH.tblDatosExtraEmpleados pagoDolares
				on m.IDEmpleado = pagoDolares.IDEmpleado
					and pagoDolares.IDDatoExtra = 4
			--left join RH.tblTipoTrabajadorEmpleado TTE
			--	on TTE.IDEmpleado = m.IDEmpleado
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
			left join IMSS.tblCatTipoTrabajador TT with (nolock) 
				on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
			left join SAT.tblCatTiposContrato TC with (nolock) 
				on TC.IDTipoContrato = TTE.IDTipoContrato
			left join RH.tblContactoEmpleado Z with (nolock) 
				on M.IDEmpleado = Z.IDEmpleado --OR Z.IDTipoContactoEmpleado = 1 
					AND Z.IDTipoContactoEmpleado = 4
			left join RH.tblContactoEmpleado Y with (nolock) 
				on M.IDEmpleado = Y.IDEmpleado --OR Z.IDTipoContactoEmpleado = 1 
					AND Y.IDTipoContactoEmpleado = 1
			left join RH.tblContactoEmpleado TelefonoMovil with (nolock) 
				on M.IDEmpleado = TelefonoMovil.IDEmpleado 
					AND TelefonoMovil.IDTipoContactoEmpleado = 2
            left join rh.tblCatPuestos puesto 
                on puesto.IDPuesto = m.IDPuesto
			left join #notasTemporal temporalNotas
				on M.IDEmpleado = temporalNotas.IDEmpleado
			left join STPS.tblcatestudios ce
				on ce.idestudio = m.idescolaridad
			left join rh.tbldatosextraempleados induccion with (nolock)
				on induccion.IDEmpleado = M.IDEmpleado and induccion.IDDatoExtra = 12

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
		
			select 
            m.ClaveEmpleado as [CLAVE EMPLEADO]
			,m.Sucursal AS SUCURSAL
			,m.Area as RUBRO
			,m.NombreCompleto as [NOMBRE]
			,m.Departamento AS DEPARTAMENTO
			,m.Puesto AS PUESTO
			,m.Division as DIVISION
			,FORMAT(m.FechaIngreso,'dd/MM/yyyy') as [FECHA INGRESO]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
			,m.tipoTrabajadorEmpleado as [STATUS]
			, --FLOOR(DATEDIFF(DAY, m.FechaAntiguedad, GETDATE()) / 365.25)AS [ANTIGÜEDAD]
			--FLOOR(((( 
			--CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25)) * 12 - FLOOR((CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25))* 12)) * (365.25 / 12)) ) + 1 AS dias, 
			--FLOOR((CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, @fecha,GETDATE()) AS float) / 365.25)) * 12) AS meses,
			--FLOOR(CAST(DATEDIFF(day, @fecha, GETDATE()) AS float) / 365.25) AS años
			--https://calculator-online.net/es/date-calculator/
				CONCAT(
				FLOOR(CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25), ' Años ',
				FLOOR((CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, m.FechaIngreso,GETDATE()) AS float) / 365.25)) * 12) , ' Meses ' ,
				FLOOR((((CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25)) * 12 - FLOOR((CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25 - FLOOR(CAST(DATEDIFF(day, m.FechaIngreso, GETDATE()) AS float) / 365.25))* 12)) * (365.25 / 12)) ) + 1 , ' Dias ') as Antiguedad
			,(SELECT top 1 Duracion from RH.tblContratoEmpleado ce
				inner join RH.tblCatDocumentos d
					on ce.IDDocumento = d.IDDocumento
					and d.EsContrato = 1
				where IDEmpleado = m.IDEmpleado 
				order by ce.FechaIni desc
				) as [DÍAS DE CONTRATO]
			,(SELECT top 1 FORMAT(ce.FechaIni,'dd/MM/yyyy') from RH.tblContratoEmpleado ce
				inner join RH.tblCatDocumentos d
					on ce.IDDocumento = d.IDDocumento
					and d.EsContrato = 1
				where IDEmpleado = m.IDEmpleado 
				order by ce.FechaIni desc
				) as [INICIO DE CONTRATO]
				,(SELECT top 1 FORMAT(ce.FechaFin,'dd/MM/yyyy') from RH.tblContratoEmpleado ce
				inner join RH.tblCatDocumentos d
					on ce.IDDocumento = d.IDDocumento
					and d.EsContrato = 1
				where IDEmpleado = m.IDEmpleado 
				order by ce.FechaIni desc
				) as [VENCIMIENTO DE CONTRATO]
				,(SELECT count(*) from RH.tblContratoEmpleado ce
				inner join RH.tblCatDocumentos d
					on ce.IDDocumento = d.IDDocumento
					and d.EsContrato = 1
				where IDEmpleado = m.IDEmpleado 
			) as [NÚMERO DE CONTRATO]
				,(SELECT top 1 FORMAT(Fecha,'dd/MM/yyyy')  from IMSS.tblMovAfiliatorios WHERE IDEmpleado = m.IDEmpleado and IDTipoMovimiento = 2 order by Fecha desc) as [FECHA DE BAJA]
				,(SELECT TOP  1 rm.Codigo
					from IMSS.tblMovAfiliatorios mov
						inner join imss.tblCatRazonesMovAfiliatorios rm
							on mov.IDRazonMovimiento = rm.IDRazonMovimiento
					WHERE mov.IDEmpleado = m.IDEmpleado and mov.IDTipoMovimiento = 2
					order by mov.Fecha desc) as [TIPO BAJA]
				,(SELECT TOP  1 rm.Descripcion
					from IMSS.tblMovAfiliatorios mov
						inner join imss.tblCatRazonesMovAfiliatorios rm
							on mov.IDRazonMovimiento = rm.IDRazonMovimiento
					WHERE mov.IDEmpleado = m.IDEmpleado and mov.IDTipoMovimiento = 2
					order by mov.Fecha desc) as [MOTIVO DE BAJA]
				,case when m.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]
				,m.Paterno AS [PRIMER APELLIDO]
				,m.Materno AS [SEGUNDO APELLIDO]
				,ISNULL(m.Nombre,'') + ' ' + ISNULL(m.SegundoNombre,'') AS [NOMBRES]
				,m.PaisNacimiento as NACIONALIDAD
				,m.CURP AS CURP
				,m.RFC AS [RFC ]
				,m.IMSS AS IMSS
				,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
				,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA ACTUAL]
				,FLOOR(DATEDIFF(DAY, m.FechaNacimiento, GETDATE()) / 365.25) as [EDAD]
				,m.EstadoNacimiento +', '+ m.MunicipioNacimiento AS [LUGAR NACIMIENTO]
				,m.Sexo AS SEXO
				,m.EstadoCivil AS [ESTADO CIVIL]
				,ce.Descripcion as [Nivel De Estudios]
				,(SELECT TOP 1 master.NOMBRECOMPLETO FROM RH.tblJefesEmpleados JE
					inner join RH.tblEmpleadosMaster master
						on JE.IDJefe = master.IDEmpleado
					WHERE JE.IDEmpleado = m.IDEmpleado
				) AS [JEFE QUE EVALÚA]
				,CONVERT(VARCHAR ,coalesce (Y.Value, '')) as [CORREO]
				,CONVERT(VARCHAR ,coalesce (Z.Value, '')) as [TELEFONO 1]
				,CONVERT(varchar,coalesce(TelefonoMovil.value,'')) as [TELEFONO MOVIL]
				,(select top 1 NombreCompleto from RH.TblFamiliaresBenificiariosEmpleados where IDEmpleado = m.IDEmpleado and Emergencia = 1 order by IDFamiliarBenificiarioEmpleado asc) as [AVISAR EN CASO DE EMERGENCIA]
				,(select top 1 p.Descripcion 
					from RH.TblFamiliaresBenificiariosEmpleados be
						inner join RH.TblCatParentescos p
							on be.IDParentesco = p.IDParentesco
					where IDEmpleado = m.IDEmpleado and Emergencia = 1 
					order by IDFamiliarBenificiarioEmpleado asc) as [PARENTESCO]
				,(select top 1 TelefonoMovil from RH.TblFamiliaresBenificiariosEmpleados where IDEmpleado = m.IDEmpleado and Emergencia = 1 order by IDFamiliarBenificiarioEmpleado asc) as [TELEFONO]				
				,m.Empresa as [RAZON SOCIAL]
				,'' as [VACANTE] -- se viene de reclutamiento
				,'' as [A SUSTITUIR] -- se viene de reclutamiento
				,'' as [VACANTE NO PS] -- se viene de reclutamiento poscision temporal en plaza
                ,puesto.DescripcionPuesto as [DESCRIPCION ACTIVIDAD]
                ,UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')) + ', ' + c.NombreAsentamiento as DIRECCION
                ,Muni.Descripcion as [DIRECCION MUNICIPIO]			
			    ,CP.CodigoPostal as [DIRECCION POSTAL]
                ,'' AS [DIRECCION EMPRESA]
                ,'' AS [HORARIO]
                ,'' AS [CUENTA INFONAVIT]
                ,'' AS [NUMERO CREDITO]
                ,'' AS [FACTOR DE DESCUENTO]
                ,'' AS [IMPORTE FACTOR DE DESCUENTO]
                ,'' AS [CREDITO FONACOT] -- SOLO ACTIVOS CONCATENADOS
                ,'' AS [IMPORTE DESCUENTO] -- SUMADE IMPORTE			    
			    ,TC.Descripcion as [TIPO CONTRATO SAT]
                ,M.NOMBRECOMPLETO AS [SUSTITUYE]
                ,'' AS [NUMERO DE HIJOS]
				,(SELECT top 1 NombreCompleto FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 1) [NOMBRE DEL PRIMER HIJO]
				,(SELECT top 1 FORMAT(FechaNacimiento,'dd/MM/yyyy')  FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 1) [FECHA DE NACIMIENTO 1]
				,(SELECT top 1 NombreCompleto FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 2) [NOMBRE DEL SEGUNDO HIJO]
				,(SELECT top 1 FORMAT(FechaNacimiento,'dd/MM/yyyy')  FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 2) [FECHA DE NACIMIENTO 2]
				,(SELECT top 1 NombreCompleto FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 3) [NOMBRE DEL TERCER HIJO]
				,(SELECT top 1 FORMAT(FechaNacimiento,'dd/MM/yyyy')  FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 3) [FECHA DE NACIMIENTO 3]
				,(SELECT top 1 NombreCompleto FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 4) [NOMBRE DEL CUARTO HIJO]
				,(SELECT top 1 FORMAT(FechaNacimiento,'dd/MM/yyyy')  FROM #tempDatosBenerifiarios 
				WHERE IDEmpleado = m.IDEmpleado and RN = 4) [FECHA DE NACIMIENTO 4]
				,temporalNotas.Notas as Observaciones
				,case when isnull(induccion.Valor,'False') = 'False' then '' else 'SI' end as [Tomo Induccion]



		from RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
			left join [RH].[tblEmpleadoPTU] PTU with (nolock) 
				on m.IDEmpleado = PTU.IDEmpleado
			left join RH.tblSaludEmpleado SE with (nolock) 
				on SE.IDEmpleado = M.IDEmpleado
			left join RH.tblDireccionEmpleado direccion with (nolock) 
				on direccion.IDEmpleado = M.IDEmpleado
				AND direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
			left join SAT.tblCatColonias c with (nolock) 
				on direccion.IDColonia = c.IDColonia
			left join SAT.tblCatMunicipios Muni with (nolock) 
				on muni.IDMunicipio = direccion.IDMunicipio
			left join SAT.tblCatEstados EST with (nolock) 
				on EST.IDEstado = direccion.IDEstado 
			left join SAT.tblCatLocalidades localidades with (nolock) 
				on localidades.IDLocalidad = direccion.IDLocalidad 
			left join SAT.tblCatCodigosPostales CP with (nolock) 
				on CP.IDCodigoPostal = direccion.IDCodigoPostal
			left join RH.tblCatRutasTransporte rutas with (nolock) 
				on direccion.IDRuta = rutas.IDRuta
			left join RH.tblInfonavitEmpleado Infonavit with (nolock) 
				on Infonavit.IDEmpleado = m.IDEmpleado
					and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
			left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) 
				on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
			left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) 
				on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
			left join RH.tblPagoEmpleado PE with (nolock) 
				on PE.IDEmpleado = M.IDEmpleado
					and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) 
				on LP.IDLayoutPago = PE.IDLayoutPago
					and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) 
				on bancos.IDBanco = PE.IDBanco
			left join RH.tblDatosExtraEmpleados CompVariable
				on CompVariable.IDEmpleado = M.IDEmpleado
					AND CompVariable.IDDatoExtra = 6
			Left Join RH.tblDatosExtraEmpleados pagoDolares
				on m.IDEmpleado = pagoDolares.IDEmpleado
					and pagoDolares.IDDatoExtra = 4
			--left join RH.tblTipoTrabajadorEmpleado TTE
			--	on TTE.IDEmpleado = m.IDEmpleado
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
			left join IMSS.tblCatTipoTrabajador TT with (nolock) 
				on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
			left join SAT.tblCatTiposContrato TC with (nolock) 
				on TC.IDTipoContrato = TTE.IDTipoContrato
			left join RH.tblContactoEmpleado Z with (nolock) 
				on M.IDEmpleado = Z.IDEmpleado --OR Z.IDTipoContactoEmpleado = 1 
					AND Z.IDTipoContactoEmpleado = 4
			left join RH.tblContactoEmpleado Y with (nolock) 
				on M.IDEmpleado = Y.IDEmpleado --OR Z.IDTipoContactoEmpleado = 1 
					AND Y.IDTipoContactoEmpleado = 1
			left join RH.tblContactoEmpleado TelefonoMovil with (nolock) 
				on M.IDEmpleado = TelefonoMovil.IDEmpleado 
					AND TelefonoMovil.IDTipoContactoEmpleado = 2
            left join rh.tblCatPuestos puesto 
                on puesto.IDPuesto = m.IDPuesto
			left join #notasTemporal temporalNotas
				on M.IDEmpleado = temporalNotas.IDEmpleado
			left join STPS.tblcatestudios ce
				on ce.idestudio = m.IDEscolaridad
			left join rh.tbldatosextraempleados induccion with (nolock)
				on induccion.IDEmpleado = M.IDEmpleado and induccion.IDDatoExtra = 12

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
--	select * from @dtEmpleados
END
GO
