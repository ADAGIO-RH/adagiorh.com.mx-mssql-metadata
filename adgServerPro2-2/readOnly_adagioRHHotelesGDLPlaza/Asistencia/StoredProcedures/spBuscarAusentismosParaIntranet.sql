USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spBuscarAusentismosParaIntranet]
AS
BEGIN
	
    SET FMTONLY OFF; 



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
    where Intranet = 1   
		
END
GO
