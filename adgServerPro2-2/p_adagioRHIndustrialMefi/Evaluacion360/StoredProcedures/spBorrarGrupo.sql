USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Borrar grupos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-09-25
** Paremetros		:   
			@IDGrupo int
			@IDUsuario int				
			@ConfirmadoEliminar bit = 0
				    		  
** Notas: Temp table #tempResponse - TipoRespuesta
	 -1 - Sin respuesta
	  0 - Eliminado
	  1 - EsperaDeConfirmación           
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-06-14			Aneudy Abreu	Se agregó validación para que no se pueda eliminar un grupo de un 
									proyecto que esté en progreso o finalizado
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBorrarGrupo](
	@IDGrupo int
	,@IDUsuario int
	,@ConfirmadoEliminar bit = 0
) as
	declare 
		@t int = 0
		,@TipoReferencia int = 0 
		,@IDProyecto int
	;

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarGrupo]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblCatGrupos]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	if object_id('tempdb..#tempResponse') is not null drop table #tempResponse;

    create table #tempResponse(
	   ID int
	   ,Mensaje Nvarchar(max)
	   ,TipoRespuesta int
--	   ,ConfirmarEliminar bit default 0
    );

	select @TipoReferencia = TipoReferencia from Evaluacion360.tblCatGrupos where IDGrupo  = @IDGrupo

	if (@TipoReferencia = 1)
	begin
		if exists(select top 1 1
				from evaluacion360.tblcatgrupos cg
					join Evaluacion360.tblCatProyectos p on p.IDProyecto =  cg.IDReferencia
				where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia)
		begin
			select top 1 @IDProyecto = p.IDProyecto
			from evaluacion360.tblcatgrupos cg
				join Evaluacion360.tblCatProyectos p on p.IDProyecto =  cg.IDReferencia
			where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia
		end;
	end;

	if (@TipoReferencia = 4)
	begin
		if exists(select top 1 1
				from evaluacion360.tblcatgrupos cg
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEvaluacionEmpleado =  cg.IDReferencia
					join Evaluacion360.tblEmpleadosProyectos ep on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
				where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia)
		begin
			select top 1 @IDProyecto = ep.IDProyecto
			from evaluacion360.tblcatgrupos cg
				join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEvaluacionEmpleado =  cg.IDReferencia
					join Evaluacion360.tblEmpleadosProyectos ep on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
			where cg.IDGrupo = @IDGrupo and cg.TipoReferencia = @TipoReferencia
		end;
	end;

	if (@TipoReferencia in (1,4))
	begin
		begin try
			EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
		end try
		begin catch
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
			return 0;
		end catch
	end

	BEGIN TRY  
		if (not exists ( select top 1 1
			from Evaluacion360.tblCatPreguntas
			where IDGrupo = @IDGrupo) or @ConfirmadoEliminar = 1)
		begin

			SELECT @OldJSON ='['+ STUFF(
            ( select ','+ a.JSON
							from (
							select
								 eva.IDEscalaValoracionGrupo
								,eva.Nombre as Escala
								,eva.Valor as ValorEscala
								,ct.IDPregunta
								,ct.IDTipoPregunta
								,ct.Descripcion as Pregunta
								,ct.EsRequerida
								,ct.Calificar
								,ct.Box9
								,ct.IDCategoriaPregunta
								,ct.Box9EsRequerido
								,ct.Comentario
								,ct.ComentarioEsRequerido
								,ct.MaximaCalificacionPosible
								,ct.Vista
								,cg.IDGrupo
								,cg.IDTipoGrupo
								,cg.Nombre as Grupo
								,cg.Descripcion
								,cg.FechaCreacion
								,cg.TipoReferencia
								,cg.IDReferencia
								,cg.CopiadoDeIDGrupo
								,cg.IDTipoPreguntaGrupo
								,cg.TotalPreguntas
								,cg.MaximaCalificacionPosible as MaximaCalificacionPosibleGrupo
								,cg.CalificacionObtenida
								,cg.CalificacionMinimaObtenida
								,cg.CalificacionMaxinaObtenida
								,cg.Promedio
								,cg.Porcentaje
								,cg.IsDefault
								,cg.Peso
							from (select * from Evaluacion360.tblEscalasValoracionesGrupos where IDGrupo = @IDGrupo) eva
							cross apply ( select * from  Evaluacion360.tblCatPreguntas where IDGrupo = @IDGrupo	) ct
							cross apply ( select * from  [Evaluacion360].[tblCatGrupos] where IDGrupo = @IDGrupo	) cg
							
							) b
							Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
												FOR xml path('')
            )
            , 1
            , 1
            , ''
			)
			+']'
	
			delete from Evaluacion360.tblEscalasValoracionesGrupos where IDGrupo = @IDGrupo
			delete from Evaluacion360.TblRespuestasPreguntas where IDPregunta in (
				select IDPregunta 
				 from Evaluacion360.tblCatPreguntas 
				 where IDGrupo = @IDGrupo
			)
			delete from Evaluacion360.tblCatPreguntas where IDGrupo = @IDGrupo
			delete from [Evaluacion360].[tblCatGrupos] where IDGrupo = @IDGrupo

			EXEC [Auditoria].[spIAuditoria]
				@IDUsuario		= @IDUsuario
				,@Tabla			= @Tabla
				,@Procedimiento	= @NombreSP
				,@Accion		= @Accion
				,@NewData		= @NewJSON
				,@OldData		= @OldJSON
				,@Mensaje		= @Mensaje
				,@InformacionExtra		= @InformacionExtra

			select @IDGrupo as ID
			 ,'Grupo elimiando correctamente.' as Mensaje
			 ,0 as TipoRespuesta
		  return;
		end else 
		begin
			select @t=count(IDPregunta)
			from Evaluacion360.tblCatPreguntas
			where IDGrupo = @IDGrupo	
			
			select @IDGrupo as ID
			 ,'Este Grupo tiene '+cast(@t as varchar)+' pregunta(s) que serán eliminada(s).' as Mensaje
			 ,1 as TipoRespuesta

		  return;			
		end;
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO
