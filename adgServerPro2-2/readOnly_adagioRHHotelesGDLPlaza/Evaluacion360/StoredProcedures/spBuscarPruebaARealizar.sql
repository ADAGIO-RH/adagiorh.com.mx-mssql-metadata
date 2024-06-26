USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca e inicializa una Evaluación de empleado
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-01-31			Aneudy Abreu	

***************************************************************************************************/
/*
        IDTipoGrupo:
            1 : Competencia
            2 : Objetivo KPIs
            3 : Valores

        TipoReferencia:
            0 : Catálogo
            1 : Asignado a una Proyecto
            2 : Asignado a un colaborador
            3 : Asignado a un puesto
            4 : Asignado a una Prueba final para responder
    */
CREATE proc [Evaluacion360].[spBuscarPruebaARealizar](
	@IDEvaluacionEmpleado int 
	,@IDEvaluador int
)
as
declare 
	@IDProyecto int --= 28
	,@IDEmpleado int --= 149
--	,@IDEvaluacionEmpleado int = 105661
	,@IDPuesto int = 0
	,@IDEmpleadoEvaluador int 
	;
	select 
		@IDProyecto = ep.IDProyecto
		,@IDEmpleado = ep.IDEmpleado
		,@IDEmpleadoEvaluador = ev.IDEvaluador
	from [Evaluacion360].[tblEvaluacionesEmpleados] ev with (nolock)
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ep.IDEmpleadoProyecto = ev.IDEmpleadoProyecto
	where ev.IDEvaluacionEmpleado = @IDEvaluacionEmpleado

	if not exists(select top 1 1 
				from [Evaluacion360].[tblCatGrupos] with (nolock)
				where TipoReferencia = 4 and IDReferencia = @IDEvaluacionEmpleado)
	begin
		-- Se Copian las compencias del puesto del colaborador
		select @IDPuesto = IDPuesto
		from [RH].[tblEmpleadosMaster]
		where IDEmpleado = @IDEmpleado

		if exists(select top 1 1
				from [Evaluacion360].[tblCatGrupos] with (nolock)
				where TipoReferencia = 3 and IDReferencia = @IDPuesto)
		begin
			exec [Evaluacion360].[spCopiarGrupo] @CopiarDeTipoReferencia = 3  
							,@CopiarDeIDReferencia = @IDPuesto 
							,@ATipoReferencia = 4 
							,@AIDReferencia = @IDEvaluacionEmpleado
		end;

		-- Se copian las competencias del Colaborador
		if exists(	select top 1 1
				from [Evaluacion360].[tblCatGrupos] with (nolock)
				where TipoReferencia = 2 and IDReferencia = @IDEmpleado)
		begin
			exec [Evaluacion360].[spCopiarGrupo] @CopiarDeTipoReferencia = 2 
							,@CopiarDeIDReferencia = @IDEmpleado 
							,@ATipoReferencia = 4 
							,@AIDReferencia = @IDEvaluacionEmpleado
		end;

		-- Se copian las Competencias del proyecto
		if exists(	select top 1 1
				from [Evaluacion360].[tblCatGrupos] with (nolock)
				where TipoReferencia = 1 and IDReferencia = @IDProyecto)
		begin
			exec [Evaluacion360].[spCopiarGrupo] @CopiarDeTipoReferencia = 1
							,@CopiarDeIDReferencia = @IDProyecto 
							,@ATipoReferencia = 4 
							,@AIDReferencia = @IDEvaluacionEmpleado
		end;

	end;

	exec [Evaluacion360].[spBuscarPreguntasAResponder] @TipoReferencia = 4, @IDReferencia = @IDEvaluacionEmpleado, @IDUsuario = @IDEvaluador
	--exec [Evaluacion360].[spBuscarCatGrupos] @TipoReferencia = 4, @IDReferencia = @IDEvaluacionEmpleado, @IDUsuario = @IDEvaluador

	--select *
	--from [Evaluacion360].[tblCatGrupos] with (nolock)
	--where TipoReferencia = 4 and IDReferencia = @IDEvaluacionEmpleado

	--select *
	--from [Evaluacion360].[tblCatGrupos] g with (nolock)
	----	join [Evaluacion360].[tblCatGrupos] gCopiado on g.CopiadoDeIDGrupo = gCopiado.IDGrupo
 -- 	join [Evaluacion360].[tblCatPreguntas] p on g.IDGrupo = p.IDGrupo
	--where g.TipoReferencia = 4 --and g.IDReferencia = 105661


	--delete [Evaluacion360].[tblCatGrupos]  where TipoReferencia = 4 and IDReferencia = @IDEvaluacionEmpleado

	--delete [Evaluacion360].tblCatGrupos
	--where IDGrupo in (
	
	
	--select g.IDGrupo
	--from [Evaluacion360].[tblCatGrupos] g with (nolock)
	----	join [Evaluacion360].[tblCatGrupos] gCopiado on g.CopiadoDeIDGrupo = gCopiado.IDGrupo
	----	join [Evaluacion360].[tblCatPreguntas] p on g.IDGrupo = p.IDGrupo
	--where g.TipoReferencia = 4 --and g.IDReferencia = 105661

	--)
GO
