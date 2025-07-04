USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spUICatPerfiles]
(
	@IDPerfil int = 0
	,@Descripcion varchar(50)
	,@Activo bit = 1
	,@AsignarTodosLosColaboradores bit = 0
	,@IDUsuario int
)
AS
BEGIN
	SET @Descripcion = UPPER(@Descripcion)

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

    IF(isnull(@IDPerfil,0) = 0)
    BEGIN
		IF EXISTS(Select Top 1 1 from Seguridad.tblCatPerfiles where Descripcion = @Descripcion)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO Seguridad.tblCatPerfiles(Descripcion,Activo, AsignarTodosLosColaboradores)
		VALUES(@Descripcion ,@Activo, @AsignarTodosLosColaboradores)

		SET @IDPerfil = @@IDENTITY

		select @NewJSON = a.JSON from Seguridad.tblCatPerfiles b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPerfil = @IDPerfil

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblCatPerfiles]','[Seguridad].[spUICatPerfiles]','INSERT',@NewJSON,''

    END
    ELSE
    BEGIN

		IF EXISTS(Select Top 1 1 from Seguridad.tblCatPerfiles where Descripcion = @Descripcion and IDPerfil <> @IDPerfil)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		select @OldJSON = a.JSON from Seguridad.tblCatPerfiles b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  b.IDPerfil = @IDPerfil


	   Update Seguridad.tblCatPerfiles
		  set Descripcion = @Descripcion,
			 Activo = @Activo,
			 AsignarTodosLosColaboradores = @AsignarTodosLosColaboradores
		Where IDPerfil = @IDPerfil

		select @NewJSON = a.JSON from Seguridad.tblCatPerfiles b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  b.IDPerfil = @IDPerfil

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblCatPerfiles]','[Seguridad].[spUICatPerfiles]','UPDATE',@NewJSON,@OldJSON
    END

	
	insert into Seguridad.tblPermisosPerfilesControllers(IDPerfil,IDController,IDTipoPermiso)
	select p.IDPerfil,c.IDController, 'R'
	From Seguridad.tblCatPerfiles p
		cross join App.tblCatControllers c
	where p.Descripcion = @Descripcion
		and c.IDController not in (Select IDController from Seguridad.tblPermisosPerfilesControllers where IDPerfil = p.IDPerfil)

END
GO
