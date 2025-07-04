USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE proc [Reportes].[spBuscarCatReportes](  
	 @IDCarpeta int = 0  
	 ,@IDUsuario int   
) as  
 select cr.*   
 from Reportes.tblCatReportes cr with (nolock)  
	--join Seguridad.tblPermisosReportesUsuarios rpu on cr.IDItem = rpu.IDItem and ISNULL(rpu.Acceso,0) = 1  
 where cr.IDCarpeta = @IDCarpeta  --and rpu.IDUsuario = @IDUsuario
 order by cr.TipoItem, cr.Nombre
GO
