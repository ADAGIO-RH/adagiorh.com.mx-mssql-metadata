USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Calcula la fecha de antiguedad y IDTipoPrestacion en la tabla de IMSS.tblMovAfiliatorios
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-11
** Paremetros		:   
				    
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
 ***************************************************************************************************/
CREATE PROCEDURE [IMSS].[spScheduleCalcularFechaAntiguedadMovAfiliatorios]
AS
BEGIN

    DECLARE 
    @IDEmpleado INT 

    SELECT @IDEmpleado = MIN(IDEmpleado) FROM IMSS.tblMovAfiliatorios WHERE FechaAntiguedad IS NULL OR IDTipoPrestacion IS NULL


    WHILE( @IDEmpleado < (SELECT MAX(IDEmpleado) FROM IMSS.tblMovAfiliatorios WHERE FechaAntiguedad IS NULL or IDTipoPrestacion IS NULL) )

    BEGIN

        EXEC [IMSS].[spCalcularFechaAntiguedadMovAfiliatorios] @IDEmpleado = @IDEmpleado    
        SELECT @IDEmpleado = MIN(IDEmpleado) FROM IMSS.tblMovAfiliatorios WHERE (FechaAntiguedad IS NULL OR IDTipoPrestacion IS NULL ) AND IDEmpleado > @IDEmpleado
    END
END
GO
