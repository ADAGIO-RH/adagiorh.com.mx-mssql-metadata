USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Borrar el Catálogo de Expedientes Digitales>
** Autor			: 
** Email			: 
** FechaCreacion	: 
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [Reclutamiento].[spBorrarCandidato]
(
	@IDCandidato int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
		@OldJSON Varchar(Max)
		,@NewJSON Varchar(Max)
		,@SQLScriptSelect nvarchar(max)
		,@SQLScriptDelete nvarchar(max)
	;
	if object_id('tempdb..#tempFksIDCandidato') is not null drop table #tempFksIDCandidato;

	select
		 [IDCandidato]  as [IDCandidato]
		,[Nombre]
		,[SegundoNombre]
		,[Paterno]
		,[Materno]
		,[Sexo]
		,[FechaNacimiento]
		,[IDPaisNacimiento]
		,[IDEstadoNacimiento]
		,[IDMunicipioNacimiento]
		,[IDLocalidadNacimiento]
		,[RFC]
		,[CURP]
		,[NSS]
		,[IDAfore]
		,[IDEstadoCivil]
		,[Estatura]
		,[Peso]
		,[TipoSangre]
		,[Extranjero]
		,ROW_NUMBER()over(ORDER BY Candidato.[IDCandidato])as ROWNUMBER
	FROM [Reclutamiento].[tblCandidatos] Candidato
	WHERE ([IDCandidato] = @IDCandidato OR isnull(@IDCandidato,0) = 0)



	select @OldJSON = a.JSON from [Reclutamiento].[tblCandidatos] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.[IDCandidato] = @IDCandidato

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCandidatos]','[Reclutamiento].[spBorrarCandidato]','DELETE','',@OldJSON

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

	SELECT @SQLScriptDelete = STUFF((
            SELECT CHAR(10) + SQLSriptDelete
            FROM #tempFksIDCandidato
            FOR XML PATH('')
            ), 1, 1, '')
	FROM #tempFksIDCandidato

	execute(@SQLScriptDelete)


	DELETE [Reclutamiento].[tblCandidatos]
	WHERE [IDCandidato] = @IDCandidato;
END
GO
