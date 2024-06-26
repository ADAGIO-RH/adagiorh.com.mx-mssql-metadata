USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Intranet].[spBuscarRecibosNominaEmpleados](
	@IDEmpleado int = 0,
	@IDUsuario int
)
AS
BEGIN
	SELECT T.IDHistorialEmpleadoPeriodo,
		 HEP.IDEmpleado,
		 HEP.IDPeriodo,
		 P.FechaFinPago,
		 P.ClavePeriodo,
		 P.Descripcion ,
		 ROW_NUMBER()OVER(Order by T.IDHistorialEmpleadoPeriodo Desc) as ROWNUMBER
	FROM Facturacion.TblTimbrado T WITH(NOLOCK)
	INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK)
		on T.IDHistorialEmpleadoPeriodo = HEP.IDHistorialEmpleadoPeriodo
	INNER JOIN Nomina.TblCatPeriodos P WITH(NOLOCK)
		on P.IDPeriodo = HEP.IDPeriodo
	WHERE 
	T.Actual = 1 and T.IDEstatusTimbrado in (SELECT IDEstatusTimbrado from Facturacion.tblCatEstatusTimbrado where DESCRIPCION = 'TIMBRADO')
	AND 
	(HEP.IDEmpleado = @IDEmpleado  )
	ORDER BY P.FechaFinPago DESC
END
GO
