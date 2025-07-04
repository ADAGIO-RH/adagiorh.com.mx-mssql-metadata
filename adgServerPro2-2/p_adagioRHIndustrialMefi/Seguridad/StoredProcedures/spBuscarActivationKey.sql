USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBuscarActivationKey](    
	@key varchar(255)    
	,@crear bit = 0  
	,@IDUsuario int = 0  
) as   
   
	declare @IDPerfil int = 0;

	if (@crear = 1 and @IDUsuario <> 0)  
	begin  
	   
		select @IDPerfil = IDPerfil
		from [Seguridad].[tblUsuarios]
		where IDUsuario = @IDUsuario

		if exists (select top 1 1  
			from Seguridad.tblUsuarios u    
			join RH.tblEmpleadosMaster e on u.IDEmpleado = e.IDEmpleado   
			where u.IDUsuario=@IDUsuario  and e.Vigente = 0  )  
		begin  
			raiserror('El empleado no se encuentra vigente!',16,1);  
			return;  
		end;  

		if not exists(select top 1 1   
					from Seguridad.TblUsuariosKeysActivacion  
					where ActivationKey = @key  
		)  
		begin  
			insert into [Seguridad].TblUsuariosKeysActivacion(IDUsuario,ActivationKey,AvaibleUntil,Activo)  
			select @IDUsuario,@key,dateadd(day,30,getdate()),1  
			
			exec Seguridad.spTransferirPermisosPerfilUsuario @IDUsuario = @IDUsuario,@IDUsuarioLogueado= 1, @IDPerfil = @IDPerfil
		end;  
	end 
	select     
		aKey.IDUsuarioKeysActivacion    
		,aKey.IDUsuario    
		,aKey.ActivationKey    
		,aKey.AvaibleUntil    
		,aKey.Activo    
		,isnull(aKey.CreationDate,getdate()) as CreationDate    
		,Vigente = case when u.IDEmpleado is null then cast(1 as bit) else isnull(e.Vigente,cast(0 as bit)) end  
	from Seguridad.TblUsuariosKeysActivacion  aKey    
		join Seguridad.tblUsuarios u on aKey.IDUsuario = u.IDUsuario  
		left join RH.tblEmpleadosMaster e on u.IDEmpleado = e.IDEmpleado   
	where aKey.ActivationKey = @key    
		--and akey.IDUsuario = @IDUsuario  
		and (aKey.Activo = 1)    
		and (aKey.AvaibleUntil >= cast(getdate() as date))
GO
