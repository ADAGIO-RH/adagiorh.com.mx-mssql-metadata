USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Reclutamiento].[spICandidatoPublica](
	@IDPlaza int
	,@Nombre varchar(50) 
	,@SegundoNombre varchar(50)
	,@Paterno varchar(50)
	,@Materno varchar(50)
	,@Sexo  char(1)
	,@FechaNacimiento date
	,@CorreoElectronico varchar(50)
	,@IDEmpleado int = null
	,@EnviarEmailActivacion bit = 1
)
AS  
BEGIN  

	DECLARE 
		@IDCandidato int,
		@IDUsuario int,
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@FechaAplicacion date = getdate(),
		@IDTipoContactoEmail int=3,
		@Key varchar(max),
		@ErrorMessage varchar(max)
	;

	if ((isnull(@CorreoElectronico, '') != '') and exists(select top 1 1 
															from [Reclutamiento].[tblCandidatos]
															where Email = @CorreoElectronico))
	begin
		set @ErrorMessage=FORMATMESSAGE('El email [%s] ya existe, recupera tu contraseña para poder ingresar.', @CorreoElectronico);

		THROW 50001, @ErrorMessage, 1
		return
	end


	select @IDUsuario=cast(Valor as int)  from App.tblConfiguracionesGenerales where IDConfiguracion='IDUsuarioAdmin'

	set @key = REPLACE(NEWID(),'-','')+''+REPLACE(NEWID(),'-','');
	
	/*Datos De Candidato*/
	INSERT INTO [Reclutamiento].[tblCandidatos]([Nombre],[SegundoNombre],[Paterno],[Materno],[Sexo],[FechaNacimiento],[Email],[IDEmpleado], ActivationKey, AvaibleUntil)
	VALUES(
		UPPER(@Nombre) 
		,UPPER(@SegundoNombre)
		,UPPER(@Paterno)
		,UPPER(@Materno)
		,@Sexo 
		,@FechaNacimiento 
		,@CorreoElectronico
		,CASE WHEN ISNULL(@IDEmpleado,0) = 0 THEN NULL ELSE @IDEmpleado END
		,@key
		,dateadd(day,30,getdate())
	)	
	SET @IDCandidato = @@IDENTITY  

	if (isnull(@EnviarEmailActivacion, 0) = 1) 
	begin
		exec [Reclutamiento].[spINotificacionesActivarCuentaCandidato] @IDCandidato=@IDCandidato, @Key= @Key
	end

	/*Datos De Vacante Deseada*/
	IF(ISNULL(@IDPlaza,0) > 0)
	BEGIN
		EXEC [Reclutamiento].[spUICandidatoPlaza]
			@IDCandidatoPlaza = 0,
			@IDCandidato = @IDCandidato,
			@IDPlaza = @IDPlaza,
			@IDProceso= null,
			@SueldoDeseado= 0,
			@IDUsuario = @IDUsuario
	END

	/*Correo Electronico*/
	if(isnull(@CorreoElectronico, '') != '')
	BEGIN
		INSERT INTO [Reclutamiento].[tblContactoCandidato]([IDCandidato],[IDTipoContacto],[Value],[Predeterminado])
		VALUES(@IDCandidato,@IDTipoContactoEmail,@CorreoElectronico,0)
	END


	select @IDCandidato as IDCandidato
END
GO
