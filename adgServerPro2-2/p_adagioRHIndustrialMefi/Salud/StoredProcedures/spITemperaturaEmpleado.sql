USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc Salud.spITemperaturaEmpleado(
	 @ClaveEmpleado varchar(20) = null
	,@IDEmpleado int = 0
	,@FechaHora datetime
	,@Temperatura decimal(18,2) 
	,@IDUsuario int
) as
	declare 
		@ErrorMsg varchar(max) 
	;
	begin try
		if (@IDEmpleado > 0) 
		begin
			insert Salud.tblTemperaturaEmpleado(IDEmpleado, FechaHora,Temperatura)
			select @IDEmpleado, @FechaHora, @Temperatura
		end else 
		begin
			select @IDEmpleado = IDEmpleado 
			from RH.tblEmpleados with (nolock) 
			where ClaveEmpleado = @ClaveEmpleado
		
			insert Salud.tblTemperaturaEmpleado(IDEmpleado, FechaHora,Temperatura)
			select @IDEmpleado, @FechaHora, @Temperatura
		end
	end try
	begin catch
		set @ErrorMsg = ERROR_MESSAGE()
		raiserror(@ErrorMsg, 16,1)
	end catch
GO
