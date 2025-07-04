USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Guarda y Actualiza Configuraciones de Semáforos de Cuestionario
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2020-06-09
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Salud].[spIUConfiguracionSemaforo](
	 @IDConfiguracionSemaforo int = 0
	,@IDCuestionario int
	,@ValorInicio decimal(18,2)
	,@ValorFinal decimal(18,2) 
	,@Color int /* 0: Verde 1: Amarillo 2: Rojo */
	,@IDUsuario int
) as

	if (@IDConfiguracionSemaforo = 0)
	begin
		insert [Salud].[tblConfiguracionSemaforo](IDCuestionario,ValorInicio,ValorFinal,Color)
		select @IDCuestionario,@ValorInicio,@ValorFinal,@Color

		set @IDConfiguracionSemaforo = @@IDENTITY
	end else
	begin
		update [Salud].[tblConfiguracionSemaforo]
			set 
				ValorInicio = @ValorInicio
				,ValorFinal = @ValorFinal
				,Color = @Color
		where IDConfiguracionSemaforo = @IDConfiguracionSemaforo
	end

	exec [Salud].[spBuscarConfiguracionSemaforo] @IDConfiguracionSemaforo = @IDConfiguracionSemaforo, @IDUsuario= @IDUsuario
GO
