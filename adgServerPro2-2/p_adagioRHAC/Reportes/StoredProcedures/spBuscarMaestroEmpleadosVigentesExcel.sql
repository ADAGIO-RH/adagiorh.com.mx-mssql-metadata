USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarMaestroEmpleadosVigentesExcel] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
	;   

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')    
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	declare
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) 
			,@FechaIni date 
			,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)
	;
	
	select @TipoNomina = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
	from @dtFiltros where Catalogo = 'TipoNomina'

	select @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
	from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'
	
	select @ClaveEmpleadoFinal = CASE WHEN ISNULL(Value,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  Value END
	from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'

	select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
	from @dtFiltros where Catalogo = 'FechaIni'
	
	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
	from @dtFiltros where Catalogo = 'FechaFin'

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))

	set @Titulo = UPPER( 'REPORTE MAESTRO DE COLABORADORES VIGENTES DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))

	if object_id('tempdb..#tempDatosExtra')	is not null drop table #tempDatosExtra 
	if object_id('tempdb..#tempData')		is not null drop table #tempData
	if object_id('tempdb..#tempSalida')		is not null drop table #tempSalida
	if object_id('tempdb..##tempDatosExtraEmpleados')is not null drop table ##tempDatosExtraEmpleados
	if object_id('tempdb..#tempInfonavit')	is not null drop table #tempInfonavit

	select Infonavit.IDEmpleado,
		Infonavit.IDRegPatronal, 
		Infonavit.NumeroCredito,
		Infonavit.Fecha,
		Infonavit.IDTipoMovimiento,
		InfonavitTipoMovimiento.Descripcion as TipoMovimiento,
		Infonavit.IDTipoDescuento,
		InfonavitTipoDescuento.Descripcion as TipoDescuento,
		Infonavit.AplicaDisminucion,
		Infonavit.ValorDescuento,
		isnull((Select top 1 Fecha from RH.tblHistorialInfonavitEmpleado where IDInfonavitEmpleado = Infonavit.IDInfonavitEmpleado and IDTipoMovimiento = 1),Infonavit.Fecha) FechaOtorgamiento,
		ROW_NUMBER()OVER(PARTITION BY Infonavit.IDEmpleado order by Infonavit.Fecha desc) RN
		into #tempInfonavit
	from RH.tblInfonavitEmpleado Infonavit with (nolock) 
		left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
		left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento

	select distinct 
		c.IDDatoExtra,
		C.Nombre,
		C.Descripcion
	into #tempDatosExtra
	from (
		select *
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
		left join RH.tblDatosExtraEmpleados DE on M.IDEmpleado = DE.IDEmpleado
		left join RH.tblCatDatosExtra CDE on DE.IDDatoExtra = CDE.IDDatoExtra

	DECLARE @cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Nombre)+',0) AS '+ QUOTENAME(c.Nombre+' ')
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

	set @query1 = 'SELECT IDEmpleado as [No. Sys] ' + coalesce(','+@cols, '') + ' 
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
					for Nombre in (' + coalesce(@colsAlone, 'NO_INFO')  + ')
				) p 
				order by IDEmpleado
				'

	exec( @query1 + @query2) 

	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select 
			 m.ClaveEmpleado as CLAVE
			,m.Paterno AS PATERNO
			,m.Materno AS MATERNO
            ,m.Nombre AS NOMBRE          
			,m.SegundoNombre AS [SEGUNDO NOMBRE]
            ,m.NOMBRECOMPLETO as [NOMBRE COMPLETO]           
			,m.RFC AS [RFC ]
			,m.CURP AS CURP
			,m.IMSS AS IMSS
			,FORMAT(m.FechaIngreso,'dd/MM/yyyy') as [FECHA INGRESO]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
            ,m.Cliente AS CLIENTE
			,m.Empresa AS EMPRESA
            ,m.RegPatronal AS [REGISTRO PATRONAL]
            ,m.Departamento AS DEPARTAMENTO
			,m.Sucursal AS SUCURSAL
			,m.Puesto AS PUESTO			
			,m.CentroCosto AS [CENTRO COSTO]
			,m.Area AS AREA
			,m.Division AS DIVISION
			,m.Region AS REGION
			,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
            ,JSON_VALUE(tp.Traduccion, FORMATMESSAGE('$.%s.%s', +lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [TIPO PRESTACION]
            ,m.TipoNomina AS [TIPO NOMINA]
            ,em.DomicilioFiscal as [CODIGO POSTAL FISCAL]
            ,LP.Descripcion AS [LAYOUT PAGO]
			,Bancos.Descripcion as BANCO
			,PE.Interbancaria as [CLABE INTERBANCARIA]
			,PE.Cuenta as [NUMERO CUENTA]
			,PE.Tarjeta as [NUMERO TARJETA]
            ,m.SalarioDiario AS [SALARIO DIARIO]
			,m.SalarioIntegrado AS [SALARIO INTEGRADO]
			,m.SalarioVariable AS [SALARIO VARIABLE]
			,m.SalarioDiarioReal AS [SALARIO DIARIO REAL]
            ,(
				Select top 1 ISNULL([value],'SIN CORREO)') 
				from RH.tblContactoEmpleado 
				where IDEmpleado = m.IDEmpleado 
					and IDTipoContactoEmpleado = (select IDTipoContacto 
													from rh.tblCatTipoContactoEmpleado 
													where Descripcion = 'EMAIL')
				order by Predeterminado desc
			) AS [CORREO ELECTRONICO]
            ,(
				Select top 1 ISNULL([value],'SIN TELEFONO)') from RH.tblContactoEmpleado 
				where IDEmpleado = m.IDEmpleado 
					and IDTipoContactoEmpleado = (select IDTipoContacto 
													from rh.tblCatTipoContactoEmpleado 
													where Descripcion = 'TELÉFONO')
			) AS [TELEFONO]
			,(
				Select top 1 ISNULL([value],'SIN TELEFONO)') 
				from RH.tblContactoEmpleado 
				where IDEmpleado = m.IDEmpleado 
					and IDTipoContactoEmpleado = (select IDTipoContacto 
													from rh.tblCatTipoContactoEmpleado 
													where Descripcion = 'TELÉFONO MOVIL')
			) AS [TELEFONO MOVIL]
			,(
				Select top 1 ISNULL([value],'SIN TELEFONO)') 
				from RH.tblContactoEmpleado 
				where IDEmpleado = m.IDEmpleado 
					and IDTipoContactoEmpleado = (select IDTipoContacto 
													from rh.tblCatTipoContactoEmpleado 
													where Descripcion = 'TELEFONO CASA')
			) AS [TELEFONO CASA]
            ,m.Afore AS AFORE
            ,CASE WHEN isnull(PTU.PTU,0) = 0 THEN 'NO' ELSE 'SI' END as [PTU ]
            ,TT.Descripcion as [TIPO TRABAJADOR SUA]
			,TC.Descripcion as [TIPO CONTRATO SAT]
			,Infonavit.NumeroCredito as [NUM CREDITO INFONAVIT]
			,Infonavit.TipoDescuento AS [TIPO DESCUENTO INFONAVIT]
			,Infonavit.ValorDescuento AS [VALOR DESCUENTO INFONAVIT]
			,FORMAT(Infonavit.FechaOtorgamiento,'dd/MM/yyyy') as [FECHA OTORGAMIENTO INFONAVIT]
            ,rutas.Descripcion as [RUTA TRANSPORTE]
            ,JSON_VALUE(rutas.Traduccion, FORMATMESSAGE('$.%s.%s', +lower(replace(@IDIdioma, '-','')), 'Descripcion'))as [RUTA TRANSPORTE]
            ,substring(UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as DIRECCION
			,c.NombreAsentamiento as [DIRECCION COLONIA]
			,localidades.Descripcion as [DIRECCION LOCALIDAD]
			,Muni.Descripcion as [DIRECCION MUNICIPIO]
			,est.NombreEstado as [DIRECCION ESTADO]
			,CP.CodigoPostal as [DIRECCION POSTAL]
			,m.LocalidadNacimiento AS [LOCALIDAD NACIMIENTO]
			,m.MunicipioNacimiento AS [MUNICIPIO NACIMIENTO]
			,m.EstadoNacimiento AS [ESTADO NACIMIENTO]
			,m.PaisNacimiento AS [PAIS NACIMIENTO]
			,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]  
			,DATEDIFF(YEAR, m.FechaNacimiento, GETDATE()) - 
				CASE 
					WHEN DATEADD(YEAR, DATEDIFF(YEAR, m.FechaNacimiento, GETDATE()), m.FechaNacimiento) > GETDATE() THEN 1 
					ELSE 0 
				END AS [EDAD]
			,m.EstadoCivil AS [ESTADO CIVIL]
            ,m.Sexo AS SEXO
			,m.Escolaridad AS ESCOLARIDAD 
			,m.DescripcionEscolaridad AS [DESCIPCION ESCOLARIDAD]
			,m.Institucion AS [INSTITTUCION]
			,m.Probatorio AS PROBATORIO
            ,SE.TipoSangre AS [TIPO SANGRE]
			,SE.Estatura AS ESTATURA
			,SE.Peso AS PESO					
            ,[FECHA ULTIMA BAJA] = (
				select top 1 FORMAT(mov.Fecha,'dd/MM/yyyy') 
				from IMSS.tblMovAfiliatorios mov with (nolock)  
					join IMSS.tblCatTipoMovimientos ctm with (nolock) on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
				where mov.IDEmpleado = m.IDEmpleado and ctm.Codigo = 'B' 
				order by mov.Fecha desc 
			) 
			,CASE WHEN Mast.Vigente = 1 THEN 'SI' ELSE 'NO' END as [VIGENTE HOY]
            		
			,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA HOY]
			,deex.*
			,(
				select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO 
				from RH.tblJefesEmpleados je with(nolock)
					inner join RH.tblEmpleadosMaster emp with(nolock) on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado and isnull(emp.Vigente, 0) = 1
				order by je.IDJefeEmpleado desc
			) as Supervisor
		from @dtEmpleados m
			inner join RH.tblEmpleadosMaster Mast with (nolock) on m.IDEmpleado = mast.IDEmpleado
            inner join RH.tblEmpleados em with (nolock) on m.IDEmpleado = em.IDEmpleado
			inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			left join RH.tblCatTiposPrestaciones TP with (nolock) on M.IDTipoPrestacion = TP.IDTipoPrestacion
			left join [RH].[tblEmpleadoPTU] PTU with (nolock) on m.IDEmpleado = PTU.IDEmpleado
			left join RH.tblSaludEmpleado SE with (nolock) on SE.IDEmpleado = M.IDEmpleado
			left join RH.tblDireccionEmpleado direccion with (nolock) on direccion.IDEmpleado = M.IDEmpleado
				and direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
			left join SAT.tblCatColonias c with (nolock) on direccion.IDColonia = c.IDColonia
			left join SAT.tblCatMunicipios Muni with (nolock) on muni.IDMunicipio = direccion.IDMunicipio
			left join SAT.tblCatEstados EST with (nolock) on EST.IDEstado = direccion.IDEstado 
			left join SAT.tblCatLocalidades localidades with (nolock) on localidades.IDLocalidad = direccion.IDLocalidad 
			left join SAT.tblCatCodigosPostales CP with (nolock) on CP.IDCodigoPostal = direccion.IDCodigoPostal
			left join RH.tblCatRutasTransporte rutas with (nolock) on direccion.IDRuta = rutas.IDRuta
			left join #tempInfonavit Infonavit
				on Infonavit.IDEmpleado = m.IDEmpleado
				and Infonavit.RN = 1
			--left join RH.tblInfonavitEmpleado Infonavit with (nolock) on Infonavit.IDEmpleado = m.IDEmpleado
			--	and Infonavit.fecha<= getdate() --and Infonavit.fecha >= getdate()   
			--	and Infonavit.IDTipoMovimiento in (1,3,4,5,6)
			--left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
			--left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
			left join RH.tblPagoEmpleado PE with (nolock) on PE.IDEmpleado = M.IDEmpleado
				and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) on LP.IDLayoutPago = PE.IDLayoutPago
					and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) on bancos.IDBanco = PE.IDBanco
			--left join RH.tblTipoTrabajadorEmpleado TTE
			--	on TTE.IDEmpleado = m.IDEmpleado
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
			left join IMSS.tblCatTipoTrabajador TT with (nolock) on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
			left join SAT.tblCatTiposContrato TC with (nolock) on TC.IDTipoContrato = TTE.IDTipoContrato
			left join ##tempDatosExtraEmpleados deex on deex.[No. Sys] = m.IDEmpleado
            --LEFT JOIN RH.tblContactoEmpleado ce on ce.IDEmpleado = m.IDEmpleado and ce.IDTipoContactoEmpleado = (select IDTipoContacto from rh.tblCatTipoContactoEmpleado where Descripcion = 'EMAIL')
		order by M.ClaveEmpleado asc
	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		insert into @dtEmpleados
		exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario
		
		select 
			 m.ClaveEmpleado as CLAVE
			,m.Paterno AS PATERNO
			,m.Materno AS MATERNO
            ,m.Nombre AS NOMBRE          
			,m.SegundoNombre AS [SEGUNDO NOMBRE]
            ,m.NOMBRECOMPLETO as [NOMBRE COMPLETO]           
			,m.RFC AS [RFC ]
			,m.CURP AS CURP
			,m.IMSS AS IMSS
			,FORMAT(m.FechaIngreso,'dd/MM/yyyy') as [FECHA INGRESO]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
            ,m.Cliente AS CLIENTE
			,m.Empresa AS EMPRESA
            ,m.RegPatronal AS [REGISTRO PATRONAL]
            ,m.Departamento AS DEPARTAMENTO
			,m.Sucursal AS SUCURSAL
			,m.Puesto AS PUESTO			
			,m.CentroCosto AS [CENTRO COSTO]
			,m.Area AS AREA
			,m.Division AS DIVISION
			,m.Region AS REGION
			,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
            ,JSON_VALUE(tp.Traduccion, FORMATMESSAGE('$.%s.%s', +lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [TIPO PRESTACION]
            ,m.TipoNomina AS [TIPO NOMINA]
            ,EM.DomicilioFiscal AS [CODIGO POSTAL FISCAL]
            ,LP.Descripcion AS [LAYOUT PAGO]
			,Bancos.Descripcion as BANCO
			,PE.Interbancaria as [CLABE INTERBANCARIA]
			,PE.Cuenta as [NUMERO CUENTA]
			,PE.Tarjeta as [NUMERO TARJETA]
            ,m.SalarioDiario AS [SALARIO DIARIO]
			,m.SalarioIntegrado AS [SALARIO INTEGRADO]
			,m.SalarioVariable AS [SALARIO VARIABLE]
			,m.SalarioDiarioReal AS [SALARIO DIARIO REAL]
            ,(
				Select top 1 ISNULL([value],'SIN CORREO)') 
				from RH.tblContactoEmpleado 
				where IDEmpleado = m.IDEmpleado 
					and IDTipoContactoEmpleado = (select IDTipoContacto 
													from rh.tblCatTipoContactoEmpleado 
													where Descripcion = 'EMAIL')
				order by Predeterminado desc
			) AS [CORREO ELECTRONICO]
            ,(
				Select top 1 ISNULL([value],'SIN TELEFONO)') from RH.tblContactoEmpleado 
				where IDEmpleado = m.IDEmpleado 
					and IDTipoContactoEmpleado = (select IDTipoContacto 
													from rh.tblCatTipoContactoEmpleado 
													where Descripcion = 'TELÉFONO')
			) AS [TELEFONO]
			,(
				Select top 1 ISNULL([value],'SIN TELEFONO)') 
				from RH.tblContactoEmpleado 
				where IDEmpleado = m.IDEmpleado 
					and IDTipoContactoEmpleado = (select IDTipoContacto 
													from rh.tblCatTipoContactoEmpleado 
													where Descripcion = 'TELÉFONO MOVIL')
			) AS [TELEFONO MOVIL]
			,(
				Select top 1 ISNULL([value],'SIN TELEFONO)') 
				from RH.tblContactoEmpleado 
				where IDEmpleado = m.IDEmpleado 
					and IDTipoContactoEmpleado = (select IDTipoContacto 
													from rh.tblCatTipoContactoEmpleado 
													where Descripcion = 'TELEFONO CASA')
			) AS [TELEFONO CASA]
            ,m.Afore AS AFORE
            ,CASE WHEN isnull(PTU.PTU,0) = 0 THEN 'NO' ELSE 'SI' END as [PTU ]
            ,TT.Descripcion as [TIPO TRABAJADOR SUA]
			,TC.Descripcion as [TIPO CONTRATO SAT]
			,Infonavit.NumeroCredito as [NUM CREDITO INFONAVIT]
			,Infonavit.TipoDescuento AS [TIPO DESCUENTO INFONAVIT]
			,Infonavit.ValorDescuento AS [VALOR DESCUENTO INFONAVIT]
            ,JSON_VALUE(rutas.Traduccion, FORMATMESSAGE('$.%s.%s', +lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [RUTA TRANSPORTE]
			,FORMAT(Infonavit.FechaOtorgamiento,'dd/MM/yyyy') as [FECHA OTORGAMIENTO INFONAVIT]
            ,substring(UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as DIRECCION
			,c.NombreAsentamiento as [DIRECCION COLONIA]
			,localidades.Descripcion as [DIRECCION LOCALIDAD]
			,Muni.Descripcion as [DIRECCION MUNICIPIO]
			,est.NombreEstado as [DIRECCION ESTADO]
			,CP.CodigoPostal as [DIRECCION POSTAL]
			,m.LocalidadNacimiento AS [LOCALIDAD NACIMIENTO]
			,m.MunicipioNacimiento AS [MUNICIPIO NACIMIENTO]
			,m.EstadoNacimiento AS [ESTADO NACIMIENTO]
			,m.PaisNacimiento AS [PAIS NACIMIENTO]
			,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]  
			,DATEDIFF(YEAR, m.FechaNacimiento, GETDATE()) - 
				CASE 
					WHEN DATEADD(YEAR, DATEDIFF(YEAR, m.FechaNacimiento, GETDATE()), m.FechaNacimiento) > GETDATE() THEN 1 
					ELSE 0 
				END AS [EDAD]           
			,m.EstadoCivil AS [ESTADO CIVIL]
            ,m.Sexo AS SEXO
			,m.Escolaridad AS ESCOLARIDAD 
			,m.DescripcionEscolaridad AS [DESCIPCION ESCOLARIDAD]
			,m.Institucion AS [INSTITTUCION]
			,m.Probatorio AS PROBATORIO
            ,SE.TipoSangre AS [TIPO SANGRE]
			,SE.Estatura AS ESTATURA
			,SE.Peso AS PESO					
            ,[FECHA ULTIMA BAJA] = (
				select top 1 FORMAT(mov.Fecha,'dd/MM/yyyy') 
				from IMSS.tblMovAfiliatorios mov with (nolock)  
					join IMSS.tblCatTipoMovimientos ctm with (nolock) on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
				where mov.IDEmpleado = m.IDEmpleado and ctm.Codigo = 'B' 
				order by mov.Fecha desc 
			) 
		    ,CASE WHEN M.Vigente = 1 THEN 'SI' ELSE 'NO' END as [VIGENTE HOY]

			,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA HOY]
			,deex.*
			,(
				select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO 
				from RH.tblJefesEmpleados je with(nolock)
					inner join RH.tblEmpleadosMaster emp with(nolock) on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado and isnull(emp.Vigente, 0) = 1
				order by je.IDJefeEmpleado desc
			) as Supervisor
		from RH.tblEmpleadosMaster M with (nolock)
			inner join RH.tblEmpleados em with (nolock) on m.IDEmpleado = em.IDEmpleado 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on m.IDEmpleado = dfe.IDEmpleado 
				and dfe.IDUsuario = @IDUsuario
            Left join @dtEmpleados e on e.IDEmpleado = M.IDEmpleado -- El IDEMPLEADO NULL son los NO vigentes
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) on M.IDTipoPrestacion = TP.IDTipoPrestacion
			left join [RH].[tblEmpleadoPTU] PTU with (nolock) on m.IDEmpleado = PTU.IDEmpleado
			left join RH.tblSaludEmpleado SE with (nolock) on SE.IDEmpleado = M.IDEmpleado
			left join RH.tblDireccionEmpleado direccion with (nolock) on direccion.IDEmpleado = M.IDEmpleado
				AND direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
			left join SAT.tblCatColonias c with (nolock) on direccion.IDColonia = c.IDColonia
			left join SAT.tblCatMunicipios Muni with (nolock) on muni.IDMunicipio = direccion.IDMunicipio
			left join SAT.tblCatEstados EST with (nolock) on EST.IDEstado = direccion.IDEstado 
			left join SAT.tblCatLocalidades localidades with (nolock) on localidades.IDLocalidad = direccion.IDLocalidad 
			left join SAT.tblCatCodigosPostales CP with (nolock) on CP.IDCodigoPostal = direccion.IDCodigoPostal
			left join RH.tblCatRutasTransporte rutas with (nolock) on direccion.IDRuta = rutas.IDRuta
			left join #tempInfonavit Infonavit
				on Infonavit.IDEmpleado = m.IDEmpleado
				and Infonavit.RN = 1
			--left join RH.tblInfonavitEmpleado Infonavit with (nolock) on Infonavit.IDEmpleado = m.IDEmpleado
			--	and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
			--left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
			--left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
			left join RH.tblPagoEmpleado PE with (nolock) on PE.IDEmpleado = M.IDEmpleado
				and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) on LP.IDLayoutPago = PE.IDLayoutPago
				and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) on bancos.IDBanco = PE.IDBanco
			--left join RH.tblTipoTrabajadorEmpleado TTE
			--	on TTE.IDEmpleado = m.IDEmpleado
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
			left join IMSS.tblCatTipoTrabajador TT with (nolock) on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
			left join SAT.tblCatTiposContrato TC with (nolock) on TC.IDTipoContrato = TTE.IDTipoContrato
			left join ##tempDatosExtraEmpleados deex on deex.[No. Sys] = m.IDEmpleado
		Where e.IDEmpleado is null and ---- El IDEMPLEADO NULL son los NO vigentes 
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
			 m.ClaveEmpleado as CLAVE
			,m.Paterno AS PATERNO
			,m.Materno AS MATERNO
            ,m.Nombre AS NOMBRE          
			,m.SegundoNombre AS [SEGUNDO NOMBRE]
            ,m.NOMBRECOMPLETO as [NOMBRE COMPLETO]           
			,m.RFC AS [RFC ]
			,m.CURP AS CURP
			,m.IMSS AS IMSS
			,FORMAT(m.FechaIngreso,'dd/MM/yyyy') as [FECHA INGRESO]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
            ,m.Cliente AS CLIENTE
			,m.Empresa AS EMPRESA
            ,m.RegPatronal AS [REGISTRO PATRONAL]
            ,m.Departamento AS DEPARTAMENTO
			,m.Sucursal AS SUCURSAL
			,m.Puesto AS PUESTO			
			,m.CentroCosto AS [CENTRO COSTO]
			,m.Area AS AREA
			,m.Division AS DIVISION
			,m.Region AS REGION
			,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
            ,JSON_VALUE(tp.Traduccion, FORMATMESSAGE('$.%s.%s', +lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [TIPO PRESTACION]
            ,m.TipoNomina AS [TIPO NOMINA]
            ,EM.DomicilioFiscal AS [CODIGO POSTAL FISCAL]
            ,LP.Descripcion AS [LAYOUT PAGO]
			,Bancos.Descripcion as BANCO
			,PE.Interbancaria as [CLABE INTERBANCARIA]
			,PE.Cuenta as [NUMERO CUENTA]
			,PE.Tarjeta as [NUMERO TARJETA]
            ,m.SalarioDiario AS [SALARIO DIARIO]
			,m.SalarioIntegrado AS [SALARIO INTEGRADO]
			,m.SalarioVariable AS [SALARIO VARIABLE]
			,m.SalarioDiarioReal AS [SALARIO DIARIO REAL]
            ,(
				Select top 1 ISNULL([value],'SIN CORREO)') 
				from RH.tblContactoEmpleado 
				where IDEmpleado = m.IDEmpleado 
					and IDTipoContactoEmpleado = (select IDTipoContacto 
													from rh.tblCatTipoContactoEmpleado 
													where Descripcion = 'EMAIL')
				order by Predeterminado desc
			) AS [CORREO ELECTRONICO]
            ,(
				Select top 1 ISNULL([value],'SIN TELEFONO)') from RH.tblContactoEmpleado 
				where IDEmpleado = m.IDEmpleado 
					and IDTipoContactoEmpleado = (select IDTipoContacto 
													from rh.tblCatTipoContactoEmpleado 
													where Descripcion = 'TELÉFONO')
			) AS [TELEFONO]
			,(
				Select top 1 ISNULL([value],'SIN TELEFONO)') 
				from RH.tblContactoEmpleado 
				where IDEmpleado = m.IDEmpleado 
					and IDTipoContactoEmpleado = (select IDTipoContacto 
													from rh.tblCatTipoContactoEmpleado 
													where Descripcion = 'TELÉFONO MOVIL')
			) AS [TELEFONO MOVIL]
			,(
				Select top 1 ISNULL([value],'SIN TELEFONO)') 
				from RH.tblContactoEmpleado 
				where IDEmpleado = m.IDEmpleado 
					and IDTipoContactoEmpleado = (select IDTipoContacto 
													from rh.tblCatTipoContactoEmpleado 
													where Descripcion = 'TELEFONO CASA')
			) AS [TELEFONO CASA]
            ,m.Afore AS AFORE
            ,CASE WHEN isnull(PTU.PTU,0) = 0 THEN 'NO' ELSE 'SI' END as [PTU ]
            ,TT.Descripcion as [TIPO TRABAJADOR SUA]
			,TC.Descripcion as [TIPO CONTRATO SAT]
			,Infonavit.NumeroCredito as [NUM CREDITO INFONAVIT]
			,Infonavit.TipoDescuento AS [TIPO DESCUENTO INFONAVIT]
			,Infonavit.ValorDescuento AS [VALOR DESCUENTO INFONAVIT]
            ,JSON_VALUE(rutas.Traduccion, FORMATMESSAGE('$.%s.%s', +lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [RUTA TRANSPORTE]
			,FORMAT(Infonavit.FechaOtorgamiento,'dd/MM/yyyy') as [FECHA OTORGAMIENTO INFONAVIT]
            ,substring(UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as DIRECCION
			,c.NombreAsentamiento as [DIRECCION COLONIA]
			,localidades.Descripcion as [DIRECCION LOCALIDAD]
			,Muni.Descripcion as [DIRECCION MUNICIPIO]
			,est.NombreEstado as [DIRECCION ESTADO]
			,CP.CodigoPostal as [DIRECCION POSTAL]
			,m.LocalidadNacimiento AS [LOCALIDAD NACIMIENTO]
			,m.MunicipioNacimiento AS [MUNICIPIO NACIMIENTO]
			,m.EstadoNacimiento AS [ESTADO NACIMIENTO]
			,m.PaisNacimiento AS [PAIS NACIMIENTO]
			,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]  
			,DATEDIFF(YEAR, m.FechaNacimiento, GETDATE()) - 
				CASE 
					WHEN DATEADD(YEAR, DATEDIFF(YEAR, m.FechaNacimiento, GETDATE()), m.FechaNacimiento) > GETDATE() THEN 1 
					ELSE 0 
				END AS [EDAD]           
			,m.EstadoCivil AS [ESTADO CIVIL]
            ,m.Sexo AS SEXO
			,m.Escolaridad AS ESCOLARIDAD 
			,m.DescripcionEscolaridad AS [DESCIPCION ESCOLARIDAD]
			,m.Institucion AS [INSTITTUCION]
			,m.Probatorio AS PROBATORIO
            ,SE.TipoSangre AS [TIPO SANGRE]
			,SE.Estatura AS ESTATURA
			,SE.Peso AS PESO					
            ,[FECHA ULTIMA BAJA] = (
				select top 1 FORMAT(mov.Fecha,'dd/MM/yyyy') 
				from IMSS.tblMovAfiliatorios mov with (nolock)  
					join IMSS.tblCatTipoMovimientos ctm with (nolock) on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
				where mov.IDEmpleado = m.IDEmpleado and ctm.Codigo = 'B' 
				order by mov.Fecha desc 
			) 
			,CASE WHEN M.Vigente = 1 THEN 'SI' ELSE 'NO' END as [VIGENTE HOY]

			,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA HOY]
			,deex.*
			,(
				select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO 
				from RH.tblJefesEmpleados je with(nolock)
					inner join RH.tblEmpleadosMaster emp with(nolock) on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado and isnull(emp.Vigente, 0) = 1
				order by je.IDJefeEmpleado desc
			) as Supervisor
		from RH.tblEmpleadosMaster M with (nolock) 
        inner join RH.tblEmpleados em with (nolock) on m.IDEmpleado = em.IDEmpleado
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado 
				and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) on M.IDTipoPrestacion = TP.IDTipoPrestacion
			left join [RH].[tblEmpleadoPTU] PTU with (nolock) on m.IDEmpleado = PTU.IDEmpleado
			left join RH.tblSaludEmpleado SE with (nolock) on SE.IDEmpleado = M.IDEmpleado
			left join RH.tblDireccionEmpleado direccion with (nolock) on direccion.IDEmpleado = M.IDEmpleado
				AND direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
			left join SAT.tblCatColonias c with (nolock) on direccion.IDColonia = c.IDColonia
			left join SAT.tblCatMunicipios Muni with (nolock) on muni.IDMunicipio = direccion.IDMunicipio
			left join SAT.tblCatEstados EST with (nolock) on EST.IDEstado = direccion.IDEstado 
			left join SAT.tblCatLocalidades localidades with (nolock) on localidades.IDLocalidad = direccion.IDLocalidad 
			left join SAT.tblCatCodigosPostales CP with (nolock) on CP.IDCodigoPostal = direccion.IDCodigoPostal
			left join RH.tblCatRutasTransporte rutas with (nolock) on direccion.IDRuta = rutas.IDRuta
			left join #tempInfonavit Infonavit
				on Infonavit.IDEmpleado = m.IDEmpleado
				and Infonavit.RN = 1
			--left join RH.tblInfonavitEmpleado Infonavit with (nolock) on Infonavit.IDEmpleado = m.IDEmpleado
			--	and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
			--left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
			--left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
			left join RH.tblPagoEmpleado PE with (nolock) on PE.IDEmpleado = M.IDEmpleado
				and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) on LP.IDLayoutPago = PE.IDLayoutPago
				and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) on bancos.IDBanco = PE.IDBanco
			--left join RH.tblTipoTrabajadorEmpleado TTE
			--	on TTE.IDEmpleado = m.IDEmpleado
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
			left join IMSS.tblCatTipoTrabajador TT with (nolock) on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
			left join SAT.tblCatTiposContrato TC with (nolock) on TC.IDTipoContrato = TTE.IDTipoContrato
			left join ##tempDatosExtraEmpleados deex on deex.[No. Sys] = m.IDEmpleado
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
