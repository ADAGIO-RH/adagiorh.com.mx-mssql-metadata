USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spBuscarCatIncidencias](  
    @IDIncidencia varchar(10) = null  
    ,@IDUsuario int  
) as  
begin  

    SET FMTONLY OFF; 

	IF OBJECT_ID('tempdb..#TempIncidencias') IS NOT NULL DROP TABLE #TempIncidencias  

	select ID   
	Into #TempIncidencias  
	from Seguridad.tblFiltrosUsuarios with(nolock)  
	where IDUsuario = @IDUsuario and Filtro = 'IncidenciasAusentismos'  

    select   
		IDIncidencia  
		,Descripcion  
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
    where ((IDIncidencia = @IDIncidencia) or (@IDIncidencia is null))  
		and (IDIncidencia in (select ID from #TempIncidencias)  
		OR Not Exists(select ID from #TempIncidencias))
end
GO
