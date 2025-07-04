USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
exec  Reportes.[spReporteBasicoFormatoPermisosANS]  
	@ClaveEmpleadoInicial = '1935'
	,@FechaHoraIni = '2021-02-19 13:00:00'
	,@FechaHoraFin = '2021-02-19 15:30:00'
	,@FechaIni = ''
	,@FechaFin =  ''
	,@IDIncidencia='B'
	,@Afectar = 0
	,@IDUsuario=1

	exec Reportes.spReporteBasicoFormatoPermisosANS @FechaHoraIni='2021-01-20 13:00:00',@FechaHoraFin='2021-01-20 15:00:00',@FechaIni=NULL,@FechaFin=NULL,@ClaveEmpleadoInicial='1935',@IDIncidencia='B',@Afectar=0,@IDUsuario=1
*/
CREATE proc [Reportes].[spReporteBasicoFormatoPermisosANS] (
	@FechaHoraIni datetime = '', 
	@FechaHoraFin datetime = '',
	@FechaIni date = '',
	@FechaFin date = '',
	@ClaveEmpleadoInicial Varchar(20) = '0', 
	@IDIncidencia varchar(10), 
	@Afectar bit = 1,
	@IDUsuario int,
	@Detalle bit = 0
) as
	SET NOCOUNT ON;
	SET FMTONLY OFF
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	set @Afectar = 1

	--declare 
	--	@FechaIni date =  '2019-08-01'
	--	,@FechaFin date = '2019-08-15'
	--	,@IDUsuario int = 1
	--;

	declare 
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@dtEmpleados RH.dtEmpleados
		,@Fechas [App].[dtFechasFull]  
		,@dtFiltros [Nomina].[dtFiltrosRH]  
		,@IDTipoNominaInt int 
			,@IDTipoNomina int
			,@IDTipoVigente int
		 ,@Titulo Varchar(max)  
		 ,@FechaHoraFinHorario datetime
		 ,@tipoChecada varchar(10) = ' '
		
	;




	SET DATEFIRST 7;  
  
	select top 1 @IDIdioma = dp.Valor  
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
	    

	insert into @dtEmpleados
	SELECT * from RH.tblEmpleadosMaster 
	WHERE IDEmpleado = CAST( @ClaveEmpleadoInicial as int)
	--Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial, @EmpleadoFin=@ClaveEmpleadoInicial, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

	IF(@IDIncidencia in ('A','DE','M','N','P','V','S'))
	BEGIN
		insert @Fechas  
		exec app.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin  
	END
	ELSE
	BEGIN
		insert @Fechas  
		exec app.spListaFechas @FechaIni = @FechaHoraIni, @FechaFin = @FechaHoraIni

		select @FechaHoraFinHorario = (cast(cast(f.Fecha as date) as datetime) + cast( h.HoraSalida as datetime))
		from @Fechas f
			cross apply @dtEmpleados e
			left join Asistencia.tblHorariosEmpleados he
				on e.IDEmpleado =  he.IDEmpleado
				and f.Fecha = he.Fecha
			left join Asistencia.tblCatHorarios h
				on he.IDHorario = h.IDHorario

		if(@IDIncidencia = 'NC' )
		BEGIN
			set @FechaHoraFinHorario = @FechaHoraFin
			if @Detalle = 1
			BEGIN
				set @tipoChecada = 'SALIDA'
			END ELSE
			BEGIN
				set @tipoChecada = 'ENTRADA'
			END
		END
	END
	SELECT 
		e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,D.Codigo +' - '+ D.Descripcion as Departamento
		,S.Codigo +' - '+ S.Descripcion as Sucursal
		,P.Codigo +' - '+ P.Descripcion as Puesto
		,E.RegPatronal
		,'('+I.IDIncidencia+') '+ I.Descripcion + ' ' + @tipoChecada as Incidencia
		, CASE WHEN I.IDIncidencia  in ('A','DE','M','N','P','V','S') THEN 'DIAS COMPLETOS'
			   ELSE 'DESCUENTO EN HORAS' 
			   END as DESCUENTO
		, FORMATO  = CASE 
						WHEN I.IDIncidencia  in ('B','T') THEN 'Formulario para otorgamiento de Permisos por Hora'
						WHEN I.IDIncidencia  in ('V') THEN 'Formulario para solicitud de Vacaciones'
						WHEN I.IDIncidencia  in ('NC') THEN 'Formulario para omisión de checado'
						WHEN I.IDIncidencia  in ('A') THEN 'Formulario para solicitud de Permisos'
						ELSE 'Formulario para solicitud de Permisos' 
					   END 
		, Mensaje = CASE 
						WHEN I.IDIncidencia  in ('V') THEN 'Declaro que al disfrutar del periodo de vacaciones arriba señalado, he recibido completo el pago tanto de mi salario como de la prima que corresponde conforme a ley.'
						ELSE 'Sin mas por el momento y en espera de sus comentarios y dudas' 
					   END 
		, JEFE = ISNULL((SELECT TOP 1 M.ClaveEmpleado +'  '+M.NOMBRECOMPLETO FROM RH.tblJefesEmpleados j inner join RH.tblEmpleadosMaster M on J.IDJefe = M.IDEmpleado WHERE J.IDEmpleado = E.IDEmpleado),'SIN JEFE ASIGNADO') 
		, CASE WHEN I.IDIncidencia  in ('A','DE','M','N','P','V','S') THEN FORMAT(@FechaIni,'dd/MM/yyyy') 
			   ELSE FORMAT(@FechaHoraIni,'dd/MM/yyyy HH:mm')
			   END as FechaIni
		, CASE WHEN I.IDIncidencia  in ('A','DE','M','N','P','V','S') THEN FORMAT(@FechaFin,'dd/MM/yyyy') 
			   ELSE FORMAT(@FechaHoraFinHorario,'dd/MM/yyyy HH:mm')
			   END as FechaFin
		, CASE WHEN I.IDIncidencia  in ('A','DE','M','N','P','V','S') THEN '0'
			   ELSE DATEDIFF(minute, @FechaHoraIni,@FechaHoraFinHorario)
			   END as DESCUENTO_TIEMPO
		, CASE WHEN I.IDIncidencia  in ('A','DE','M','N','P','V','S') THEN 0 
			   ELSE CAST(DATEDIFF(minute, @FechaHoraIni,@FechaHoraFinHorario)/60.0 as decimal(18,2))
			   END as DESCUENTO_HORAS
		,FOTO = CG.Valor + CASE WHEN FE.IDEmpleado is null THEN 'Fotos/nofoto.jpg'
					ELSE 'Fotos/Empleados/'  +FE.ClaveEmpleado+'.jpg'
					END
		,CASE WHEN I.IDIncidencia  in ('T','B') THEN [Asistencia].[fnTimeDiffWithDatetimes](@FechaHoraIni,@FechaHoraFinHorario)
			   END as HORAS_RELOJ
	from @dtEmpleados E
	Inner join Asistencia.tblCatIncidencias I
		on I.IDIncidencia = @IDIncidencia
	left join RH.tblCatDepartamentos d
		on E.IDDepartamento = d.IDDepartamento
	left join RH.tblCatSucursales S
		on e.IDSucursal = S.IDSucursal
	left join RH.tblCatPuestos p	
		on e.IDPuesto = p.IDPuesto
	left join app.tblConfiguracionesGenerales CG
		on CG.IDConfiguracion = 'Url'
	left join RH.tblFotosEmpleados FE 
		on E.IDEmpleado = FE.IDEmpleado
	

	IF(@Afectar = 1 and @IDIncidencia <> 'NC')
	BEGIN
		IF(@IDIncidencia in ('A','DE','M','N','P','V','S'))
		BEGIN
			insert into Asistencia.tblIncidenciaEmpleado(IDEmpleado,IDIncidencia,Fecha,Autorizado,AutorizadoPor,ComentarioTextoPlano, FechaHoraCreacion)
			Select FechaEmp.IDEmpleado, @IDIncidencia, FechaEmp.Fecha, CASE WHEN @IDIncidencia IN ('A','DE','M','N','P','V','S') THEN 0 ELSE 1 END,@IDUsuario, 'GENERADO POR FORMATO DE PERMISOS', GETDATE()  
			FROM (
				SELECT *
				FROM @dtEmpleados E
				,@Fechas F
				) FechaEmp
				left join asistencia.tblIncidenciaEmpleado IE
					on FechaEmp.IDEmpleado = IE.IDEmpleado
					and IE.fecha = FechaEmp.Fecha
					and IE.IDIncidencia = 'D'
				left join Asistencia.TblCatDiasFestivos F
					on F.fecha = FechaEmp.Fecha
					and f.Autorizado = 1
				where f.IDDiaFestivo is null
				and IE.IDIncidenciaEmpleado is null
		END
		ELSE
		BEGIN

			
			insert into Asistencia.tblIncidenciaEmpleado(IDEmpleado,IDIncidencia,Fecha,Autorizado,AutorizadoPor,ComentarioTextoPlano, FechaHoraCreacion, TiempoSugerido, TiempoAutorizado )
			Select FechaEmp.IDEmpleado, @IDIncidencia, FechaEmp.Fecha, CASE WHEN @IDIncidencia IN ('A','DE','M','N','P','V','S') THEN 0 ELSE 1 END,@IDUsuario, 'GENERADO POR FORMATO DE PERMISOS', GETDATE(),[Asistencia].[fnTimeDiffWithDatetimes](@FechaHoraIni,@FechaHoraFinHorario), [Asistencia].[fnTimeDiffWithDatetimes](@FechaHoraIni,@FechaHoraFinHorario)
			FROM (
				SELECT *
				FROM @dtEmpleados E
				,@Fechas F
				) FechaEmp
		END
	END




GO
