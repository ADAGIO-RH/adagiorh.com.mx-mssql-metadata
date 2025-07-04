USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE proc [Asistencia].[spBorrarCatIncidencia]  
(  
  @IDIncidencia varchar(10)
 ,@IDUsuario int
) as  
BEGIN  

  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	select @OldJSON = (SELECT IDIncidencia
                                ,EsAusentismo
                                ,GoceSueldo
                                ,PermiteChecar
                                ,AfectaSUA
                                ,TiempoIncidencia
                                ,Autorizar
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [Asistencia].[tblCatIncidencias]
                            WHERE IDIncidencia = @IDIncidencia FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

 

	 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatIncidencias]','[Asistencia].[spBorrarCatIncidencia]','DELETE','',@OldJSON
		
  
	delete Asistencia.tblCatIncidencias
	where IDIncidencia = @IDIncidencia

END;
GO
