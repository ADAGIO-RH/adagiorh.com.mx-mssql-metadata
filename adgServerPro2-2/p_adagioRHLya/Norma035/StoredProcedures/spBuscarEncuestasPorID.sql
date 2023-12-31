USE [p_adagioRHLya]
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
CREATE proc [Norma035].[spBuscarEncuestasPorID]
(@IDEncuesta INT)
as
BEGIN

	SELECT TE.[IDEncuesta] AS NUMENCUESTA
	  ,CASE
			WHEN TE.TodaEmpresa = 1 THEN EMP.NombreComercial
			ELSE TS.Descripcion
		END AS ENTIDAD
	  ,TIP.Descripcion AS TIPOENCUESTA
      ,CONVERT(date, TE.FechaIni) AS FECHAINI	
      ,CONVERT(date, TE.FechaFin) AS FECHAINI
	  ,TCE.Descripcion AS ESTATUS
	  ,TE.Cantidad as CANTIDAD
	  ,count(TEE.IDEncuestaEmpleado) AS PARTICIPACIONES
	FROM [Norma035].[tblEncuestaEmpleado] TEE
	right JOIN [Norma035].[tblEncuestas] TE ON TEE.IDEncuesta = TE.IDEncuesta
	JOIN [Norma035].[tblCatTiposEncuestas] TIP ON TE.IDTipoEncuesta = TIP.IDTipoEncuesta
	LEFT JOIN [RH].[tblEmpresa] EMP on TE.IDEntidad = EMP.IdEmpresa
	LEFT JOIN [RH].[tblCatSucursales] TS on TE.IDEntidad = TS.IDSucursal
	JOIN [Norma035].[tblCatEstatus] TCE ON TE.Estatus = TCE.IDEstatus
	WHERE TE.IDEncuesta = @IDEncuesta
	GROUP BY
		 TE.IDEncuesta
		,TE.TodaEmpresa
		,EMP.NombreComercial
		,TS.Descripcion
		,TE.FechaIni
		,TE.FechaFin
		,TIP.Descripcion
		,TCE.Descripcion
		,TE.Cantidad

	--select * from [Norma035].[tblEncuestas]
	--select * from [Norma035].[tblCatEstatus]
	--select * from [Norma035].[tblEncuestas] 
	--select * from [Norma035].[tblEncuestaEmpleado]
	--SELECT * FROM [RH].[tblEmpresa]
	--SELECT * FROM [RH].[tblCatSucursales]
	--SELECT * FROM [RH].[tblCatSucursales]

	end
GO
