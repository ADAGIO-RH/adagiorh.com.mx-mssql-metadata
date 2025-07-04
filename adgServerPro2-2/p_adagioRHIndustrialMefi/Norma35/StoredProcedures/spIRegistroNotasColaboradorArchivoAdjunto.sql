USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE Norma35.spIRegistroNotasColaboradorArchivoAdjunto
	-- Add the parameters for the stored procedure here
	@IDRegistroNotasColaborador int,
    @Name varchar(50),
    @ContentType nvarchar(200),
    @Data varbinary(max),
    @Notas varchar(max),
    @IDUsuario int
AS
BEGIN
	
	DECLARE @NewJSON VARCHAR(MAX);

	INSERT INTO [Norma35].[tblRegistroNotasColaboradorArchivoAdjunto]
           ([IDRegistroNotasColaborador]
           ,[Name]
           ,[ContentType]
           ,[Data]
           ,[IDUsuario]
           ,[Notas]
           )
     VALUES
           (@IDRegistroNotasColaborador 
           ,@Name
           ,@ContentType
           ,@Data
           ,@IDUsuario
           ,@Notas)
      
	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Norma35].[tblRegistroNotasColaboradorArchivoAdjunto]','[Norma35].[spIRegistroNotasColaboradorArchivoAdjunto]','INSERT',@NewJSON,''
END
GO
