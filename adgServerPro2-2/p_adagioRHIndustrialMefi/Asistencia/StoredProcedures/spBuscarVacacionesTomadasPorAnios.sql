USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Calcula el historial de saldos de vacaciones de un colaborador  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2019-01-01  
** Paremetros  :                
  
 Si se modifica el result set de este sp será necesario modificar los siguientes SP's:  
  [Asistencia].[spBuscarVacacionesPendientesEmpleado]  
  
** DataTypes Relacionados:   [Asistencia].[dtSaldosDeVacaciones]  
  
  
[Asistencia].[spBuscarVacacionesTomadasPorAnios] 390,1  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
  
CREATE proc [Asistencia].[spBuscarVacacionesTomadasPorAnios] --390,1
(  
   @IDUsuario int  
  ,@dtPagination [Nomina].[dtFiltrosRH] READONLY              
  ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY
) as  
  
	IF EXISTS(Select top 1 1 from app.tblConfiguracionesGenerales CG where IDConfiguracion = 'RefactorizacionVacaciones' and Valor = 1)
    BEGIN
    print 'REFACTOR PROCEDURE'
		/*
			EXEC REFACTOR  STORE PROCEDURE 
		*/

    EXEC [Asistencia].[spBuscarVacacionesTomadasPorAniosRefactor] 
			 @IDUsuario	    = @IDUsuario
			,@dtPagination	= @dtPagination
			,@dtFiltros  	= @dtFiltros
    
    END
    ELSE
    BEGIN
    EXEC [Asistencia].[spCoreBuscarVacacionesTomadasPorAnios] 
			 @IDUsuario	    = @IDUsuario
			,@dtPagination	= @dtPagination
			,@dtFiltros  	= @dtFiltros
    END
GO
