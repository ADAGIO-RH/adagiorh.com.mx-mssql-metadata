USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA ACTIVAR/ DESACTIVAR LOS TIPOS DE CHECADAS
** Autor			: JOSE ROMAN
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spUTiposChecadas] 
(
	@IDTipoChecada Varchar(10) = NULL,
	@Activo bit ,
	@IDUsuario int
)
AS
BEGIN
DECLARE  
		@IDIdioma varchar(225)
	;
    select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))
 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	select @OldJSON =(SELECT IDTipoChecada
                        ,TipoChecada
                        ,Activo
                        ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoChecada')) as Traduccion
                        FROM [Asistencia].[tblCatTiposChecadas]                    
                    WHERE IDTipoChecada = @IDTipoChecada FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    


	UPDATE Asistencia.tblCatTiposChecadas
		set Activo = @Activo
	WHERE IDTipoChecada = @IDTipoChecada

	select @NewJSON = (SELECT IDTipoChecada
                        ,TipoChecada
                        ,Activo
                        ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoChecada')) as Traduccion
                        FROM [Asistencia].[tblCatTiposChecadas]                    
                    WHERE IDTipoChecada = @IDTipoChecada FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatTiposChecadas]','[Asistencia].[spUTiposChecadas]','UPDATE',@NewJSON,@OldJSON
		

EXEC Asistencia.spBuscarTiposChecadas @IDTipoChecada
END
GO
