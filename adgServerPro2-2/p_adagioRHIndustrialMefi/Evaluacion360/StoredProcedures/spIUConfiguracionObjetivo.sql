USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Evaluacion360].[spIUConfiguracionObjetivo](
	@IDConfiguracionObjetivo int = 0,
	@IDGrupo int,
	@FechaInicio date,
	@FechaFin date,
	@IDTipoMedicionObjetivo int,
	@IDEstatusObjetivo int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	IF(isnull(@IDConfiguracionObjetivo, 0) = 0)
	BEGIN
		INSERT INTO [Evaluacion360].[tblConfiguracionesObjetivos](
			[IDGrupo]
			,[FechaInicio]
			,[FechaFin]
			,[IDTipoMedicionObjetivo]
			,[IDEstatusObjetivo]
			,[IDUsuario]
		)
		VALUES(
			@IDGrupo
			,@FechaInicio
			,@FechaFin
			,@IDTipoMedicionObjetivo
			,@IDEstatusObjetivo
			,@IDUsuario
		)

		set @IDConfiguracionObjetivo = @@IDENTITY

		select @NewJSON = a.JSON 
		from (
			select 
				co.IDConfiguracionObjetivo
				,co.IDGrupo
				,g.Nombre as Grupo
				,co.FechaInicio
				,co.FechaFin
				,co.IDTipoMedicionObjetivo
				,JSON_VALUE(tmo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoMedicion 
				,co.IDEstatusObjetivo
				,JSON_VALUE(o.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Estatus 
				,co.IDUsuario
				,co.FechaHoraReg
			from [Evaluacion360].[tblConfiguracionesObjetivos] co
				join Evaluacion360.tblCatGrupos g on g.IDGrupo = co.IDGrupo
				join Evaluacion360.tblCatTiposMedicionesObjetivos tmo on tmo.IDTipoMedicionObjetivo = co.IDTipoMedicionObjetivo
				join Evaluacion360.tblCatEstatusObjetivos o on o.IDEstatusObjetivo = co.IDEstatusObjetivo
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDConfiguracionObjetivo=@IDConfiguracionObjetivo;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Evaluacion360].[tblConfiguracionesObjetivos]','[Evaluacion360].[spIUConfiguracionObjetivo]','INSERT',@NewJSON,''
	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON 
		from (
			select 
				co.IDConfiguracionObjetivo
				,co.IDGrupo
				,g.Nombre as Grupo
				,co.FechaInicio
				,co.FechaFin
				,co.IDTipoMedicionObjetivo
				,JSON_VALUE(tmo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoMedicion 
				,co.IDEstatusObjetivo
				,JSON_VALUE(o.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Estatus 
				,co.IDUsuario
				,co.FechaHoraReg
			from [Evaluacion360].[tblConfiguracionesObjetivos] co
				join Evaluacion360.tblCatGrupos g on g.IDGrupo = co.IDGrupo
				join Evaluacion360.tblCatTiposMedicionesObjetivos tmo on tmo.IDTipoMedicionObjetivo = co.IDTipoMedicionObjetivo
				join Evaluacion360.tblCatEstatusObjetivos o on o.IDEstatusObjetivo = co.IDEstatusObjetivo
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDConfiguracionObjetivo=@IDConfiguracionObjetivo;

		UPDATE [Evaluacion360].[tblConfiguracionesObjetivos]
		SET FechaInicio = @FechaInicio,
			FechaFin = @FechaFin,
			IDTipoMedicionObjetivo = @IDTipoMedicionObjetivo,
			IDEstatusObjetivo = @IDEstatusObjetivo
		WHERE IDConfiguracionObjetivo = @IDConfiguracionObjetivo

		select @NewJSON = a.JSON 
		from (
			select 
				co.IDConfiguracionObjetivo
				,co.IDGrupo
				,g.Nombre as Grupo
				,co.FechaInicio
				,co.FechaFin
				,co.IDTipoMedicionObjetivo
				,JSON_VALUE(tmo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoMedicion 
				,co.IDEstatusObjetivo
				,JSON_VALUE(o.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Estatus 
				,co.IDUsuario
				,co.FechaHoraReg
			from [Evaluacion360].[tblConfiguracionesObjetivos] co
				join Evaluacion360.tblCatGrupos g on g.IDGrupo = co.IDGrupo
				join Evaluacion360.tblCatTiposMedicionesObjetivos tmo on tmo.IDTipoMedicionObjetivo = co.IDTipoMedicionObjetivo
				join Evaluacion360.tblCatEstatusObjetivos o on o.IDEstatusObjetivo = co.IDEstatusObjetivo
		) b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDConfiguracionObjetivo=@IDConfiguracionObjetivo;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Evaluacion360].[tblConfiguracionesObjetivos]','[Evaluacion360].[spIUConfiguracionObjetivo]','UPDATE',@NewJSON, @OldJSON

	END


	exec Evaluacion360.[spBuscarConfiguracionesObjetivos] @IDConfiguracionObjetivo= @IDConfiguracionObjetivo, @IDUsuario=@IDUsuario
END
GO
