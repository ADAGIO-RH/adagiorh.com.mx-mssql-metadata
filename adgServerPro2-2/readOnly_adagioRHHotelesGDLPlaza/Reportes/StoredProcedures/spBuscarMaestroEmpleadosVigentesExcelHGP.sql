USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	NO MOVER SP
	IMPORTANTE
	NO MOVER
	ARTURO
*/

CREATE procedure [Reportes].[spBuscarMaestroEmpleadosVigentesExcelHGP] (
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
	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select 
			 m.ClaveEmpleado as CLAVE
			,m.Paterno AS PATERNO
			,m.Materno AS MATERNO
			,CASE WHEN ( m.SegundoNombre = '' ) OR ( m.SegundoNombre IS NULL ) THEN m.Nombre ELSE CONCAT( m.Nombre , ' ', m.SegundoNombre) END AS  [Nombres]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
			,FORMAT(m.FechaIngreso,'dd/MM/yyyy') as [FECHA INGRESO]
			,m.Puesto AS PUESTO
			,m.Departamento AS DEPARTAMENTO
			,m.Sucursal AS SUCURSAL
			,[Ultimo Movimiento] = (select top 1 ctm.Codigo 
										from IMSS.tblMovAfiliatorios mov with (nolock)  
											join IMSS.tblCatTipoMovimientos ctm with (nolock)  
												on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
													where mov.IDEmpleado = m.IDEmpleado
									order by mov.Fecha desc ) 
			,[Fecha Ultimo Movimiento] = FORMAT ( 
											(select top 1 mov.Fecha 
												from IMSS.tblMovAfiliatorios mov with (nolock)  
													join IMSS.tblCatTipoMovimientos ctm with (nolock)  
														on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
												where mov.IDEmpleado = m.IDEmpleado
											order by mov.Fecha desc ) ,'dd/MM/yyyy')
			,m.SalarioDiario AS [SALARIO DIARIO]
			,m.SalarioVariable AS [SALARIO VARIABLE]
			,m.SalarioIntegrado AS [SALARIO INTEGRADO]
			,CTP.Codigo as [CLAVE FACTOR]
			,M.TiposPrestacion AS [DESCRIPCION FACTOR]
			,CASE WHEN CTP.Sindical = 1 THEN 'SINDICAL' ELSE 'CONFIANZA' END AS [TIPO DE FACTOR]
			,DATEDIFF (YEAR , M.FechaAntiguedad , GETDATE ())  AS [ANTIGUEDAD]
			,tpd.DiasVacaciones AS [DIAS DE VACACIONES]
			,m.RFC AS [RFC ]
			,m.CURP AS CURP
			,m.IMSS AS IMSS
			,M.UMF AS [UMF ]
			,M.tipoTrabajadorEmpleado AS [PERMANENTE/EVENTUAL]
			,Infonavit.NumeroCredito as [NUM CREDITO INFONAVIT]
			,FORMAT(Infonavit.Fecha,'dd/MM/yyyy') as [FECHA OTORGAMIENTO INFONAVIT]
			,Infonavit.ValorDescuento AS [VALOR DESCUENTO INFONAVIT]
			,InfonavitTipoDescuento.Descripcion AS [TIPO DESCUENTO INFONAVIT]
			,Infonavit.ValorDescuento AS [VALOR DESCUENTO (REPETIDO)]
			,M.TipoNomina as [TIPO NOMINA]
			,M.JornadaLaboral as [TURNO]
			,CASE WHEN ( PE.Cuenta = '' ) OR ( PE.Cuenta IS NULL ) THEN 'CHEQUE' ELSE 'TARJETA' END AS [TIPO PAGO]
			,PE.Cuenta AS [CUENTA BANCARIA]
			,substring(UPPER(COALESCE(direccion.calle,'')),1,49) as DIRECCION
			,substring(UPPER(COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as NUMERO
			,substring(UPPER(COALESCE(direccion.Colonia,'')),1,49) as COLONIA
			,substring(UPPER(COALESCE(direccion.CodigoPostal,'')),1,49) as CODIGOPOSTAL
			,substring(UPPER(COALESCE(direccion.Localidad,'')),1,49) as POBLACION
			,substring(UPPER(COALESCE(direccion.Municipio,'')),1,49) as MUNICIPIO
			,substring(UPPER(COALESCE(direccion.Estado,'')),1,49) as ESTADO
			,(select top 1 value from RH.tblContactoEmpleado where IDEmpleado = M.IDEmpleado and IDTipoContactoEmpleado = 2)  as [TELEFONO1]
			,(select top 1 value from RH.tblContactoEmpleado where IDEmpleado = M.IDEmpleado and IDTipoContactoEmpleado = 3)  as [TELEFONO2]
			,(select top 1 value from RH.tblContactoEmpleado where IDEmpleado = M.IDEmpleado and IDTipoContactoEmpleado = 4)  as [TELEFONO3]
			,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
			,M.MunicipioNacimiento AS [LUGAR NACIMIENTO]
			,M.Sexo as [SEXO]
			,M.EstadoCivil as [ESTADO CIVIL]
			,M.DescripcionEscolaridad AS [DESCIPCION ESCOLARIDAD]
			,M.Sucursal AS [NOTA]
			,'MEXICANA' AS NACIONALIDAD
			,Extras.Valor as [TARJETA VALES]
		
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
			left join RH.tblCatTiposPrestaciones CTP with (nolock) 
				on CTP.IDTipoPrestacion = M.IDTipoPrestacion
			--left join RH.tblContactoEmpleado CTC with (nolock) 
			--	on CTC.IDEmpleado = M.IDEmpleado and CTC.IDTipoContactoEmpleado = 4
			--left join RH.tblContactoEmpleado CTC2 with (nolock) 
			--	on CTC.IDEmpleado = M.IDEmpleado and CTC2.IDTipoContactoEmpleado = 3
			--left join RH.tblContactoEmpleado CTC3 with (nolock) 
			--	on CTC.IDEmpleado = M.IDEmpleado and CTC3.IDTipoContactoEmpleado = 2
			left join [RH].[tblDatosExtraEmpleados] Extras
				on Extras.IDEmpleado = M.idEmpleado and Extras.IDDatoExtra = 1
			left join RH.tblCatTiposPrestacionesDetalle tpd
				on m.IDTipoPrestacion = tpd.IDTipoPrestacion
				and DATEDIFF(YEAR, m.FechaAntiguedad,getdate()) +1 = tpd.Antiguedad
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
		
		select 
			 m.ClaveEmpleado as CLAVE
			,m.Paterno AS PATERNO
			,m.Materno AS MATERNO
			,CASE WHEN ( m.SegundoNombre = '' ) OR ( m.SegundoNombre IS NULL ) THEN m.Nombre ELSE CONCAT( m.Nombre , ' ', m.SegundoNombre) END AS  [Nombres]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
			,FORMAT(m.FechaIngreso,'dd/MM/yyyy') as [FECHA INGRESO]
			,m.Puesto AS PUESTO
			,m.Departamento AS DEPARTAMENTO
			,m.Sucursal AS SUCURSAL
			,[Ultimo Movimiento] = (select top 1 ctm.Codigo 
										from IMSS.tblMovAfiliatorios mov with (nolock)  
											join IMSS.tblCatTipoMovimientos ctm with (nolock)  
												on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
													where mov.IDEmpleado = m.IDEmpleado
									order by mov.Fecha desc ) 
			,[Fecha Ultimo Movimiento] = FORMAT ( 
											(select top 1 mov.Fecha 
												from IMSS.tblMovAfiliatorios mov with (nolock)  
													join IMSS.tblCatTipoMovimientos ctm with (nolock)  
														on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
												where mov.IDEmpleado = m.IDEmpleado
											order by mov.Fecha desc ) ,'dd/MM/yyyy')
			,m.SalarioDiario AS [SALARIO DIARIO]
			,m.SalarioVariable AS [SALARIO VARIABLE]
			,m.SalarioIntegrado AS [SALARIO INTEGRADO]
			,CTP.Codigo as [CLAVE FACTOR]
			,M.TiposPrestacion AS [DESCRIPCION FACTOR]
			,CASE WHEN CTP.Sindical = 1 THEN 'SINDICAL' ELSE 'CONFIANZA' END AS [TIPO DE FACTOR]
			,DATEDIFF (YEAR , M.FechaAntiguedad , GETDATE ()) + 1 AS [ANTIGUEDAD]
			,25 AS [DIAS DE VACACIONES]
			,m.RFC AS [RFC ]
			,m.CURP AS CURP
			,m.IMSS AS IMSS
			,M.UMF AS [UMF ]
			,M.tipoTrabajadorEmpleado AS [PERMANENTE/EVENTUAL]
			,Infonavit.NumeroCredito as [NUM CREDITO INFONAVIT]
			,FORMAT(Infonavit.Fecha,'dd/MM/yyyy') as [FECHA OTORGAMIENTO INFONAVIT]
			,Infonavit.ValorDescuento AS [VALOR DESCUENTO INFONAVIT]
			,InfonavitTipoDescuento.Descripcion AS [TIPO DESCUENTO INFONAVIT]
			,Infonavit.ValorDescuento AS [VALOR DESCUENTO (REPETIDO)]
			,M.TipoNomina as [TIPO NOMINA]
			,M.JornadaLaboral as [TURNO]
			,CASE WHEN ( PE.Cuenta = '' ) OR ( PE.Cuenta IS NULL ) THEN 'CHEQUE' ELSE 'TARJETA' END AS [TIPO PAGO]
			,PE.Cuenta AS [CUENTA BANCARIA]
			,substring(UPPER(COALESCE(direccion.calle,'')),1,49) as DIRECCION
			,substring(UPPER(COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as NUMERO
			,substring(UPPER(COALESCE(direccion.Colonia,'')),1,49) as COLONIA
			,substring(UPPER(COALESCE(direccion.CodigoPostal,'')),1,49) as CODIGOPOSTAL
			,substring(UPPER(COALESCE(direccion.Localidad,'')),1,49) as POBLACION
			,substring(UPPER(COALESCE(direccion.Municipio,'')),1,49) as MUNICIPIO
			,substring(UPPER(COALESCE(direccion.Estado,'')),1,49) as ESTADO
			,(select top 1 value from RH.tblContactoEmpleado where IDEmpleado = M.IDEmpleado and IDTipoContactoEmpleado = 2)  as [TELEFONO1]
			,(select top 1 value from RH.tblContactoEmpleado where IDEmpleado = M.IDEmpleado and IDTipoContactoEmpleado = 3)  as [TELEFONO2]
			,(select top 1 value from RH.tblContactoEmpleado where IDEmpleado = M.IDEmpleado and IDTipoContactoEmpleado = 4)  as [TELEFONO3]
			--,substring(UPPER(COALESCE(CTC2.[Value],'')),1,49) as [TELEFONO2]
			--,substring(UPPER(COALESCE(CTC3.[Value],'')),1,49) as [TELEFONO3]
			,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
			,M.MunicipioNacimiento AS [LUGAR NACIMIENTO]
			,M.Sexo as [SEXO]
			,M.EstadoCivil as [ESTADO CIVIL]
			,M.DescripcionEscolaridad AS [DESCIPCION ESCOLARIDAD]
			,M.Sucursal AS [NOTA]
			,'MEXICANA' AS NACIONALIDAD
			,Extras.Valor as [TARJETA VALES]
		
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
			left join RH.tblCatTiposPrestaciones CTP with (nolock) 
				on CTP.IDTipoPrestacion = M.IDTipoPrestacion
			--left join RH.tblContactoEmpleado CTC with (nolock) 
			--	on CTC.IDEmpleado = M.IDEmpleado and CTC.IDTipoContactoEmpleado = 4
			--left join RH.tblContactoEmpleado CTC2 with (nolock) 
			--	on CTC.IDEmpleado = M.IDEmpleado and CTC2.IDTipoContactoEmpleado = 3
			--left join RH.tblContactoEmpleado CTC3 with (nolock) 
			--	on CTC.IDEmpleado = M.IDEmpleado and CTC3.IDTipoContactoEmpleado = 2
			left join [RH].[tblDatosExtraEmpleados] Extras
				on Extras.IDEmpleado = M.idEmpleado and Extras.IDDatoExtra = 1
		Where 
		m.Vigente=0 and
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
			 m.ClaveEmpleado as CLAVE
			,m.Paterno AS PATERNO
			,m.Materno AS MATERNO
			,CASE WHEN ( m.SegundoNombre = '' ) OR ( m.SegundoNombre IS NULL ) THEN m.Nombre ELSE CONCAT( m.Nombre , ' ', m.SegundoNombre) END AS  [Nombres]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
			,FORMAT(m.FechaIngreso,'dd/MM/yyyy') as [FECHA INGRESO]
			,m.Puesto AS PUESTO
			,m.Departamento AS DEPARTAMENTO
			,m.Sucursal AS SUCURSAL
			,[Ultimo Movimiento] = (select top 1 ctm.Codigo 
										from IMSS.tblMovAfiliatorios mov with (nolock)  
											join IMSS.tblCatTipoMovimientos ctm with (nolock)  
												on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
													where mov.IDEmpleado = m.IDEmpleado
									order by mov.Fecha desc ) 
			,[Fecha Ultimo Movimiento] = FORMAT ( 
											(select top 1 mov.Fecha 
												from IMSS.tblMovAfiliatorios mov with (nolock)  
													join IMSS.tblCatTipoMovimientos ctm with (nolock)  
														on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
												where mov.IDEmpleado = m.IDEmpleado
											order by mov.Fecha desc ) ,'dd/MM/yyyy')
			,m.SalarioDiario AS [SALARIO DIARIO]
			,m.SalarioVariable AS [SALARIO VARIABLE]
			,m.SalarioIntegrado AS [SALARIO INTEGRADO]
			,CTP.Codigo as [CLAVE FACTOR]
			,M.TiposPrestacion AS [DESCRIPCION FACTOR]
			,CASE WHEN CTP.Sindical = 1 THEN 'SINDICAL' ELSE 'CONFIANZA' END AS [TIPO DE FACTOR]
			,DATEDIFF (YEAR , M.FechaAntiguedad , GETDATE ()) + 1 AS [ANTIGUEDAD]
			,25 AS [DIAS DE VACACIONES]
			,m.RFC AS [RFC ]
			,m.CURP AS CURP
			,m.IMSS AS IMSS
			,M.UMF AS [UMF ]
			,M.tipoTrabajadorEmpleado AS [PERMANENTE/EVENTUAL]
			,Infonavit.NumeroCredito as [NUM CREDITO INFONAVIT]
			,FORMAT(Infonavit.Fecha,'dd/MM/yyyy') as [FECHA OTORGAMIENTO INFONAVIT]
			,Infonavit.ValorDescuento AS [VALOR DESCUENTO INFONAVIT]
			,InfonavitTipoDescuento.Descripcion AS [TIPO DESCUENTO INFONAVIT]
			,Infonavit.ValorDescuento AS [VALOR DESCUENTO (REPETIDO)]
			,M.TipoNomina as [TIPO NOMINA]
			,M.JornadaLaboral as [TURNO]
			,CASE WHEN ( PE.Cuenta = '' ) OR ( PE.Cuenta IS NULL ) THEN 'CHEQUE' ELSE 'TARJETA' END AS [TIPO PAGO]
			,PE.Cuenta AS [CUENTA BANCARIA]
			,substring(UPPER(COALESCE(direccion.calle,'')),1,49) as DIRECCION
			,substring(UPPER(COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as NUMERO
			,substring(UPPER(COALESCE(direccion.Colonia,'')),1,49) as COLONIA
			,substring(UPPER(COALESCE(direccion.CodigoPostal,'')),1,49) as CODIGOPOSTAL
			,substring(UPPER(COALESCE(direccion.Localidad,'')),1,49) as POBLACION
			,substring(UPPER(COALESCE(direccion.Municipio,'')),1,49) as MUNICIPIO
			,substring(UPPER(COALESCE(direccion.Estado,'')),1,49) as ESTADO
			,(select top 1 value from RH.tblContactoEmpleado where IDEmpleado = M.IDEmpleado and IDTipoContactoEmpleado = 2)  as [TELEFONO1]
			,(select top 1 value from RH.tblContactoEmpleado where IDEmpleado = M.IDEmpleado and IDTipoContactoEmpleado = 3)  as [TELEFONO2]
			,(select top 1 value from RH.tblContactoEmpleado where IDEmpleado = M.IDEmpleado and IDTipoContactoEmpleado = 4)  as [TELEFONO3]
			--,substring(UPPER(COALESCE(CTC2.[Value],'')),1,49) as [TELEFONO2]
			--,substring(UPPER(COALESCE(CTC3.[Value],'')),1,49) as [TELEFONO3]
			,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
			,M.MunicipioNacimiento AS [LUGAR NACIMIENTO]
			,M.Sexo as [SEXO]
			,M.EstadoCivil as [ESTADO CIVIL]
			,M.DescripcionEscolaridad AS [DESCIPCION ESCOLARIDAD]
			,M.Sucursal AS [NOTA]
			,'MEXICANA' AS NACIONALIDAD
			,Extras.Valor as [TARJETA VALES]
		
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
			left join RH.tblCatTiposPrestaciones CTP with (nolock) 
				on CTP.IDTipoPrestacion = M.IDTipoPrestacion
			--left join RH.tblContactoEmpleado CTC with (nolock) 
			--	on CTC.IDEmpleado = M.IDEmpleado and CTC.IDTipoContactoEmpleado = 4
			--left join RH.tblContactoEmpleado CTC2 with (nolock) 
			--	on CTC.IDEmpleado = M.IDEmpleado and CTC2.IDTipoContactoEmpleado = 3
			--left join RH.tblContactoEmpleado CTC3 with (nolock) 
			--	on CTC.IDEmpleado = M.IDEmpleado and CTC3.IDTipoContactoEmpleado = 2
			left join [RH].[tblDatosExtraEmpleados] Extras
				on Extras.IDEmpleado = M.idEmpleado and Extras.IDDatoExtra = 1
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
