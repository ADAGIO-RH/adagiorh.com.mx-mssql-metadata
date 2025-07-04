USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
exec  Reportes.[spReporteBasicoFormatoPermisosNomade]  
	@ClaveEmpleadoInicial = '1935'
	,@FechaHoraIni = '2021-02-19 13:00:00'
	,@FechaHoraFin = '2021-02-19 15:30:00'
	,@FechaIni = ''
	,@FechaFin =  ''
	,@IDIncidencia='B'
	,@Afectar = 0
	,@IDUsuario=1

	exec Reportes.spReporteBasicoFormatoPermisosNomade @FechaHoraIni='2021-01-20 13:00:00',@FechaHoraFin='2021-01-20 15:00:00',@FechaIni=NULL,@FechaFin=NULL,@ClaveEmpleadoInicial='1935',@IDIncidencia='B',@Afectar=0,@IDUsuario=1
*/
CREATE proc [Reportes].[spReporteBasicoFormatoPermisosNomade] (
	@FechaHoraIni datetime = '', 
	@FechaHoraFin datetime = '',
	@FechaIni date = '',
	@FechaFin date = '',
	@ClaveEmpleadoInicial Varchar(20) = '0', 
	@IDIncidencia varchar(10), 
	@Afectar bit = 0,
	@IDUsuario int
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
		,@Fechas [App].[dtFechas]  
		,@dtFiltros [Nomina].[dtFiltrosRH]  
		,@IDTipoNominaInt int 
		,@IDTipoNomina int
		,@IDTipoVigente int
		,@Titulo Varchar(max)  
		,@FechaHoraFinHorario datetime
        ,@idempleado int
        ,@AniversarioVaca int 
        ,@diasdisponibles INT
        ,@diasdisfrutdos int
		
	;

    SELECT @idempleado = IDEmpleado from RH.tblEmpleadosMaster 
	WHERE IDEmpleado = CAST( @ClaveEmpleadoInicial as int) or ClaveEmpleado = @ClaveEmpleadoInicial

    --Taer vacaciones del empleado
     
    -- Tabla temporal que recibe todas las columnas del SP
declare @tmpVacaciones table (
	Anio int,
	FechaIni date,
	FechaFin date,
	Dias int,
	DiasGenerados int,
	DiasTomados int,
	DiasVencidos int,
	DiasDisponibles decimal(18,2),
	TipoPrestacion varchar(100),
	FechaIniDisponible date,
	FechaFinDisponible date
)

-- Inserta el resultado completo del SP en la tabla temporal
insert into @tmpVacaciones
exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @idempleado, 0, null, @IDUsuario

-- Ahora solo se insertan las columnas necesarias en @vaca
Declare @vaca Table (
	anios int,
	fechaini date,
	fechafin date,
	dias int,
	diastomados int,
	diasvencidsos int,
	DiasDisponibles int
)

insert into @vaca (anios, fechaini, fechafin, dias, diastomados, diasvencidsos, DiasDisponibles)
select 
	Anio,
	FechaIni,
	FechaFin,
	Dias,
	DiasTomados,
	DiasVencidos,
	DiasDisponibles
from @tmpVacaciones


    Select top 1 @AniversarioVaca = anios,@diasdisponibles = DiasDisponibles,@diasdisfrutdos = diastomados from @vaca

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
	WHERE IDEmpleado = CAST( @ClaveEmpleadoInicial as int) or ClaveEmpleado = @ClaveEmpleadoInicial
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
		--exec app.spListaFechas @FechaHoraIni = @FechaHoraIni, @FechaHoraFin = @FechaHoraIni

		select @FechaHoraFinHorario = (cast(cast(f.Fecha as date) as datetime) + cast( h.HoraSalida as datetime))
		from @Fechas f
			cross apply @dtEmpleados e
			left join Asistencia.tblHorariosEmpleados he
				on e.IDEmpleado =  he.IDEmpleado
				and f.Fecha = he.Fecha
			left join Asistencia.tblCatHorarios h
				on he.IDHorario = h.IDHorario
	END
	SELECT 
		 e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,D.Descripcion as Departamento
		,S.Descripcion as Sucursal
		,P.Descripcion as Puesto
		,E.RegPatronal
        ,@FechaIni as fechaIni
        ,@FechaFin as fechFin
        ,mov.Fecha as FechaBaja
        ,@AniversarioVaca as Aniversario
        ,@diasdisfrutdos as dDisfrutados
        ,@diasdisponibles as dDisponibles
		,'('+I.IDIncidencia+') '+ I.Descripcion as Incidencia
		, JEFE = ISNULL((SELECT TOP 1 M.NOMBRECOMPLETO FROM RH.tblJefesEmpleados j inner join RH.tblEmpleadosMaster M on J.IDJefe = M.IDEmpleado WHERE J.IDEmpleado = E.IDEmpleado),'SIN JEFE ASIGNADO') 
		, CASE WHEN I.IDIncidencia  in ('A','DE','M','N','P','V','S','F') THEN FORMAT(@FechaIni,'dd/MM/yyyy') 
			   ELSE FORMAT(@FechaHoraIni,'dd/MM/yyyy HH:mm')
			   END as FechaHoraIni
		, CASE WHEN I.IDIncidencia  in ('A','DE','M','N','P','V','S') THEN FORMAT(@FechaFin,'dd/MM/yyyy') 
			   ELSE FORMAT(@FechaHoraFin,'dd/MM/yyyy HH:mm')
			   END as FechaHoraFin
        , CASE WHEN I.IDIncidencia  in ('A','DE','M','N','P','V','S','F') THEN FORMAT(@FechaIni,'dd/MM/yyyy') 
			   ELSE FORMAT(@FechaHoraIni,'HH:mm')
			   END as HoraIni
		, CASE WHEN I.IDIncidencia  in ('A','DE','M','N','P','V','S') THEN FORMAT(@FechaFin,'dd/MM/yyyy') 
			   ELSE FORMAT(@FechaHoraFin,'HH:mm')
			   END as HoraFin
		, CASE WHEN I.IDIncidencia  in ('A','DE','M','N','P','V','S') THEN 0 
			   ELSE DATEDIFF(minute, @FechaHoraIni,@FechaHoraFinHorario)
			   END as DESCUENTO_TIEMPO
		, CASE WHEN I.IDIncidencia  in ('A','DE','M','N','P','V','S') THEN 0 
			   ELSE CAST(DATEDIFF(minute, @FechaHoraIni,@FechaHoraFinHorario)/60.0 as decimal(18,2))
			   END as DESCUENTO_HORAS
		, DATEDIFF(day, @FechaIni, @FechaFin) as Dias
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
    left join IMSS.tblMovAfiliatorios mov 
    on mov.IDEmpleado = e.IDEmpleado and IDTipoMovimiento = 2
	

	IF(@Afectar = 1 and @IDIncidencia <> 'NC')
	BEGIN
		IF(@IDIncidencia in ('A','DE','M','N','P','V','S'))
		BEGIN
			insert into Asistencia.tblIncidenciaEmpleado(IDEmpleado,IDIncidencia,Fecha,Autorizado,AutorizadoPor,ComentarioTextoPlano, FechaHoraCreacion)
			Select FechaEmp.IDEmpleado, @IDIncidencia, FechaEmp.Fecha, CASE WHEN @IDIncidencia = 'V' THEN 0 ELSE 1 END,@IDUsuario, 'GENERADO POR FORMATO DE PERMISOS', GETDATE()  
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
			Select FechaEmp.IDEmpleado, @IDIncidencia, FechaEmp.Fecha, CASE WHEN @IDIncidencia = 'V' THEN 0 ELSE 1 END,@IDUsuario, 'GENERADO POR FORMATO DE PERMISOS', GETDATE(),[Asistencia].[fnTimeDiffWithDatetimes](@FechaHoraIni,@FechaHoraFinHorario), [Asistencia].[fnTimeDiffWithDatetimes](@FechaHoraIni,@FechaHoraFinHorario)
			FROM (
				SELECT *
				FROM @dtEmpleados E
				,@Fechas F
				) FechaEmp
		END
	END
GO
