USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE STPS.spBuscarEstatusCursosEmpleados
AS
BEGIN
	select IDEstatusCursoEmpleados
		,Descripcion 
	from STPS.tblEstatusCursosEmpleados
END
GO
