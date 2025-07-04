USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: ?
** Autor			: ?
** Email			: ?
** FechaCreacion	: ?
** Paremetros		:  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2024-01-11		    Jose Vargas		Se añade el sp [IMSS].[spCalcularFechaAntiguedadMovAfiliatorios], despues de realizar modificaciones a la tabla de "IMSS.tblMovAfiliatorios" 
                                    para realizar el calculo de "FechaAntiguedad" y "IDTipoPrestacion"
 ***************************************************************************************************/
CREATE proc [Demo].[spSimularRotacionPersonal] (
	@FechaIni date
	,@FechaFin date

)as
DECLARE @FechaHoy DATE=@FechaIni

DECLARE 
     @MesInt INT = DATEPART(MONTH,@FechaHoy)
    ,@Mes VARCHAR(2)
    ,@Ejercicio VARCHAR(4)=CAST(DATEPART(YEAR,@FechaHoy) AS VARCHAR)
    ,@IDDatoExtraRotacion INT
    ;


IF OBJECT_ID('TEMPDB..#TempData') IS NOT NULL  
DROP TABLE #TempData

IF OBJECT_ID('TEMPDB..#tempUltimoMovimiento') IS NOT NULL  
DROP TABLE #tempUltimoMovimiento

IF OBJECT_ID('TEMPDB..#TempFinalData') IS NOT NULL  
DROP TABLE #TempFinalData

SET @Mes=CASE WHEN @MesInt<10 THEN CONCAT('0', CAST(@MesInt AS VARCHAR)) 
              ELSE CAST(@MesInt AS VARCHAR)
              END

SELECT @IDDatoExtraRotacion=IDDatoExtra FROM RH.tblCatDatosExtra WHERE NOMBRE='ROTACION'


SELECT E.*,CONCAT(@Ejercicio,'-',@Mes,'-0',CAST((FLOOR(RAND((E.IDEmpleado)/RAND()) * 9) + 1) AS VARCHAR)) AS FechaMovAlta,DATEADD(DAY,15,CONCAT(@Ejercicio,'-',@Mes,'-0',CAST((FLOOR(RAND((E.IDEmpleado)/RAND()) * 9) + 1) AS VARCHAR))) AS FechaMovBaja
INTO #TempData
FROM RH.tblEmpleadosMaster E
    INNER JOIN RH.tblDatosExtraEmpleados DEE
        ON E.IDEmpleado=DEE.IDEmpleado AND DEE.IDDatoExtra=@IDDatoExtraRotacion


DECLARE 
     @UMA decimal(10,2)
    ,@SalarioMinimo decimal(10,2)
    ,@UMATOPADA decimal(10,2);

SELECT TOP 1
        @UMA=UMA
       ,@SalarioMinimo=SalarioMinimo
	from Nomina.tblSalariosMinimos with (nolock)  
	where Year(Fecha) = @Ejercicio  
	order by Fecha desc 


SET @UMATOPADA=@UMA*25


UPDATE #TempData
    SET SalarioDiario=CASE WHEN SalarioDiario<@SalarioMinimo THEN @SalarioMinimo ELSE SalarioDiario END
    

Select E.IDEmpleado
      ,E.SalarioDiario
      ,0 AS SalarioVariable
      ,TPD.Factor
      ,CASE WHEN ((E.SalarioDiario * tpd.Factor))>=@UMATOPADA
       THEN @UMATOPADA
       ELSE (E.SalarioDiario * tpd.Factor)END AS SDI
      ,E.IDRegPatronal
      ,E.SalarioDiarioReal 
      ,E.FechaMovAlta
      ,E.FechaMovBaja
      ,E.IDTipoPrestacion
      ,E.FechaAntiguedad
