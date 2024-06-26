USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE proc [App].[spIUAplicacionUsuario](  
	@IDUsuario int  
	,@IDAplicacion nvarchar(100)  
	,@Permiso bit  
	,@PermisoPersonalizado bit = 0
) as  
	if exists (select top 1 1   
				from [App].[tblAplicacionUsuario]   
				where IDUsuario = @IDUsuario and IDAplicacion = @IDAplicacion)  
	begin  
		if (@Permiso = 1)   
		begin  
			insert into [App].[tblAplicacionUsuario](IDUsuario,IDAplicacion,AplicacionPersonalizada)  
			select @IDUsuario, @IDAplicacion, @PermisoPersonalizado   
		end else  
		begin  
			delete   
			from [App].[tblAplicacionUsuario]   
			where IDUsuario = @IDUsuario and IDAplicacion = @IDAplicacion  
		end;  
	end else  
	begin  
		if (@Permiso = 1)   
		begin  
			insert into [App].[tblAplicacionUsuario](IDUsuario,IDAplicacion,AplicacionPersonalizada)  
			select @IDUsuario, @IDAplicacion, @PermisoPersonalizado     
		end  
	end
GO
