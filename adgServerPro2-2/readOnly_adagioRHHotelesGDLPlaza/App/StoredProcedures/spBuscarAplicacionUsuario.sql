USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [App].[spBuscarAplicacionUsuario](      
	@IDUsuario int      
) as      
	select       
		isnull(ap.IDAplicacionUsuario,0) as IDAplicacionUsuario      
		,ca.IDAplicacion      
		,ca.Descripcion as DescripcionAplicacion      
		,ca.Icon
		,ca.Url  
		,Permiso = case when ap.IDAplicacionUsuario is not null then cast(1 as bit) else cast(0 as bit) end      
		,@IDUsuario as IDUsuario      
	from [App].[tblAplicacionUsuario] ap      
		right join [App].[tblCatAplicaciones] ca on ap.IDAplicacion = ca.IDAplicacion and ap.IDUsuario = @IDUsuario  
		--	and ap.AplicacionPersonalizada is not null
	order by ca.Orden asc
GO
