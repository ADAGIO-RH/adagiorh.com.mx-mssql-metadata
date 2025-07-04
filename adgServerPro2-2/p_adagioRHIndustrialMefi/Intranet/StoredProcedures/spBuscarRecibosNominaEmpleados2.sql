USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [d_adagioRH]
--GO
--/****** Object:  StoredProcedure [Intranet].[spBuscarRecibosNominaEmpleados]    Script Date: 05/07/2022 07:57:54 p. m. ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON

--[Intranet].[spBuscarRecibosNominaEmpleados] 1279,1
--GO
CREATE PROCEDURE [Intranet].[spBuscarRecibosNominaEmpleados2](
	@IDEmpleado int = 0,
	@IDUsuario int
)
AS
BEGIN
	--SELECT isnull(T.IDHistorialEmpleadoPeriodo, 0) as IDHistorialEmpleadoPeriodo,
	--	 isnull(HEP.IDEmpleado,@IDEmpleado) as IDEmpleado,
	--	 p.IDPeriodo,
	--	 P.FechaFinPago,
	--	 P.ClavePeriodo,
	--	 P.Descripcion ,
	--	 ROW_NUMBER()OVER(Order by T.IDHistorialEmpleadoPeriodo Desc) as ROWNUMBER
	--FROM Nomina.TblCatPeriodos P
	--	LEFT JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK) on HEP.IDPeriodo = p.IDPeriodo
	--	LEFT JOIN Facturacion.TblTimbrado T WITH(NOLOCK) on T.IDHistorialEmpleadoPeriodo = HEP.IDHistorialEmpleadoPeriodo
	--WHERE isnull(p.Cerrado, 0) = 1 AND (HEP.IDEmpleado = @IDEmpleado  )
	--	--T.Actual = 1 and T.IDEstatusTimbrado in (SELECT IDEstatusTimbrado from Facturacion.tblCatEstatusTimbrado where DESCRIPCION = 'TIMBRADO') AND (HEP.IDEmpleado = @IDEmpleado  )
	--ORDER BY P.FechaFinPago DESC

	SELECT 
		T.IDHistorialEmpleadoPeriodo,
		 HEP.IDEmpleado,
		 HEP.IDPeriodo,
		 P.FechaFinPago,
		 P.ClavePeriodo,
		 P.Descripcion ,
		 ROW_NUMBER()OVER(Order by T.IDHistorialEmpleadoPeriodo Desc) as ROWNUMBER
	FROM Facturacion.TblTimbrado T WITH(NOLOCK)
		INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK) on T.IDHistorialEmpleadoPeriodo = HEP.IDHistorialEmpleadoPeriodo
		INNER JOIN Nomina.TblCatPeriodos P WITH(NOLOCK) on P.IDPeriodo = HEP.IDPeriodo
	WHERE isnull(p.Cerrado, 0) = 1 and T.Actual = 1 and T.IDEstatusTimbrado in (SELECT IDEstatusTimbrado from Facturacion.tblCatEstatusTimbrado where DESCRIPCION = 'TIMBRADO') AND (HEP.IDEmpleado = @IDEmpleado  )
	ORDER BY P.FechaFinPago DESC
END
GO
