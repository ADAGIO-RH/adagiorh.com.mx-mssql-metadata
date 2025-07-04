USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spGenerarScheduleVacaciones]  
AS  
BEGIN  
        DECLARE 
         @IDScheduleVacaciones INT
        ,@ProcName NVARCHAR(MAX)
        ,@SQL NVARCHAR(MAX);

        SELECT @IDScheduleVacaciones = MIN(IDScheduleVacaciones) FROM app.tblScheduleVacaciones Where Generado = 0 AND Masivo = 1

        WHILE @IDScheduleVacaciones <= (Select MAX(IDScheduleVacaciones) FROM app.tblScheduleVacaciones Where Generado = 0 AND Masivo = 1)
        BEGIN
         
            SELECT @ProcName = StoredProcedure FROM app.tblScheduleVacaciones Where IDScheduleVacaciones = @IDScheduleVacaciones
 
            SET @SQL = 'EXEC ' + @ProcName

            --PRINT @IDScheduleVacaciones

            UPDATE app.tblScheduleVacaciones
            SET Generado = 1 , FechaHoraGeneracion = GETDATE()
            Where IDScheduleVacaciones = @IDScheduleVacaciones 

            EXEC sp_executesql @SQL; 

            SET @IDScheduleVacaciones = (Select MIN(IDScheduleVacaciones) FROM app.tblScheduleVacaciones Where Generado = 0 AND Masivo = 1 AND IDScheduleVacaciones > @IDScheduleVacaciones ) 
        END

END
GO
