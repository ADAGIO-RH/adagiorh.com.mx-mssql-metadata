USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: valida que los articulos con fecha de entrega pasada ya hayan sido entregados
					  y envia notificacion si no han sido entregados los articulos
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
CREATE     proc [ControlEquipos].[spValidarDevolucionDeArticulo]
as
begin
	select 1
	print 1
end
GO
