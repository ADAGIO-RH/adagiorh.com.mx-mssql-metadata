USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Demo.spAutoResponderprueba as
	declare 
		@IDUsuario int = 1
		,@IDProyecto int = 4
		,@IDEvaluador int 
		,@IDEvaluacionEmpleado int 

		,@IDGrupo int
		,@IDTipoPreguntaGrupo int
		,@dtRespuestas [Evaluacion360].[dtRespuestaPregunta]

		,@IDPregunta int

		,@MinValueEscalaProyecto int
		,@MaxValueEscalaProyecto int

		,@MinValueEscalaGrupo int
		,@MaxValueEscalaGrupo int
	;

	declare @tempEscalaProyecto table (
		IDEscalaValoracionProyecto	int
		,IDProyecto	int	
		,Nombre	varchar(100)
		,Descripcion	varchar(255)		
		,Valor	int	
	)


	INSERT @tempEscalaProyecto	
	select * 
	from Evaluacion360.tblEscalasValoracionesProyectos 
	where IDProyecto = @IDProyecto

	select @MinValueEscalaProyecto= min(Valor)
		 ,@MaxValueEscalaProyecto = max(Valor)
	from @tempEscalaProyecto

	declare @tempEvaluaciones table (
		IDEmpleadoProyecto 		int
		,IDProyecto				int
		,IDEmpleado				int
		,ClaveEmpleado			varchar(20)
		,Colaborador			varchar(500)
		,IDEvaluacionEmpleado	int
		,IDTipoRelacion			int
		,Relacion				varchar(255)
		,IDEvaluador			int
		,ClaveEvaluador			varchar(20)
		,Evaluador				varchar(500)
		,Minimo					int
		,Maximo					int
		,Requerido				bit
		,CumpleTipoRelacion		bit
		,[Row]					int
		,IDEstatusEvaluacionEmpleado int
		,IDEstatus	int
		,Estatus	varchar(255)
		,Progreso  int
	);

	declare @tempPreguntasAResponder table(
		[IDGrupo] [int] NOT NULL,
		[IDTipoGrupo] [int] NOT NULL,
		[TipoGrupo] [varchar](100) NOT NULL,
		[Grupo] [varchar](254) NOT NULL,
		[DescripcionGrupo] [nvarchar](max) NULL,
		[FechaCreacion] [datetime] NOT NULL,
		[FechaCreacionStr] [nvarchar](15) NULL,
		[TipoReferencia] [int] NOT NULL,
		[IDReferencia] [int] NOT NULL,
		[CopiadoDeIDGrupo] [int] NOT NULL,
		[IDPregunta] [int] NOT NULL,
		[IDTipoPregunta] [int] NOT NULL,
		[Pregunta] [varchar](max) NOT NULL,
		[EsRequerida] [bit] NOT NULL,
		[Calificar] [bit] NOT NULL,
		[Box9] [bit] NOT NULL,
		[IDCategoriaPregunta] [int] NOT NULL,
		[CategoriaPregunta] [varchar](255) NOT NULL,
		[Completa] [bit] NULL,
		[Respuesta] [nvarchar](max) NULL,
		[Box9DesempenioActual] [int] NOT NULL,
		[Box9DesempenioFuturo] [int] NOT NULL,
		[GrupoEscala] [bit] NULL,
		[Box9EsRequerido] [bit] NOT NULL,
		[Comentario] [bit] NOT NULL,
		[ComentarioEsRequerido] [bit] NOT NULL,
		[TotalComentarios] [int] NULL,
		[Row] [bigint] NULL
	);  

	declare @tempGrupos table (
		IDGrupo int
		,IDTipoPreguntaGrupo int
	);

	insert @tempEvaluaciones
	exec Evaluacion360.spBuscarEvaluacionesEmpleadosPorProyecto @IDProyecto,@IDUsuario

	delete from @tempEvaluaciones where ISNULL(IDEvaluador,0) = 0 --or IDEvaluacionEmpleado > 60

	select @IDEvaluacionEmpleado = min(IDEvaluacionEmpleado) from @tempEvaluaciones

	while exists(select top 1 1 from @tempEvaluaciones where IDEvaluacionEmpleado >= @IDEvaluacionEmpleado)
	begin
		print @IDEValuacionEmpleado

		select @IDEvaluador = IDEvaluador
		from @tempEvaluaciones
		where IDEvaluacionEmpleado = @IDEvaluacionEmpleado

		delete from @tempPreguntasAResponder
		delete from @tempGrupos

		insert @tempPreguntasAResponder
		exec Evaluacion360.spBuscarPruebaARealizar @IDEValuacionEmpleado,@IDEvaluador

		insert @tempGrupos
		select distinct tp.IDGrupo,g.IDTipoPreguntaGrupo
		from @tempPreguntasAResponder tp
			join Evaluacion360.tblCatGrupos g on tp.IDGrupo = g.IDGrupo

		--select * from @tempGrupos
		--select g.*,tpr.* 
		--from @tempPreguntasAResponder tpr
		--	join @tempGrupos g on tpr.IDGrupo = g.IDGrupo
		--return

		select @IDGrupo = min(IDGrupo) from @tempGrupos
		while exists(select top 1 1 from @tempGrupos where IDGrupo >= @IDGrupo)
		begin
			print '@IDGrupo'
			print @IDGrupo

			select @IDTipoPreguntaGrupo = IDTipoPreguntaGrupo
			from @tempGrupos
			where IDGrupo = @IDGrupo

			delete from @dtRespuestas

			if (@IDTipoPreguntaGrupo = 1)
			begin
				BEGIN	-- Preguntas de Opción múltimples
					select @IDPregunta = min(IDPregunta) from @tempPreguntasAResponder where IDGrupo = @IDGrupo and IDTipoPregunta = 1

					while exists (select top 1 1 
								from @tempPreguntasAResponder 
								where IDGrupo = @IDGrupo and IDTipoPregunta = 1 and IDPregunta >= @IDPregunta)
					begin
						
						print '@IDPregunta'
						print @IDPregunta

						insert @dtRespuestas
						select top 1 @IDEvaluacionEmpleado as IDEvaluacionEmpleado
							  ,IDPregunta
							  ,Valor
							  ,NULL as Box9
						from Evaluacion360.tblPosiblesRespuestasPreguntas
						where IDPregunta = @IDPregunta
						order by NEWID()

						select  @IDPregunta = min(IDPregunta)
						from @tempPreguntasAResponder 
						where IDGrupo = @IDGrupo and IDTipoPregunta = 1 and IDPregunta > @IDPregunta
					end
				END
			end

			select @IDTipoPreguntaGrupo as IDTipoPreguntaGrupo
			if (@IDTipoPreguntaGrupo = 2)
			begin				
				select @IDGrupo as IDGrupo
				insert @dtRespuestas
				select @IDEvaluacionEmpleado as IDEvaluacionEmpleado
					  ,IDPregunta
					  ,ABS(CHECKSUM(NewId())) % @MaxValueEscalaProyecto as Valor
					  ,'' as Box9
				from @tempPreguntasAResponder
				where IDGrupo = @IDGrupo				

				insert @dtRespuestas
				select @IDEvaluacionEmpleado as IDEvaluacionEmpleado
					  ,IDPregunta
					  ,ABS(CHECKSUM(NewId())) % 3 as Valor
					  ,'actual' as Box9
				from @tempPreguntasAResponder
				where IDGrupo = @IDGrupo				

				insert @dtRespuestas
				select @IDEvaluacionEmpleado as IDEvaluacionEmpleado
					  ,IDPregunta
					  ,ABS(CHECKSUM(NewId())) % @MaxValueEscalaProyecto as Valor
					  ,'futuro' as Box9
				from @tempPreguntasAResponder
				where IDGrupo = @IDGrupo				
			end;

			select * from @dtRespuestas

			if exists (select top 1 1 from @dtRespuestas)
			begin
				select 'Si entré'
				exec Evaluacion360.spIURespuestaPregunta @dtRespuestas=@dtRespuestas, @IDUsuario = @IDUsuario
			end

			select @IDGrupo = min(IDGrupo) from @tempGrupos where IDGrupo > @IDGrupo
		end;
		--select * from @tempPreguntasAResponder --where IDTipoPreguntaGrupo =  2

		select @IDEvaluacionEmpleado = min(IDEvaluacionEmpleado) from @tempEvaluaciones where IDEvaluacionEmpleado > @IDEvaluacionEmpleado
	end;

	--select * from @tempEvaluaciones

	--select *
	--from Evaluacion360.tblEmpleadosProyectos ep
	--	join Evaluacion360.tblEvaluacionesEmpleados ee on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
	--where ep.IDProyecto = @IDProyecto

--exec Evaluacion360.spBuscarProyectos @IDUsuario = 1
GO
