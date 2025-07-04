USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author.............: Ing. Aneudy Abreu  
-- Create date........: 15/Oct/2012  
-- Last Date Modified.: 15/Oct/2012  
-- Description: Retorna en formato de Time la diferencia entre las dos horas recibidas por parametro.   
--  
-- Versión....: 1.0  
-- =============================================  
CREATE FUNCTION [Asistencia].[DIFFTIME](@HoraFin as time,@HoraInicio as time)  
RETURNS time AS  
BEGIN  
 --esta funcion obtiene la diferencia de horas: HoraFin-HoraInicio, y devuelve el resultado en formato tiempo,siempre devuelve el resultado positivo  
 DECLARE  
 @sols int,@tsolucion time  
   
 SET @sols=DATEDIFF(SECOND,@HoraInicio,@HoraFin)--diferencia en segundos  
 SET @tsolucion=convert(time,dateadd(SECOND,@sols,0))  
 RETURN @tsolucion   
END
GO
