USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spUIDiasFestivos]  
(  
 @IDDiasFestivo int = 0  
   ,@Fecha Date  
   ,@FechaReal Date  
   ,@Descripcion Varchar(255)  
   ,@Autorizado bit 
   ,@IDPais int = 151
   ,@IDUsuario int  
   ,@Traduccion NVARCHAR(max)=null
)  
AS  
BEGIN  

set @Descripcion = UPPER(@Descripcion)
 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);
 IF(@IDDiasFestivo = 0)  
 BEGIN  
  INSERT INTO Asistencia.TblCatDiasFestivos (Fecha,FechaReal,Descripcion,Autorizado, IDPais,Traduccion)  
  Values(@Fecha,@FechaReal,@Descripcion,@Autorizado, ISNULL(@IDPais,151),case when ISJSON(@Traduccion) > 0 then @Traduccion else null end)  
    
  set @IDDiasFestivo = @@IDENTITY  

  		select @NewJSON = (SELECT IDDiaFestivo
                                ,Fecha
                                ,FechaReal
                                ,Autorizado
                                ,IDPais
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [Asistencia].[TblCatDiasFestivos]
                            WHERE IDDiaFestivo = @IDDiasFestivo FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[TblCatDiasFestivos]','[Asistencia].[spUIDiasFestivos]','INSERT',@NewJSON,''
		
 END  
 ELSE  
 BEGIN  

 select @OldJSON = (SELECT IDDiaFestivo
                                ,Fecha
                                ,FechaReal
                                ,Autorizado
                                ,IDPais
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [Asistencia].[TblCatDiasFestivos]
                            WHERE IDDiaFestivo = @IDDiasFestivo FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        

	  UPDATE Asistencia.TblCatDiasFestivos  
	   set Fecha = @Fecha,  
		FechaReal = @FechaReal,  
		Descripcion = @Descripcion,  
		Autorizado = @Autorizado,  
		IDPais = isnull(IDPais,151),
        Traduccion=case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
	  WHERE IDDiaFestivo = @IDDiasFestivo
  
  
  		select @NewJSON = (SELECT IDDiaFestivo
                                ,Fecha
                                ,FechaReal
                                ,Autorizado
                                ,IDPais
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [Asistencia].[TblCatDiasFestivos]
                            WHERE IDDiaFestivo = @IDDiasFestivo FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[TblCatDiasFestivos]','[Asistencia].[spUIDiasFestivos]','INSERT',@NewJSON,@OldJSON
		
    
 END  
  
-- EXEC Asistencia.spBuscarDiasFestivos @IDDiasFestivo  
  
END
GO
