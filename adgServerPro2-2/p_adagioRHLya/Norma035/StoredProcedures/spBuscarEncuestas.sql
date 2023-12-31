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
CREATE proc [Norma035].[spBuscarEncuestas]
(@Admin INT = 0
,@IDUsuario INT)
as
BEGIN
	IF (@Admin = 1)
	BEGIN
			--Cambia el status de las encuestas terminadas
	/*	UPDATE  [Norma035].[tblEncuestas] 
	SET Estatus = 3
        from [Norma035].[tblEncuestas]  INNER JOIN 
        (
            SELECT  IDEncuestaEmpleado,
                    COUNT(*) AS EncuestasRealizadas
            FROM [Norma035].[tblEncuestaEmpleado]
            GROUP BY IDEncuestaEmpleado
        ) p
            ON IDEncuesta = p.IDEncuestaEmpleado
		where Cantidad = p.EncuestasRealizadas


	--cambia el status de las encuestas expíradas
	UPDATE  [Norma035].[tblEncuestas] 
	SET Estatus = 4
	where FechaFin <= GETDATE()
	*/

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
	  ,TE.Cantidad as CANTIDAD
	  ,count(TEE.IDEncuestaEmpleado) AS PARTICIPACIONES
	FROM [Norma035].[tblEncuestaEmpleado] TEE
		right JOIN [Norma035].[tblEncuestas] TE ON TEE.IDEncuesta = TE.IDEncuesta
		JOIN [Norma035].[tblCatTiposEncuestas] TIP ON TE.IDTipoEncuesta = TIP.IDTipoEncuesta
		LEFT JOIN [RH].[tblEmpresa] EMP on TE.IDEntidad = EMP.IdEmpresa
		LEFT JOIN [RH].[tblCatSucursales] TS on TE.IDEntidad = TS.IDSucursal
		JOIN [Norma035].[tblCatEstatus] TCE ON TE.Estatus = TCE.IDEstatus
	--where TEE.Estatus = 4
	GROUP BY
		 TE.IDEncuesta
		,TE.TodaEmpresa
		,EMP.NombreComercial
		,TS.Descripcion
		,TE.FechaIni
		,TE.FechaFin
		,TIP.Descripcion
		,TCE.Descripcion
		,TEE.Estatus 
		,TE.Cantidad
	END

	ELSE

	BEGIN
		PRINT 'NOT DEVELOPED YET'
	END




	--select * from [Norma035].[tblEncuestas]
	--select * from [Norma035].[tblCatEstatus]
	--select * from [Norma035].[tblEncuestas] 
	--select * from [Norma035].[tblEncuestaEmpleado]
	--SELECT * FROM [RH].[tblEmpresa]
	--SELECT * FROM [RH].[tblCatSucursales]
	--SELECT * FROM [RH].[tblCatSucursales]

	end
GO
