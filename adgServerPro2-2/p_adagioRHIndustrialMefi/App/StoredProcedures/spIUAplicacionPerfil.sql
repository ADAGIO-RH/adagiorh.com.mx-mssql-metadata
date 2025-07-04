USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE proc [App].[spIUAplicacionPerfil](
	@IDPerfil int
	,@IDAplicacion nvarchar(100)
	,@Permiso bit
 ) as
	if exists (select top 1 1 
				from [App].[tblAplicacionPerfiles] 
				where IDPerfil = @IDPerfil and IDAplicacion = @IDAplicacion)
	begin
		if (@Permiso = 0) 
		begin
			delete 
			from [App].[tblAplicacionPerfiles] 
			where IDPerfil = @IDPerfil and IDAplicacion = @IDAplicacion
		end;
	end else
	begin
		if (@Permiso = 1) 
		begin
			insert into [App].[tblAplicacionPerfiles](IDPerfil,IDAplicacion)
			select @IDPerfil, @IDAplicacion				
		end
	end
GO
