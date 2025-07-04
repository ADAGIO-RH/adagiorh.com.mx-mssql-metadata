USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUIEmpleado]
(
	 @IDUsuario int
	,@IDEmpleado int
	,@ClaveEmpleado varchar(20)
	,@RFC varchar(20) = null
	,@CURP varchar(20) = null
	,@IMSS varchar(20) = null
	,@Nombre varchar(50)
	,@SegundoNombre varchar(50) = null
	,@Paterno varchar(50)
	,@Materno varchar(50)
	,@IDLocalidadNacimiento int
	,@IDMunicipioNacimiento int
	,@IDEstadoNacimiento int
	,@IDPaisNacimiento int
	,@LocalidadNacimiento Varchar(100)
	,@MunicipioNacimiento Varchar(100)
	,@EstadoNacimiento Varchar(100)
	,@PaisNacimiento Varchar(100)
	,@FechaNacimiento datetime
	,@IDEstadoCivil int
	,@Sexo varchar(1)
	,@IDEscolaridad int = null
	,@DescripcionEscolaridad varchar(max) = null
	,@IDInstitucion int
	,@IDProbatorio int
	,@FechaPrimerIngreso date = null
	,@FechaIngreso date
	,@FechaAntiguedad date = null
	,@Sindicalizado bit = 0
	,@IDJornadaLaboral int = null
	,@UMF varchar(10) = null
	,@CuentaContable varchar(50) = null
	,@IDTipoRegimen int = null
)
AS
BEGIN

  DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

select @OldJSON = a.JSON from [RH].[tblEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleado = @IDEmpleado

	UPDATE RH.tblEmpleados
		set ClaveEmpleado		= @ClaveEmpleado
		,RFC					= @RFC
		,CURP					= @CURP
		,IMSS					= @IMSS
		,Nombre					= ltrim(rtrim(@Nombre))
		,SegundoNombre			= ltrim(rtrim(@SegundoNombre))
		,Paterno				= ltrim(rtrim(@Paterno))
		,Materno				= ltrim(rtrim(@Materno))
		,IDLocalidadNacimiento  = case when @IDLocalidadNacimiento = 0 then null else @IDLocalidadNacimiento end
		,IDMunicipioNacimiento	= case when @IDMunicipioNacimiento = 0 then null else @IDMunicipioNacimiento end
		,IDEstadoNacimiento		= case when @IDEstadoNacimiento = 0 then null else @IDEstadoNacimiento end
		,IDPaisNacimiento		= case when @IDPaisNacimiento = 0 then null else @IDPaisNacimiento end
		,LocalidadNacimiento	= @LocalidadNacimiento
		,MunicipioNacimiento	= @MunicipioNacimiento
		,EstadoNacimiento		= @EstadoNacimiento
		,PaisNacimiento			= @PaisNacimiento
		,FechaNacimiento		= @FechaNacimiento
		,IDEstadoCivil			= @IDEstadoCivil
		,Sexo					= @Sexo
		,IDEscolaridad			= case when @IDEscolaridad = 0 then null else @IDEscolaridad end
		,DescripcionEscolaridad	= @DescripcionEscolaridad
		,IDInstitucion			= case when @IDInstitucion = 0 then null else @IDInstitucion end
		,IDProbatorio			= case when @IDProbatorio = 0 then null else @IDProbatorio end
		,FechaPrimerIngreso		= CASE WHEN @FechaPrimerIngreso IS NULL THEN @FechaIngreso ELSE @FechaPrimerIngreso END
		,FechaIngreso			= @FechaIngreso
		,FechaAntiguedad		= CASE WHEN @FechaAntiguedad IS NULL THEN @FechaIngreso ELSE @FechaAntiguedad END
		,Sindicalizado			= @Sindicalizado
		,IDJornadaLaboral		= @IDJornadaLaboral
		,UMF					= @UMF
		,CuentaContable			= @CuentaContable
		,IDTipoRegimen			= case when @IDTipoRegimen = 0 then null else @IDTipoRegimen end
	
	Where IDEmpleado = @IDEmpleado

		select @NewJSON = a.JSON from [RH].[tblEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleado = @IDEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblEmpleados]','[RH].[spUIEmpleado]','UPDATE',@NewJSON,@OldJSON



	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
END
GO
