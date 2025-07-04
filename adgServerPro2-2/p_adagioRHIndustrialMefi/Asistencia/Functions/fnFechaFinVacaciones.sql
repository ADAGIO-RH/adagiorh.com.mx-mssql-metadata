USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 /****************************************************************************************************       
** Descripción  : Buscar los eventos del calendario duplicados Por Area/Departamento del storedProcedure   
** Autor   : Emmanuel Contreras     
** Email   : emmanuel.contreras@adagio.com.mx      
** FechaCreacion : 2022-03-30     
** Paremetros  :   
      @FechaInicio date      
      ,@FechaFin date      
      ,@IDUsuario
	  
** Notas: Tipos de eventos:       
    0 - No Vigente     
	1 - Incidencias		
	2 - Ausentismos		*
	3 - Horarios		
	4 - Checadas		
	5 - Papeletas
	6 - Festivos programados 
  
	select [Asistencia].[fnFechaFinVacaciones]('2020-12-14',3,'1,7',1)
   
****************************************************************************************************      
HISTORIAL DE CAMBIOS      
Fecha(yyyy-mm-dd) Autor   Comentario      
------------------- ------------------- ------------------------------------------------------------      

***************************************************************************************************/  
CREATE FUNCTION [Asistencia].[fnFechaFinVacaciones]
	(@Fecha date
	,@Duracion int,
	@DiasDescanso varchar(max)
	,@IDUsuario int)
	returns date as
BEGIN
	declare @FechaFin date
	exec @FechaFin = [Asistencia].[spFechaFinVacaciones] @Fecha,@Duracion,@DiasDescanso,@IDUsuario
	return @FechaFin
END
GO
