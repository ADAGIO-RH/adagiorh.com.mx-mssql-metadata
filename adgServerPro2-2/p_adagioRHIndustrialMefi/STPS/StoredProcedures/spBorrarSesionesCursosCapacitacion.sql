USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBorrarSesionesCursosCapacitacion]
(
	@IDSesion int
    ,@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[STPS].[spBorrarSesionesCursosCapacitacion]',
		@Tabla		varchar(max) = '[STPS].[tblSesionesCursosCapacitacion]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	select @OldJSON = a.JSON
		from (
			select 
				 scc.IDSesion
				,scc.IDProgramacionCursoCapacitacion
				,cc.Codigo+' - '+cc.Nombre as CursoCapacitacion
				,scc.IDSalaCapacitacion
				,sc.Nombre as Sala
				,scc.FechaHoraInicial
				,scc.FechaHoraFinal
			from STPS.tblSesionesCursosCapacitacion scc with (nolock)
				join STPS.tblProgramacionCursosCapacitacion pcc with (nolock) on pcc.IDProgramacionCursoCapacitacion = pcc.IDProgramacionCursoCapacitacion
				join STPS.tblCursosCapacitacion cc with (nolock) on cc.IDCursoCapacitacion = pcc.IDCursoCapacitacion
				left join STPS.tblSalasCapacitacion sc with (nolock) on sc.IDSalaCapacitacion = scc.IDSalaCapacitacion
			WHERE scc.IDSesion = @IDSesion
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	DELETE STPS.tblSesionesCursosCapacitacion
	WHERE IDSesion = @IDSesion

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra
END
GO
