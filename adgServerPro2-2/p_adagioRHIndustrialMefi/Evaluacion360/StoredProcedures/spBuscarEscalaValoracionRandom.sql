USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Selecciona de forma aleatoria una escala de valoración del catálogo
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-03-22
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc Evaluacion360.spBuscarEscalaValoracionRandom
as
	declare 
		@IDEscalaValoracion int
		,@Min int = 0
		,@Max int = 0
		,@Row int = 0
		,@i int = 0
		;

		while not exists(select top 1 1
			from Evaluacion360.tblDetalleEscalaValoracion with (nolock)
			where IDEscalaValoracion = @IDEscalaValoracion )
		begin
			select @Min = min(IDEscalaValoracion)
				, @Max = max(IDEscalaValoracion) 
			from Evaluacion360.tblCatEscalaValoracion with (nolock)
		
			SELECT @IDEscalaValoracion = FLOOR(RAND()*(@Max-@Min+1)+@Min);			 

			--print @IDEscalaValoracion

			set @i = @i + 1;

			if (@i >= 100)
			break
		end;

		select *
		from Evaluacion360.tblDetalleEscalaValoracion with (nolock)
		where IDEscalaValoracion = @IDEscalaValoracion

--[Evaluacion360].[spBuscarDetalleEscalaValoracion]  @IDEscalaValoracion = 3
GO