into #TempFinalData
from #TempData E 
		LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD WITH(NOLOCK)
			on  TPD.IDTipoPrestacion = E.IDTipoPrestacion
            and (tpd.Antiguedad) = 1


		
		insert into IMSS.tblMovAfiliatorios(  
			Fecha  
			,IDEmpleado  
			,IDTipoMovimiento  
			,IDRazonMovimiento  
			,SalarioDiario  
			,SalarioIntegrado  
			,SalarioVariable  
			,SalarioDiarioReal
			,IDRegPatronal
            ,IDTipoPrestacion
            ,FechaAntiguedad
            )  
        
		select 
			FechaMovAlta
			,IDEmpleado  
			,3 AS IDTipoMovimiento
            ,1 AS IDRazonMovimiento
			,CAST(SalarioDiario AS DECIMAL(10,2)) SalarioDiario
			,CAST(SDI AS DECIMAL(10,2))  SalarioIntegrado 
			,CAST(SalarioVariable AS DECIMAL(10,2)) SalarioVariable
			,CAST(SalarioDiarioReal AS DECIMAL(10,2)) SalarioDiarioReal
			,IDRegPatronal 
            ,IDTipoPrestacion
            ,FechaAntiguedad
		from #TempFinalData d 
		WHERE
		NOT EXISTS( SELECT 1
			FROM IMSS.tblMovAfiliatorios t2
			WHERE     d.FechaMovAlta = t2.Fecha
				  AND d.IDEmpleado = t2.IDEmpleado
				  AND (CAST(d.SalarioDiario AS DECIMAL(10,2))     = CAST(t2.SalarioDiario AS DECIMAL(10,2)))
				  AND (CAST(d.SDI AS DECIMAL(10,2))  = CAST(t2.SalarioIntegrado AS DECIMAL(10,2)))
				  AND (CAST(d.SalarioVariable AS DECIMAL(10,2))   = CAST(t2.SalarioVariable AS DECIMAL(10,2)))
				  AND (CAST(d.SalarioDiarioReal AS DECIMAL(10,2)) = CAST(t2.SalarioDiarioReal AS DECIMAL(10,2)))
				  AND d.IDRegPatronal = t2.IDRegPatronal) 

        insert into IMSS.tblMovAfiliatorios(  
			Fecha  
			,IDEmpleado  
			,IDTipoMovimiento  
			,IDRazonMovimiento  
			,SalarioDiario  
			,SalarioIntegrado  
			,SalarioVariable  
			,SalarioDiarioReal
			,IDRegPatronal
            ,IDTipoPrestacion
            ,FechaAntiguedad
            )  
        
		select 
			FechaMovBaja
			,IDEmpleado  
			,2 AS IDTipoMovimiento
            ,2 AS IDRazonMovimiento
			,CAST(SalarioDiario AS DECIMAL(10,2)) SalarioDiario
			,CAST(SDI AS DECIMAL(10,2))  SalarioIntegrado 
			,CAST(SalarioVariable AS DECIMAL(10,2)) SalarioVariable
			,CAST(SalarioDiarioReal AS DECIMAL(10,2)) SalarioDiarioReal
			,IDRegPatronal 
            ,IDTipoPrestacion
            ,FechaAntiguedad
		from #TempFinalData d 
		WHERE
		NOT EXISTS( SELECT 1
			FROM IMSS.tblMovAfiliatorios t2
			WHERE     d.FechaMovBaja = t2.Fecha
				  AND d.IDEmpleado = t2.IDEmpleado
				  AND (CAST(d.SalarioDiario AS DECIMAL(10,2))     = CAST(t2.SalarioDiario AS DECIMAL(10,2)))
				  AND (CAST(d.SDI AS DECIMAL(10,2))  = CAST(t2.SalarioIntegrado AS DECIMAL(10,2)))
				  AND (CAST(d.SalarioVariable AS DECIMAL(10,2))   = CAST(t2.SalarioVariable AS DECIMAL(10,2)))
				  AND (CAST(d.SalarioDiarioReal AS DECIMAL(10,2)) = CAST(t2.SalarioDiarioReal AS DECIMAL(10,2)))
				  AND d.IDRegPatronal = t2.IDRegPatronal)  
                
    EXEC [IMSS].[spIUVigenciaEmpleado]
    EXEC [RH].[spSincronizarEmpleadosMaster]
GO
