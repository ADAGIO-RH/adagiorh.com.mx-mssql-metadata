USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Intranet].[spBuscarCatIncidenciasIntranet](      
    @IDUsuario int  
	,@SoloIntranet bit
) as  
begin  
    declare 
		@IDIdioma varchar(225)	;   
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')		      
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
		,AdministrarSaldos
		,ROW_NUMBER()over(ORDER BY IDIncidencia)as ROWNUMBER   
    from [Asistencia].[tblCatIncidencias] with (nolock)  
    where Intranet = @SoloIntranet	
    
end
GO
