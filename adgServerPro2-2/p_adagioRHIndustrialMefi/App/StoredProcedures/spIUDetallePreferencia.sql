USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].spIUDetallePreferencia(@IDUsuario int, @TipoPreferencia varchar(255), @Valor nvarchar(max))
as
begin
    declare @IDPreferencia int = 0
		 ,@IDTipoPreferencia int = 0;

    select @IDTipoPreferencia=IDTipoPreferencia
    from [App].[tblCatTiposPreferencias]
    where TipoPreferencia = @TipoPreferencia

    if (@IDTipoPreferencia is null)
    begin
	   exec [App].[spObtenerError] @IDUsuario,'0000002';
    end;

    select @IDPreferencia=IDPreferencia
    from [Seguridad].[tblUsuarios] with (nolock) 
    where IDUsuario=@IDUsuario

    if (@IDPreferencia is null)
    begin
	   Insert into [App].[tblPreferencias](Fecha)
	   values(getdate())

	   select @IDPreferencia=@@IDENTITY;

	   update [Seguridad].tblUsuarios
	   set IDPreferencia=@IDPreferencia
	   where IDUsuario=@IDUsuario
    end;

    if exists(select 1 from [App].[tblDetallePreferencias] where IDPreferencia=@IDPreferencia and IDTipoPreferencia=@IDTipoPreferencia)
    begin
	   update [App].[tblDetallePreferencias]
	   set Valor=@Valor
	   where IDPreferencia=@IDPreferencia and IDTipoPreferencia=@IDTipoPreferencia 
    end else
    begin
	   insert into [App].[tblDetallePreferencias](IDPreferencia,IDTipoPreferencia,Valor)
	   select @IDPreferencia,@IDTipoPreferencia,@Valor
    end;
end;
GO
