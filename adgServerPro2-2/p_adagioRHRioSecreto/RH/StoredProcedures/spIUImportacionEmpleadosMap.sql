USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUImportacionEmpleadosMap]
(
	@dtEmpleados [RH].[dtEmpleadosImportacionMap] READONLY,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE @IDIdioma VARCHAR(MAX);
    select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))    



	declare @tempMessages as table(
		ID int,
		[Message] varchar(500),
		Valid bit
	)
	declare @tempClave as table(
		ClaveEmpleado varchar(30),
		LongitudClaveIngresada int,
		LongitudClaveCliente int,
		Cliente varchar(100)
	)

	Declare @AltaColaboradorPTUDefault bit,
		@LongitudClaveEmpleado int,
		@AltaColaboradorBloqueoDiasPrevios bit,
		@AltaColaboradorBloqueoDiasQty int,
		@FechaBloqueoDiasPrevios Date,
		@ValidaRFCImportacionEmpleados bit,
		@ValidaCURPImportacionEmpleados bit,
		@ValidaIMSSImportacionEmpleados bit,
		@ValidaCLABEAltaEmpleados bit;



	Select @AltaColaboradorPTUDefault = CAST(isnull(Valor,0) as bit) from App.tblConfiguracionesGenerales where IDConfiguracion = 'AltaColaboradorPTUDefault'
	Select @AltaColaboradorBloqueoDiasPrevios = CAST(isnull(Valor,0) as bit) from App.tblConfiguracionesGenerales where IDConfiguracion = 'AltaColaboradorBloqueoDiasPrevios'
	Select @AltaColaboradorBloqueoDiasQty = CAST(isnull(Valor,0) as int) from App.tblConfiguracionesGenerales where IDConfiguracion = 'AltaColaboradorBloqueoDiasQty'

	Select @ValidaRFCImportacionEmpleados = CAST(isnull(Valor,0) as bit) from App.tblConfiguracionesGenerales where IDConfiguracion = 'ValidaRFCImportacionEmpleados'
	Select @ValidaCURPImportacionEmpleados = CAST(isnull(Valor,0) as bit) from App.tblConfiguracionesGenerales where IDConfiguracion = 'ValidaCURPImportacionEmpleados'
	Select @ValidaIMSSImportacionEmpleados = CAST(isnull(Valor,0) as bit) from App.tblConfiguracionesGenerales where IDConfiguracion = 'ValidaIMSSImportacionEmpleados'
	Select @ValidaCLABEAltaEmpleados = CAST(isnull(Valor,0) as bit) from App.tblConfiguracionesGenerales where IDConfiguracion = 'ValidaCLABEAltaEmpleados'

	SET @FechaBloqueoDiasPrevios = DATEADD(DAY,(@AltaColaboradorBloqueoDiasQty * -1),GETDATE())

	insert into @tempClave(ClaveEmpleado, LongitudClaveIngresada, LongitudClaveCliente, Cliente)
	select 
		   dt.ClaveEmpleado, 
		   len(dt.ClaveEmpleado),
		   (
			select 
				ISNULL(CC.LongitudNoNomina, 0)
			from RH.tblCatClientes CC with(nolock)
			where CC.NombreComercial = dt.Cliente
		   ),
		   dt.Cliente
	from @dtEmpleados dt

	insert @tempMessages(ID, [Message], Valid)
	values
		(1, 'Datos correctos', 1),
		(2, 'El Nombre del Cliente no Existe', 0),
		(3, 'El Tipo de nomina del Cliente no Existe', 0),
		(4, 'El Primer Nombre del colaboradore es necesario', 0),
		(5, 'El Apellido Paterno del colaboradore es necesario', 0),
		(6, 'El Pais de Nacimiento no Existe', 1),
		(7, 'El Estado de Nacimiento no Existe', 1),
		(8, 'El Municipio de Nacimiento no Existe', 1),
		(9, 'La Fecha de Nacimiento es necesaria', 1),
		(10, 'La Fecha de Nacimiento es necesaria', 1),
		(11, 'El Sexo del colaborador es necesaria', 0),
		(12, 'El Estado Civil del colaborador es necesaria', 1),
		(13, 'La Fecha de Antiguedad del colaborador es necesaria', 0),
		(14, 'La Fecha de Ingreso del colaborador es necesaria', 0),
		(15, 'El tipo de Prestación del colaborador es necesaria', 0),
		(16, 'La Razón Social del colaborador es necesaria', 0),
		(17, 'El Registro Patronal del colaborador es necesaria', 0),
		(18, 'El Salario Diario del colaborador es necesaria', 0),
		(19, 'El Salario Integrado del colaborador es necesaria', 0),
		(20, 'El Email del colaborador es necesaria', 1),
		(21, 'El Departamento del colaborador no coincide', 1),
		(22, 'La Sucursal del colaborador no coincide', 1),
		(23, 'El Puesto del colaborador no coincide', 1),
		(24, 'El Centro de Costo del colaborador no coincide', 1),
		(25, 'El Area del colaborador no coincide', 1),
		(26, 'La Región del colaborador no coincide', 1),
		(27, 'La División del colaborador no coincide', 1),
		(28, 'La Clasificación Corporativa del colaborador no coincide', 1),
		(29, 'La Dirección del colaborador no coincide', 1),
		(30, 'La Escolaridad del colaborador no coincide', 1),
		(31, 'La Institución del colaborador no coincide', 1),
		(32, 'El Tipo de Regimen Fiscal del colaborador no coincide', 1),
		(33, 'La Clave del Colaborador Existe', 0),
		(34, 'El código postal fiscal es necesaria', 1),
		(35, 'El Layout Pago del colaborador no coincide', 1),
		--(36, 'Debes ingresar una clave para el colaborador', 0),
		(36, 'La Clave ingresada es más larga que la permitida.', 0),
		(37, ('La fecha de antiguedad no debe exceder el bloqueo de dias previos. '+ CAST(@AltaColaboradorBloqueoDiasQty AS VARCHAR(10))), 1),
		(38, ('El RFC del colaborador ya fue registrado en otro colaborador. '), 0),
		(39, ('El CURP del colaborador ya fue registrado en otro colaborador. '), 0),
		(40, ('El IMSS del colaborador ya fue registrado en otro colaborador. '), 0),
		(41, 'El número de la CLABE bancaria no es válido.', 1)
		;

	select
		info.*,
        (select m.[Message] as Message, CAST(m.Valid as bit) as Valid
        from @tempMessages m
        where ID in (SELECT ITEM from app.split(info.IDMensaje,','))
        FOR JSON PATH) as Msg,
		CAST(
		CASE WHEN EXISTS (  (select m.[Valid] as Message
        from @tempMessages m
        where ID in (SELECT ITEM from app.split(info.IDMensaje,',') )and Valid = 0 )) THEN 0 ELSE 1 END as bit)  as Valid
