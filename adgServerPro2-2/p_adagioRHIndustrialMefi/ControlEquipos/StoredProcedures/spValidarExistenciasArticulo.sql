USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: valida el stock de articulos disponibles para asignacion y envia notificacion si
					  el stock es bajo
** Autor			: Justin Davila
** Email			: jdavila@adagio.com.mx
** FechaCreacion	: 2024-03-01
** Paremetros		:              
	

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE     proc [ControlEquipos].[spValidarExistenciasArticulo]
as
begin
	select 1
	print 1
end
GO
