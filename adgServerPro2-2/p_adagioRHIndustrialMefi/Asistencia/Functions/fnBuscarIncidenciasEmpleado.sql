USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
      
/****************************************************************************************************       
** Descripción  : Funcion que obtiene la cantidad de dias de Incidencia autorizadas de un empleado dentro de       
       un periodo de tiempo.      
** Autor   : Jose Roman      
** Email   : jose.roman@adagio.com.mx      
** FechaCreacion : 13-07-2018      
** Paremetros  :                    
****************************************************************************************************      
HISTORIAL DE CAMBIOS      
Fecha(yyyy-mm-dd) Autor   Comentario      
------------------- ------------------- ------------------------------------------------------------      
0000-00-00  NombreCompleto  ¿Qué cambió?      
2018-07-16  Jose Roman   Se modifica function para pasar una cadena mas larga de tipos      
         de incidencias por empleado.      
***************************************************************************************************/      
      
CREATE FUNCTION [Asistencia].[fnBuscarIncidenciasEmpleado](      
	@IDEmpleado int,      
	@IDIncidencia varchar(100),      
	@FechaIni date,      
	@FechaFin date      
)      
RETURNS int      
AS      
BEGIN      
      
	DECLARE @Incidencias INT=0;      
       
	select @Incidencias = ISNULL(COUNT(*),0)      
	from Asistencia.tblIncidenciaEmpleado IE      
		Inner join Asistencia.tblCatIncidencias I on IE.IDIncidencia = I.IDIncidencia      
	where IE.IDEmpleado = @IDEmpleado      
		AND I.IDIncidencia in( select Item from App.Split( @IDIncidencia,','))      
		AND IE.Fecha Between @FechaIni and @FechaFin      
		AND IE.Autorizado = 1;      
      
	RETURN @Incidencias;      
      
END
GO
