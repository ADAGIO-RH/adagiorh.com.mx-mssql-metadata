USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spBorrarDiasFestivos]
(
	@IDDiasFestivo int,
	@IDUsuario int
)
AS
BEGIN

	 DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max);

		select @OldJSON =(SELECT IDDiaFestivo
                                ,Fecha
                                ,FechaReal
                                ,Autorizado
                                ,IDPais
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [Asistencia].[TblCatDiasFestivos]
                            WHERE IDDiaFestivo = @IDDiasFestivo FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        


	 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[TblCatDiasFestivos]','[Asistencia].[spBorrarDiasFestivos]','DELETE','',@OldJSON
		


		--EXEC Asistencia.spBuscarDiasFestivos @IDDiasFestivo
	
		DELETE Asistencia.TblCatDiasFestivos
		WHERE IDDiaFestivo = @IDDiasFestivo
END
GO
