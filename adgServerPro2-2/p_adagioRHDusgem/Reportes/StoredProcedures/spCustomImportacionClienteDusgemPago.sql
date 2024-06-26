USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spCustomImportacionClienteDusgemPago] (
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
			,@Orden Varchar(max)
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

	select @Orden = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
	from @dtFiltros where Catalogo = 'Orden'

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))

	set @Titulo = UPPER( 'TEMPLATE ALTA EMPLEADOS  ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))

	if object_id('tempdb..#tempDatosExtra')	is not null drop table #tempDatosExtra 
	if object_id('tempdb..#tempData')		is not null drop table #tempData
	if object_id('tempdb..#tempSalida')		is not null drop table #tempSalida
	if object_id('tempdb..##tempDatosExtraEmpleados')is not null drop table ##tempDatosExtraEmpleados

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

	DECLARE @cols      AS VARCHAR(MAX),
		    @query1    AS VARCHAR(MAX),
		    @query2    AS VARCHAR(MAX),
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

	IF ( @ClaveEmpleadoInicial <> 0 )
	BEGIN
			insert into @dtEmpleados
			Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@IDUsuario=@IDUsuario
			select 
					'9' + SUBSTRING(m.ClaveEmpleado,2,7)																			as 'CLAVE',
					'DUSGEM PAGAR'																									as 'CLIENTE',
					ISNULL(m.TipoNomina,'')																							as 'TIPO DE NÓMINA',
					isnull(m.Nombre,'')																								as 'PRIMER NOMBRE',
					isnull(m.SegundoNombre,'')																						as 'SEGUNDO NOMBRE',
					isnull(m.Paterno,'')																							as 'PATERNO',
					isnull(m.Materno,'')																							as 'MATERNO',
					isnull(m.RFC,'')																								as 'RFC ',
					isnull(m.CURP,'')																								as 'CURP',
					isnull(m.IMSS,'')																								as 'IMSS',
					case when m.PaisNacimiento = '' THEN 'MEXICO' ELSE isnull(m.PaisNacimiento,'') end 								as 'PAIS NACIMIENTO',
					case when m.EstadoNacimiento = '' THEN 'JALISCO' ELSE isnull(m.EstadoNacimiento,'') end 						as 'ESTADO NACIMIENTO',
					case when m.MunicipioNacimiento = '' THEN 'ZAPOPAN' ELSE isnull(m.MunicipioNacimiento,'') end 					as 'MUNICIPIO NACIMIENTO',
					isnull(m.LocalidadNacimiento,'')																				as 'LOCALIDAD NACIMIENTO',
					isnull ( cast(m.FechaNacimiento as date),'')																    as 'FECHA NACIMIENTO',
					isnull(m.Sexo,'')																								as 'SEXO',
					case when m.EstadoCivil = '' THEN 'SOLTERO (A)' ELSE isnull(m.EstadoCivil,'SOLTERO (A)') end 					as 'ESTADO CIVIL',
					isnull ( convert (varchar ,m.FechaAntiguedad,23),'')															as 'FECHA ANTIGUEDAD',
					isnull ( cast (m.FechaPrimerIngreso as date),'')															    as 'FECHA DE INGRESO',
					isnull(m.TiposPrestacion,'')																					as 'TIPO PRESTACION',
					isnull(m.Empresa,'')																							as 'RAZÓN SOCIAL',
					ISNULL(rp.RegistroPatronal,'')																						as 'REGISTRO PATRONAL',
					isnull(m.Departamento,'')																						as 'DEPARTAMENTO',
					isnull(m.Sucursal,'')																							as 'SUCURSAL',
					isnull(m.Puesto,'')																								as 'PUESTO',
					ISNULL(m.CentroCosto,'')																						as 'CENTRO COSTO',
					ISNULL(m.Area,'')																								as 'AREA',
					ISNULL(m.Region,'')																								as 'REGION',
					ISNULL(m.Division,'')																							as 'DIVISION',
					ISNULL(m.ClasificacionCorporativa,'')												                            as 'CLASIFICACION CORPORATIVA',
					ISNULL(m.JornadaLaboral,'')																						as 'JORNADA LABORAL',
					ISNULL(TT.Descripcion,'')																						as 'TIPO DE TRABAJADOR SUA',
					ISNULL(TC.Descripcion,'')																						as 'TIPO CONTRATO SAT',
					ISNULL(LP.Descripcion,'') 																						as 'LAYOUT PAGO',
					isnull( bancos.descripcion,'')																					as 'BANCO',
					isnull( PE.Interbancaria,'')																					as 'CLABE INTERBANCARIA',
					isnull( PE.cuenta,'')																							as 'NÚMERO DE CUENTA',
					isnull( PE.tarjeta,'')																							as 'NÚMERO TARJETA',
					isnull( PE.IDBancario,'')																						as 'ID BANCARIO',
					isnull( PE.Sucursal,'')																							as 'SUCURSAL BANCARIA',
					isnull( m.SalarioDiario, 0.00 )																		     		as 'SalarioDiario',
					isnull( m.SalarioVariable, 0.00 )																				as 'SalarioVariable',
					isnull( m.SalarioIntegrado, 0.00 )																				as 'SalarioIntegrado',
					isnull( m.SalarioDiarioReal, 0.00 )																		    	as 'SalarioDiarioReal',
					ISNULL(direccion.Calle,'')																						as 'DIRECCION CALLE',
					ISNULL(direccion.Exterior,'')																					as 'DIRECCION INT',
					ISNULL(direccion.Interior,'')																					as 'DIRECCION EXT',
					ISNULL(direccion.Colonia,'')																					as 'DIRECCION COLONIA',
					ISNULL(direccion.Localidad,'')																					as 'DIRECCION LOCALIDAD',
					ISNULL(direccion.Municipio,'')																					as 'DIRECCION MUNICIPIO',
					ISNULL(direccion.Estado,'')																						as 'DIRECCION ESTADO',
					ISNULL(direccion.CodigoPostal,'')																				as 'DIRECCION POSTAL',
					ISNULL(m.Escolaridad,'')																						as 'ESCOLARIDAD',
					ISNULL(m.DescripcionEscolaridad,'')																				as 'DESCRIPCION ESCOLARIDAD',																											
					ISNULL(m.Institucion,'')																						as 'INSTITUCION ESCOLARIDAD',
					ISNULL(m.Probatorio,'')																							as 'DOCUMENTO PROBATORIO ESCOLARIDAD',
					''																												as 'SINDICALIZADO',
					''																												as 'UMF ',
					''																												as 'CUENTA CONTABLE',
					''																												as 'REGIMEN FISCAL',
					ISNULL(m.TipoRegimen,'')																						as 'TIPO REGIMEN FISCAL',
					''       																										as 'EMAIL',
					''																												as 'TELEFONO CASA',
					''																												as 'TELÉFONO MOVIL',
					ISNULL(em.DomicilioFiscal,'')																					as 'CP FISCAL'
			from @dtEmpleados m
				inner join RH.tblEmpleadosMaster Mast with (nolock) on m.IDEmpleado = mast.IDEmpleado
				left join [RH].[tblCatRegPatronal] Rp with (nolock) on mast.IDRegPatronal = Rp.IDRegPatronal
				inner join RH.tblEmpleados em with (nolock) on m.IDEmpleado = em.IDEmpleado
				join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
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
				left join RH.tblInfonavitEmpleado Infonavit with (nolock) on Infonavit.IDEmpleado = m.IDEmpleado
					and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
				left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
				left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
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
				LEFT JOIN RH.tblContactoEmpleado ce 
					on ce.IDEmpleado = m.IDEmpleado 
						and ce.IDTipoContactoEmpleado = (select IDTipoContacto from rh.tblCatTipoContactoEmpleado where Descripcion = 'EMAIL')
				where '9' + SUBSTRING(m.ClaveEmpleado,2,7) not in (select ClaveEmpleado from rh.tblempleados)
				order by 
					CASE WHEN @Orden = 'Clave' THEN m.ClaveEmpleado
						 WHEN @Orden = 'Nombre' THEN m.NOMBRECOMPLETO 
						 ELSE m.ClaveEmpleado
					END
		END

	--	ELSE IF ( @ClaveEmpleadoInicial = 0 )
	--	BEGIN




			if(@IDTipoVigente = 1)
			BEGIN
				insert into @dtEmpleados
				Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario
			
				--saber como HRSJ necesita su información, en el buscar empleados de arriba vienen los trabajadores VIGENTES con las fehcas de ingreso a el reporte
				
				--Si quieren que salgan los trabajadores que ingresaron en las fechas de arriba... Descomentar estas 2 lineas y comentar la de arriba

					--Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

					--delete from @dtEmpleados where FechaAntiguedad not between @FechaIni and @FechaFin


				select 
					'9' + SUBSTRING(m.ClaveEmpleado,2,7)																			as 'CLAVE',
					'DUSGEM PAGAR'																									as 'CLIENTE',
					ISNULL(m.TipoNomina,'')																							as 'TIPO DE NÓMINA',
					isnull(m.Nombre,'')																								as 'PRIMER NOMBRE',
					isnull(m.SegundoNombre,'')																						as 'SEGUNDO NOMBRE',
					isnull(m.Paterno,'')																							as 'PATERNO',
					isnull(m.Materno,'')																							as 'MATERNO',
					isnull(m.RFC,'')																								as 'RFC ',
					isnull(m.CURP,'')																								as 'CURP',
					isnull(m.IMSS,'')																								as 'IMSS',
					case when m.PaisNacimiento = '' THEN 'MEXICO' ELSE isnull(m.PaisNacimiento,'') end 								as 'PAIS NACIMIENTO',
					case when m.EstadoNacimiento = '' THEN 'JALISCO' ELSE isnull(m.EstadoNacimiento,'') end 						as 'ESTADO NACIMIENTO',
					case when m.MunicipioNacimiento = '' THEN 'ZAPOPAN' ELSE isnull(m.MunicipioNacimiento,'') end 					as 'MUNICIPIO NACIMIENTO',
					isnull(m.LocalidadNacimiento,'')																				as 'LOCALIDAD NACIMIENTO',
					isnull ( cast(m.FechaNacimiento as date),'')																    as 'FECHA NACIMIENTO',
					isnull(m.Sexo,'')																								as 'SEXO',
					case when m.EstadoCivil = '' THEN 'SOLTERO (A)' ELSE isnull(m.EstadoCivil,'SOLTERO (A)') end 					as 'ESTADO CIVIL',
					isnull ( convert (varchar ,m.FechaAntiguedad,23),'')															as 'FECHA ANTIGUEDAD',
					isnull ( cast (m.FechaPrimerIngreso as date),'')															    as 'FECHA DE INGRESO',
					isnull(m.TiposPrestacion,'')																					as 'TIPO PRESTACION',
					isnull(m.Empresa,'')																							as 'RAZÓN SOCIAL',
					ISNULL(rp.RegistroPatronal,'')																					as 'REGISTRO PATRONAL',
					isnull(m.Departamento,'')																						as 'DEPARTAMENTO',
					isnull(m.Sucursal,'')																							as 'SUCURSAL',
					isnull(m.Puesto,'')																								as 'PUESTO',
					ISNULL(m.CentroCosto,'')																						as 'CENTRO COSTO',
					ISNULL(m.Area,'')																								as 'AREA',
					ISNULL(m.Region,'')																								as 'REGION',
					ISNULL(m.Division,'')																							as 'DIVISION',
					ISNULL(m.ClasificacionCorporativa,'')												                            as 'CLASIFICACION CORPORATIVA',
					ISNULL(m.JornadaLaboral,'')																						as 'JORNADA LABORAL',
					ISNULL(TT.Descripcion,'')																						as 'TIPO DE TRABAJADOR SUA',
					ISNULL(TC.Descripcion,'')																						as 'TIPO CONTRATO SAT',
					ISNULL(LP.Descripcion,'') 																						as 'LAYOUT PAGO',
					isnull( bancos.descripcion,'')																					as 'BANCO',
					isnull( PE.Interbancaria,'')																					as 'CLABE INTERBANCARIA',
					isnull( PE.cuenta,'')																							as 'NÚMERO DE CUENTA',
					isnull( PE.tarjeta,'')																							as 'NÚMERO TARJETA',
					isnull( PE.IDBancario,'')																						as 'ID BANCARIO',
					isnull( PE.Sucursal,'')																							as 'SUCURSAL BANCARIA',
					isnull( m.SalarioDiario, 0.00 )																		     		as 'SalarioDiario',
					isnull( m.SalarioVariable, 0.00 )																				as 'SalarioVariable',
					isnull( m.SalarioIntegrado, 0.00 )																				as 'SalarioIntegrado',
					isnull( m.SalarioDiarioReal, 0.00 )																		    	as 'SalarioDiarioReal',
					ISNULL(direccion.Calle,'')																						as 'DIRECCION CALLE',
					ISNULL(direccion.Exterior,'')																					as 'DIRECCION INT',
					ISNULL(direccion.Interior,'')																					as 'DIRECCION EXT',
					ISNULL(direccion.Colonia,'')																					as 'DIRECCION COLONIA',
					ISNULL(direccion.Localidad,'')																					as 'DIRECCION LOCALIDAD',
					ISNULL(direccion.Municipio,'')																					as 'DIRECCION MUNICIPIO',
					ISNULL(direccion.Estado,'')																						as 'DIRECCION ESTADO',
					ISNULL(direccion.CodigoPostal,'')																				as 'DIRECCION POSTAL',
					ISNULL(m.Escolaridad,'')																						as 'ESCOLARIDAD',
					ISNULL(m.DescripcionEscolaridad,'')																				as 'DESCRIPCION ESCOLARIDAD',																											
					ISNULL(m.Institucion,'')																						as 'INSTITUCION ESCOLARIDAD',
					ISNULL(m.Probatorio,'')																							as 'DOCUMENTO PROBATORIO ESCOLARIDAD',
					''																												as 'SINDICALIZADO',
					''																												as 'UMF ',
					''																												as 'CUENTA CONTABLE',
					''																												as 'REGIMEN FISCAL',
					ISNULL(m.TipoRegimen,'')																						as 'TIPO REGIMEN FISCAL',
					''       																										as 'EMAIL',
					''																												as 'TELEFONO CASA',
					''																												as 'TELÉFONO MOVIL',
					ISNULL(em.DomicilioFiscal,'')																					as 'CP FISCAL'
					
				from @dtEmpleados m
				inner join RH.tblEmpleadosMaster Mast with (nolock) on m.IDEmpleado = mast.IDEmpleado
				left join [RH].[tblCatRegPatronal] Rp with (nolock) on mast.IDRegPatronal = Rp.IDRegPatronal
				inner join RH.tblEmpleados em with (nolock) on m.IDEmpleado = em.IDEmpleado
				join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
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
				left join RH.tblInfonavitEmpleado Infonavit with (nolock) on Infonavit.IDEmpleado = m.IDEmpleado
					and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
				left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
				left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
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
				LEFT JOIN RH.tblContactoEmpleado ce 
					on ce.IDEmpleado = m.IDEmpleado 
						and ce.IDTipoContactoEmpleado = (select IDTipoContacto from rh.tblCatTipoContactoEmpleado where Descripcion = 'EMAIL')
				where '9' + SUBSTRING(m.ClaveEmpleado,2,7) not in (select ClaveEmpleado from rh.tblempleados)
				order by 
					CASE WHEN @Orden = 'Clave' THEN m.ClaveEmpleado
						 WHEN @Orden = 'Nombre' THEN m.NOMBRECOMPLETO 
						 ELSE m.ClaveEmpleado
					END
					
			END
			ELSE IF(@IDTipoVigente = 2)
			BEGIN
				insert into @dtEmpleados
				exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario
		
				select 
					'9' + SUBSTRING(m.ClaveEmpleado,2,7)																			as 'CLAVE',
					'DUSGEM PAGAR'																									as 'CLIENTE',
					ISNULL(m.TipoNomina,'')																							as 'TIPO DE NÓMINA',
					isnull(m.Nombre,'')																								as 'PRIMER NOMBRE',
					isnull(m.SegundoNombre,'')																						as 'SEGUNDO NOMBRE',
					isnull(m.Paterno,'')																							as 'PATERNO',
					isnull(m.Materno,'')																							as 'MATERNO',
					isnull(m.RFC,'')																								as 'RFC ',
					isnull(m.CURP,'')																								as 'CURP',
					isnull(m.IMSS,'')																								as 'IMSS',
					case when m.PaisNacimiento = '' THEN 'MEXICO' ELSE isnull(m.PaisNacimiento,'') end 								as 'PAIS NACIMIENTO',
					case when m.EstadoNacimiento = '' THEN 'JALISCO' ELSE isnull(m.EstadoNacimiento,'') end 						as 'ESTADO NACIMIENTO',
					case when m.MunicipioNacimiento = '' THEN 'ZAPOPAN' ELSE isnull(m.MunicipioNacimiento,'') end 					as 'MUNICIPIO NACIMIENTO',
					isnull(m.LocalidadNacimiento,'')																				as 'LOCALIDAD NACIMIENTO',
					isnull ( cast(m.FechaNacimiento as date),'')																    as 'FECHA NACIMIENTO',
					isnull(m.Sexo,'')																								as 'SEXO',
					case when m.EstadoCivil = '' THEN 'SOLTERO (A)' ELSE isnull(m.EstadoCivil,'SOLTERO (A)') end 					as 'ESTADO CIVIL',
					isnull ( convert (varchar ,m.FechaAntiguedad,23),'')															as 'FECHA ANTIGUEDAD',
					isnull ( cast (m.FechaPrimerIngreso as date),'')															    as 'FECHA DE INGRESO',
					isnull(m.TiposPrestacion,'')																					as 'TIPO PRESTACION',
					isnull(m.Empresa,'')																							as 'RAZÓN SOCIAL',
					ISNULL(rp.RegistroPatronal,'')																					as 'REGISTRO PATRONAL',
					isnull(m.Departamento,'')																						as 'DEPARTAMENTO',
					isnull(m.Sucursal,'')																							as 'SUCURSAL',
					isnull(m.Puesto,'')																								as 'PUESTO',
					ISNULL(m.CentroCosto,'')																						as 'CENTRO COSTO',
					ISNULL(m.Area,'')																								as 'AREA',
					ISNULL(m.Region,'')																								as 'REGION',
					ISNULL(m.Division,'')																							as 'DIVISION',
					ISNULL(m.ClasificacionCorporativa,'')												                            as 'CLASIFICACION CORPORATIVA',
					ISNULL(m.JornadaLaboral,'')																						as 'JORNADA LABORAL',
					ISNULL(TT.Descripcion,'')																						as 'TIPO DE TRABAJADOR SUA',
					ISNULL(TC.Descripcion,'')																						as 'TIPO CONTRATO SAT',
					ISNULL(LP.Descripcion,'') 																						as 'LAYOUT PAGO',
					isnull( bancos.descripcion,'')																					as 'BANCO',
					isnull( PE.Interbancaria,'')																					as 'CLABE INTERBANCARIA',
					isnull( PE.cuenta,'')																							as 'NÚMERO DE CUENTA',
					isnull( PE.tarjeta,'')																							as 'NÚMERO TARJETA',
					isnull( PE.IDBancario,'')																						as 'ID BANCARIO',
					isnull( PE.Sucursal,'')																							as 'SUCURSAL BANCARIA',
					isnull( m.SalarioDiario, 0.00 )																		     		as 'SalarioDiario',
					isnull( m.SalarioVariable, 0.00 )																				as 'SalarioVariable',
					isnull( m.SalarioIntegrado, 0.00 )																				as 'SalarioIntegrado',
					isnull( m.SalarioDiarioReal, 0.00 )																		    	as 'SalarioDiarioReal',
					ISNULL(direccion.Calle,'')																						as 'DIRECCION CALLE',
					ISNULL(direccion.Exterior,'')																					as 'DIRECCION INT',
					ISNULL(direccion.Interior,'')																					as 'DIRECCION EXT',
					ISNULL(direccion.Colonia,'')																					as 'DIRECCION COLONIA',
					ISNULL(direccion.Localidad,'')																					as 'DIRECCION LOCALIDAD',
					ISNULL(direccion.Municipio,'')																					as 'DIRECCION MUNICIPIO',
					ISNULL(direccion.Estado,'')																						as 'DIRECCION ESTADO',
					ISNULL(direccion.CodigoPostal,'')																				as 'DIRECCION POSTAL',
					ISNULL(m.Escolaridad,'')																						as 'ESCOLARIDAD',
					ISNULL(m.DescripcionEscolaridad,'')																				as 'DESCRIPCION ESCOLARIDAD',																											
					ISNULL(m.Institucion,'')																						as 'INSTITUCION ESCOLARIDAD',
					ISNULL(m.Probatorio,'')																							as 'DOCUMENTO PROBATORIO ESCOLARIDAD',
					''																												as 'SINDICALIZADO',
					''																												as 'UMF ',
					''																												as 'CUENTA CONTABLE',
					''																												as 'REGIMEN FISCAL',
					ISNULL(m.TipoRegimen,'')																						as 'TIPO REGIMEN FISCAL',
					''       																										as 'EMAIL',
					''																												as 'TELEFONO CASA',
					''																												as 'TELÉFONO MOVIL',
					ISNULL(em.DomicilioFiscal,'')																					as 'CP FISCAL'
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
					left join RH.tblInfonavitEmpleado Infonavit with (nolock) on Infonavit.IDEmpleado = m.IDEmpleado
						and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
					left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
					left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
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
					left join [RH].[tblCatRegPatronal] Rp with (nolock) on m.IDRegPatronal = Rp.IDRegPatronal
					LEFT JOIN RH.tblContactoEmpleado ce 
						on ce.IDEmpleado = m.IDEmpleado 
							and ce.IDTipoContactoEmpleado = (select IDTipoContacto from rh.tblCatTipoContactoEmpleado where Descripcion = 'EMAIL')
				Where e.IDEmpleado is null ---- El IDEMPLEADO NULL son los NO vigentes 
					and '9' + SUBSTRING(m.ClaveEmpleado,2,7) not in (select ClaveEmpleado from rh.tblempleados) and
				( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
					or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
				   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
				   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
				   and  ((M.IDCentroCosto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),','))             
				     or (Not exists(Select 1 from @dtFiltros where Catalogo = 'CentrosCostos' and isnull(Value,'')<>''))))
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
				  -- and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
					 --or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
				   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
				 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))   
				and ((M.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
				   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))       
				 and ((M.IDRegion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Regiones'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Regiones' and isnull(Value,'')<>''))) 
				 and ((M.IDArea in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Areas' and isnull(Value,'')<>''))) 
				   and ((            
					((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
						) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by 
					CASE WHEN @Orden = 'Clave' THEN m.ClaveEmpleado
						 WHEN @Orden = 'Nombre' THEN m.NOMBRECOMPLETO 
						 ELSE m.ClaveEmpleado
					END
			
			END ELSE IF(@IDTipoVigente = 3)
			BEGIN
				select 
					'9' + SUBSTRING(m.ClaveEmpleado,2,7)																			as 'CLAVE',
					'DUSGEM PAGAR'																									as 'CLIENTE',
					ISNULL(m.TipoNomina,'')																							as 'TIPO DE NÓMINA',
					isnull(m.Nombre,'')																								as 'PRIMER NOMBRE',
					isnull(m.SegundoNombre,'')																						as 'SEGUNDO NOMBRE',
					isnull(m.Paterno,'')																							as 'PATERNO',
					isnull(m.Materno,'')																							as 'MATERNO',
					isnull(m.RFC,'')																								as 'RFC ',
					isnull(m.CURP,'')																								as 'CURP',
					isnull(m.IMSS,'')																								as 'IMSS',
					case when m.PaisNacimiento = '' THEN 'MEXICO' ELSE isnull(m.PaisNacimiento,'') end 								as 'PAIS NACIMIENTO',
					case when m.EstadoNacimiento = '' THEN 'JALISCO' ELSE isnull(m.EstadoNacimiento,'') end 						as 'ESTADO NACIMIENTO',
					case when m.MunicipioNacimiento = '' THEN 'ZAPOPAN' ELSE isnull(m.MunicipioNacimiento,'') end 					as 'MUNICIPIO NACIMIENTO',
					isnull(m.LocalidadNacimiento,'')																				as 'LOCALIDAD NACIMIENTO',
					isnull ( cast(m.FechaNacimiento as date),'')																    as 'FECHA NACIMIENTO',
					isnull(m.Sexo,'')																								as 'SEXO',
					case when m.EstadoCivil = '' THEN 'SOLTERO (A)' ELSE isnull(m.EstadoCivil,'SOLTERO (A)') end 					as 'ESTADO CIVIL',
					isnull ( convert (varchar ,m.FechaAntiguedad,23),'')															as 'FECHA ANTIGUEDAD',
					isnull ( cast (m.FechaPrimerIngreso as date),'')															    as 'FECHA DE INGRESO',
					isnull(m.TiposPrestacion,'')																					as 'TIPO PRESTACION',
					isnull(m.Empresa,'')																							as 'RAZÓN SOCIAL',
					ISNULL(rp.RegistroPatronal,'')																					as 'REGISTRO PATRONAL',
					isnull(m.Departamento,'')																						as 'DEPARTAMENTO',
					isnull(m.Sucursal,'')																							as 'SUCURSAL',
					isnull(m.Puesto,'')																								as 'PUESTO',
					ISNULL(m.CentroCosto,'')																						as 'CENTRO COSTO',
					ISNULL(m.Area,'')																								as 'AREA',
					ISNULL(m.Region,'')																								as 'REGION',
					ISNULL(m.Division,'')																							as 'DIVISION',
					ISNULL(m.ClasificacionCorporativa,'')												                            as 'CLASIFICACION CORPORATIVA',
					ISNULL(m.JornadaLaboral,'')																						as 'JORNADA LABORAL',
					ISNULL(TT.Descripcion,'')																						as 'TIPO DE TRABAJADOR SUA',
					ISNULL(TC.Descripcion,'')																						as 'TIPO CONTRATO SAT',
					ISNULL(LP.Descripcion,'') 																						as 'LAYOUT PAGO',
					isnull( bancos.descripcion,'')																					as 'BANCO',
					isnull( PE.Interbancaria,'')																					as 'CLABE INTERBANCARIA',
					isnull( PE.cuenta,'')																							as 'NÚMERO DE CUENTA',
					isnull( PE.tarjeta,'')																							as 'NÚMERO TARJETA',
					isnull( PE.IDBancario,'')																						as 'ID BANCARIO',
					isnull( PE.Sucursal,'')																							as 'SUCURSAL BANCARIA',
					isnull( m.SalarioDiario, 0.00 )																		     		as 'SalarioDiario',
					isnull( m.SalarioVariable, 0.00 )																				as 'SalarioVariable',
					isnull( m.SalarioIntegrado, 0.00 )																				as 'SalarioIntegrado',
					isnull( m.SalarioDiarioReal, 0.00 )																		    	as 'SalarioDiarioReal',
					ISNULL(direccion.Calle,'')																						as 'DIRECCION CALLE',
					ISNULL(direccion.Exterior,'')																					as 'DIRECCION INT',
					ISNULL(direccion.Interior,'')																					as 'DIRECCION EXT',
					ISNULL(direccion.Colonia,'')																					as 'DIRECCION COLONIA',
					ISNULL(direccion.Localidad,'')																					as 'DIRECCION LOCALIDAD',
					ISNULL(direccion.Municipio,'')																					as 'DIRECCION MUNICIPIO',
					ISNULL(direccion.Estado,'')																						as 'DIRECCION ESTADO',
					ISNULL(direccion.CodigoPostal,'')																				as 'DIRECCION POSTAL',
					ISNULL(m.Escolaridad,'')																						as 'ESCOLARIDAD',
					ISNULL(m.DescripcionEscolaridad,'')																				as 'DESCRIPCION ESCOLARIDAD',																											
					ISNULL(m.Institucion,'')																						as 'INSTITUCION ESCOLARIDAD',
					ISNULL(m.Probatorio,'')																							as 'DOCUMENTO PROBATORIO ESCOLARIDAD',
					''																												as 'SINDICALIZADO',
					''																												as 'UMF ',
					''																												as 'CUENTA CONTABLE',
					''																												as 'REGIMEN FISCAL',
					ISNULL(m.TipoRegimen,'')																						as 'TIPO REGIMEN FISCAL',
					''       																										as 'EMAIL',
					''																												as 'TELEFONO CASA',
					''																												as 'TELÉFONO MOVIL',
					ISNULL(em.DomicilioFiscal,'')																					as 'CP FISCAL'
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
					left join RH.tblInfonavitEmpleado Infonavit with (nolock) on Infonavit.IDEmpleado = m.IDEmpleado
						and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
					left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
					left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
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
					left join [RH].[tblCatRegPatronal] Rp with (nolock) on m.IDRegPatronal = Rp.IDRegPatronal
					LEFT JOIN RH.tblContactoEmpleado ce 
						on ce.IDEmpleado = m.IDEmpleado 
							and ce.IDTipoContactoEmpleado = (select IDTipoContacto from rh.tblCatTipoContactoEmpleado where Descripcion = 'EMAIL')
				Where '9' + SUBSTRING(m.ClaveEmpleado,2,7) not in (select ClaveEmpleado from rh.tblempleados) and
				( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
					or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
				   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
				     or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
				   and  ((M.IDCentroCosto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),','))             
				     or (Not exists(Select 1 from @dtFiltros where Catalogo = 'CentrosCostos' and isnull(Value,'')<>''))))
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
				  -- and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
					 --or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
				   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
				 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>''))) 
				 and ((M.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
				   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))  
				 and ((M.IDRegion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Regiones'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Regiones' and isnull(Value,'')<>''))) 
				 and ((M.IDArea in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Areas' and isnull(Value,'')<>''))) 
				   and ((            
					((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
						) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by 
					CASE WHEN @Orden = 'Clave' THEN m.ClaveEmpleado
						 WHEN @Orden = 'Nombre' THEN m.NOMBRECOMPLETO 
						 ELSE m.ClaveEmpleado
					END
			END
		END
	--END
GO
