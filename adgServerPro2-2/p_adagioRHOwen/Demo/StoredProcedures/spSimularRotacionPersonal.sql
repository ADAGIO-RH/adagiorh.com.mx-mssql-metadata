USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
into #TempFinalData
from #TempData E 
		LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD WITH(NOLOCK)
			on  TPD.IDTipoPrestacion = E.IDTipoPrestacion
            and (tpd.Antiguedad) = 1


-- SELECT * FROM #TempFinalData
-- RETURN
        

		
		insert into IMSS.tblMovAfiliatorios(  
			Fecha  
			,IDEmpleado  
			,IDTipoMovimiento  
			,IDRazonMovimiento  
			,SalarioDiario  
			,SalarioIntegrado  
			,SalarioVariable  
			,SalarioDiarioReal
			,IDRegPatronal)  

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
			,IDRegPatronal)  

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

/*
    borrar todos los movimientos despues del 15 de marzo de 2023
*/


/*

    INGRESAR BAJAS MASIVAS A PERSONAL
select m.*,ROW_NUMBER()OVER(partition by m.idempleado order by m.fecha desc) RN
	    into #tempUltimoMovimiento
	    from #TempData  E
		inner join IMSS.tblMovAfiliatorios M
		 on E.IDEmpleado = M.IDEmpleado
		 and m.Fecha >= e.FechaAntiguedad
		 and m.Fecha <= @FechaHoy
        
		 
	
		 delete #tempUltimoMovimiento
		 where RN > 1
    


insert into IMSS.tblMovAfiliatorios(  
			Fecha  
			,IDEmpleado  
			,IDTipoMovimiento  
			,IDRazonMovimiento  
			,SalarioDiario  
			,SalarioIntegrado  
			,SalarioVariable  
			,SalarioDiarioReal
			,IDRegPatronal)  

		select 
			'2023-03-30'
			,IDEmpleado  
			,2 AS IDTipoMovimiento
            ,2 AS IDRazonMovimiento
			,CAST(SalarioDiario AS DECIMAL(10,2)) SalarioDiario
			,CAST(SalarioIntegrado AS DECIMAL(10,2))  SalarioIntegrado 
			,CAST(SalarioVariable AS DECIMAL(10,2)) SalarioVariable
			,CAST(SalarioDiarioReal AS DECIMAL(10,2)) SalarioDiarioReal
			,IDRegPatronal 
		    --, d.Afecta
		from #tempUltimoMovimiento d 
		WHERE
		NOT EXISTS( SELECT 1
			FROM IMSS.tblMovAfiliatorios t2
			WHERE     '2023-03-30' = t2.Fecha
				  AND d.IDEmpleado = t2.IDEmpleado
				  AND (CAST(d.SalarioDiario AS DECIMAL(10,2))     = CAST(t2.SalarioDiario AS DECIMAL(10,2)))
				  AND (CAST(d.SalarioIntegrado AS DECIMAL(10,2))  = CAST(t2.SalarioIntegrado AS DECIMAL(10,2)))
				  AND (CAST(d.SalarioVariable AS DECIMAL(10,2))   = CAST(t2.SalarioVariable AS DECIMAL(10,2)))
				  AND (CAST(d.SalarioDiarioReal AS DECIMAL(10,2)) = CAST(t2.SalarioDiarioReal AS DECIMAL(10,2)))
				  AND d.IDRegPatronal = t2.IDRegPatronal) 

*/
GO
