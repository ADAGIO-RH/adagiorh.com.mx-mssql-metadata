USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reclutamiento].[spIUCurriculumDigitalCandidato]
(
      @IDCurriculumDigitalCandidato int = 0 
	 ,@IDCandidato int
     ,@Name varchar(50)
     ,@ContentType nvarchar(200)
     ,@Data varbinary(max)
)
AS
BEGIN
	IF(not exists (Select top 1 1 from [Reclutamiento].[tblCurriculumDigitalCandidato] with(nolock) where IDCandidato = @IDCandidato ))
	BEGIN
		INSERT INTO [Reclutamiento].[tblCurriculumDigitalCandidato]
			   ([IDCandidato]
			   ,[Name]
			   ,[ContentType]
			   ,[Data])
		 VALUES
			   (@IDCandidato
			   ,@Name
			   ,@ContentType
			   ,@Data)
	END ELSE
	BEGIN
		UPDATE CV
		   SET [IDCandidato] = @IDCandidato
			  ,[Name] = @Name
			  ,[ContentType] = @ContentType
			  ,[Data] = @Data
		FROM [Reclutamiento].[tblCurriculumDigitalCandidato] CV
		 WHERE 
		  CV.IDCandidato = @IDCandidato
	END

END;
GO
