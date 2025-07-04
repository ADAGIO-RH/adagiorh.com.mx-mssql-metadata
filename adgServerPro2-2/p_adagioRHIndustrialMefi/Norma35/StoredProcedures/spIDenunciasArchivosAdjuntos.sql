USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spIDenunciasArchivosAdjuntos]
(
	 @IDDenuncia int,
     @Name varchar(50),
     @ContentType nvarchar(200),
     @Data varbinary(max),
	 @IDUsuario int
)
AS
BEGIN
	
	DECLARE @NewJSON VARCHAR(MAX);

	INSERT INTO [Norma35].[tblDenunciasArchivosAdjuntos]
           ([IDDenuncia]
           ,[Name]
           ,[ContentType]
           ,[Data])
     VALUES
           (@IDDenuncia 
           ,@Name
           ,@ContentType
           ,@Data)
      
	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[tblDenunciasArchivosAdjuntos]','[Norma35].[spIDenunciasArchivosAdjuntos]','INSERT',@NewJSON,''

END;
GO
