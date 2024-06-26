USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarDepartamentoEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select 
		     DE.IDDepartamentoEmpleado,
			DE.IDEmpleado,
			DE.IDDepartamento,
			D.Codigo,
			D.Descripcion as Departamento,
			DE.FechaIni,
			DE.FechaFin
		From RH.tblDepartamentoEmpleado DE
			inner join RH.tblCatDepartamentos D
				on DE.IDDepartamento = D.IDDepartamento
		Where DE.IDEmpleado = @IDEmpleado
		ORDER BY DE.FechaIni DESC
END
GO
