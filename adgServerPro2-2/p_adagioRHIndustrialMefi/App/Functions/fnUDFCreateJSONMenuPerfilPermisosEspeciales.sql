USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function [App].[fnUDFCreateJSONMenuPerfilPermisosEspeciales](
	@IDPerfil int, 
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
				   ,JSON_QUERY ([App].[fnUDFCreateJSONMenuPerfilPermisosEspeciales](@IDPerfil,@parentID, PE.Codigo)) AS items
				   ,CAST(isnull(CASE WHEN peu.IDPermisoEspecialPerfil is not null THEN 1 else 0 end,0) as bit) checked
				from App.tblCatPermisosEspeciales PE
					left join Seguridad.tblPermisosEspecialesPerfiles peu
						on pe.IDPermiso = peu.IDPermiso
						and peu.IDPerfil = @IDPerfil
				 Where         
					PE.IDUrlParent= @parentID 
					and isnull(PE.CodigoParent,'') = isnull(@CodigoParent,'')
				    for json auto
            );

    return @json  
end
GO
