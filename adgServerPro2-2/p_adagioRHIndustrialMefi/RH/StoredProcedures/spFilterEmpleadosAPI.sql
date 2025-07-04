USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca empleados por Nombre y/o clave Empleado
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-12-24
** Paremetros		:              
	@tipo = -1		: Ambos
			0		: No Vigentes
			1		: Vigentes
			

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE proc [RH].[spFilterEmpleadosAPI](  
	@tipo	int = -1,
	@claveEmpleado	varchar(20) = null,
	@fechaUltimaActualizacion	date = null,
	@fechaIngreso		date = null,
	@idMesNacimiento	int = 0,
	@IDUsuario			int
)as   

	declare 
		@vigencia bit = null,
		@FechaIni date = getdate(),
		@Fechafin date = getdate(),
		@IDIdioma varchar(10)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if object_id('tempdb..#tempMovAfil') is not null drop table #tempMovAfil    
  
	select 
		mm.IDEmpleado
		--,FechaAlta
		,FechaBaja
		--,case when ((mm.FechaBaja is not null and mm.FechaReingreso is not null) and mm.FechaReingreso > mm.FechaBaja) then mm.FechaReingreso else null end as FechaReingreso
		--,mm.FechaReingresoAntiguedad
		--,mm.IDMovAfiliatorio    
		--,mm.SalarioDiario
		--,mm.SalarioVariable
		--,mm.SalarioIntegrado
		--,mm.SalarioDiarioReal
	into #tempMovAfil  
	from IMSS.TblVigenciaEmpleado mm with (nolock)
	where (mm.FechaAlta <= @FechaFin and (mm.FechaBaja >= @FechaIni or mm.FechaBaja is null)) or (mm.FechaReingreso <= @FechaFin)

	set @vigencia = case when @tipo = -1 then null else CAST(@tipo as bit) end

	select
		 e.IDEmpleado
		,e.ClaveEmpleado
		,e.IMSS
		,e.Nombre
		,e.SegundoNombre
		,e.Paterno
		,e.Materno
		,e.NOMBRECOMPLETO as NombreCompleto

		,e.RFC
		,e.CURP

		,JSON_VALUE(SEXOS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Sexo

		,isnull(e.FechaIngreso,'1990-01-01') as FechaIngreso
		,isnull(e.FechaAntiguedad,'1990-01-01') as FechaAntiguedad
		,e.FechaNacimiento
		--,ISNULL(mov.FechaBaja, '1990-01-01') as FechaUltimaBaja
		,mov.FechaBaja as FechaUltimaBaja

		,isnull(e.IDDepartamento,0) as IDDepartamento
		,ISNULL(d.Codigo, '0000') as CodigoDepartamento
		,JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Departamento

		,isnull(e.IDSucursal,0) as IDSucursal
		,ISNULL(s.Codigo, '0000') as CodigoSucursal
		,e.Sucursal

		,isnull(e.IDPuesto,0) as IDPuesto
		,ISNULL(p.Codigo, '0000') as CodigoPuesto
		,JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Puesto

		,isnull(e.IDTipoNomina,0) as IDTipoNomina
		,tipoNomina.Descripcion as TipoNomina
		,periodicidadPago.Descripcion as PeriodicidadPago

		,isnull(uae.Fecha, getdate()) as FechaUltimaActualizacion
		,e.Vigente
		,(
			select *
			from (
				Select   
				   --PE.IDPagoEmpleado,  
				   --PE.IDEmpleado,  
				 --  isnull(PE.IDLayoutPago,0) as IDLayoutPago,  
				   coalesce(lp.Descripcion,'SIN LAYOUT')as Descripcion,  
				   PE.Cuenta,  
				   PE.Sucursal,  
				   PE.Interbancaria,  
				   PE.Tarjeta,  
				   PE.IDBancario,  
				  -- isnull(b.IDBanco,0) as IDBanco ,  
				   coalesce(b.Descripcion,'SIN BANCO')as Banco  
				From RH.tblPagoEmpleado PE  
				   LEFT Join Nomina.tblLayoutPago lp on PE.IDLayoutPago = lp.IDLayoutPago  
				   Left Join Sat.tblCatBancos b on PE.IDBanco = b.IDBanco  
				Where PE.IDEmpleado = e.IDEmpleado
			) infoPago
			FOR JSON AUTO
		) as TiposPago
		,(
			select *
			from (
				Select 
					--CE.IDContactoEmpleado,
					--CE.IDEmpleado,
					--CE.IDTipoContactoEmpleado,
					JSON_VALUE(TCE.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoContacto,
					CE.[Value],
					--TCE.Mask,
					--TCE.CssClassIcon,
					isnull(ce.Predeterminado,0) as Predeterminado,
					--tce.IDMedioNotificacion as IDMedioNotificacion,
					JSON_VALUE(mn.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as MedioNotificacion
				from RH.tblContactoEmpleado CE
					inner join RH.tblCatTipoContactoEmpleado TCE on CE.IDTipoContactoEmpleado = TCE.IDTipoContacto
					left join App.tblMediosNotificaciones mn on tce.IDMedioNotificacion = mn.IDMedioNotificacion
				WHERE (CE.IDEmpleado = e.IDEmpleado)
			) as infoContacto
			FOR JSON AUTO
		) Contactos
		,(
			SELECT
				--DE.IDDatoExtra
				DE.Nombre
				,DE.Descripcion
				,DE.TipoDato
				--,ISNULL(DEE.IDDatoExtraEmpleado,0) IDDatoExtraEmpleado
				,CASE WHEN (DE.TipoDato in ('bool','BIT'))THEN ISNULL(DEE.Valor,'false')
					WHEN (DE.TipoDato in ('string','Varchar'))THEN ISNULL(DEE.Valor,'')
					WHEN (DE.TipoDato in ('Date'))THEN ISNULL(DEE.Valor,'')
					WHEN (DE.TipoDato in ('INT','FLOAT','REAL','DECIMAL', 'NUMERIC'))THEN ISNULL(DEE.Valor,'0')
					ELSE '0'
					END as Valor
			--	,e.IDEmpleado
			FROM RH.tblCatDatosExtra DE
				left join RH.tblDatosExtraEmpleados DEE on DE.IDDatoExtra = DEE.IDDatoExtra
					and  DEE.IDEmpleado = e.IDEmpleado
			FOR JSON AUTO
		) as DatosExtra
	from [RH].[tblEmpleadosMaster] e with (nolock)
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		left join RH.tblCatSucursales s with (nolock) on s.IDSucursal = e.IDSucursal
		left join RH.tblCatDepartamentos d with (nolock) on d.IDDepartamento = e.IDDepartamento
		left join RH.tblCatPuestos p with (nolock) on p.IDPuesto = e.IDPuesto
		left join Nomina.tblCatTipoNomina tipoNomina with (nolock) on tipoNomina.IDTipoNomina = e.IDTipoNomina
		left join Sat.tblCatPeriodicidadesPago periodicidadPago on periodicidadPago.IDPeriodicidadPago = tipoNomina.IDPeriodicidadPago
		LEFT JOIN RH.tblCatGeneros SEXOS WITH(NOLOCK) ON SUBSTRING(E.Sexo, 1,1) = SEXOS.IDGenero
		left join RH.tblUltimaActualizacionEmpleados uae with (nolock) on uae.IDEmpleado = e.IDEmpleado
		left join #tempMovAfil mov on mov.IDEmpleado = e.IDEmpleado
	where (e.Vigente = case when @vigencia is not null then @vigencia else e.Vigente end)
		and (e.ClaveEmpleado = @claveEmpleado or ISNULL(@claveEmpleado, '') = '')
		and (CAST(isnull(uae.Fecha,getdate()) as date) = @fechaUltimaActualizacion or @fechaUltimaActualizacion is null)
		and (isnull(e.FechaIngreso,'1990-01-01') = @fechaIngreso or @fechaIngreso is null)
		and (DATEPART(MONTH, e.FechaNacimiento) = @idMesNacimiento or ISNULL(@idMesNacimiento, 0) = 0 )
	order by ClaveEmpleado asc
GO
