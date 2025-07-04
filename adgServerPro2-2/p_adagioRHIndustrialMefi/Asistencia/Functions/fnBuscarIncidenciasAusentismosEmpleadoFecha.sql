USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/****************************************************************************************************   
** Descripción  : Buscar las incidencias y ausentismos por empleados por rangos de fecha  
** Autor   : Jose Roman  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 2018-11-25  
** Paremetros  :     @IDEmpleado int  
     ,@FechaInicio date  
     ,@FechaFin date  
     ,@IDUsuario int  
     ,@Tipo int : 0 = Incidencias  
          1 = Ausentismos         
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
create function [Asistencia].[fnBuscarIncidenciasAusentismosEmpleadoFecha](  
     @IDEmpleado int  
    ,@FechaInicio date  
    ,@FechaFin date  
    ,@IDUsuario int  
    ,@Tipo int  
) RETURNS @tmpIncidencias TABLE  (
	IDIncidenciaEmpleado  int,
	IDEmpleado  		  int,
	IDIncidencia  		  varchar(10),
	Incidencia  		  varchar(255),
	Fecha  				  date,
	TiempoSugerido  	  time,
	TiempoAutorizado  	  time,
	Comentario  		  nvarchar(max),
	CreadoPorIDUsuario    int,
	CreadoPorUsuario  	  varchar(500),
	Autorizado  		  bit,
	AutorizadoPor  		  int,
	AutorizadoPorUsuario  varchar(500),
	FechaHoraAutorizacion datetime, 
	FechaHoraCreacion  	  datetime,
	IDIncapacidadEmpleado int, 
	allDay 				  bit,
	Color  				  varchar(255)
)
as  
BEGIN
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))


	insert @tmpIncidencias
	select   
		ie.IDIncidenciaEmpleado  
		,ie.IDEmpleado  
		,ie.IDIncidencia  
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Incidencia
		,ie.Fecha  
		,isnull(ie.TiempoSugerido,'00:00') as TiempoSugerido  
		,isnull(ie.TiempoAutorizado,'00:00') as TiempoAutorizado  
		,ie.Comentario  
		,isnull(ie.CreadoPorIDUsuario,0) as CreadoPorIDUsuario  
		,COALESCE(usuarioCreaInc.Nombre,'') + ' ' + COALESCE(usuarioCreaInc.Apellido,'') as CreadoPorUsuario  
		,isnull(ie.Autorizado,cast(0 as bit)) as Autorizado  
		,isnull(ie.AutorizadoPor,0) as AutorizadoPor  
		,COALESCE(usuarioAutorizo.Nombre,'') + ' ' + COALESCE(usuarioAutorizo.Apellido,'') as AutorizadoPorUsuario  
		,isnull(ie.FechaHoraAutorizacion, '1900-01-01 00:00:00') as FechaHoraAutorizacion  
		,isnull(ie.FechaHoraCreacion, '1900-01-01 00:00:00') as FechaHoraCreacion  
		,isnull(ie.IDIncapacidadEmpleado,0) as IDIncapacidadEmpleado  
		,allDay = case when i.TiempoIncidencia = 1 then cast(0 as bit) else cast(1 as bit) end  
		,ISNULL(I.Color,'#000000') as Color  
	from [Asistencia].[tblIncidenciaEmpleado] ie  
		join [Asistencia].[tblCatIncidencias] i on ie.IDIncidencia = i.IDIncidencia  
		left join [Seguridad].[tblUsuarios] usuarioCreaInc on ie.CreadoPorIDUsuario = usuarioCreaInc.IDUsuario       
		left join [Seguridad].[tblUsuarios] usuarioAutorizo on ie.AutorizadoPor = usuarioAutorizo.IDUsuario   
	where ie.IDEmpleado = @IDEmpleado   
		AND (ie.Fecha BETWEEN @FechaInicio and @FechaFin)   
		AND  i.EsAusentismo = @Tipo

	return;

END
GO
