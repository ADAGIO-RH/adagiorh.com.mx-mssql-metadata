USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Asistencia].[spRegistrarWebChecada] --1, 17260
(
	@IDLector int,
	@IDEmpleado int
)
AS
BEGIN

	DECLARE @dtUTC DATETIME = GETUTCDATE(),
			@dtLectorZonaHoraria Varchar(100),
			@dtFechaZonaHoraria Datetime,
			@IDZonaHoraria int,
			@IDChecada int = 0,
			@Valida bit = 1,
			@FechaOrigen Date,
			@TipoChecada Varchar(5),
			@Mensaje Varchar(max),
			@EsRepetida bit= 0 ,
			@dtEmpleados [RH].[dtEmpleados],
            @IDIdioma varchar(max)
		
	;

    select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')
	
	select 
		@dtLectorZonaHoraria = isnull(z.Name,'UTC') 
		,@IDZonaHoraria = isnull(z.Id ,(select top 1 id from tzdb.Zones where Name = 'UTC'))
	from Asistencia.tblLectores l
		left join Tzdb.Zones z on l.IDZonaHoraria = z.Id
	where l.IDLector = @IDLector

	set  @dtFechaZonaHoraria = Tzdb.UtcToLocal(@dtUTC,@dtLectorZonaHoraria)

	select
		@FechaOrigen = t.FechaOrigen,
		@TipoChecada = t.TipoChecada
	From [Asistencia].[fnValidaDiaOrigen](@IDEmpleado,@dtFechaZonaHoraria) t

	--select @IDEmpleado,@FechaOrigen,@TipoChecada,@IDLector, @dtFechaZonaHoraria

	exec Asistencia.spValidarChecada
		@IDEmpleado = @IDEmpleado,
		@dtEmpleados2 = @dtEmpleados,
		@FechaOrigen = @FechaOrigen,
		@Tipochecada = @TipoChecada,
		@IDLector = @IDLector,
		@dtFechaZonaHoraria = @dtFechaZonaHoraria,
		@outChecadaValida = @Valida output,
		@outMensajeValidacion = @Mensaje output,
		@outEsRepetida = @EsRepetida output      


	 


	if(@Valida = 1)
	BEGIN
		insert into Asistencia.tblChecadas(Fecha,FechaOrigen,IDLector,IDEmpleado,IDTipoChecada,IDZonaHoraria,Automatica,FechaReg, FechaOriginal)
		select 
			@dtFechaZonaHoraria as Fecha
			,@FechaOrigen
			,@IDLector
			,@IDEmpleado
			,@TipoChecada
			,@IDZonaHoraria
			,1
			,@dtUTC
			,@dtFechaZonaHoraria

		set @IDChecada = @@IDENTITY

		Select 
			c.IDChecada,
			c.Fecha,
			c.FechaOrigen,
			isnull(c.IDLector,0) as IDLector,
			isnull(l.Lector,'NINGUNO') as Lector,
			isnull(c.IDEmpleado,0) as IDEmpleado,
			isnull(m.ClaveEmpleado,'00000') as ClaveEmpleado,
			m.NOMBRECOMPLETO as NombreCompleto,
			isnull(c.IDUsuario,0) as IDUsuario,
			c.Comentario,
			c.IDTipoChecada,
			JSON_VALUE(tc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoChecada')) as TipoChecada ,
			isnull(c.IDZonaHoraria,0) as IDZonaHoraria,
			z.Name as ZonaHoraria,
			c.FechaReg,
			@Valida as Valida,
			'Checada Registrada Satisfactoriamente. Tipo Checada: ' + tc.TipoChecada  as MensajeChecada
		from Asistencia.tblChecadas c
			inner join Asistencia.tblLectores l on c.IDLector = l.IDLector
			inner join tzdb.Zones z on z.Id = c.IDZonaHoraria
			inner join RH.tblEmpleadosMaster m on c.IDEmpleado = m.IDEmpleado
			Inner join Asistencia.tblCatTiposChecadas tc on c.IDTipoChecada = tc.IDTipoChecada
		where IDChecada = @IDChecada
	END
	ELSE
	BEGIN
		Select 
			0 as IDChecada,
			isnull(@dtFechaZonaHoraria, GETDATE())  as Fecha,
			isnull(@FechaOrigen, GETDATE()) as FechaOrigen,
			isnull(l.IDLector,0) as IDLector,
			'Lector' as Lector,
			isnull(m.IDEmpleado,0) as IDEmpleado,
			isnull(m.ClaveEmpleado,'00000') as ClaveEmpleado,
			m.NOMBRECOMPLETO as NombreCompleto,
			0 as IDUsuario,
			'' as Comentario,
			'' as IDTipoChecada,
			'' as TipoChecada,
			isnull(@IDZonaHoraria,0) as IDZonaHoraria,
			@dtLectorZonaHoraria as ZonaHoraria,
			@dtUTC as FechaReg,
			@Valida as Valida,
			'Checada Incorrecta.' + @Mensaje as MensajeChecada
			FROM Asistencia.tblLectores l
				cross apply RH.tblEmpleadosMaster m
			WHERE l.IDLector = @IDLector
			and M.IDEmpleado = @IDEmpleado

		EXEC Asistencia.spIBitacoraChecadas @IDEmpleado,@dtUTC,@IDLector,@Mensaje
	END
END
GO
