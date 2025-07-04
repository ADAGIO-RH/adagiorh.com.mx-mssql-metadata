USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[spBuscarPreferencias](@IDUsuario int = 0,@IDPreferencia int = 0)
as
    if (@IDUsuario <> 0)
    begin
	   select @IDPreferencia=IDPreferencia
	   from [Seguridad].[tblUsuarios] with (nolock) 
	   where IDUsuario=@IDUsuario
	   
	   select dt.IDDetallePreferencia,dt.IDPreferencia,p.Fecha,dt.IDTipoPreferencia,ctp.TipoPreferencia,dt.Valor
	   from App.tblDetallePreferencias dt with (nolock) 
		  join [App].[tblPreferencias] p with (nolock) on dt.IDPreferencia = p.IDPreferencia
		  join [App].[tblCatTiposPreferencias] ctp with (nolock) on dt.IDTipoPreferencia = ctp.IDTipoPreferencia
	   where dt.IDPreferencia=@IDPreferencia

	   return 0;
    end;

    if (@IDPreferencia <> 0)
    begin
	   select dt.IDDetallePreferencia,dt.IDPreferencia,p.Fecha,dt.IDTipoPreferencia,ctp.TipoPreferencia,dt.Valor
	   from App.tblDetallePreferencias dt with (nolock) 
		  join [App].[tblPreferencias] p with (nolock) on dt.IDPreferencia = p.IDPreferencia
		  join [App].[tblCatTiposPreferencias] ctp with (nolock) on dt.IDTipoPreferencia = ctp.IDTipoPreferencia
	   where dt.IDPreferencia=@IDPreferencia
    end;
GO
