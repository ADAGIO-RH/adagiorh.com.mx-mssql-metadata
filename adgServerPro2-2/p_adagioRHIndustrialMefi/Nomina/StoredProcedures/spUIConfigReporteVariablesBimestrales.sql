USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUIConfigReporteVariablesBimestrales]
(
	@ConceptosValesDespensa Nvarchar(MAX),
	@ConceptosPremioPuntualidad Nvarchar(MAX),
	@ConceptosPremioAsistencia Nvarchar(MAX),
	@ConceptosHorasExtrasDobles Nvarchar(MAX),
	@ConceptosIntegrablesVariables Nvarchar(MAX),
	@ConceptosDias Nvarchar(MAX), 
	@IDRazonMovimiento int,
	@CriterioDias bit = 0,
	@PromediarUMA int = 0,
	@TopePremioPuntualidadAsistencia int = 0,
	@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUIConfigReporteVariablesBimestrales]',
		@Tabla		varchar(max) = '[Nomina].[tblConfigReporteVariablesBimestrales]',
		@Accion		varchar(20)	= ''
	;

	if ((select count(*) from Nomina.tblConfigReporteVariablesBimestrales)>0) 
	BEGIN
		select @OldJSON = a.JSON 
			,@Accion = 'UPDATE'
		from [Nomina].tblConfigReporteVariablesBimestrales b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

		UPDATE Nomina.tblConfigReporteVariablesBimestrales
			set  ConceptosValesDespensa				= @ConceptosValesDespensa
				,ConceptosPremioPuntualidad			= @ConceptosPremioPuntualidad
				,ConceptosPremioAsistencia			= @ConceptosPremioAsistencia
				,ConceptosHorasExtrasDobles			= @ConceptosHorasExtrasDobles
				,ConceptosIntegrablesVariables		= @ConceptosIntegrablesVariables
				,ConceptosDias						= @ConceptosDias
				,IDRazonMovimiento					= @IDRazonMovimiento
				,CriterioDias						= @CriterioDias
				,PromediarUMA						= @PromediarUMA
				,TopePremioPuntualidadAsistencia	= @TopePremioPuntualidadAsistencia

		select @NewJSON = a.JSON 
		from [Nomina].tblConfigReporteVariablesBimestrales b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	END
	ELSE
	BEGIN
		insert into Nomina.tblConfigReporteVariablesBimestrales(
					ConceptosValesDespensa
					,ConceptosPremioPuntualidad
					,ConceptosPremioAsistencia
					,ConceptosHorasExtrasDobles
					,ConceptosIntegrablesVariables
					,ConceptosDias
					,IDRazonMovimiento
					,CriterioDias
					,PromediarUMA
					,TopePremioPuntualidadAsistencia)
		Values(
			@ConceptosValesDespensa
			,@ConceptosPremioPuntualidad
			,@ConceptosPremioAsistencia
			,@ConceptosHorasExtrasDobles
			,@ConceptosIntegrablesVariables
			,@ConceptosDias
			,@IDRazonMovimiento
			,@CriterioDias
			,@PromediarUMA
			,@TopePremioPuntualidadAsistencia
		)

		select @NewJSON = a.JSON 
			,@Accion = 'INSERT'
		from [Nomina].tblConfigReporteVariablesBimestrales b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	END

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

	exec Nomina.spBuscarConfigReporteVariablesBimestrales
END
GO
