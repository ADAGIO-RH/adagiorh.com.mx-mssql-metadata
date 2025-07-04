USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spIUSesionesCursosCapacitacion]
(
	@IDProgramacionCursoCapacitacion int
	,@IDSesion int
	,@IDSalaCapacitacion int
	,@FechaHoraInicial datetime
	,@FechaHoraFinal datetime
	,@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[STPS].[spIUSesionesCursosCapacitacion]',
		@Tabla		varchar(max) = '[STPS].[tblSesionesCursosCapacitacion]',
		@Accion		varchar(20)	= '',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	IF(isnull(@IDProgramacionCursoCapacitacion,0) = 0)
	BEGIN
		RAISERROR('La Programación del curso es requerida.',16,1);
		RETURN;
	END
	
	IF(@IDSesion = 0)
	BEGIN
		INSERT INTO STPS.tblSesionesCursosCapacitacion(IDProgramacionCursoCapacitacion,IDSalaCapacitacion,FechaHoraInicial,FechaHoraFinal)
		VALUES(@IDProgramacionCursoCapacitacion,case when @IDSalaCapacitacion = 0 then null else @IDSalaCapacitacion end,@FechaHoraInicial,@FechaHoraFinal)
		
		SET @IDSesion = @@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
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
			WHERE scc.IDSesion = @IDSesion AND scc.IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
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
			WHERE scc.IDSesion = @IDSesion AND scc.IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

		UPDATE STPS.tblSesionesCursosCapacitacion
			SET IDSalaCapacitacion = case when @IDSalaCapacitacion = 0 then null else @IDSalaCapacitacion end
				,FechaHoraInicial = @FechaHoraInicial
				,FechaHoraFinal = @FechaHoraFinal
		WHERE IDSesion = @IDSesion
			AND IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion

		select @NewJSON = a.JSON			
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
			WHERE scc.IDSesion = @IDSesion AND scc.IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	END

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra
        
        exec [STPS].[spBuscarSesionesCursosCapacitacion] @IDSesion=@IDSesion,@IDUsuario=@IDUsuario,@FechaFin=@FechaHoraFinal,@FechaInicio=@FechaHoraInicial
END;
GO
