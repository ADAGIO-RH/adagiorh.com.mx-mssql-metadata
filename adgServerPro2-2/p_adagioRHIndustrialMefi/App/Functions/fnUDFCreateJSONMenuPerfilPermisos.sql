USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 select
 [App].[fnUDFCreateJSONMenuPerfilPermisos](
	3 , 
	19,
	'Catalogos',
	1
	) 
*/

CREATE function [App].[fnUDFCreateJSONMenuPerfilPermisos](
	@IDPerfil int, 
	@parentID int,
	@IDAplicacion nvarchar(100),
	@IDUsuario int
	) 
returns varchar(max)
begin 
    declare @json nvarchar(max) 

	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))	

        set @json =  
            (
              	select   
					isnull(M.IDMenu ,0) as IDMenu       
				   ,isnull(M.IDUrl,0 )  as IDUrl     
				   ,isnull(M.ParentID,0) ParentID       
				   ,isnull(M.CssClass,'')as  CssClass        
				   ,JSON_VALUE(u.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion           
				   ,case when (U.URL ='#') then '' else U.URL end as URL        
				   ,isnull(M.Orden,0) as Orden        
				   ,isnull(m.IDAplicacion,'') as IDAplicacion
				   ,isnull(c.IDController,0) as IDController
				   ,isnull(puc.IDPerfil,@IDPerfil) as IDPerfil
				   ,cast(case when isnull(puc.IDTipoPermiso,'') <> '' THEN 1 ELSE 0 END as bit) TienePermiso
				   ,isnull(puc.IDTipoPermiso,'') as IDTipoPermiso
				   ,JSON_QUERY ([App].[fnUDFCreateJSONMenuPerfilPermisos](@IDPerfil,isnull(M.IDMenu,0 ),@IDAplicacion,@IDUsuario)) AS Childrens
				   ,JSON_QUERY ([App].[fnUDFCreateJSONMenuPerfilPermisosEspeciales](@IDPerfil,isnull(M.IDUrl,0 ),null)) AS Especiales
				from App.tblMenu M        
					left join app.tblCatUrls u on m.IDUrl = u.IDUrl      
					left join app.tblCatControllers c on u.IDController = c.IDController      
					left join app.tblCatAreas a on c.IDArea = a.IDArea      
					left join app.tblCatTipoPermiso tp on tp.IDTipoPermiso = u.IDTipoPermiso      
					left join Seguridad.tblPermisosPerfilesControllers puc on   
					  puc.IDController = c.IDController
						and puc.IDPerfil = @IDPerfil 
					left join app.tblCatTipoPermiso tpu on tpu.IDTipoPermiso = puc.IDTipoPermiso      
						and tpu.Prioridad >= tp.Prioridad      
				 Where         
					M.ParentID = @parentID      
				   and m.IDAplicacion = @IDAplicacion 
				    for json auto
            );

    return @json  
end
GO
