USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spBuscarAcumuladoPorMesyEmpresaConceptosEmpleados_SURFAX] (

	@Ejercicio INT,
	@CodigosConceptos VARCHAR(MAX) = NULL,
	@dtEmpleados RH.dtEmpleados READONLY,
	@IDUsuario INT,
	@IDEmpresa INT = NULL,
	@IDMes INT

) AS

	DECLARE
		@FechaInicial DATE = FORMATMESSAGE('%d-01-01', @Ejercicio),
		@FechaFin DATE = FORMATMESSAGE('%d-12-31', @Ejercicio)
	
	;

	SELECT
		IDEmpleado,
		ClaveEmpleado, 
		Colaborador, 
		IDConcepto,
		CodigoConcepto, 
		Concepto, 
		Periodo,
		Total,
		OrdenCalculo
	FROM (
		SELECT 
			E.IDEmpleado,
			E.ClaveEmpleado, 
			E.NOMBRECOMPLETO AS Colaborador, 
			C.IDConcepto,
			C.Codigo AS CodigoConcepto, 
			C.Descripcion AS Concepto,
			DP.IDPeriodo AS Periodo,
			SUM(isnull(DP.ImporteTotal1,0)) AS Total, 
			C.OrdenCalculo
		FROM RH.tblEmpleadosMaster E WITH (NOLOCK) 
			INNER JOIN Nomina.tblDetallePeriodo DP WITH (NOLOCK) ON E.IDEmpleado = DP.IDEmpleado
			INNER JOIN Nomina.tblCatPeriodos P WITH (NOLOCK) ON DP.IDPeriodo = P.IDPeriodo AND ISNULL(P.Cerrado,0) = 1 AND P.IDMes = @IDMes AND P.Ejercicio = @Ejercicio
			INNER JOIN Nomina.tblCatConceptos C WITH (NOLOCK) ON DP.IDConcepto = C.IDConcepto
			INNER JOIN (SELECT EE.IDEmpleado, EE.FechaIni AS EmpresaInicio, EE.FechaFin AS EmpresaFin 
						FROM RH.tblEmpresaEmpleado EE 
						WHERE EE.IDEmpresa = @IDEmpresa
						) Fempresa ON Fempresa.IDEmpleado = E.IDEmpleado
		WHERE (C.Codigo IN (SELECT Item FROM App.Split(@CodigosConceptos, ',')) OR @CodigosConceptos IS NULL) AND
			  (E.IDEmpleado IN (SELECT IDEmpleado FROM @dtEmpleados) OR (SELECT COUNT(IDEmpleado) FROM @dtEmpleados) = 0) AND 
			   P.FechaFinPago BETWEEN Fempresa.EmpresaInicio AND Fempresa.EmpresaFin
		GROUP BY E.IDEmpleado, E.ClaveEmpleado, E.NOMBRECOMPLETO, C.IDConcepto, C.Codigo, C.Descripcion, DP.IDPeriodo, C.OrdenCalculo
	) AS [DATA]
	ORDER BY ClaveEmpleado, OrdenCalculo
GO
