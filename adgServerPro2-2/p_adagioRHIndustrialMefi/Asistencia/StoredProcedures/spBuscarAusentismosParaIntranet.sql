USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spBuscarAusentismosParaIntranet](
	@IDUsuario int
)
AS
BEGIN
    SET FMTONLY OFF; 

	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))

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
		,ISNULL(AdministrarSaldos,0) as AdministrarSaldos
		,ROW_NUMBER()over(ORDER BY IDIncidencia)as ROWNUMBER   
    from [Asistencia].[tblCatIncidencias] with (nolock)  
    where (isnull(Intranet, 0) = 1 or isnull(AdministrarSaldos, 0) = 1)
		
END
GO
