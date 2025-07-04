USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Asigna de forma automática evaluadores en una prueba
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019--06-27
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
create proc [Evaluacion360].[spAsignacionAutomaticaEvaluadores_OLD] (
	@IDUsuario		int
	,@IDProyecto	int
	,@SoloRequeridas bit = 0
) as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spAsignacionAutomaticaEvaluadores]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblEvaluacionesEmpleados]',
		@Accion		varchar(20)	= 'ASIGNACIÓN AUTOMÁTICA EVALUADORES',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;
	--declare
	--	@IDUsuario		int = 1
	--	,@IDProyecto	int = 3
	--	,@SoloRequeridas bit = 0
	--	;

	begin try
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	end try
	begin catch
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		--return 0;
	end catch

	select @InformacionExtra = a.JSON 
	from (
		select IDProyecto
			, Nombre
			, Descripcion
			, FORMAT(isnull(FechaCreacion, GETDATE()),'dd/MM/yyyy') as FechaCreacion
			, Progreso
			, @SoloRequeridas as SoloPruebasRequeridas
		from Evaluacion360.tblCatProyectos p 
		where IDProyecto = @IDProyecto
	) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		
	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra

	declare @ListaEmps table (
			IDEmpleado int 
	);

	declare @RelacionesProyecto table(
		IDEmpleadoProyecto	   int
		,IDProyecto			   int
		,IDEmpleado			   int
		,Colaborador		   varchar(500)
		,IDEvaluacionEmpleado  int
		,IDTipoRelacion		   int
		,Relacion			   varchar(100)
		,IDEvaluador		   int
		,Evaluador			   varchar(500)
		,Requerido 			   bit
	);

	if object_id('tempdb..#tempJefes') is not null drop table #tempJefes;
	if object_id('tempdb..#tempColegas') is not null drop table #tempColegas;
	if object_id('tempdb..#tempSubordinados') is not null drop table #tempSubordinados;

	insert @ListaEmps(IDEmpleado)
	select IDEmpleado 
	from Evaluacion360.tblEmpleadosProyectos with (nolock)
	where IDProyecto = @IDProyecto

	--select * 
	--from @ListaEmps e
	--	join RH.tblEmpleadosMaster emp with (nolock) on e.IDEmpleado = emp.IDEmpleado

	select e.IDEmpleado,emp.NOMBRECOMPLETO Empleado,je.IDJefe as IDJefeEvaluador, empJefe.NOMBRECOMPLETO as JefeEvaluador,0 as Factor
	INTO #tempJefes
	from @ListaEmps e
		join RH.tblJefesEmpleados je with (nolock) on je.IDEmpleado = e.IDEmpleado
		join RH.tblEmpleadosMaster emp with (nolock) on e.IDEmpleado = emp.IDEmpleado
		join RH.tblEmpleadosMaster empJefe with (nolock) on je.IDJefe = empJefe.IDEmpleado

	select j.IDEmpleado,j.Empleado
		--,j.IDJefeEvaluador,j.JefeEvaluador
		,colega.IDEmpleado as IDColegaEvaluador, colega.NOMBRECOMPLETO as ColegaEvaluador,0 as Factor
	INTO #tempColegas
	from #tempJefes j
		join RH.tblJefesEmpleados je with (nolock) on je.IDJefe = j.IDJefeEvaluador and je.IDEmpleado <> j.IDEmpleado
		join RH.tblEmpleadosMaster colega with (nolock) on je.IDEmpleado = colega.IDEmpleado
	order by j.IDEmpleado,j.IDJefeEvaluador,colega.IDEmpleado

	;WITH tempColegasCTE (IDEmpleado,duplicateRecCount)
	AS
	(
	SELECT IDEmpleado,ROW_NUMBER() OVER(PARTITION by IDEmpleado, Empleado,IDColegaEvaluador,ColegaEvaluador ORDER BY IDEmpleado) AS duplicateRecCount
	FROM #tempColegas
	)

	
	--Now Delete Duplicate Rows
	DELETE FROM tempColegasCTE
	WHERE duplicateRecCount > 1 

	select e.IDEmpleado,empJefe.NOMBRECOMPLETO as Empleado,je.IDEmpleado as IDSubordinadoEvaluador, emp.NOMBRECOMPLETO as SubordinadoEvaluador,0 as Factor
	INTO #tempSubordinados
	from @ListaEmps e
		join RH.tblJefesEmpleados je on je.IDJefe = e.IDEmpleado
		join RH.tblEmpleadosMaster empJefe on e.IDEmpleado = empJefe.IDEmpleado
		join RH.tblEmpleadosMaster emp on je.IDEmpleado = emp.IDEmpleado
	--select * from Evaluacion360.tblCatTiposRelaciones

	update e 
	set e.Factor = isnull(Total,0)
	from #tempJefes e
		left join (
			select  e.IDEmpleado,e.IDJefeEvaluador,count(*) as Total
			from #tempJefes e
				join Evaluacion360.tblEmpleadosProyectos ep on ep.IDEmpleado = e.IDEmpleado and ep.IDProyecto <> @IDProyecto
				join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto and ee.IDEvaluador = e.IDJefeEvaluador
							and ee.IDTipoRelacion =  1
			group by e.IDEmpleado,e.IDJefeEvaluador) t on e.IDEmpleado = t.IDEmpleado and e.IDJefeEvaluador = t.IDJefeEvaluador
	
	update e 
	set e.Factor = isnull(Total,0)
	from #tempColegas e
		left join (
			select  e.IDEmpleado,e.IDColegaEvaluador,count(*) as Total
			from #tempColegas e
				join Evaluacion360.tblEmpleadosProyectos ep on ep.IDEmpleado = e.IDEmpleado and ep.IDProyecto <> @IDProyecto
				join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto and ee.IDEvaluador = e.IDColegaEvaluador
							and ee.IDTipoRelacion =  3
			group by e.IDEmpleado,e.IDColegaEvaluador) t on e.IDEmpleado = t.IDEmpleado and e.IDColegaEvaluador = t.IDColegaEvaluador

	update e 
	set e.Factor = isnull(Total,0)
	from #tempSubordinados e
		left join (
			select  e.IDEmpleado,e.IDSubordinadoEvaluador,count(*) as Total
			from #tempSubordinados e
				join Evaluacion360.tblEmpleadosProyectos ep on ep.IDEmpleado = e.IDEmpleado and ep.IDProyecto <> @IDProyecto
				join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto and ee.IDEvaluador = e.IDSubordinadoEvaluador
							and ee.IDTipoRelacion = 2
			group by e.IDEmpleado,e.IDSubordinadoEvaluador) t on e.IDEmpleado = t.IDEmpleado and e.IDSubordinadoEvaluador = t.IDSubordinadoEvaluador

	--select * from #tempJefes			order by IDEmpleado
	--select * from #tempColegas		order by IDColegaEvaluador
	--select * from #tempSubordinados where IDEmpleado = 72 order by IDEmpleado 

	--select * 
	--from #tempColegas c
	--	join #tempJefes j on c.IDEmpleado = j.IDEmpleado and c.IDColegaEvaluador = j.IDJefeEvaluador

	--return
	--SELECT * FROM rh.tblJefesEmpleados where IDJefe  =197			

	insert @RelacionesProyecto
	exec [Evaluacion360].[spBuscarRelacionesProyecto]  
		 @IDProyecto =@IDProyecto 
		,@IDUsuario =@IDUsuario

	-- Se eliminan las personas que ya tienen evaluadores asignados
	delete t from @RelacionesProyecto p join #tempJefes		   t on p.IDEmpleado = t.IDEmpleado and p.IDEvaluador = t.IDJefeEvaluador
	delete t from @RelacionesProyecto p join #tempColegas	   t on p.IDEmpleado = t.IDEmpleado and p.IDEvaluador = t.IDColegaEvaluador
	delete t from @RelacionesProyecto p join #tempSubordinados t on p.IDEmpleado = t.IDEmpleado and p.IDEvaluador = t.IDSubordinadoEvaluador
	delete from @RelacionesProyecto where isnull(IDEvaluador,0) <> 0

