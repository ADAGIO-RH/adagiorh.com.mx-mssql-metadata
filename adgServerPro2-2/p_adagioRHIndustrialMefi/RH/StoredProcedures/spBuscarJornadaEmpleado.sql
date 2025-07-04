USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarJornadaEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select
		   JE.IDJornadaEmpleado, 
			JE.IDEmpleado,
			JE.IDJornada,
			TJ.Codigo,
			TJ.Descripcion Jornada,
			JE.FechaIni,
			JE.FechaFin
		From RH.tblJornadaEmpleado JE
			Inner join Sat.tblCatTiposJornada TJ
				on JE.IDJornada = @IDEmpleado
		ORDER by JE.FechaIni Desc
END
GO
