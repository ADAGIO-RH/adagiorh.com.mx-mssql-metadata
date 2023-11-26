USE [p_adagioRHEdman]
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
)  
AS  
BEGIN  

set @Descripcion = UPPER(@Descripcion)
 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);
 IF(@IDDiasFestivo = 0)  
 BEGIN  
  INSERT INTO Asistencia.TblCatDiasFestivos (Fecha,FechaReal,Descripcion,Autorizado, IDPais)  
  Values(@Fecha,@FechaReal,@Descripcion,@Autorizado, ISNULL(@IDPais,151))  
    
  set @IDDiasFestivo = @@IDENTITY  

  		select @NewJSON = a.JSON from [Asistencia].[TblCatDiasFestivos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDiaFestivo = @IDDiasFestivo

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[TblCatDiasFestivos]','[Asistencia].[spUIDiasFestivos]','INSERT',@NewJSON,''
		
 END  
 ELSE  
 BEGIN  

 select @OldJSON = a.JSON from [Asistencia].[TblCatDiasFestivos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDiaFestivo = @IDDiasFestivo

	  UPDATE Asistencia.TblCatDiasFestivos  
	   set Fecha = @Fecha,  
		FechaReal = @FechaReal,  
		Descripcion = @Descripcion,  
		Autorizado = @Autorizado,  
		IDPais = isnull(IDPais,151)
	  WHERE IDDiaFestivo = @IDDiasFestivo
  
  
  		select @NewJSON = a.JSON from [Asistencia].[TblCatDiasFestivos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDiaFestivo = @IDDiasFestivo

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[TblCatDiasFestivos]','[Asistencia].[spUIDiasFestivos]','INSERT',@NewJSON,@OldJSON
		
    
 END  
  
-- EXEC Asistencia.spBuscarDiasFestivos @IDDiasFestivo  
  
END
GO
