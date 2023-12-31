USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Norma035].[spBuscarMisEncuestas](
	@IDEmpleado int
	,@IDUsuario int
)
as
BEGIN
	SELECT 
		TE.[IDEncuesta] AS NUMENCUESTA
	  ,CASE
			WHEN TE.TodaEmpresa = 1 THEN EMP.NombreComercial
			ELSE TS.Descripcion
		END AS ENTIDAD
	  ,TIP.Descripcion AS TIPOENCUESTA
      ,CONVERT(date, TE.FechaIni) AS FECHAINI	
      ,CONVERT(date, TE.FechaFin) AS FECHAFIN
	  ,isnull(TEE.Estatus,2) AS ESTATUS
	  ,TCE.Descripcion AS DESCESTATUS
	  ,CANTIDAD = (select COUNT(*)
					from Norma035.tblCatSeccion s
						join Norma035.tblCatPreguntas p on p.IDSeccion = s.IDSeccion
					where s.IDTipoEncuesta = TE.IDTipoEncuesta)
	  ,PARTICIPACIONES = (select COUNT(*)
							from Norma035.tblRespuestasEmpleados re
							where re.IDEncuestaEmpleado = TEE.IDEncuestaEmpleado
		)
	  --,count(TEE.IDEncuestaEmpleado) AS PARTICIPACIONES
	FROM [Norma035].[tblEncuestas] TE
		left JOIN [Norma035].[tblEncuestaEmpleado] TEE ON TEE.IDEncuesta = TE.IDEncuesta --and TEE.Estatus <> 4
		JOIN [Norma035].[tblCatTiposEncuestas] TIP ON TE.IDTipoEncuesta = TIP.IDTipoEncuesta
		LEFT JOIN [RH].[tblEmpresa] EMP on TE.IDEntidad = EMP.IdEmpresa
		LEFT JOIN [RH].[tblCatSucursales] TS on TE.IDEntidad = TS.IDSucursal
		JOIN [Norma035].[tblCatEstatus] TCE ON TE.Estatus = TCE.IDEstatus
	where tee.IDEmpleado = @IDEmpleado
	--GROUP BY
	--	 TE.IDEncuesta
	--	,TE.TodaEmpresa
	--	,EMP.NombreComercial
	--	,TS.Descripcion
	--	,TE.FechaIni
	--	,TE.FechaFin
	--	,TIP.Descripcion
	--	,TCE.Descripcion
	--	,TEE.Estatus 
	--	,TE.Cantidad
	end
GO
