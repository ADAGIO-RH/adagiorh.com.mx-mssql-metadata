USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [App].[spBorradoFisicoColaborador](
	@IDEmpleado int,
	@IDUsuarioLogin int
) as

	DECLARE 
		@OldJSON Varchar(Max)
		,@NewJSON Varchar(Max)
		,@SQLScriptSelect nvarchar(max)
		,@SQLScriptDelete nvarchar(max)

		,@SQLScriptSelectUsuario nvarchar(max)
		,@SQLScriptDeleteUsuario nvarchar(max)

		,@IDUsuario int
	;

	select @IDUsuario = IDUsuario
	from Seguridad.tblUsuarios
	where IDEmpleado = @IDEmpleado

	if object_id('tempdb..#tempFksIDEmpleado') is not null drop table #tempFksIDEmpleado;
	if object_id('tempdb..#tempFksIDUsuario') is not null drop table #tempFksIDUsuario;

	select 
		cast(f.name as varchar(255)) as foreign_key_name
		, cast(c.name as varchar(255)) as foreign_table
		, cast(fc.name as varchar(255)) as foreign_column
		, cast(p.name as varchar(255)) as parent_table
		, cast(rc.name as varchar(255)) as parent_column
		, SQLSriptDelete = N'delete from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDUsuario = '+CAST(@IDUsuario as varchar(100))
		, SQLSriptSelect = N'select * from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDUsuario = '+CAST(@IDUsuario as varchar(100))
	INTO #tempFksIDUsuario
	from  dbo.sysobjects f
		inner join sys.objects c on f.parent_obj = c.object_id
		inner join sysreferences r on f.id = r.constid
		inner join sysobjects p on r.rkeyid = p.id
		inner join syscolumns rc on r.rkeyid = rc.id and r.rkey1 = rc.colid
		inner join syscolumns fc on r.fkeyid = fc.id and r.fkey1 = fc.colid
	where f.type = 'F' and fc.name = 'IDUsuario' and p.name = 'tblUsuarios'

	select 
		cast(f.name as varchar(255)) as foreign_key_name
		, cast(c.name as varchar(255)) as foreign_table
		, cast(fc.name as varchar(255)) as foreign_column
		, cast(p.name as varchar(255)) as parent_table
		, cast(rc.name as varchar(255)) as parent_column
		, SQLSriptDelete = N'delete from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDEmpleado = '+CAST(@IDEmpleado as varchar(100))
		, SQLSriptSelect = N'select * from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDEmpleado = '+CAST(@IDEmpleado as varchar(100))
	INTO #tempFksIDEmpleado
	from  sysobjects f
		inner join sys.objects c on f.parent_obj = c.object_id
		inner join sysreferences r on f.id = r.constid
		inner join dbo.sysobjects p on r.rkeyid = p.id
		inner join syscolumns rc on r.rkeyid = rc.id and r.rkey1 = rc.colid
		inner join syscolumns fc on r.fkeyid = fc.id and r.fkey1 = fc.colid
	where f.type = 'F' and fc.name = 'IDEmpleado' and p.name = 'tblEmpleados'


	SELECT @SQLScriptDeleteUsuario = STUFF((
            SELECT CHAR(10) + SQLSriptDelete
            FROM #tempFksIDUsuario
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDEmpleado

	SELECT @SQLScriptSelectUsuario = STUFF((
            SELECT CHAR(10) +SQLSriptSelect
            FROM #tempFksIDUsuario
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDEmpleado

	SELECT @SQLScriptDelete = STUFF((
            SELECT CHAR(10) + SQLSriptDelete
            FROM #tempFksIDEmpleado
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDEmpleado

	SELECT @SQLScriptSelect = STUFF((
            SELECT CHAR(10) +SQLSriptSelect
            FROM #tempFksIDEmpleado
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDEmpleado

	--print @SQLScriptSelect	
	--print @SQLScriptDelete	
	--select @SQLScriptSelect	
	--select @SQLScriptDelete
		
	delete t 
	from Facturacion.TblTimbrado t 
		join Nomina.tblHistorialesEmpleadosPeriodos hep on hep.IDHistorialEmpleadoPeriodo = t.IDHistorialEmpleadoPeriodo
	where IDEmpleado = @IDEmpleado

	delete pd
	from Nomina.tblPrestamos p
		join Nomina.tblPrestamosDetalles pd on pd.IDPrestamo = p.IDPrestamo
	where p.IDEmpleado = @IDEmpleado
	
	delete hie
	from RH.tblInfonavitEmpleado ie
		join RH.tblHistorialInfonavitEmpleado hie on hie.IDInfonavitEmpleado = ie.IDInfonavitEmpleado
	where ie.IDEmpleado = @IDEmpleado

	delete Asistencia.tblIncidenciaEmpleado
	where IDEmpleado = @IDEmpleado and IDIncidencia = 'I'

	delete dca
	from Nomina.tblCajaAhorro ca
		join  Nomina.TblDevolucionesCajaAhorro dca on dca.IDCajaAhorro = ca.IDCajaAhorro
	where ca.IDEmpleado = @IDEmpleado

	delete ee
	from Evaluacion360.tblEmpleadosProyectos ep
		join Evaluacion360.TblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
	where ep.IDEmpleado = @IDEmpleado

	delete ee
	from Evaluacion360.tblEmpleadosProyectos ep
		join Evaluacion360.TblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
	where ee.IDEvaluador = @IDEmpleado

	delete u
	from Seguridad.tblUsuarios u
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfeu on dfeu.IDUsuario = u.IDUsuario
	where u.IDUsuario = @IDUsuario 

--	execute(@SQLScriptSelectUsuario)	
	execute(@SQLScriptDeleteUsuario)

--	execute(@SQLScriptSelect)	
	execute(@SQLScriptDelete)

	select @OldJSON = a.JSON from RH.tblEmpleadosMaster b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDEmpleado = @IDEmpleado
	
	EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogin,'[RH].[tblEmpleadosMaster]','[App].[spBorradoFisicoColaborador]','DELETE',@NewJSON,@OldJSON


	select @OldJSON = a.JSON from RH.tblEmpleados b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDEmpleado = @IDEmpleado
	
	EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogin,'[RH].[tblEmpleados]','[App].[spBorradoFisicoColaborador]','DELETE',@NewJSON,@OldJSON

	delete from RH.tblJefesEmpleados where IDEmpleado = @IDEmpleado
	delete from RH.tblJefesEmpleados where IDJefe = @IDEmpleado
	delete from RH.tblEmpleadosMaster where IDEmpleado = @IDEmpleado
	delete from RH.tblEmpleados where IDEmpleado = @IDEmpleado
GO
