USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spDatosPersonalesColaborador] (
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

	Declare 
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) 
			,@FechaIni date 
			,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)


	select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaIni'
	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaFin'
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))


	if object_id('tempdb..#tempDatosExtraEmpleados')is not null drop table #tempDatosExtraEmpleados

	select cde.Nombre, cde.Descripcion, cde.TipoDato, dee.*
	into #tempDatosExtraEmpleados
	from RH.tblDatosExtraEmpleados dee with(nolock)
		inner join RH.tblCatDatosExtra cde with(nolock)
			on dee.IDDatoExtra = cde.IDDatoExtra

	if object_id('tempdb..#tempContactoEmpleado')is not null drop table #tempContactoEmpleado

	SELECT ROW_NUMBER() over (PARTition by CE.IDTipoContactoEmpleado order by ce.idempleado) as RN, ce.idempleado, ce.value, ce.predeterminado,  ce.idtipocontactoempleado, tce.descripcion 
	into #tempContactoEmpleado
	from rh.tblcontactoempleado CE
		inner join rh.tblcattipocontactoempleado TCE
			ON CE.IDTipoContactoEmpleado = TCE.idtipoContacto

	if object_id('tempdb..#tempParentesco')is not null drop table #tempParentesco

	select cp.Descripcion, beneficiario.* 
	into #tempParentesco
	from rh.TblFamiliaresBenificiariosEmpleados beneficiario
		inner join rh.TblCatParentescos cp
		on beneficiario.IDParentesco = cp.IDParentesco

		if object_id('tempdb..##tempDatosExtraEmpleados')is not null drop table ##tempDatosExtraEmpleados

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
		left join RH.tblDatosExtraEmpleados DE
			on M.IDEmpleado = DE.IDEmpleado
		left join RH.tblCatDatosExtra CDE
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

	set @query1 = 'SELECT IDEmpleado ' + coalesce(','+@cols, '') + ' 
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

	--select len(@query1) +len( @query2) 

	exec( @query1 + @query2) 

	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select m.ClaveEmpleado as CLAVE
			,m.NOMBRECOMPLETO AS NOMBRE			
			,m.Departamento AS DEPARTAMENTO
			,m.Puesto AS PUESTO
			,SE.TipoSangre AS [TIPO SANGRE]
			,SE.Estatura AS ESTATURA
			,SE.Peso AS PESO
			,SE.IMC as [INDICE MASA CORPORAL]
			,SE.IMCC AS [CATEGORIA DE MASA CORPORAL]
			,M.UMF AS [UMF   ]
			,CASE WHEN SE.RequiereTarjetaSalud = 0 THEN 'NO' ELSE 'SI' END AS [REQUIERE TARJETA SALUD]
			,FORMAT(SE.VencimientoTarjeta,'dd/MM/yyyy') AS [VENCIMIENTO TARJETA]
			,SE.Alergias AS [ALERGIAS COLABORADOR]
			,SE.TratamientoAlergias AS [TRATAMIENTO ALERGIA]
			,CB.Descripcion as [BRIGADAS DE EMERGENCIA]
			,email.value as [EMAIL]
			,tel.value as [TELEFONO]
			,telcasa.value as [TELEFONO CASA]
			,telmovil.value as [TELÉFONO MOVIL],
			substring(UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as DIRECCION
			,c.NombreAsentamiento as [DIRECCION COLONIA]
			,localidades.Descripcion as [DIRECCION LOCALIDAD]
			,Muni.Descripcion as [DIRECCION MUNICIPIO]
			,est.NombreEstado as [DIRECCION ESTADO]
			,CP.CodigoPostal as [DIRECCION POSTAL]
			,Madre.NombreCompleto as [FAMILIAR MADRE]
			,Padre.NombreCompleto as [FAMILIAR PADRE]
			,deex.GASTOS_FUNERARIOS
			,deex.SEGURO_DE_VIDA
			,deex.SEG_GASTOS_MEDICOS
			,deex.P_FUNERARIOS
		from @dtEmpleados m
		inner join RH.tblEmpleadosMaster Mast with (nolock) 
			on m.IDEmpleado = mast.IDEmpleado
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
			left join rh.tblbrigadasempleado be
				on be.idempleado = m.idempleado
			left join rh.tblCatBrigadas cb
				on cb.idbrigada = be.brigadas	
			left join #tempContactoEmpleado email
				on email.idempleado = m.IDEmpleado and email.RN = 1 and email.Descripcion = 'EMAIL'
			left join #tempContactoEmpleado tel
				on tel.idempleado = m.IDEmpleado and tel.RN = 1 and tel.Descripcion = 'TELEFONO'
			left join #tempContactoEmpleado telCasa
				on telCasa.idempleado = m.IDEmpleado and telCasa.RN = 1 and telCasa.Descripcion = 'TELEFONO CASA'
			left join #tempContactoEmpleado telMovil
				on telMovil.idempleado = m.IDEmpleado and telMovil.RN = 1 and telMovil.Descripcion = 'TELÉFONO MOVIL'
			left join #tempParentesco Madre
				on Madre.IDEmpleado=m.IDEmpleado and Madre.Descripcion = 'MADRE'
			left join #tempParentesco Padre
				on Padre.IDEmpleado=m.IDEmpleado and Padre.Descripcion = 'PADRE'
			left join ##tempDatosExtraEmpleados deex
				on deex.idempleado = m.IDEmpleado


	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		
			select m.ClaveEmpleado as CLAVE
			,m.NOMBRECOMPLETO AS NOMBRE			
			,m.Departamento AS DEPARTAMENTO
			,m.Puesto AS PUESTO
			,SE.TipoSangre AS [TIPO SANGRE]
			,SE.Estatura AS ESTATURA
			,SE.Peso AS PESO
			,SE.IMC as [INDICE MASA CORPORAL]
			,SE.IMCC AS [CATEGORIA DE MASA CORPORAL]
			,M.UMF AS [UMF   ]
			,CASE WHEN SE.RequiereTarjetaSalud = 0 THEN 'NO' ELSE 'SI' END AS [REQUIERE TARJETA SALUD]
			,FORMAT(SE.VencimientoTarjeta,'dd/MM/yyyy') AS [VENCIMIENTO TARJETA]
			,SE.Alergias AS [ALERGIAS COLABORADOR]
			,SE.TratamientoAlergias AS [TRATAMIENTO ALERGIA]
			,CB.Descripcion as [BRIGADAS DE EMERGENCIA]
			,email.value as [EMAIL]
			,tel.value as [TELEFONO]
			,telcasa.value as [TELEFONO CASA]
			,telmovil.value as [TELÉFONO MOVIL],
			substring(UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as DIRECCION
			,c.NombreAsentamiento as [DIRECCION COLONIA]
			,localidades.Descripcion as [DIRECCION LOCALIDAD]
			,Muni.Descripcion as [DIRECCION MUNICIPIO]
			,est.NombreEstado as [DIRECCION ESTADO]
			,CP.CodigoPostal as [DIRECCION POSTAL]
			,Madre.NombreCompleto as [FAMILIAR MADRE]
			,Padre.NombreCompleto as [FAMILIAR PADRE]
			,deex.GASTOS_FUNERARIOS
			,deex.SEGURO_DE_VIDA
			,deex.SEG_GASTOS_MEDICOS
			,deex.P_FUNERARIOS
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
			left join rh.tblbrigadasempleado be
				on be.idempleado = m.idempleado
			left join rh.tblCatBrigadas cb
				on cb.idbrigada = be.brigadas	
			left join #tempContactoEmpleado email
				on email.idempleado = m.IDEmpleado and email.RN = 1 and email.Descripcion = 'EMAIL'
			left join #tempContactoEmpleado tel
				on tel.idempleado = m.IDEmpleado and tel.RN = 1 and tel.Descripcion = 'TELEFONO'
			left join #tempContactoEmpleado telCasa
				on telCasa.idempleado = m.IDEmpleado and telCasa.RN = 1 and telCasa.Descripcion = 'TELEFONO CASA'
			left join #tempContactoEmpleado telMovil
				on telMovil.idempleado = m.IDEmpleado and telMovil.RN = 1 and telMovil.Descripcion = 'TELÉFONO MOVIL'
			left join #tempParentesco Madre
				on Madre.IDEmpleado=m.IDEmpleado and Madre.Descripcion = 'MADRE'
			left join #tempParentesco Padre
				on Padre.IDEmpleado=m.IDEmpleado and Padre.Descripcion = 'PADRE'
			left join ##tempDatosExtraEmpleados deex
				on deex.idempleado = m.IDEmpleado
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
		
			select m.ClaveEmpleado as CLAVE
			,m.NOMBRECOMPLETO AS NOMBRE			
			,m.Departamento AS DEPARTAMENTO
			,m.Puesto AS PUESTO
			,SE.TipoSangre AS [TIPO SANGRE]
			,SE.Estatura AS ESTATURA
			,SE.Peso AS PESO
			,SE.IMC as [INDICE MASA CORPORAL]
			,SE.IMCC AS [CATEGORIA DE MASA CORPORAL]
			,M.UMF AS [UMF   ]
			,CASE WHEN SE.RequiereTarjetaSalud = 0 THEN 'NO' ELSE 'SI' END AS [REQUIERE TARJETA SALUD]
			,FORMAT(SE.VencimientoTarjeta,'dd/MM/yyyy') AS [VENCIMIENTO TARJETA]
			,SE.Alergias AS [ALERGIAS COLABORADOR]
			,SE.TratamientoAlergias AS [TRATAMIENTO ALERGIA]
			,CB.Descripcion as [BRIGADAS DE EMERGENCIA]
			,email.value as [EMAIL]
			,tel.value as [TELEFONO]
			,telcasa.value as [TELEFONO CASA]
			,telmovil.value as [TELÉFONO MOVIL],
			substring(UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as DIRECCION
			,c.NombreAsentamiento as [DIRECCION COLONIA]
			,localidades.Descripcion as [DIRECCION LOCALIDAD]
			,Muni.Descripcion as [DIRECCION MUNICIPIO]
			,est.NombreEstado as [DIRECCION ESTADO]
			,CP.CodigoPostal as [DIRECCION POSTAL]
			,Madre.NombreCompleto as [FAMILIAR MADRE]
			,Padre.NombreCompleto as [FAMILIAR PADRE]
			,deex.GASTOS_FUNERARIOS
			,deex.SEGURO_DE_VIDA
			,deex.SEG_GASTOS_MEDICOS
			,deex.P_FUNERARIOS
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
			left join rh.tblbrigadasempleado be
				on be.idempleado = m.idempleado
			left join rh.tblCatBrigadas cb
				on cb.idbrigada = be.brigadas	
			left join #tempContactoEmpleado email
				on email.idempleado = m.IDEmpleado and email.RN = 1 and email.Descripcion = 'EMAIL'
			left join #tempContactoEmpleado tel
				on tel.idempleado = m.IDEmpleado and tel.RN = 1 and tel.Descripcion = 'TELEFONO'
			left join #tempContactoEmpleado telCasa
				on telCasa.idempleado = m.IDEmpleado and telCasa.RN = 1 and telCasa.Descripcion = 'TELEFONO CASA'
			left join #tempContactoEmpleado telMovil
				on telMovil.idempleado = m.IDEmpleado and telMovil.RN = 1 and telMovil.Descripcion = 'TELÉFONO MOVIL'
			left join #tempParentesco Madre
				on Madre.IDEmpleado=m.IDEmpleado and Madre.Descripcion = 'MADRE'
			left join #tempParentesco Padre
				on Padre.IDEmpleado=m.IDEmpleado and Padre.Descripcion = 'PADRE'
			left join ##tempDatosExtraEmpleados deex
				on deex.idempleado = m.IDEmpleado
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
