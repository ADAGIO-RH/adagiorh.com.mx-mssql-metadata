USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [STPS].[spBorrarProgramacionCursosCapacitacion]
(
	@IDProgramacionCursoCapacitacion int,
	@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[STPS].[spBorrarProgramacionCursosCapacitacion]',
		@Tabla		varchar(max) = '[STPS].[tblProgramacionCursosCapacitacion]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;
	EXEC STPS.spBuscarProgramacionCursosCapacitacion @IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion
	
	BEGIN TRY  
		select @OldJSON = a.JSON 
		from (
			SELECT PC.IDProgramacionCursoCapacitacion
				  ,ISNULL(PC.IDCursoCapacitacion,0) as IDCursoCapacitacion
				  ,UPPER(CC.Codigo) as CodigoCurso
				  ,UPPER(CC.Nombre) as NombreCurso
				  ,ISNULL(PC.Duracion,0) as Duracion
				  ,PC.FechaIni as FechaIni
				  ,PC.FechaFin as FechaFin
				  ,ISNULL(PC.IDModalidad,0) as IDModalidad
				  ,UPPER(M.Descripcion) as Modalidad
				  ,ISNULL(PC.IDAgenteCapacitacion,0) as IDAgenteCapacitacion
				  ,UPPER(AC.Nombre)  as NombreAgenteCapacitacion
				  ,UPPER(AC.Apellidos) as ApellidosAgenteCapacitacion
				  ,UPPER(COALESCE(AC.RFC,'')+' - '+COALESCE(AC.Nombre,'')+' '+COALESCE(AC.Apellidos,'')) AS AgenteCapacitacion              
				  ,ROW_NUMBER()Over(Order by PC.IDProgramacionCursoCapacitacion asc) ROWNUMBER
			FROM STPS.tblProgramacionCursosCapacitacion PC with ( nolock)
				INNER JOIN STPS.tblCursosCapacitacion CC with ( nolock)
					on CC.IDCursoCapacitacion = PC.IDCursoCapacitacion
				LEFT JOIN STPS.tblCatModalidades M with ( nolock)
					on M.IDModalidad = PC.IDModalidad
				LEFT JOIN STPS.tblAgentesCapacitacion AC with ( nolock)
					on PC.IDAgenteCapacitacion = AC.IDAgenteCapacitacion
			where (PC.IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion)
			) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

		Delete STPS.tblProgramacionCursosCapacitacion
		where IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra
	END TRY  
	BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END CATCH ;
END
GO
