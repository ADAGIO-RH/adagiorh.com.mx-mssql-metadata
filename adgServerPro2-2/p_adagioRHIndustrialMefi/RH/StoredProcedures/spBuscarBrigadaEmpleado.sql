USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spBuscarBrigadaEmpleado] --0,30
(
     @IDBrigadaEmpleado int = 0
    ,@IDEmpleado int = 0
)
AS
BEGIN
		Select 
		     BE.IDBrigadaEmpleado,
			 BE.IDEmpleado,
			 BE.Brigadas
			 into #temp
		from RH.tblBrigadasEmpleado BE
		
		WHERE (BE.IDEmpleado = @IDEmpleado and @IDBrigadaEmpleado=0) or (BE.IDBrigadaEmpleado = @IDBrigadaEmpleado and @IDEmpleado=0)

		IF((Select count(*) from #temp) = 0)
		BEGIN
			Select 0 as IDBrigadaEmpleado,
				@IDEmpleado as IDEmpleado,
				'' as Brigadas	
		END
		ELSE
		BEGIN
			Select * from #temp
		END

		Drop table #temp
END
GO
