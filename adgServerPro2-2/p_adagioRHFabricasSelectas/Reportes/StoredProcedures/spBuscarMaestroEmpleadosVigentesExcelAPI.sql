USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarMaestroEmpleadosVigentesExcelAPI] (
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
			,@IDTipoNomina int	= 0
			,@IDTipoVigente int = 1
			,@Titulo VARCHAR(MAX) 
			,@FechaIni date = getdate()
			,@FechaFin date = getdate()
			,@ClaveEmpleadoInicial varchar(255) = '0'
			,@ClaveEmpleadoFinal varchar(255) = 'ZZZZZZZZZZZZZZZZZZZZ'
			,@TipoNomina Varchar(max) = '0'
			,@IDDatoExtraJefeInmediato int
	;
	
	--select @TipoNomina = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
	--from @dtFiltros where Catalogo = 'TipoNomina'

	--select @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
	--from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'
	
	--select @ClaveEmpleadoFinal = CASE WHEN ISNULL(Value,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  Value END
	--from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'

	--select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
	--from @dtFiltros where Catalogo = 'FechaIni'
	
	--select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
	--from @dtFiltros where Catalogo = 'FechaFin'

	--SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
	--SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))

	set @Titulo = UPPER( 'REPORTE API ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))

	DECLARE
		@IDEmpleado int
		,@tempDiasVacacionesRep [Asistencia].[dtSaldosDeVacaciones]
	;

	SELECT top 1 @IDDatoExtraJefeInmediato = IDDatoExtra from rh.tblCatDatosExtra where Nombre = 'JEFE_INMEDIATO'
	
	DECLARE @TableSaldos as Table(
		IDEmpleado int,
		Anio int,
		FechaIni date,
		FechaFin date,
		Dias decimal(18,2),
		DiasTomados decimal(18,2),
		DiasVencidos decimal(18,2),
		DiasDisponibles decimal(18,2),
		TipoPrestacion Varchar(500),
		Errores Varchar(500)
	)


		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario
		
		/***************************************** SALDO VACACIONES NO PROPORCIONALES *****************************************/
		select @IDEmpleado = min(IDEmpleado) from @dtEmpleados

		--WHILE (@IDEmpleado <= (SELECT MAX(IDEmpleado) from @dtEmpleados))
		--BEGIN
		--	BEGIN TRY
		--		insert @tempDiasVacacionesRep
		--		EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado = @IDEmpleado, @Proporcional = 0, @FechaBaja = null, @IDUsuario = @IDUsuario
		--	END TRY
		--	BEGIN CATCH
		--		print ERROR_MESSAGE() 
		--		INSERT INTO @TableSaldos(IDEmpleado, Errores)
		--		SELECT @IDEmpleado,ERROR_MESSAGE()
		--	END CATCH

		--	INSERT INTO @TableSaldos
		--	SELECT @IDEmpleado, Anio, FechaIni, FechaFin, Dias, DiasTomados, DiasVencidos, DiasDisponibles, TipoPrestacion ,''
		--	FROM @tempDiasVacacionesRep

		--	Delete @tempDiasVacacionesRep

		--	SELECT @IDEmpleado = min(IDEmpleado) from @dtEmpleados where IDEmpleado > @IDEmpleado
		--END
	
		if object_id('tempdb..#VacacionesNoProporcionales')	is not null drop table #VacacionesNoProporcionales

		Select 
			s.IDEmpleado
			,max(s.Anio) as Anio
			,MAX(s.Dias) as DiasPorAniosPrestacion
			,SUM(s.Dias) as VacacionesGeneradasDesdeIngreso
			,SUM(s.DiasTomados) as DiasTomados
			,SUM(s.DiasVencidos) as DiasVencidos
			,SUM(s.DiasDisponibles) as DiasDisponibles
			,S.Errores as Errores
			into #VacacionesNoProporcionales
			FROM @TableSaldos s
			GROUP BY s.IDEmpleado, s.Errores
			
		Delete @tableSaldos
	
		/***************************************** SALDO VACACIONES PROPORCIONALES *****************************************/

		select @IDEmpleado = min(IDEmpleado) from @dtEmpleados

		--WHILE (@IDEmpleado <= (SELECT MAX(IDEmpleado) from @dtEmpleados))
		--BEGIN
		--	BEGIN TRY
		--		insert @tempDiasVacacionesRep
		--		EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado = @IDEmpleado, @Proporcional = 1, @FechaBaja = null, @IDUsuario = @IDUsuario
		--	END TRY
		--	BEGIN CATCH
		--		print ERROR_MESSAGE() 
		--		INSERT INTO @TableSaldos(IDEmpleado, Errores)
		--		SELECT @IDEmpleado,ERROR_MESSAGE()
		--	END CATCH

		--	INSERT INTO @TableSaldos
		--	SELECT @IDEmpleado, Anio, FechaIni, FechaFin, Dias, DiasTomados, DiasVencidos, DiasDisponibles, TipoPrestacion ,''
		--	FROM @tempDiasVacacionesRep

		--	Delete @tempDiasVacacionesRep

		--	SELECT @IDEmpleado = min(IDEmpleado) from @dtEmpleados where IDEmpleado > @IDEmpleado
		--END
	
		if object_id('tempdb..#VacacionesProporcionales') is not null drop table #VacacionesProporcionales

		Select 
			s.IDEmpleado
			,max(s.Anio) as Anio
			,MAX(s.Dias) as DiasPorAniosPrestacion
			,SUM(s.Dias) as VacacionesGeneradasDesdeIngreso
			,SUM(s.DiasTomados) as DiasTomados
			,SUM(s.DiasVencidos) as DiasVencidos
			,SUM(s.DiasDisponibles) as DiasDisponibles
			,S.Errores as Errores
			into #VacacionesProporcionales
			FROM @TableSaldos s
			GROUP BY s.IDEmpleado, s.Errores

		select 
			 m.ClaveEmpleado	AS CLAVE		--Numero de Empleado
			,m.IDEmpleado AS IDEmpleado
			,m.IDEmpresa		AS idBD			--Identificador de Base de datos (Para saber de que empresa son, EL LECHA, AVI, FABRICAS, etc.)
			,TRIM(COALESCE(m.Nombre,'')) + CASE WHEN TRIM(ISNULL(m.SegundoNombre,'')) <> '' THEN ' '+TRIM(COALESCE(m.SegundoNombre,'')) ELSE '' END	AS NOMBREN	--Nombre
			,m.Paterno			AS NOMBREP		--Apellido Paterno
			,m.Materno			AS NOMBREM		--Apellido Materno
			,UPPER(COALESCE(direccion.calle,''))	AS CALLE		--Calle
			,UPPER(COALESCE(direccion.Exterior,'')) AS NUMERO		--Numero del domicilio
			,UPPER(COALESCE(direccion.Interior,'')) AS INTERIOR		--Numero del domicilio
			,c.NombreAsentamiento as [COLONIA]		--Colonia
			,CP.CodigoPostal as [CP]				--Codigo Postal
			,est.NombreEstado as [ESTADO]			--Estado
			,Muni.Descripcion as [MUNICIPIO]		--Municipio
			,(Select top 1 ISNULL([value],'SIN TELEFONO)') from RH.tblContactoEmpleado 
                where IDEmpleado = m.IDEmpleado 
                    and IDTipoContactoEmpleado in (select IDTipoContacto from rh.tblCatTipoContactoEmpleado 
                        where Descripcion in ('TELÉFONO MOVIL','TELÉFONO','TELEFONO CASA')) )
             AS [TELEFONO_1]					--Telefono
			 ,m.IDDepartamento AS idDep			--Identificador de Departamento
			 ,m.Departamento AS departamento	--Nombre del Departamento
			 ,m.IDPuesto as idPuesto			--Identificador de Puesto
			 ,m.Puesto AS puesto				--Nombre del Puesto
			 ,m.IDSucursal AS idSucursal		--Identificador de la Sucursal
			 ,m.Sucursal AS sucursal			--Sucursal (Guadalajara, CDMX, etc)
			 ,m.IDRegion	AS idReg			--Identificador de Región
			 ,m.Region	AS Region				--Nombre de la Región
			 ,m.CURP AS CURP					--Curp
			 ,FORMAT(m.FechaNacimiento,'dd/MM/yyyy') AS FECHA_NACIMIENTO	--Fecha de Nacimiento
			 ,FORMAT(m.FechaIngreso,'dd/MM/yyyy') as FECHA_ENTRADA			--Fecha de Ingreso (Alta)
			 ,(
				select top 1 emp.Empresa
				from RH.tblJefesEmpleados je with(nolock)
					inner join RH.tblEmpleadosMaster emp with(nolock) on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado and isnull(emp.Vigente, 0) = 1
				order by je.IDJefeEmpleado desc
			) as idBDjefe					--Identificador del Jefe Inmediato (En que empresa se encuentra el Jefe)
			,(
				select top 1 emp.ClaveEmpleado
				from RH.tblJefesEmpleados je with(nolock)
					inner join RH.tblEmpleadosMaster emp with(nolock) on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado and isnull(emp.Vigente, 0) = 1
				order by je.IDJefeEmpleado desc
			) as JEFE_INMEDIATO				--Identificador del Jefe Inmediato (Numero de empleado)
			,dee.Valor as [Organigrama]
			,FORMAT(LastDep.FechaIni,'dd/MM/yyyy') AS FechaDep	--Fecha del ultimo cambio de departamento
			,FORMAT(LastPos.FechaIni,'dd/MM/yyyy') AS FechaPues	--Fecha del ultimo cambio de puesto
			,m.IDCentroCosto AS idCCosto
			,m.CentroCosto AS [CCosto]		--Centro de Costos (Texto ej: TI DESARROLLO Y CALIDAD)
			,m.Area AS AREA					--Ej, ADMINISTRACION, VENTAS, etc.
			,m.Empresa AS razonSocial		--Nombre del patrón (FABRICAS SELECTAS DEL CENTRO, etc.)
			,FORMAT(ce.FechaIni,'dd/MM/yyyy')  AS fechaContrato
			,FORMAT(ce.FechaFin,'dd/MM/yyyy')  AS fechaFinContrato
			,ce.Duracion AS duracionContrato
			,m.SalarioDiario AS sueldo		--Sueldo diario (Se utiliza en la app de requisiciones de puesto)
			,m.RFC AS [RFC]
			,m.IMSS AS IMSS
			,isnull(VacNoProp.DiasTomados,0)		AS DiasVaca				--Número de Días tomados de vacaciones
			,isnull(VacNoProp.DiasDisponibles,0)	AS DIAS_TOTAL_VACA		--Número de Días que tiene derecho de vacaciones de acuerdo a la antigüedad
			,PE.Tarjeta as CTA_TARJETA							--No. Tarjeta
			,PE.Cuenta  as CTA_PAGO								--No. cuenta
			,PE.Interbancaria as CTA_INTERBANCARIA				--CLABLE Interbancaria
			,B.Descripcion AS Banco
			,isnull(VacProp.DiasDisponibles,0) AS [CH]		--Se puede considerar que el reporte de ADAGIO en cuanto a las vacaciones lo otorgue de manera proporcional (1.5 días, 3.4 días, etc) Para que al momento de aplicar la vacación no se un neativo.
			,'ACTIVO' ESTATUS
			,isnull(m.RequiereChecar,0) as REQUIERE_CHECAR
		from @dtEmpleados m
			inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) 
				on m.IDEmpleado = dfe.IDEmpleado 
					and dfe.IDUsuario = @IDUsuario
			left join RH.tblDireccionEmpleado direccion with (nolock) 
				on direccion.IDEmpleado = M.IDEmpleado
					and direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
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
			left join RH.tblPagoEmpleado PE with (nolock) 
				on PE.IDEmpleado = M.IDEmpleado
				and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			LEFT JOIN Sat.tblCatBancos B with (nolock) 
				on b.idbanco = pe.idbanco
			left join (select CE.*, ROW_NUMBER() OVER (Partition by IDempleado, EsContrato order by FechaIni desc) [ROW] from rh.tblcontratoempleado ce
						 inner join rh.tblcatdocumentos cd
							on cd.IDDocumento = ce.IDDocumento and EsContrato = 1) as CE
				on CE.IDEmpleado = m.IDEmpleado and CE.[ROW] = 1
			left join (select DE.*, ROW_NUMBER() OVER (PARTITION BY IDEmpleado order by FechaIni desc) [ROW]
							from rh.tblDepartamentoEmpleado DE) LastDep
				on LastDep.IDEmpleado = m.IDEmpleado and LastDep.[ROW] = 1
			left join ( select PE.*, ROW_NUMBER() OVER (PARTITION BY IDEmpleado order by FechaIni desc) [ROW]
							from rh.tblPuestoEmpleado PE) LastPos
				on LastPos.IDEmpleado = m.IDEmpleado and LastPos.[ROW] = 1
			left join (
                select *
                from Asistencia.tblVacacionesReporteAPI va
                where isnull(va.Proporcional, 0) = 0
            ) VacNoProp
				on VacNoProp.IDEmpleado = m.IDEmpleado
			left join (
                select *
                from Asistencia.tblVacacionesReporteAPI va
                where isnull(va.Proporcional, 0) = 1
            ) VacProp
				on VacProp.IDEmpleado = m.IDEmpleado
			left join rh.tbldatosextraempleados dee
				on dee.idempleado = m.IDEmpleado and dee.IDDatoExtra = @IDDatoExtraJefeInmediato
		order by M.ClaveEmpleado asc
		
END
GO
