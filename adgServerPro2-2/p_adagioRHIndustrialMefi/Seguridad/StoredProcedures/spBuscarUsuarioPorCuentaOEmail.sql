USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Seguridad].[spBuscarUsuarioPorCuentaOEmail](@Valor varchar(255))
as
declare 
	--@Valor varchar(255) = 'aneudy91@gmail.com'
	@IDUsuario int = 0;

	if exists (select top  1 1
				from Seguridad.tblUsuarios
				where Email = @Valor) 
	begin
		select top 1 @IDUsuario=IDUsuario
		from Seguridad.tblUsuarios
		where Email = @Valor

		exec [Seguridad].[spBuscarUsuario] @IDUsuario = @IDUsuario
		return;
	end;

	if exists (select top  1 1
				from Seguridad.tblUsuarios
				where Cuenta = @Valor) 
		begin
			select top 1 @IDUsuario=IDUsuario
			from Seguridad.tblUsuarios
			where Cuenta = @Valor

			exec [Seguridad].[spBuscarUsuario] @IDUsuario = @IDUsuario
			return;
		end

	--exec [Seguridad].[spBuscarUsuario] @IDUsuario = -1;
	raiserror('No se encuentra el usuario.',16,1);
	return;
GO
