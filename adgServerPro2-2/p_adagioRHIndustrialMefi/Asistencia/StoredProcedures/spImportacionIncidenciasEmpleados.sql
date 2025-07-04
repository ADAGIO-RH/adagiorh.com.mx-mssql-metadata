USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spImportacionIncidenciasEmpleados]  
(  
	@dtImportacion [Asistencia].[dtIncidenciasAusentismosImportacion] READONLY  
	,@IDUsuario int
)  
AS  
BEGIN  
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))

	IF OBJECT_ID('tempdb..#TempIncidencias') IS NOT NULL DROP TABLE #TempIncidencias  
	
	select ID   
	Into #TempIncidencias  
	from Seguridad.tblFiltrosUsuarios with(nolock)  
	where IDUsuario = @IDUsuario and Filtro = 'IncidenciasAusentismos'  

	select 
		ROW_NUMBER()over(Order by e.ClaveEmpleado,Fecha ASC) as RN  
		,isnull(em.IDEmpleado,0) as [IDEmpleado]  
		,E.[ClaveEmpleado]  
		,isnull(em.NOMBRECOMPLETO,'') as [NombreCompleto]  
		,E.IDIncidencia
		,isnull((Select TOP 1 JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion from Asistencia.tblCatIncidencias Where IDIncidencia = E.[IDIncidencia]),'') as [Incidencia]  
		,FORMAT(cast(isnull(E.[Fecha],'9999-12-31') as DATE),'dd/MM/yyyy') as [Fecha]  
	from @dtImportacion E  
		left join RH.tblEmpleadosMaster em on e.ClaveEmpleado = em.ClaveEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on em.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
		LEFT JOIN #TempIncidencias tempInc on E.IDIncidencia = tempInc.ID
	WHERE isnull(E.ClaveEmpleado,'') <>''   
END
GO