from (

	select
	isnull((Select TOP 1 IDEmpleado from RH.tblEmpleados Where ClaveEmpleado = E.[ClaveEmpleado] ),0)as [IDEmpleado]
	,E.[ClaveEmpleado]
	,(
        select top 1 IDCliente,  JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Descripcion
        from RH.tblCatClientes c with(nolock)
        where JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) = E.[Cliente]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      ) as [clienteEmpleado]
	  ,(
        select  top 1 tn.IDTipoNomina,  tn.Descripcion as Descripcion
        from RH.tblCatClientes c with(nolock)
			inner join Nomina.tblCatTipoNomina tn with(nolock)
				on c.IDCliente = tn.IDCliente
        where JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) = E.[Cliente]
			and tn.Descripcion = E.[TipoNomina]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      ) as [tipoNominaEmpleado]
	,E.[Nombre]
	,E.[SegundoNombre]
	,E.[Paterno]
	,E.[Materno]
	,E.[RFC]
	,E.[CURP]
	,E.[IMSS]
	,isnull((Select TOP 1 IDPais from SAT.tblCatPaises Where Descripcion like '%'+E.[PaisNacimiento] +'%'),0) as [IDPaisNacimiento]
	,isnull((Select TOP 1 IDEstado from SAT.tblCatEstados Where NombreEstado like '%'+E.[EstadoNacimiento] +'%'),0) as [IDEstadoNacimiento]
	,isnull((Select TOP 1 IDMunicipio from SAT.tblCatMunicipios Where Descripcion like '%'+E.[MunicipioNacimiento] +'%'),0) as [IDMunicipioNacimiento]
	,cast(isnull(E.[FechaNacimiento],'9999-12-31') as DATE) as [FechaNacimiento]
	,E.[Sexo]
	,isnull((Select TOP 1 IDEstadoCivil from RH.tblCatEstadosCiviles Where Descripcion like '%'+E.[EstadoCivil] +'%'),0) as [IDEstadoCivil]
	,cast(E.[FechaAntiguedad] as DATE) as [FechaAntiguedad]
	,cast(E.[FechaIngreso] as DATE ) as [FechaIngreso]
	,(
        select  top 1 IDTipoPrestacion, JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
        from RH.tblCatTiposPrestaciones with(nolock)
        where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  = E.[TipoPrestacion]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      ) as [prestacionEmpleado]
	  ,(
        select  top 1 IDEmpresa, NombreComercial
        from RH.tblEmpresa with(nolock)
        where NombreComercial = E.[RazonSocial]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      ) as [empresaEmpleado]
	  ,(
        select  top 1 IDRegPatronal, RazonSocial
        from RH.tblCatRegPatronal with(nolock)
        where RegistroPatronal = E.[RegistroPatronal]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      ) as [registroPatronalEmpleado]
	 ,(
        select  top 1 IDDepartamento,  JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
        from RH.tblCatDepartamentos with(nolock)
        where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = E.[Departamento]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      ) as [departamentoEmpleado]
	,(
        select  top 1 IDSucursal, Descripcion
        from RH.tblCatSucursales with(nolock)
        where Descripcion = E.[Sucursal]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      ) as [sucursalEmpleado]
	 ,(
        select  top 1 IDPuesto,  JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
        from RH.tblCatPuestos with(nolock)
        where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = e.[Puesto]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) as [puestoEmpleado]
	,(
        select  top 1 IDCentroCosto,  JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
        from RH.tblCatCentroCosto with(nolock)
        where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = E.[CentroCosto]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      ) as [centroCostoEmpleado]
	,(
        select  top 1 IDArea, JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  as Descripcion
        from RH.tblCatArea with(nolock)
        where  JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = E.[Area]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      ) as [areaEmpleado]
	,(
        select  top 1 IDRegion, JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  as Descripcion
        from RH.tblCatRegiones with(nolock)
        where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = E.[Region]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      ) as [regionEmpleado]
	 ,(
        select  top 1 IDDivision, JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  as Descripcion
        from RH.tblCatDivisiones with(nolock)
        where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  = E.[Division]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      ) as [divisionEmpleado]
	 ,(
        --select  top 1 IDClasificacionCorporativa, Descripcion
		select  top 1 IDClasificacionCorporativa, ISNULL(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS Descripcion
        from RH.tblCatClasificacionesCorporativas with(nolock)
        where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  = E.[ClasificacionCorporativa]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      ) as [clasificacionCorporativaEmpleado]
	 ,(
        select  top 1 IDTipoJornada as IDJornada, Descripcion
        from SAT.tblCatTiposJornada with(nolock)
        where Descripcion = E.[JornadaLaboral]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      ) as [jornadaEmpleado]

	 ,(
        select isnull((select TOP 1 IDTipoTrabajador from IMSS.tblCatTipoTrabajador WHERE Descripcion = E.[TipoTrabajadorSua]),0) as IDTipoTrabajador
       , ISNULL((select TOP 1 IDTipoContrato from sat.tblCatTiposContrato WHERE Descripcion = E.TipoContratoSat),0) as IDTipoContrato
        for json PATH, WITHOUT_ARRAY_WRAPPER
      ) as [tipoTrabajadorEmpleado]
	  ,(
	    select isnull((select TOP 1 IDLayoutPago from nomina.tbllayoutpago WHERE Descripcion = E.[LayoutPago]),0) as IDLayoutPago
        , isnull((select TOP 1 IDBanco from SAT.tblCatBancos WHERE Descripcion = E.[Banco]),0) as IDBanco
        ,e.[Banco]
		,e.[ClaveInterbancaria] as [Interbancaria]
		,e.[NumeroCuenta] as [Cuenta]
		,e.[NumeroTarjeta] as  [Tarjeta]
		,e.[IDBancario] as [IDBancario]
		,e.[SucursalBancaria] as [Sucursal]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	  ) as [pagoEmpleado]
	 ,(
	    select E.[FechaAntiguedad] as Fecha
		,1 as IDTipoMovimiento
        ,E.[SalarioDiario]
		,E.[SalarioVariable]
		,E.[SalarioIntegrado]
		,E.[SalarioDiarioReal]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	  ) as [movAfiliatorio]
	  ,(
	    select top 1
			isnull(cp.IDCodigoPostal,0)IDCodigoPostal,
			ISNULL(cp.CodigoPostal, E.[DireccionCodigoPostal]) as CodigoPostal,
			isnull(est.IDEstado,0)IDEstado,
			isnull(est.NombreEstado, E.[DireccionEstado]) as Estado,
			isnull(muni.IDMunicipio,0)IDMunicipio,
			isnull(muni.Descripcion,E.[DireccionMunicipio])Municipio,
			isnull(c.IDColonia,0)IDColonia,
			isnull(c.NombreAsentamiento,E.DireccionColonia)Colonia,
			isnull(p.IDPais,0)IDPais,
			isnull(p.Descripcion,'')Pais,
			e.[DireccionCalle] as Calle,
			e.[DireccionInt] as Interior,
			e.[DireccionExt] as Exterior
		from SAT.tblCatPaises p with(nolock)
			inner join Sat.tblCatEstados est with(nolock)
				on p.IDPais = est.IDPais
				and est.NombreEstado = E.[DireccionEstado]
			left join Sat.tblcatMunicipios muni with(nolock)
				on muni.IDEstado = est.IDEstado
				and muni.Descripcion = E.[DireccionMunicipio]
			left join SAT.tblcatLocalidades l with(nolock)
				on l.IDEstado = est.IDEstado
			left join Sat.tblcatCodigosPostales cp
				on cp.IDEstado = est.IDEstado
				and cp.IDMunicipio = muni.IDMunicipio
				and cp.CodigoPostal =  E.[DireccionCodigoPostal]
			left join Sat.tblcatColonias c
				on c.IDCodigoPostal = cp.IDCodigoPostal
				and c.NombreAsentamiento = E.DireccionColonia
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	  ) as [direccionEmpleado]
	,isnull((Select TOP 1 IDEstudio from STPS.tblCatEstudios Where Descripcion like '%'+E.[Escolaridad] +'%'),0) as [IDEscolaridad]
	,E.[DescripcionEscolaridad]
	,isnull((Select TOP 1 IDInstitucion from STPS.tblCatInstituciones Where Descripcion like '%'+E.[InstitucionEscolaridad] +'%'),0) as [IDInstitucion]
	,isnull((Select TOP 1 IDProbatorio from STPS.tblCatProbatorios Where Descripcion like '%'+E.[DocumentoProbatorioEscolaridad] +'%'),0) as [IDProbatorio]
	,CAST(CASE WHEN E.[Sindicalizado] = 'SI' THEN 1 else 0 END as bit) as [Sindicalizado]
	,E.[UMF]
	,E.[CuentaContable]
	,isnull((Select TOP 1 IDTipoRegimen from SAT.tblCatTiposRegimen Where Descripcion = E.[TipoRegimenFiscal] ),0) as [IDTipoRegimen]
	,isnull((Select TOP 1 IDRegimenFiscal from SAT.tblCatRegimenesFiscales Where Descripcion = E.[RegimenFiscal]),0) as [IDRegimenFiscal]
	,isnull(@AltaColaboradorPTUDefault,0) as [PTU]
	,(
		SELECT 
			isnull((Select TOP 1 IDTipoRegimen from SAT.tblCatTiposRegimen Where Descripcion = E.[TipoRegimenFiscal] ),0) as [IDTipoRegimen]
			,isnull((Select TOP 1 IDRegimenFiscal from SAT.tblCatRegimenesFiscales Where Descripcion = E.[RegimenFiscal]),0) as [IDRegimenFiscal]
			,isnull(@AltaColaboradorPTUDefault,0) as [PTU]
			,E.[CuentaContable]
			,isnull((select  top 1 IDTipoJornada from SAT.tblCatTiposJornada with(nolock) where Descripcion = E.[JornadaLaboral]),0) as IDJornadaLaboral
			,e.CodigoPostalFiscal as DomicilioFiscal
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	) as datosNominaCFDI
	,(
        select cc.IDTipoContactoEmpleado, cc.value
		from (
		select top 1 IDTipoContacto as IDTipoContactoEmpleado, E.[Email] as [Value]
        from RH.tblCatTipoContactoEmpleado with(nolock)
        where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = 'EMAIL'
		UNION
		select top 1 IDTipoContacto as IDTipoContactoEmpleado, E.[TelefonoFijo] as [Value]
        from RH.tblCatTipoContactoEmpleado with(nolock)
        where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = 'TELEFONO CASA'
		UNION
		select top 1 IDTipoContacto as IDTipoContactoEmpleado, E.[Celular] as [Value]
        from RH.tblCatTipoContactoEmpleado with(nolock)
        where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = 'TELÉFONO MOVIL'
		) cc
        FOR JSON PATH
      ) as [contactoEmpleado]
	 ,E.Email
	 ,e.CodigoPostalFiscal
	 , IDMensaje =
							case when isnull((Select TOP 1 IDEmpleado from RH.tblEmpleados Where ClaveEmpleado = E.[ClaveEmpleado] ),0) <> 0 then '33,' else '' END
							+case when isnull(( select IDCliente from RH.tblCatClientes with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) = E.[Cliente]),0) = 0 then  '2,' else '' END
							+case when isnull((  select tn.IDTipoNomina
											from RH.tblCatClientes c with(nolock)
												inner join Nomina.tblCatTipoNomina tn with(nolock)
													on c.IDCliente = tn.IDCliente
											where JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) = E.[Cliente]
											and tn.Descripcion = E.[TipoNomina]
											),0) = 0 then '3,' else '' END

							+case when isnull(E.[Nombre],'') = '' then '4,' else '' END
							+case when isnull(E.[Paterno],'') = '' then '5,' else '' END
							+case when isnull((Select TOP 1 IDPais from SAT.tblCatPaises Where Descripcion like '%'+E.[PaisNacimiento] +'%'),0) = 0 then '6,' else '' END
							+case when isnull((Select TOP 1 IDEstado from SAT.tblCatEstados Where NombreEstado like '%'+E.[EstadoNacimiento] +'%'),0) = 0 then '7,'   else '' END
							+case when isnull((Select TOP 1 IDMunicipio from SAT.tblCatMunicipios Where Descripcion like '%'+E.[MunicipioNacimiento] +'%'),0) = 0 then '8,'   else '' END
							+case when isnull(E.[FechaNacimiento],'9999-12-31') = '9999-12-31' then '9,'  else '' END
							+case when isnull(E.[Sexo],'') = '' then '11,' else '' END
							+case when isnull((Select TOP 1 IDEstadoCivil from RH.tblCatEstadosCiviles Where Descripcion like '%'+E.[EstadoCivil] +'%'),0) = 0 then '12,'  else '' END
							+case when isnull(E.[FechaAntiguedad],'9999-12-31') = '9999-12-31' then '13,' else '' END
							+case when isnull(E.[FechaIngreso],'9999-12-31') = '9999-12-31' then '14,' else '' END
							+case when isnull(( select  top 1 IDTipoPrestacion from RH.tblCatTiposPrestaciones with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = E.[TipoPrestacion]),0) = 0 then '15,' else '' END
							+case when isnull(( select  top 1 IDEmpresa from RH.tblEmpresa with(nolock) where NombreComercial = E.[RazonSocial]),0) = 0 then '16,' else '' END
							+case when isnull(( select  top 1 IDRegPatronal  from RH.tblCatRegPatronal with(nolock) where RegistroPatronal = E.[RegistroPatronal]),0) = 0 then '17,'   else '' END
							+case when isnull((  select  top 1 IDDepartamento  from RH.tblCatDepartamentos with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = E.[Departamento]),0) = 0 then '21,' else '' END
							+case when isnull(E.[SalarioDiario],0) = 0 then '18,'  else '' END
							+case when isnull(E.[SalarioIntegrado],0) = 0 then '19,'  else '' END
							+case when isnull(E.[Email],'') = '' then '20,' else '' END
							+case when isnull(( select  top 1 IDSucursal  from RH.tblCatSucursales with(nolock) where Descripcion = E.[Sucursal]),0) = 0 then '22,' else '' END
							+case when isnull(( select  top 1 IDPuesto from RH.tblCatPuestos with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = E.[Puesto]),0) = 0 then '23,'  else '' END
							+case when isnull(( select  top 1 IDCentroCosto from RH.tblCatCentroCosto with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = E.[CentroCosto]),0) = 0 then '24,' else '' END
							+case when isnull(( select  top 1 IDArea  from RH.tblCatArea with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = E.[Area]),0) = 0 then '25,'  else '' END
							+case when isnull(( select  top 1 IDRegion  from RH.tblCatRegiones with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = E.[Region]),0) = 0 then '26,'  else '' END
							+case when isnull(( select  top 1 IDDivision from RH.tblCatDivisiones with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = E.[Division]),0) = 0 then '27,'   else '' END
							+case when isnull(( select  top 1 IDClasificacionCorporativa from RH.tblCatClasificacionesCorporativas with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Descripcion')) = E.[ClasificacionCorporativa]),0) = 0 then '28,'  else '' END
							+case when isnull(E.[CodigoPostalFiscal],'') = '' then '34,'  else '' END
							+case when isnull((select TOP 1 IDLayoutPago from nomina.tbllayoutpago WHERE Descripcion = E.[LayoutPago]),0) = 0 then '35,'  else '' END
							--+case when isnull(E.[ClaveEmpleado], '') = '' then '36,' else '' END
							+case when (select top 1 LongitudClaveIngresada from @tempClave tc where tc.Cliente = E.Cliente) > (select top 1 LongitudClaveCliente from @tempClave tc where tc.Cliente = E.Cliente) then '36' else '' END
						    +case when isnull(@AltaColaboradorBloqueoDiasPrevios,0) = 1 and E.FechaAntiguedad < @FechaBloqueoDiasPrevios then '37,' else '' END
						    +case when isnull(@ValidaRFCImportacionEmpleados,0) = 1 and EXISTS (SELECT TOP 1 1 FROM RH.tblEmpleados where replace(isnull(RFC,''),' ','') = replace(isnull(e.RFC,''),' ','') and replace(isnull(RFC,''),' ','') <> '' ) then '38,' else '' END
						    +case when isnull(@ValidaCURPImportacionEmpleados,0) = 1 and EXISTS (SELECT TOP 1 1 FROM RH.tblEmpleados where replace(isnull(CURP,''),' ','') = replace(isnull(e.CURP,''),' ','') and replace(isnull(CURP,''),' ','') <> '' ) then '39,' else '' END
						    +case when isnull(@ValidaIMSSImportacionEmpleados,0) = 1 and EXISTS (SELECT TOP 1 1 FROM RH.tblEmpleados where replace(isnull(IMSS,''),' ','') = replace(isnull(e.IMSS,''),' ','') and replace(isnull(IMSS,''),' ','') <> '' ) then '40,' else '' END
							+case when isnull(@ValidaCLABEAltaEmpleados,0) = 1 and utilerias.CalcularUltimoDigitoCLABE(e.[ClaveInterbancaria]) = 0 then '41,' else '' END
	from @dtEmpleados E
	WHERE isnull(E.Nombre,'') <>''
		) info
	order by info.ClaveEmpleado
END
GO
