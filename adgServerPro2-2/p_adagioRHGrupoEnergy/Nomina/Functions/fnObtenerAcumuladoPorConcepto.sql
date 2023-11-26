USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Nomina].[fnObtenerAcumuladoPorConcepto]
(@IDEmpleado int,
 @IDConcepto int,
 @Ejercicio int
)
RETURNS @tblAcumuladoPorConcepto TABLE 
(
    -- Columns returned by the function
    IDEmpleado int PRIMARY KEY NOT NULL, 
    IDConcepto int NULL, 
    Ejercicio int NULL, 
    ImporteGravado Decimal(18,2)NULL, 
    ImporteExento Decimal(18,2)NULL, 
	ImporteTotal1 Decimal(18,2)NULL, 
	ImporteTotal2 Decimal(18,2)NULL 
)
AS 
BEGIN
	insert into @tblAcumuladoPorConcepto(IDEmpleado,IDConcepto,Ejercicio,ImporteGravado,ImporteExento,ImporteTotal1,ImporteTotal2)
	Select @IDEmpleado as IDEmpleado,
		   @IDConcepto as IDConcepto,
		   @Ejercicio as Ejercicio,
		   ISNULL(SUM(DP.ImporteGravado),0) as  ImporteGravado,
		   ISNULL(SUM(DP.ImporteExcento),0) as  ImporteExcento,
		   ISNULL(SUM(DP.ImporteTotal1),0) as  ImporteTotal1,
		   ISNULL(SUM(DP.ImporteTotal2),0) as  ImporteTotal2
	from Nomina.tblDetallePeriodo DP
		Inner join Nomina.tblCatPeriodos P
		  on DP.IDPeriodo = P.IDPeriodo
		  AND DP.IDConcepto = @IDConcepto
		  AND DP.IDEmpleado = @IDEmpleado
		  AND P.Ejercicio = @Ejercicio
		  AND P.Cerrado = 1
	
	RETURN;
END
GO
