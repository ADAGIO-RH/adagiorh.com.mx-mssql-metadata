USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Function para obtener Anios de diferencia entre dos fechas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 20-12-2018
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/


CREATE function [Evaluacion360].[fnBuscarProgresoWizardUsuario]
(

	@IDWizardUsuario int
)
returns Decimal(18,2)
AS
BEGIN
	declare @TotalItems decimal(10,2)
	,@Completos  decimal(10,2)
	

	select 
		@TotalItems= count(*)
		,@Completos= SUM(case when Completo = 1 then 1 else 0 end)
		--,SUM(case when Completo = 0 then 1 else 0 end)
	from [Evaluacion360].[tblDetalleWizardUsuario]
	where IDWizardUsuario = @IDWizardUsuario

  return (@Completos * 100.0) / @TotalItems
END
GO
