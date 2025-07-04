USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spEncabezadoReportesIndividuales] --51
(
	@IDEncuestaEmpleado int
)
AS
BEGIN

Declare @IdiomaSQL varchar(50)
	set @IdiomaSQL = 'Spanish' ;
	SET LANGUAGE @IdiomaSQL; 

--	DECLARE @IDEncuestaEmpleado int = 51	

Select EE.IDEncuesta
	, E.IDCatEncuesta
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
where ee.IDEncuestaEmpleado = @IDEncuestaEmpleado
END;
GO
