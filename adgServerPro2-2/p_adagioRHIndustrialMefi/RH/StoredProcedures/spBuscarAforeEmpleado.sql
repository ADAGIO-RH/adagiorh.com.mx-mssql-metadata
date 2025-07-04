USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [RH].[spBuscarAforeEmpleado] --0,30
(
     @IDAforeEmpleado int = 0
    ,@IDEmpleado int = 0
)
AS
BEGIN
		Select 
		     AE.IDAforeEmpleado,
			 AE.IDEmpleado,
			 AE.IDAfore
			 into #temp
		from RH.tblAforeEmpleado AE
		
		WHERE (AE.IDEmpleado = @IDEmpleado and @IDAforeEmpleado=0) or (AE.IDAforeEmpleado = @IDAforeEmpleado and @IDEmpleado=0)

		IF((Select count(*) from #temp) = 0)
		BEGIN
			Select 0 as IDAforeEmpleado,
				@IDEmpleado as IDEmpleado,
				0 as IDAfore	
		END
		ELSE
		BEGIN
			Select * from #temp
		END

		Drop table #temp
END
GO
