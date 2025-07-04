USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spListaEmpleadosReportesGenerales](
	@IDEncuesta int
)
AS
BEGIN
	Declare 
		@IdiomaSQL varchar(50)
	;

	set @IdiomaSQL = 'Spanish' ;
	SET LANGUAGE @IdiomaSQL; 

	Select 
		--EE.IDEncuesta
		--, E.IDCatEncuesta
		--, EE.IDEncuestaEmpleado
		E.NombreEncuesta as [ENCUESTA]
		, CE.Descripcion as [TIPO DE ENCUESTA]
		, M.ClaveEmpleado as [CLAVE COLABORADOR]
		, M.NOMBRECOMPLETO as COLABORADOR
		, M.Departamento as DEPARTAMENTO
		, M.Puesto as PUESTO
		, M.Sucursal as SUCURSAL
		, M.Empresa as [RAZÓN SOCIAL]
		, EE.Resultado as RESULTADO
		, EE.RequiereAtencion as [REQUIERE ATENCIÓN]
		,Utilerias.fnDateToStringByFormat(EE.FechaUltimaActualizacion,'FL',@IdiomaSQL) as [FECHA ÚLTIMA ACTUALIZACIÓN]
	from Norma35.tblEncuestasEmpleados EE
		inner join Norma35.tblEncuestas E on EE.IDEncuesta = E.IDEncuesta
		inner join Norma35.tblCatEncuestas CE on E.IDCatEncuesta = CE.IDCatEncuesta
		inner join RH.tblEmpleadosMaster M on EE.IDEmpleado = M.IDEmpleado
	where ee.IDEncuesta = @IDEncuesta
	order by m.ClaveEmpleado asc
END;
GO