--	select * from @RelacionesProyecto

	if (@SoloRequeridas = 1) delete from @RelacionesProyecto where isnull(Requerido,0) = 0
	
	BEGIN -- Se seleccionan las asignaciones según el factor
		-- Sección Jefes
		;WITH jefesCTE (IDEmpleado,duplicateRecCount)
		AS
		(
			SELECT IDEmpleado,ROW_NUMBER() OVER(PARTITION by IDJefeEvaluador ORDER BY IDJefeEvaluador,Factor asc) AS duplicateRecCount
			FROM #tempJefes
		)
		
		--select * from jefesCTE
		
		DELETE FROM jefesCTE
		WHERE duplicateRecCount > 1 

		-- Sección Colegas
		;WITH ColegasCTE (IDEmpleado,duplicateRecCount)
		AS
		(
			SELECT IDEmpleado,ROW_NUMBER() OVER(PARTITION by IDColegaEvaluador, Factor ORDER BY IDColegaEvaluador,Factor asc) AS duplicateRecCount
			FROM #tempColegas
		)

		DELETE FROM ColegasCTE
		WHERE duplicateRecCount > 1 

		-- Sección Subordinados
		;WITH subordinadosCTE (IDEmpleado,duplicateRecCount)
		AS
		(
			SELECT IDEmpleado,ROW_NUMBER() OVER(PARTITION by IDSubordinadoEvaluador, Factor ORDER BY IDSubordinadoEvaluador,Factor asc) AS duplicateRecCount
			FROM #tempSubordinados
		)

		DELETE FROM subordinadosCTE
		WHERE duplicateRecCount > 1 
	END;

	update r
	set r.IDEvaluador = j.IDJefeEvaluador
	from @RelacionesProyecto r 
		join #tempJefes j on r.IDEmpleado = j.IDEmpleado and r.IDTipoRelacion = 1

	update r
	set r.IDEvaluador = c.IDColegaEvaluador
	from @RelacionesProyecto r 
		join #tempColegas c on r.IDEmpleado = c.IDEmpleado and r.IDTipoRelacion = 3

	update r
	set r.IDEvaluador = s.IDSubordinadoEvaluador
	from @RelacionesProyecto r 
		join #tempSubordinados s on r.IDEmpleado = s.IDEmpleado and r.IDTipoRelacion = 2

	DECLARE @archive TABLE (
		ActionType VARCHAR(50),
		IDEvaluacionEmpleado int
	);

	;WITH tempRelacionesProyectoCTE (IDEmpleado,duplicateRecCount)
	AS
	(
		SELECT IDEmpleado,ROW_NUMBER() OVER(PARTITION by IDEmpleado ,IDEvaluador ORDER BY IDEmpleado) AS duplicateRecCount
		FROM @RelacionesProyecto
	)
	--Now Delete Duplicate Rows
	DELETE FROM tempRelacionesProyectoCTE
	WHERE duplicateRecCount > 1 

	delete @RelacionesProyecto where isnull(IDEvaluador,0) = 0

	BEGIN TRY
		BEGIN TRAN TransEvaEmpProyecto
			MERGE [Evaluacion360].[tblEvaluacionesEmpleados] AS TARGET
			USING @RelacionesProyecto as SOURCE
			on TARGET.IDEmpleadoProyecto = SOURCE.IDEmpleadoProyecto 
			 and TARGET.IDTipoRelacion = SOURCE.IDTipoRelacion
			 and isnull(TARGET.IDEvaluador,0) = 0
			WHEN MATCHED THEN
				update 
				 set TARGET.IDEvaluador = SOURCE.IDEvaluador
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleadoProyecto,IDTipoRelacion,IDEvaluador)
				values(SOURCE.IDEmpleadoProyecto,SOURCE.IDTipoRelacion, SOURCE.IDEvaluador)
			--WHEN NOT MATCHED BY SOURCE and TARGET.IDTipoRelacion = 4 THEN 
			--DELETE
			OUTPUT
			$action AS ActionType,
			inserted.IDEvaluacionEmpleado
			INTO @archive;

		COMMIT TRAN TransEvaEmpProyecto			
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN TransEvaEmpProyecto

		select ERROR_MESSAGE() 
	END CATCH

	
	insert [Evaluacion360].[tblEstatusEvaluacionEmpleado](IDEvaluacionEmpleado,IDEstatus,IDUsuario)
	select IDEvaluacionEmpleado,11,@IDUsuario from @archive

	--select *
	--from @RelacionesProyecto r
	--	left join Evaluacion360.tblEvaluacionesEmpleados ee on r.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
