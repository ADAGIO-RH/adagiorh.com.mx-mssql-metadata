USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**************************************************************************************************** 
** Descripción		: Procedimiento para obtener los días por Prima de Antiguedad
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 08-08-2019
** Paremetros		:              

[Nomina].[spBuscarPrimaDeAntiguedad] 72, '2019-08-08',1

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [Nomina].[spBuscarPrimaDeAntiguedad](
	@IDEmpleado int
	,@FechaBaja date
	,@FechaAntiguedad date = null
	,@AniosAntiguedad int = null
	,@IDUsuario int
)as
--declare 
--	@IDEmpleado int = 72
--	,@FechaBaja date = '2019-08-05'
--	;
--declare
--	 @FechaAntiguedad date
--	,@AniosAntiguedad int
--	;

	if (@FechaAntiguedad is null)
	begin
		select   
			@FechaAntiguedad = isnull(e.FechaAntiguedad,getdate())  
		from [RH].[tblEmpleados] e with (nolock)  
		where e.IDEmpleado = @IDEmpleado  
	end;

	if (isnull(@AniosAntiguedad,0) = 0)
	begin
		SELECT @AniosAntiguedad = DATEDIFF(day,@FechaAntiguedad,@FechaBaja) / 365.2425  
	end;

	select @AniosAntiguedad as Anios, 12 as DiasPorAnio, @AniosAntiguedad * 12 as PrimaAntiguedad
GO
