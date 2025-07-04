USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Intranet].[spBuscarSolicitudesEmpleados](
	@IDSolicitud int = 0,
	@IDEmpleado int = 0,
	@IDTipoSolicitud int = 0,
	@IDEstatusSolicitud int = 0,
	@IDUsuario int
)
AS
BEGIN
	declare  
		@IDIdioma varchar(225)
	;
	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	SELECT 
		SE.IDSolicitud
		,'S'+ cast(SE.IDSolicitud as Varchar(10)) as Folio
		,SE.IDEmpleado
		,M.ClaveEmpleado
		,M.NOMBRECOMPLETO as NombreCompleto
		,SE.IDTipoSolicitud
		,JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoSolicitud
		,SE.IDEstatusSolicitud 
		,JSON_VALUE(ES.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as EstatusSolicitud
		,SE.IDIncidencia 
		--,I.Descripcion as Incidencia
		,JSON_VALUE(I.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Incidencia
		,isnull(SE.FechaIni,'9999-12-31') as FechaIni
		,ISNULL(SE.CantidadDias,0) as CantidadDias
		,SE.DiasDescanso
		,SE.FechaCreacion
		,SE.ComentarioEmpleado
		,SE.ComentarioSupervisor
		,ISNULL(SE.CantidadMonto,0) as CantidadMonto
		,isnull(SE.IDUsuarioAutoriza,0) as IDUsuarioAutoriza
		,ROW_NUMBER()OVER(ORDER BY SE.IDSolicitud ASC) ROWNUMBER
	FROM Intranet.tblSolicitudesEmpleado SE WITH(NOLOCK)
		INNER JOIN RH.tblEmpleadosMaster M WITH(NOLOCK) on SE.IDEmpleado = M.IDEmpleado
		INNER JOIN Intranet.tblCatTipoSolicitud TS WITH(NOLOCK) on TS.IDTipoSolicitud = SE.IDTipoSolicitud
		INNER JOIN Intranet.tblCatEstatusSolicitudes ES WITH(NOLOCK) on ES.IDEstatusSolicitud = SE.IDEstatusSolicitud
		LEFT JOIN Asistencia.tblCatIncidencias I WITH(NOLOCK) on SE.IDIncidencia = I.IDIncidencia
	WHERE (SE.IDSolicitud = @IDSolicitud OR @IDSolicitud = 0)
		AND (SE.IDEmpleado = @IDEmpleado  OR @IDEmpleado = 0)
		AND (SE.IDTipoSolicitud = @IDTipoSolicitud OR @IDTipoSolicitud = 0)
		AND (SE.IDEstatusSolicitud = @IDEstatusSolicitud OR @IDEstatusSolicitud = 0)
	ORDER BY SE.FechaCreacion DESC
END
GO
