USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Nomina.spBuscarCatBimestres
AS
BEGIN
	select 
	IDBimestre
	,Descripcion
	,Meses
	from Nomina.tblCatBimestres
END
GO
