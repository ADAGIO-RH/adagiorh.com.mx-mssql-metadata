USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spIDenunciasRegistroDocumental]
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


INSERT INTO [Norma35].[tblDenunciasRegistroDocumental]
           ([IDDenuncia]
           ,[Name]
           ,[ContentType]
           ,[Data])
     VALUES
           (@IDDenuncia 
           ,@Name
           ,@ContentType
           ,@Data)

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[tblDenunciasRegistroDocumental]','[Norma35].[spIDenunciasRegistroDocumental]','INSERT',@NewJSON,''
	--METODO BUSCAR PENDIENTE
END;
GO
