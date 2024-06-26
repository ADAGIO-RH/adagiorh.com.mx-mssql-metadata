USE [readOnly_adagioRHHotelesGDLPlaza]
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
)
AS
BEGIN
	SET @Descripcion = UPPER(@Descripcion)

    IF(@IDPerfil = 0)
    BEGIN
	   Insert into Seguridad.tblCatPerfiles(
								Descripcion
								,Activo
								)
			 Values(
					   @Descripcion
					   ,@Activo)

    set @IDPerfil = @@IDENTITY
    END
    ELSE
    BEGIN
	   Update Seguridad.tblCatPerfiles
		  set Descripcion = @Descripcion,
			 Activo = @Activo
		  Where IDPerfil = @IDPerfil
    END
	
    SELECT IDPerfil,Descripcion,Activo,ROW_NUMBER()over(ORDER BY IDPerfil) as ROWNUMBER
    FROM Seguridad.tblCatPerfiles
    where IDPerfil=@IDPerfil
END
GO
