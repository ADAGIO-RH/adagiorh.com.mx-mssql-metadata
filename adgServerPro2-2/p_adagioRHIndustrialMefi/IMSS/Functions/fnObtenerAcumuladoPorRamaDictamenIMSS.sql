USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción     : Función para obtener acumulado por rama del dictamen
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2024-02-12
** Parámetros      :    
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE   FUNCTION [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS]
(@IDEmpleado INT,
 @IDRegistroPatronal INT,
 @FechaIni DATE,
 @FechaFin DATE,
 @Periodos Nomina.dtPeriodos READONLY,
 @ConceptosRamaDictamen VARCHAR(MAX)
)
RETURNS @tblAcumuladoPorRama TABLE 
(    
    IDEmpleado int PRIMARY KEY NOT NULL,   
    ImporteGravado Decimal(18,2)NULL, 
    ImporteExcento Decimal(18,2)NULL, 
	ImporteTotal1 Decimal(18,2)NULL, 
	ImporteTotal2 Decimal(18,2)NULL 
)
AS 
BEGIN
    
    

	INSERT INTO @tblAcumuladoPorRama(IDEmpleado,ImporteGravado,ImporteExcento,ImporteTotal1,ImporteTotal2)
	SELECT @IDEmpleado as IDEmpleado,		    		
		   ISNULL(SUM(detallePeriodo.ImporteGravado),0) as  ImporteGravado,
		   ISNULL(SUM(detallePeriodo.ImporteExcento),0) as  ImporteExcento,
		   ISNULL(SUM(detallePeriodo.ImporteTotal1),0) as  ImporteTotal1,
		   ISNULL(SUM(detallePeriodo.ImporteTotal2),0) as  ImporteTotal2
	FROM Nomina.tblDetallePeriodo detallePeriodo
		INNER JOIN @Periodos periodos
		        ON detallePeriodo.IDPeriodo = periodos.IDPeriodo
		       AND detallePeriodo.IDConcepto IN (select item from app.Split(@ConceptosRamaDictamen,','))
		       AND detallePeriodo.IDEmpleado = @IDEmpleado		  
		       AND periodos.Cerrado = 1               
        INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos historialEmpleadoPeriodo 
                ON historialEmpleadoPeriodo.IDEmpleado = detallePeriodo.IDEmpleado 
               AND historialEmpleadoPeriodo.IDPeriodo = periodos.IDPeriodo
	WHERE historialEmpleadoPeriodo.IDRegPatronal=@IDRegistroPatronal          
          AND (periodos.FechaInicioPago BETWEEN @FechaIni AND @FechaFin  OR periodos.FechaFinPago BETWEEN @FechaIni AND @FechaFin )
           


	RETURN;
END
GO