--return


--	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null drop table #tempHistorialEstatusEvaluacion;

--	select ee.*,eee.IDEstatusEvaluacionEmpleado
--		,eee.IDEstatus
--		,eee.IDUsuario
--		,eee.FechaCreacion 
--		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
--							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
--	INTO #tempHistorialEstatusEvaluacion
--	from [Evaluacion360].[tblEvaluacionesEmpleados] ee
--		join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
--		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = ep.IDEmpleado and dfe.IDUsuario = @IDUsuario
--		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
--	where ep.IDProyecto = @IDProyecto 

--	select
--		 ee.IDEvaluacionEmpleado
--		,ee.IDEmpleadoProyecto
--		,ee.IDTipoRelacion
--		,cte.Relacion
--		,ee.IDEvaluador
--		,eva.ClaveEmpleado as ClaveEvaluador
--		,eva.NOMBRECOMPLETO as Evaluador
--		,ep.IDProyecto
--		,p.Nombre as Proyecto
--		,ep.IDEmpleado
--		,emp.ClaveEmpleado 
--		,emp.NOMBRECOMPLETO as Colaborador
--		,thee.IDEstatusEvaluacionEmpleado
--		,thee.IDEstatus
--		,estatus.Estatus
--		,thee.IDUsuario
--		,thee.FechaCreacion		
--		,isnull(ee.Progreso,0) as Progreso -- = case when isnull(thee.IDEstatus,0) = 13 then 100 else floor(RAND()*(100-0)+0) end
--	from [Evaluacion360].[tblEvaluacionesEmpleados] ee 
--		join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
--		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = ep.IDEmpleado and dfe.IDUsuario = @IDUsuario
--		left join #tempHistorialEstatusEvaluacion thee on ee.IDEvaluacionEmpleado = thee.IDEvaluacionEmpleado and thee.[ROW]  = 1
--		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on thee.IDEstatus = estatus.IDEstatus
--		join [Evaluacion360].[tblCatTiposRelaciones] cte on ee.IDTipoRelacion = cte.IDTipoRelacion
--		join [RH].[tblEmpleadosMaster] emp on ep.IDEmpleado = emp.IDEmpleado
--		left join [RH].[tblEmpleadosMaster] eva on ee.IDEvaluador = eva.IDEmpleado
--		join [Evaluacion360].[tblCatProyectos] p on ep.IDProyecto = p.IDProyecto
--	where ep.IDProyecto = @IDProyecto 

--	exec [Evaluacion360].[spBuscarPruebasPorProyecto] @IDProyecto = @IDProyecto, @Tipo =3, @IDUsuario = 1
GO
