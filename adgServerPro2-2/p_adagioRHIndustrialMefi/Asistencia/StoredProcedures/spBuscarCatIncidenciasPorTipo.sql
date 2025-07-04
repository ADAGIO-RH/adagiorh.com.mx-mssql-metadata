USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Buscar Incidencias por Tipo: Ausentismos, Incidencias  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2018-05-16  
** Paremetros  : 
	@Tipo - 
		0 = Incidencias  
		1 = Ausentismos    
    @IDUsuario : Usuario que ejecuta el sp            
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
2018-07-27  Jose Roman		Se agrega Color al tipo de Incidencia.  
2019-11-25  Aneudy Abreu	Se agrega la columna GenerarIncidencias
***************************************************************************************************/  
CREATE proc [Asistencia].[spBuscarCatIncidenciasPorTipo](  
    @Tipo int  
    ,@IDUsuario int  
) as  
begin  
    declare 
		@IDIdioma varchar(225),
		@EsAusentismo bit
	;  
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	IF OBJECT_ID('tempdb..#TempIncidencias') IS NOT NULL DROP TABLE #TempIncidencias  

	select ID   
	Into #TempIncidencias  
	from Seguridad.tblFiltrosUsuarios with(nolock)  
	where IDUsuario = @IDUsuario and Filtro = 'IncidenciasAusentismos'  

    select @EsAusentismo = cast(@Tipo as bit);  
  
    select   
		IDIncidencia  
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,EsAusentismo  
		,GoceSueldo  
		,PermiteChecar  
		,AfectaSUA
		,Autorizar  
		,TiempoIncidencia  
		,ISNULL(Color,'#000000') as Color  
		,ISNULL(GenerarIncidencias,0) as GenerarIncidencias
		,ISNULL(Intranet,0) as Intranet
		,ROW_NUMBER()over(ORDER BY IDIncidencia)as ROWNUMBER   
    from [Asistencia].[tblCatIncidencias] with (nolock)  
    where EsAusentismo = @EsAusentismo  
	and (IDIncidencia in (select ID from #TempIncidencias)  
		OR Not Exists(select ID from #TempIncidencias))
end
GO
