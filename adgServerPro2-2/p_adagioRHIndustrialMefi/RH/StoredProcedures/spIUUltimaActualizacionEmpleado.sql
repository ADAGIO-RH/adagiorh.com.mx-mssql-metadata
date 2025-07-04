USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE proc [RH].[spIUUltimaActualizacionEmpleado](
	@IDEmpleado int
 ) as
	if (not exists (select top 1 1 
					from RH.tblUltimaActualizacionEmpleados 
					where IDEmpleado = @IDEmpleado)
					and ISNULL(@IDEmpleado,0) > 0
					)
	begin
		insert RH.tblUltimaActualizacionEmpleados(IDEmpleado,Fecha)
		select @IDEmpleado, GETDATE()
	end else
	begin
		update RH.tblUltimaActualizacionEmpleados
			set Fecha = GETDATE()
		where IDEmpleado = @IDEmpleado
	end
GO
