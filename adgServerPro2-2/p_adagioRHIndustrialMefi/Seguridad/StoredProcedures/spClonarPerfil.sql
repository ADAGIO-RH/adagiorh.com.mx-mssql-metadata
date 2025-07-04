USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spClonarPerfil]
(
	 @IDPerfil int = 0
	,@Descripcion varchar(50)
	,@Activo bit = 1
	,@AsignarTodosLosColaboradores bit = 0
	,@IDUsuario int
)
AS
BEGIN
	SET @Descripcion = 'COPIA DE ' +  UPPER(@Descripcion)

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
        @IDPerfilNuevo int 

    IF((Select top 1 1 from Seguridad.tblCatPerfiles where Descripcion = @Descripcion) = 1)
    BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario , @CustomMessage = 'Ya existe un perfil con esta descripcion'
		RETURN 0;
	END

    IF(isnull(@IDPerfil,0) = 0)
    BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario , @CustomMessage = 'ID Perfil Erroneo'
		RETURN 0;
	END

   
		INSERT INTO Seguridad.tblCatPerfiles(Descripcion,Activo, AsignarTodosLosColaboradores)
		VALUES(@Descripcion ,@Activo, @AsignarTodosLosColaboradores)

		SET @IDPerfilNuevo = @@IDENTITY

		select @NewJSON = a.JSON from Seguridad.tblCatPerfiles b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPerfil = @IDPerfilNuevo

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblCatPerfiles]','[Seguridad].[spClonarPerfil]','INSERT',@NewJSON,''

        Insert into Seguridad.tblPermisosPerfilesControllers
        select @IDPerfilNuevo,IDController,IDTipoPermiso from Seguridad.tblPermisosPerfilesControllers where IDPerfil = @IDPerfil

        Insert into Seguridad.tblPermisosPerfiles
        select @IDPerfilNuevo,IDUrl from Seguridad.tblPermisosPerfiles where IDPerfil = @IDPerfil

        Insert into Seguridad.tblPermisosReportesPerfiles
        select @IDPerfilNuevo,IDReporteBasico,Acceso from Seguridad.tblPermisosReportesPerfiles where IDPerfil = @IDPerfil

        Insert into Seguridad.tblPermisosEspecialesPerfiles
        select IDPermiso,@IDPerfilNuevo from Seguridad.tblPermisosEspecialesPerfiles where IDPerfil = @IDPerfil

        Insert into app.tblAplicacionPerfiles
        Select IDAplicacion,@IDPerfilNuevo from app.tblAplicacionPerfiles where IDPerfil = @IDPerfil


        Select * from Seguridad.tblCatPerfiles where IDPerfil = @IDPerfilNuevo

   
    
END
GO
