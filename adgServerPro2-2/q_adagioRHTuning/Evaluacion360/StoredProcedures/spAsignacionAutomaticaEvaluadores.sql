USE [q_adagioRHTuning]
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
CREATE proc [Evaluacion360].[spAsignacionAutomaticaEvaluadores] (
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

	DECLARE @archive TABLE (
		ActionType VARCHAR(50),
		IDEvaluacionEmpleado int
	);

	if object_id('tempdb..#tempEvaluadores') is not null drop table #tempEvaluadores;
	if object_id('tempdb..#tempHistorialEvaluadores') is not null drop table #tempHistorialEvaluadores;
	if object_id('tempdb..#tempRelacionesProyecto') is not null drop table #tempRelacionesProyecto;

	insert @RelacionesProyecto
	exec [Evaluacion360].[spBuscarRelacionesProyecto]  
		 @IDProyecto =@IDProyecto 
		,@IDUsuario =@IDUsuario

	delete @RelacionesProyecto where IDTipoRelacion = 4

	if (isnull(@SoloRequeridas, 0) = 1) 
	begin
		delete @RelacionesProyecto where ISNULL(Requerido, 0) = 0
	end

	select *, ROW_NUMBER()OVER(partition by IDEmpleado, IDTipoRelacion order by Total asc) as RN
	INTO #tempHistorialEvaluadores
	from (
		select
			ep.IDEmpleado, 
			ee.IDTipoRelacion , 
			ee.IDEvaluador,
			count(*) as Total
		from  Evaluacion360.tblEmpleadosProyectos ep 
			join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
			join RH.tblEmpleadosMaster e on e.IDEmpleado = ep.IDEmpleado and isnull(e.Vigente, 0) = 1
		where ep.IDProyecto <> @IDProyecto and ee.IDTipoRelacion <> 4
		group by ep.IDEmpleado, ee.IDTipoRelacion , ee.IDEvaluador
	) info
		
	delete the
	from #tempHistorialEvaluadores the
		join @RelacionesProyecto rp on rp.IDEmpleado = the.IDEmpleado 
			and rp.IDEvaluador = the.IDEvaluador
			and rp.IDTipoRelacion = the.IDTipoRelacion

	delete @RelacionesProyecto where isnull(IDEvaluacionEmpleado, 0) > 0

	select *, ROW_NUMBER()OVER(partition by IDEmpleado, IDTipoRelacion order by IDEmpleado asc) as RN
	INTO #tempRelacionesProyecto
	from @RelacionesProyecto

	update trp
		set trp.IDEvaluador = the.IDEvaluador
	from #tempRelacionesProyecto trp
		join #tempHistorialEvaluadores the on the.IDEmpleado = trp.IDEmpleado
			and the.IDTipoRelacion = trp.IDTipoRelacion
			and the.RN = trp.RN

	BEGIN TRY
		BEGIN TRAN TransEvaEmpProyecto
			MERGE [Evaluacion360].[tblEvaluacionesEmpleados] AS TARGET
			USING #tempRelacionesProyecto as SOURCE
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
	
	if object_id('tempdb..#tempEvaluadores') is not null drop table #tempEvaluadores;
	if object_id('tempdb..#tempHistorialEvaluadores') is not null drop table #tempHistorialEvaluadores;
	if object_id('tempdb..#tempRelacionesProyecto') is not null drop table #tempRelacionesProyecto;
GO
