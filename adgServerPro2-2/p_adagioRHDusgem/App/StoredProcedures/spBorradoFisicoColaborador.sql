USE [p_adagioRHDusgem]
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
@Error VARCHAR(MAX)

BEGIN TRY
    BEGIN TRAN DeleteEmpleado
	DECLARE 
		@OldJSON Varchar(Max)
		,@NewJSON Varchar(Max)

        ,@SQLScriptSelectCandidato NVARCHAR(MAX)
        ,@SQLScriptdeleteCandidato NVARCHAR(MAX)

        ,@SQLScriptSelectMovAfil NVARCHAR(MAX)
        ,@SQLScriptdeleteMovAfil NVARCHAR(MAX)

		,@SQLScriptSelect nvarchar(max)
		,@SQLScriptDelete nvarchar(max)

		,@SQLScriptSelectUsuario nvarchar(max)
		,@SQLScriptDeleteUsuario nvarchar(max)

		,@IDUsuario int
        ,@IDCandidato int 
        ,@IDMovAfiliatorio int
	;

	select @IDUsuario = IDUsuario
	from Seguridad.tblUsuarios
	where IDEmpleado = @IDEmpleado

    select @IDCandidato = IDCandidato
	from Reclutamiento.tblCandidatos
	where IDEmpleado = @IDEmpleado




	if object_id('tempdb..#tempFksIDEmpleado') is not null drop table #tempFksIDEmpleado;
	if object_id('tempdb..#tempFksIDUsuario') is not null drop table #tempFksIDUsuario;
    if object_id('tempdb..#tempFksIDCandidato') is not null drop table #tempFksIDCandidato;
    if object_id('tempdb..#tempFksIDMovAfiliatorio') is not null drop table #tempFksIDMovAfiliatorio;


    select 
		cast(f.name as varchar(255)) as foreign_key_name
		, cast(c.name as varchar(255)) as foreign_table
		, cast(fc.name as varchar(255)) as foreign_column
		, cast(p.name as varchar(255)) as parent_table
		, cast(rc.name as varchar(255)) as parent_column
		, SQLSriptDelete = N'delete from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDCandidato = '+CAST(@IDCandidato as varchar(100))
		, SQLSriptSelect = N'select * from '+SCHEMA_NAME(c.schema_id)+'.'+cast(c.name as varchar(255))+' where IDCandidato = '+CAST(@IDCandidato as varchar(100))
	INTO #tempFksIDCandidato
	from  dbo.sysobjects f
		inner join sys.objects c on f.parent_obj = c.object_id
		inner join sysreferences r on f.id = r.constid
		inner join sysobjects p on r.rkeyid = p.id
		inner join syscolumns rc on r.rkeyid = rc.id and r.rkey1 = rc.colid
		inner join syscolumns fc on r.fkeyid = fc.id and r.fkey1 = fc.colid
	where f.type = 'F' and fc.name = 'IDCandidato' and p.name = 'tblCandidatos'

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

    SELECT 
        CAST(f.name AS VARCHAR(255)) AS foreign_key_name,
        CAST(c.name AS VARCHAR(255)) AS foreign_table,
        CAST(fc.name AS VARCHAR(255)) AS foreign_column,
        CAST(p.name AS VARCHAR(255)) AS parent_table,
        CAST(rc.name AS VARCHAR(255)) AS parent_column,
        SQLSriptDelete = N'DELETE FROM ' + SCHEMA_NAME(c.schema_id) + '.' + CAST(c.name AS VARCHAR(255)) + ' WHERE IDEmpleado = ' + CAST(@IDEmpleado AS VARCHAR(100)),
        SQLSriptSelect = N'SELECT * FROM ' + SCHEMA_NAME(c.schema_id) + '.' + CAST(c.name AS VARCHAR(255)) + ' WHERE IDEmpleado = ' + CAST(@IDEmpleado AS VARCHAR(100))
    INTO #tempFksIDMovAfiliatorio
    FROM sysobjects f
        INNER JOIN sys.objects c ON f.parent_obj = c.object_id
        INNER JOIN sysreferences r ON f.id = r.constid
        INNER JOIN dbo.sysobjects p ON r.rkeyid = p.id
        INNER JOIN syscolumns rc ON r.rkeyid = rc.id AND r.rkey1 = rc.colid
        INNER JOIN syscolumns fc ON r.fkeyid = fc.id AND r.fkey1 = fc.colid
    WHERE f.type = 'F' 
    AND EXISTS (
        SELECT 1
        FROM syscolumns fc1
        WHERE fc1.id = fc.id AND fc1.name = 'IDMovAfiliatorio'
    )
    AND EXISTS (
        SELECT 1
        FROM syscolumns fc2
        WHERE fc2.id = fc.id AND fc2.name = 'IDEmpleado'
    )
    AND p.name = 'tblMovAfiliatorios';


    SELECT @SQLScriptdeleteCandidato = STUFF((
            SELECT CHAR(10) + SQLSriptDelete
            FROM #tempFksIDCandidato
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDEmpleado

    SELECT @SQLScriptSelectCandidato = STUFF((
            SELECT CHAR(10) + SQLSriptDelete
            FROM #tempFksIDCandidato
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDEmpleado

    SELECT @SQLScriptdeleteMovAfil = STUFF((
            SELECT CHAR(10) + SQLSriptDelete
            FROM #tempFksIDMovAfiliatorio
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDEmpleado

    SELECT @SQLScriptSelectMovAfil = STUFF((
            SELECT CHAR(10) + SQLSriptDelete
            FROM #tempFksIDMovAfiliatorio
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDEmpleado

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


-----------------El orden de los DELETE afecta el procedimiento-----------------------------
	
    --print @SQLScriptSelect		
	--select @SQLScriptSelect	
	--select @SQLScriptDelete

    --execute(@SQLScriptSelectCandidato)

    print @SQLScriptdeleteMovAfil
    execute(@SQLScriptdeleteMovAfil)

    print @SQLScriptDeletecandidato	
	execute(@SQLScriptdeleteCandidato)

	--execute(@SQLScriptSelectUsuario)
    print @SQLScriptDeleteUsuario	
	execute(@SQLScriptDeleteUsuario)


    delete ce 
    from Salud.tblPruebasEmpleados pe  
        join salud.tblCuestionariosEmpleados ce on pe.IDPruebaEmpleado = ce.IDPruebaEmpleado
    Where pe.IDEmpleado = @IDEmpleado

    delete t 
	from Facturacion.TblTimbrado t 
		join Nomina.tblHistorialesEmpleadosPeriodos hep on hep.IDHistorialEmpleadoPeriodo = t.IDHistorialEmpleadoPeriodo
	where IDEmpleado = @IDEmpleado

    delete g
	from Facturacion.tblGeneracionRecibos g 
		join Nomina.tblHistorialesEmpleadosPeriodos hep on hep.IDHistorialEmpleadoPeriodo = g.IDHistorialEmpleadoPeriodo
	where IDEmpleado = @IDEmpleado


    delete pa 
    from Nomina.tblPrestamosFondoAhorro pa
    where pa.IDEmpleado = @IDEmpleado

    delete fdu 
    from Docs.tblDetalleFiltrosDocumentosUsuarios fdu
    join Docs.tblCarpetasDocumentos cd on fdu.IDDocumento = cd.IDItem
    where cd.IDAutor = @IDUsuario


    delete cd
    from Docs.tblCarpetasDocumentos cd
    where IDAutor = @IDUsuario

    delete siup  
    from Intranet.tblSolicitudesPrestamos siup 
    where IDUsuarioAutorizo = @IDUsuario


    delete sip  
    from Intranet.tblSolicitudesPrestamos sip
    where IDUsuarioCancelo = @IDUsuario

    delete se 
    from Intranet.tblSolicitudesEmpleado se
    where IDUsuarioAutoriza = @IDUsuario

    delete cdc 
    from Reclutamiento.tblContactoCandidato cdc 
    where idcandidato = @IDCandidato

    delete rdc 
    from Reclutamiento.tblDireccionResidenciaCandidato rdc 
    where idcandidato = @IDCandidato

    delete iem 
    from Asistencia.tblIncidenciaEmpleado iem 
    where iem.IDEmpleado = @IDEmpleado

    delete ieme 
    from Asistencia.tblIncapacidadEmpleado ieme
    where ieme.IDEmpleado = @IDEmpleado

    delete com 
    from Comedor.tblPedidos com 
    where IDEmpleadoRecibe = @IDEmpleado

    delete  Asistencia.tblSaldoVacacionesEmpleado
	where IDEmpleado = @IDEmpleado

--	execute(@SQLScriptSelect)
    print @SQLScriptDelete	
	execute(@SQLScriptDelete)
	
    
	

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
	where u.IDUsuario = @IDUsuario

    delete c 
    from Reclutamiento.tblCandidatos c 
    where c.IDCandidato = @IDCandidato 

	print 5

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
        
        COMMIT TRAN DeleteEmpleado
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN DeleteEmpleado
        select  ERROR_MESSAGE ( ) 
        
        --EXEC [App].[spObtenerError] @IDUsuario = @IDUsuarioLogin, @CodigoError = '1700002', @CustomMessage= @ERROR
    END CATCH
GO
