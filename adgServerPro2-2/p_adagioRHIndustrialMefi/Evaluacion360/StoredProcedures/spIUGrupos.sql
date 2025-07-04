USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Insertar / Actualizar Grupos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-09-25
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2018-11-26			Aneudy Abreu	Se agregó el parámetro IDCategoriaCompetencia
***************************************************************************************************/
CREATE proc [Evaluacion360].[spIUGrupos](
	 @IDGrupo int					
	,@IDTipoGrupo int		
	,@Nombre varchar(254)		
	,@Descripcion nvarchar(max)
	,@IDUsuario int	
	,@TipoReferencia int
	,@IDReferencia int
	,@IDTipoPreguntaGrupo int
	,@RequerirComentario bit  = 0
	,@IDTipoEvaluacion int = null
	,@Activo int = 1
) as
	
	declare 
		@IDEscalaValoracion int
		,@Min int = 0
		,@Max int = 0
		,@Row int = 0
	;

	if object_id('tempdb..#tempEscalaGrupo') IS NOT NULL DROP TABLE #tempEscalaGrupo;

	select 
		@Nombre			= [App].[fnRemoveVarcharSpace] (UPPER(@Nombre))
		,@Descripcion	= [App].[fnRemoveVarcharSpace] (UPPER(@Descripcion))
	;

	SET @IDTipoEvaluacion = CASE WHEN ISNULL(@IDTipoEvaluacion, 0) = 0 THEN NULL ELSE @IDTipoEvaluacion END;

	if (isnull(@IDGrupo, 0) = 0)
	begin
		if exists (select top 1 1 
					from [Evaluacion360].[tblCatGrupos]
					where IDTipoGrupo = @IDTipoGrupo AND Nombre = @Nombre and TipoReferencia = @TipoReferencia and IDReferencia = @IDReferencia and ISNULL(IDTipoEvaluacion, 0) = ISNULL(@IDTipoEvaluacion, 0))
		begin
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		end;

		insert into [Evaluacion360].[tblCatGrupos](
			IDTipoGrupo,
			Nombre,
			Descripcion,
			FechaCreacion,
			TipoReferencia,
			IDReferencia,
			IDTipoPreguntaGrupo,
			RequerirComentario,
			IDTipoEvaluacion,
			Activo
		)
		select 
			@IDTipoGrupo, 
			@Nombre, 
			@Descripcion,
			getdate(),
			@TipoReferencia,
			@IDReferencia,
			@IDTipoPreguntaGrupo,
			@RequerirComentario,
			@IDTipoEvaluacion,
			@Activo

		select @IDGrupo=@@IDENTITY
	end else
	begin
		if exists (select top 1 1 
					from [Evaluacion360].[tblCatGrupos]
					where IDTipoGrupo = @IDTipoGrupo AND Nombre = @Nombre and  IDGrupo <> @IDGrupo and TipoReferencia =  @TipoReferencia and IDReferencia = @IDReferencia AND ISNULL(IDTipoEvaluacion, 0) = ISNULL(@IDTipoEvaluacion, 0))
		begin
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		end;

		update [Evaluacion360].[tblCatGrupos]
			set 
				IDTipoGrupo		= @IDTipoGrupo
				,Nombre			= @Nombre
				,Descripcion	= @Descripcion
				,IDTipoPreguntaGrupo	= @IDTipoPreguntaGrupo
				,RequerirComentario		= @RequerirComentario
				,IDTipoEvaluacion		= @IDTipoEvaluacion
				,Activo					= @Activo
		where IDGrupo = @IDGrupo

		if (@IDTipoPreguntaGrupo = 2) 
		begin
			update Evaluacion360.tblCatPreguntas
				set IDTipoPregunta = 8
			where IDGrupo = @IDGrupo
		end;

		if (@IDTipoPreguntaGrupo = 3) 
		begin
			update Evaluacion360.tblCatPreguntas
				set IDTipoPregunta = 9
			where IDGrupo = @IDGrupo
		end;
	end;

	if (@IDTipoPreguntaGrupo = 3) and not exists (select top 1 1 
													from Evaluacion360.tblEscalasValoracionesGrupos 
													where IDGrupo = @IDGrupo
												)
	begin
		select *, ROW_NUMBER()over(order By Total asc) as [Row]
		INTO #tempEscalaGrupo
		from (
			select ev.IDEscalaValoracion,Sum(dev.Valor)  as Total
			from Evaluacion360.tblCatEscalaValoracion ev
				join Evaluacion360.tblDetalleEscalaValoracion dev on ev.IDEscalaValoracion = dev.IDEscalaValoracion
			Group by ev.IDEscalaValoracion 
		) escalas

		if exists (select top 1 1 from #tempEscalaGrupo)
		begin
			select @Min = min(Row)
					, @Max = max(row) from #tempEscalaGrupo

			set @Row = @Max / 2;

			select top 1 @IDEscalaValoracion = IDEscalaValoracion
			from #tempEscalaGrupo
			where [Row] = @Row		
			
			insert Evaluacion360.tblEscalasValoracionesGrupos (IDGrupo,Nombre,Valor)
			select @IDGrupo,Nombre, Valor
			from Evaluacion360.tblDetalleEscalaValoracion
			where IDEscalaValoracion = @IDEscalaValoracion
		end;
	end;

	exec [Evaluacion360].[spBuscarCatGrupos] 
			 @IDGrupo = @IDGrupo
			,@TipoReferencia=@TipoReferencia
			,@IDReferencia=@IDReferencia
			,@IDUsuario=@IDUsuario
GO
