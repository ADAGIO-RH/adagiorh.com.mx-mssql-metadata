USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spListaEmpleadosReportesGenerales] --22
(
	@IDEncuesta int
)
AS
BEGIN

Declare @IdiomaSQL varchar(50)
	set @IdiomaSQL = 'Spanish' ;
	SET LANGUAGE @IdiomaSQL; 

--	DECLARE @IDEncuestaEmpleado int = 51	

Select EE.IDEncuesta
	, E.IDCatEncuesta
	, EE.IDEncuestaEmpleado
	,CE.Descripcion as TipoEncuesta
	, M.ClaveEmpleado
	,M.NOMBRECOMPLETO as NombreCompleto
	, M.Departamento
	, M.Puesto
	, M.Sucursal
	, M.Empresa as RazonSocial
	, EE.Resultado
	, EE.RequiereAtencion
	,Utilerias.fnDateToStringByFormat(EE.FechaUltimaActualizacion,'FL',@IdiomaSQL) as FechaUltimaActualizacion
from Norma35.tblEncuestasEmpleados EE
			inner join Norma35.tblEncuestas E
				on EE.IDEncuesta = E.IDEncuesta
			inner join Norma35.tblCatEncuestas CE
				on E.IDCatEncuesta = CE.IDCatEncuesta
			inner join RH.tblEmpleadosMaster M
				on EE.IDEmpleado = M.IDEmpleado
where ee.IDEncuesta = @IDEncuesta
order by m.ClaveEmpleado asc
END;
GO
