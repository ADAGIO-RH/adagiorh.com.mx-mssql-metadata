USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[spBuscarAplicaciones] (
	@IDAplicacion varchar(max) = null
)   as  
	declare 
		@IDIdioma varchar(20) = 'esmx'
	;

	select     
		IDAplicacion    
		--,Descripcion  
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,JSON_VALUE(ISNULL(TraduccionCustom, Traduccion), FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as DescripcionCustom

		,Orden  
		,Icon
		,Url    
		,Traduccion
		,case when Url='#/' then 'Redirige a la SinglePage.'
			when Url like '%http%' then 'Abre una nueva pestaña con el link externo.'
			else 'Sale de la SinglePage y redirige a https://{host}/{ControllerName}'
			end as Informacion 
 
	from app.tblCatAplicaciones
	where IDAplicacion = @IDAplicacion OR isnull(@IDAplicacion,'') = ''
	order by Orden
GO
