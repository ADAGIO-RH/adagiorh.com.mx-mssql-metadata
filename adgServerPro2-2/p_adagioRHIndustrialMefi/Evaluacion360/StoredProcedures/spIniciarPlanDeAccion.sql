USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--create table Evaluacion360.tblPlanDeAccion(
--	IDPlanDeAccion int identity(1,1) not null constraint Pk_Evaluacion360TblPlanDeAccion_IDPlanDeAccion primary key
--	,IDEmpleadoProyecto int not null constraint Fk_Evaluacion360TblPlanDeAccion_Evaluacion360TblEmpleadosProyectos_IDEmpleadoProyecto foreign key references Evaluacion360.tblEmpleadosProyectos(IDEmpleadoProyecto) on delete cascade
--	,IDTipoGrupo int not null constraint Fk_Evaluacion360TblPlanDeAccion_Evaluacion360TblCatTipoGrupo_IDTipoGrupo foreign key references Evaluacion360.TblCatTipoGrupo(IDTipoGrupo)
--	,Grupo varchar(255) not null
--	,CalificacionActual decimal(18,2) constraint D_Evaluacion360TblPlanDeAccion_CalificacionActual default 0
--	,Acciones varchar(max)
--	,ResultadoEsperado decimal(18,2) constraint D_Evaluacion360TblPlanDeAccion_ResultadoEsperado default 0
--	,FechaCompromiso date
--	,IDUsuario int not null constraint Fk_Evaluacion360TblPlanDeAccion_SeguridadTblUsuarios foreign key references Seguridad.TblUsuarios (IDUsuario)
--	,FechaHora datetime constraint D_Evaluacion360TblPlanDeAccion_FechaHora default getdate()
--)
--GO
CREATE proc [Evaluacion360].[spIniciarPlanDeAccion](
  @IDEmpleadoProyecto int
	,@IDUsuario int
) as
	--declare
	--	@IDProyecto int = 22
	--	,@IDEmpleadoProyecto int = 128
	--	,@IDUsuario int = 1
	--;
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spIniciarPlanDeAccion]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblPlanDeAccion]',
		@Accion		varchar(20)	= 'INSERT',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	if object_id('tempdb..#temp') is not null drop table #temp;

	select  IDTipoGrupo
				,Grupo
				,cast(SUM(Respuesta)/count(*) as decimal(18,2))	as Respuesta
				,Orden

	into #temp
	from (
		select 
			ctg.IDTipoGrupo
			,ep.IDEmpleadoProyecto
			,g.Nombre						as Grupo
			,cast(SUM(isnull(rp.ValorFinal,0))/count(*) as decimal(18,2))	as Respuesta
			,ctg.Orden
		from Evaluacion360.tblEmpleadosProyectos ep			with (nolock) 
			join Evaluacion360.tblEvaluacionesEmpleados ee	with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
			--join Evaluacion360.tblCatProyectos p with (nolock)  on p.IDProyecto = ep.IDProyecto
			join Evaluacion360.tblCatGrupos g				with (nolock) on ee.IDEvaluacionEmpleado = g.IDReferencia and g.TipoReferencia = 4
			join Evaluacion360.tblCatTipoGrupo ctg			with (nolock) on g.IDTipoGrupo = ctg.IDTipoGrupo
			join Evaluacion360.tblCatPreguntas cp			with (nolock) on cp.IDGrupo = g.IDGrupo
			left join Evaluacion360.tblRespuestasPreguntas rp with (nolock) on cp.IDPregunta = rp.IDPregunta
		where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto  
		group by ctg.IDTipoGrupo,ep.IDEmpleadoProyecto,g.Nombre,cp.Descripcion,ctg.Orden
	) CaliPreguntas
	group by  IDTipoGrupo
			,Grupo
			,Orden

	begin try
		MERGE Evaluacion360.tblPlanDeAccion AS TARGET
		USING #temp as SOURCE
		on TARGET.IDEmpleadoProyecto = @IDEmpleadoProyecto
			and TARGET.IDTipoGrupo = SOURCE.IDTipoGrupo
			and TARGET.Grupo		= SOURCE.GRUPO
		WHEN MATCHED THEN
			update 
				set TARGET.CalificacionActual = SOURCE.Respuesta
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleadoProyecto,IDTipoGrupo,Grupo,CalificacionActual,IDUsuario)
			values(@IDEmpleadoProyecto,SOURCE.IDTipoGrupo,SOURCE.Grupo,SOURCE.Respuesta,@IDUsuario)
		WHEN NOT MATCHED BY SOURCE  and TARGET.IDEmpleadoProyecto = @IDEmpleadoProyecto THEN 
		DELETE;
	end try
	begin catch
		select 
			ERROR_MESSAGE()
	end catch

	SELECT @NewJSON ='['+ STUFF(
            ( select ','+ a.JSON
			from (
				select 
					 pda.IDPlanDeAccion
					,pda.IDEmpleadoProyecto
					,pda.IDTipoGrupo
					,ctg.Nombre as TipoGrupo
					,pda.Grupo
					,pda.CalificacionActual
					,pda.Acciones
					,pda.ResultadoEsperado
					,isnull(pda.FechaCompromiso,getdate()) as FechaCompromiso
					,pda.IDUsuario
					,pda.FechaHora
				from Evaluacion360.tblPlanDeAccion pda with (nolock)
					JOIN Evaluacion360.tblCatTipoGrupo ctg with (nolock) on ctg.IDTipoGrupo = pda.IDTipoGrupo
				where pda.IDEmpleadoProyecto = @IDEmpleadoProyecto 
				--order by ctg.Orden asc, pda.Grupo asc
			
			) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
												FOR xml path('')
            )
            , 1
            , 1
            , ''
		)+']'
	
	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra
	
	exec Evaluacion360.spBuscarPlanDeAccion @IDEmpleadoProyecto=@IDEmpleadoProyecto,@IDUsuario = @IDUsuario
	--select *
	-- from Evaluacion360.tblPlanDeAccion

	--select *
	--from #temp
	--order by Orden, Grupo
GO
