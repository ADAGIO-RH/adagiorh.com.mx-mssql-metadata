USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar las incidencias y ausentismos por empleados por IDIncidenciaEmpleado o IDEmpleado
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-07-24
** Paremetros		:      
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Asistencia].[spBuscarIncidenciasEmpleadoPorID](
    @IDIncidenciaEmpleado int = 0
    ,@IDEmpleado int = 0
    ,@IDUsuario int 
    ,@IDPapeleta int 
) as
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select 
		ie.IDIncidenciaEmpleado
		,ie.IDEmpleado
		,ie.IDIncidencia
		,JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Incidencia
		,ie.Fecha
		,isnull(ie.TiempoSugerido,'00:00') as TiempoSugerido
		,isnull(ie.TiempoAutorizado,'00:00') as TiempoAutorizado
		,ie.Comentario
		,ie.ComentarioTextoPlano
		,isnull(ie.CreadoPorIDUsuario,0) as CreadoPorIDUsuario
		,COALESCE(usuarioCreaInc.Nombre,'') + ' ' + COALESCE(usuarioCreaInc.Apellido,'') as CreadoPorUsuario
		,isnull(ie.Autorizado,cast(0 as bit)) as Autorizado
		,isnull(ie.AutorizadoPor,0) as AutorizadoPor
		,COALESCE(usuarioAutorizo.Nombre,'') + ' ' + COALESCE(usuarioAutorizo.Apellido,'') as AutorizadoPorUsuario
		,isnull(ie.FechaHoraAutorizacion, '1900-01-01 00:00:00') as FechaHoraAutorizacion
		,isnull(ie.FechaHoraCreacion, '1900-01-01 00:00:00') as FechaHoraCreacion
		,isnull(ie.IDIncapacidadEmpleado,0) as IDIncapacidadEmpleado
		,allDay = case when i.TiempoIncidencia = 1 then cast(0 as bit) else cast(1 as bit) end
        ,isnull(ie.IDPapeleta,0) as IDPapeleta
    from [Asistencia].[tblIncidenciaEmpleado] ie
		join [Asistencia].[tblCatIncidencias] i on ie.IDIncidencia = i.IDIncidencia
		left join [Seguridad].[tblUsuarios] usuarioCreaInc on ie.CreadoPorIDUsuario = usuarioCreaInc.IDUsuario     
		left join [Seguridad].[tblUsuarios] usuarioAutorizo on ie.AutorizadoPor = usuarioAutorizo.IDUsuario 
    where (ie.IDEmpleado = @IDEmpleado or @IDEmpleado = 0)
	   and  (ie.IDIncidenciaEmpleado = @IDIncidenciaEmpleado or @IDIncidenciaEmpleado = 0)
       and  (ie.IDPapeleta = @IDPapeleta or @IDPapeleta = 0)
GO
