USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtener Encuestas
** Autor			: Denzel Ovando
** Email			: denzel.ovando@adagio.com.mx
** FechaCreacion	: 2020-06-17
** Paremetros		:               
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE proc [Norma035].[spBuscarReporteEncuestasPorID]
(@IDEncuesta INT)
as
BEGIN
	DECLARE @TotalPreguntas int;

	
	SELECT @TotalPreguntas = COUNT(*)
	FROM  [Norma035].[tblEncuestas]
	INNER JOIN [Norma035].[tblCatTiposEncuestas] on [Norma035].[tblCatTiposEncuestas].IDTipoEncuesta=[Norma035].[tblEncuestas].IDTipoEncuesta
	INNER JOIN [Norma035].[tblCatSeccion] on [Norma035].[tblCatSeccion].IDTipoEncuesta=[Norma035].[tblEncuestas].IDTipoEncuesta
	INNER JOIN [Norma035].[tblCatPreguntas]  on [Norma035].[tblCatPreguntas].IDSeccion =[Norma035].[tblCatSeccion].IDSeccion	
	WHERE [Norma035].[tblEncuestas].IDEncuesta = @IDEncuesta;

	 

	SELECT 
		CONCAT(TE.Nombre,' ',TE.SegundoNombre,' ',TE.Paterno,' ',TE.Materno) AS NOMBREEMPLEADO,
		TD.Descripcion AS DEPARTAMENTO,
		CP.Descripcion AS PUESTO,
		(
			(SELECT (COUNT(*)  *100)/@TotalPreguntas 
			FROM [Norma035].tblEncuestaEmpleado
			inner join [Norma035].[tblRespuestasEmpleados] 
			on [Norma035].[tblRespuestasEmpleados].IDEncuestaEmpleado= [Norma035].tblEncuestaEmpleado.IDEncuestaEmpleado
			WHERE [Norma035].tblEncuestaEmpleado.IDEncuesta=@IDEncuesta  and 
			[Norma035].tblEncuestaEmpleado.IDEmpleado=TE.IDEmpleado)
		) as porcentaje
		,E.FechaIni
		,E.FechaFin
		,E.Cantidad
		,TEE.Estatus
		,TEE.IDEmpleado



	FROM [Norma035].[tblEncuestaEmpleado] TEE
	join RH.tblEmpleados TE on TEE.IDEmpleado = TE.IDEmpleado
	join RH.tblDepartamentoEmpleado DE on TE.IDEmpleado = DE.IDEmpleado
	join RH.tblCatDepartamentos TD on DE.IDDepartamento = TD.IDDepartamento
	JOIN RH.tblPuestoEmpleado PE on TE.IDEmpleado = PE.IDEmpleado
	JOIN RH.tblCatPuestos CP on PE.IDPuesto = CP.IDPuesto
	join Norma035.tblEncuestas E on E.IDEncuesta = TEE.IDEncuesta
	WHERE TEE.IDEncuesta = @IDEncuesta







	end
GO
