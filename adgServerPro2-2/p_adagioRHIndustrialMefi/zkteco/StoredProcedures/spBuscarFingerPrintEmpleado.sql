USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [zkteco].[spBuscarFingerPrintEmpleado](
	@IDEmpleado int
) as
	declare 
		@PIN varchar(20)
	;

	select 
		@PIN = cast(stuff(ClaveEmpleado, 1, patindex('%[0-9]%', ClaveEmpleado)-1, '') as bigint)
	from RH.tblEmpleados
	where IDEmpleado = @IDEmpleado

	select 
		IDFingerPrintEmpleado
		,IDEmpleado
		,Content
		,FechaReg
	from zkteco.tblFingerPrintEmpleado
	where IDEmpleado = @IDEmpleado
	UNION ALL
	select 
		 0 as IDFingerPrintEmpleado
		,@IDEmpleado as IDEmpleado
		,Tmp as Content
		,getdate() as FechaReg
	from [zkteco].[tblTmpFP] 
	where PIN = @PIN
GO
