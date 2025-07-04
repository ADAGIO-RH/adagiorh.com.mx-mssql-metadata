USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [Evaluacion360].[spBorrarProyecto](
	@IDProyecto int  
	,@IDUsuario int  
	,@ConfirmadoEliminar bit = 0
	) as

	declare @t int = 0
		,@dtProyecto [Evaluacion360].[dtProyectos]
		,@IDGrupo int = 0
		,@SQLScriptSelect nvarchar(max)
		,@SQLScriptDelete nvarchar(max)
		,@EVALUACION0001 bit = 0 -- Puede eliminar cualquier prueba
		,@NombreUsuario varchar(255) = ''
		,@IDUsuarioCreoPrueba int = 0
	;

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spBorrarProyecto]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblCatGrupos]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'EVALUACION0001')
	begin
		set @EVALUACION0001 = 1
	end;

	insert @dtProyecto
	exec [Evaluacion360].[spBuscarProyectos] @IDUsuario=@IDUsuario

	select top 1 @IDUsuarioCreoPrueba = p.IDUsuario
			,@NombreUsuario = coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'')
	from @dtProyecto p
		join Seguridad.tblUsuarios u on p.IDUsuario = u.IDUsuario
	where p.IDProyecto = @IDProyecto

	if ((@IDUsuario <> @IDUsuarioCreoPrueba) and (@EVALUACION0001 = 0))
	begin
		
		select @IDProyecto as ID
			,'Esta prueba solo puede ser elimina por '+coalesce(@NombreUsuario,'') as Mensaje
			,'Solo puedes borrar las pruebas que has creado tu.' as Titulo
			,2 as TipoRespuesta

		return;		
	end

	--if object_id('tempdb..#tempGrupos') is not null drop table #tempGrupos;
	if object_id('tempdb..#tempResponse') is not null drop table #tempResponse;
	if object_id('tempdb..#tempFksIDProyecto') is not null drop table #tempFksIDProyecto;

    create table #tempResponse(
	   ID int
	   ,Mensaje Nvarchar(max)
	   ,TipoRespuesta int
--	   ,ConfirmarEliminar bit default 0
    );

	BEGIN TRY  
		if (exists(select top 1 1 from @dtProyecto where IDProyecto = @IDProyecto and IDEstatus = 6)
			and (@EVALUACION0001 = 0)
		)
		begin
			select @IDProyecto as ID
			 ,'No puede eliminar un proyecto con estatus de COMPLETO.' as Mensaje
			 ,'Advertencia' as Titulo

			 ,2 as TipoRespuesta

		  return;		
		end;
		--select * from Evaluacion360.tblCatEstatus


		if (not exists (select top 1 1
			from Evaluacion360.tblCatGrupos
			where TipoReferencia = 1 and IDReferencia = @IDProyecto) or @ConfirmadoEliminar = 1)
		begin

			--select IDGrupo
			--INTO #tempGrupos
			--from Evaluacion360.tblCatGrupos
			--where TipoReferencia = 1 and IDReferencia = @IDProyecto

			--select @IDGrupo=min(IDGrupo) from #tempGrupos
			--while exists(select top 1 1 from #tempGrupos where IDGrupo >= @IDGrupo)
			--begin
			--	exec [Evaluacion360].spBorrarGrupo @IDGrupo=@IDGrupo
			--									,@IDUsuario=@IDUsuario
			--									,@ConfirmadoEliminar=1
				
			--	select @IDGrupo=min(IDGrupo) from #tempGrupos where IDGrupo > @IDGrupo
			--end;

			select 
				cast(f.name as varchar(255)) as foreign_key_name
				, cast(c.name as varchar(255)) as foreign_table
				, cast(fc.name as varchar(255)) as foreign_column
				, cast(p.name as varchar(255)) as parent_table
				, cast(rc.name as varchar(255)) as parent_column
				, SQLSriptDelete = N'delete from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDProyecto = '+CAST(@IDProyecto as varchar(100))
				, SQLSriptSelect = N'select * from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDProyecto = '+CAST(@IDProyecto as varchar(100))
			INTO #tempFksIDProyecto
			from  sysobjects f
			inner join sys.objects c on f.parent_obj = c.object_id
			inner join sysreferences r on f.id = r.constid
			inner join sysobjects p on r.rkeyid = p.id
			inner join syscolumns rc on r.rkeyid = rc.id and r.rkey1 = rc.colid
			inner join syscolumns fc on r.fkeyid = fc.id and r.fkey1 = fc.colid
			where f.type = 'F' and fc.name = 'IDProyecto' and p.name = 'tblCatProyectos'

			SELECT @SQLScriptDelete = STUFF((
				SELECT CHAR(10) + SQLSriptDelete
				FROM #tempFksIDProyecto
				FOR XML PATH('')
				), 1, 1, '')
			FROM #tempFksIDProyecto

			SELECT @SQLScriptSelect = STUFF((
					SELECT CHAR(10) +SQLSriptSelect
					FROM #tempFksIDProyecto
					FOR XML PATH('')
					), 1, 1, '')
			FROM #tempFksIDProyecto

			--	execute(@SQLScriptSelect)	
			execute(@SQLScriptDelete)

			select @OldJSON =(SELECT *  FROM [Evaluacion360].[tblCatProyectos]                 
                    WHERE IDProyecto = @IDProyecto FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
       

			DELETE [Evaluacion360].[tblCatProyectos] 
			where IDProyecto = @IDProyecto

			EXEC [Auditoria].[spIAuditoria]
				@IDUsuario		= @IDUsuario
				,@Tabla			= @Tabla
				,@Procedimiento	= @NombreSP
				,@Accion		= @Accion
				,@NewData		= @NewJSON
				,@OldData		= @OldJSON
				,@Mensaje		= @SQLScriptDelete
				,@InformacionExtra = @InformacionExtra

			
			select @IDProyecto as ID
			 ,'Proyecto elimiando correctamente.' as Mensaje
			 ,'' Titulo
			 ,0 as TipoRespuesta


			 EXEC [Evaluacion360].[spActualizarTotalEvaluacionesPorEstatus]
		  return;
		end else 
		begin
			select @t=count(IDGrupo)
			from Evaluacion360.tblCatGrupos
			where TipoReferencia = 1 and IDReferencia = @IDProyecto
			
			select @IDProyecto as ID
			 ,'Este proyecto tiene '+cast(@t as varchar)+' competencias(s) que serán eliminada(s).' as Mensaje
			 ,'' Titulo
			 ,1 as TipoRespuesta

		  return;			
		end;
	END TRY  
	BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END CATCH ;


--d_adagioRH.Evaluacion360.tblConfiguracionAvanzadaProyecto: Fk_Evaluacion360TblConfiguracionesAvanzadas_Evaluacion360TblCatProyectos_IDProyecto
--d_adagioRH.Evaluacion360.tblEmpleadosProyectos: Pk_Evaluacion360TblEmpleadosProyectos_Evaluacion360TblProyectos_IDProyecto
--d_adagioRH.Evaluacion360.tblEncargadosProyectos: Pk_Evaluacion360TblEncargadosProyectos_Evaluacion360TblProyectos_IDProyecto
--d_adagioRH.Evaluacion360.tblEvaluadoresRequeridos: Fk_Evaluacion360TblEvaluadoresRequeridos_Evaluacion360TblCatProyectos_IDProyecto
--d_adagioRH.Evaluacion360.tblFiltrosProyectos: Pk_Evaluacion360TblFiltrosProyectos_Evaluacion360TblProyectos_IDProyecto
GO
