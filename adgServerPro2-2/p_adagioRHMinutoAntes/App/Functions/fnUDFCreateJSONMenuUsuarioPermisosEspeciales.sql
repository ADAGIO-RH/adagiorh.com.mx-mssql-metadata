USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*select [App].[fnUDFCreateJSONMenuUsuarioPermisosEspeciales](3914,1218,null) */

CREATE function [App].[fnUDFCreateJSONMenuUsuarioPermisosEspeciales](
	@IDUsuario int, 
	@parentID int,
	@CodigoParent varchar(20)
	
) 
returns varchar(max)
begin 
    declare @json varchar(max) 

	--@IDUsuario int = 3914, 
	--@parentID int = 1218,
	--@CodigoParent varchar(20) = null

	
set @json =  
            (
              	select   
					isnull(PE.IDPermiso ,0) as id       
				   ,isnull(PE.IDUrlParent,0 )  as IDUrlParent     
				   ,isnull(PE.Codigo,'') Codigo       
				   ,isnull(PE.CodigoParent,'')as  CodigoParent        
				   ,isnull(PE.Descripcion,'')as  [text]
				   ,JSON_QUERY ([App].[fnUDFCreateJSONMenuUsuarioPermisosEspeciales](@IDUsuario,@parentID, PE.Codigo)) AS items
				   ,CAST(isnull(CASE WHEN peu.IDPermisoEspecialUsuario is not null THEN 1 else 0 end,0) as bit) checked
				from App.tblCatPermisosEspeciales PE
					left join Seguridad.tblPermisosEspecialesUsuarios peu
						on pe.IDPermiso = peu.IDPermiso
						and peu.IDUsuario = @IDUsuario
				 Where         
					PE.IDUrlParent= @parentID 
					and isnull(PE.CodigoParent,'') = isnull(@CodigoParent,'')
				    for json auto
            );

    return @json  
end
GO
