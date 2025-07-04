USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [zkteco].[spCoreCreateSchedulerQueryUsersDataZKTECO](
	@DevSN varchar(50),
	@dtUserInfo [zkteco].[dtUserInfo] readonly,
	@IDUsuario int
)
AS
BEGIN
	Declare @dtUserInfoLocal [zkteco].[dtUserInfo]
	IF((Select count(*) from @dtUserInfo) > 0)
	BEGIN
		insert into @dtUserInfoLocal
		select * from @dtUserInfo
	END
	ELSE
	BEGIN
		Insert into @dtUserInfoLocal
		Exec zkteco.spCoreBuscarEmpleadosMasterByLector @DevSN= @DevSN, @IDUsuario = @IDUsuario
	END


	--DECLARE @StartRow INT = 1;
	--DECLARE @EndRow INT = 10;

	--WHILE @StartRow <= (SELECT MAX(RowNumber) FROM (SELECT ROW_NUMBER() OVER (ORDER BY PIN) AS RowNumber, PIN
	--															FROM @dtUserInfoLocal
	--															WHERE (ISNULL(NewUser, 0) = 1)
	--															OR (ISNULL(Face, 0) = 0 AND ISNULL(FaceMaster, 0) > 0)
	--															OR (ISNULL(FP, 0) = 0 AND ISNULL(FPMaster, 0) > 0)
	--															OR (ISNULL(BioData, 0) = 0 AND ISNULL(BioDataMaster, 0) > 0)
	--															OR (isnull(UserPasswd, 0) = 0  and ISNULL(UserPasswdMaster, 0) > 0)
	--															OR (isnull(UserIDCard, 0) = 0  and ISNULL(UserIDCardMaster, 0) > 0)
	--															) AS Temp)
	--BEGIN
		DECLARE @PINs VARCHAR(MAX);
    
		SELECT @PINs = STUFF((
			SELECT ',' + PIN
			FROM (SELECT distinct PIN
					FROM @dtUserInfoLocal
					WHERE (ISNULL(NewUser, 0) = 1)
					OR (ISNULL(Face, 0) = 0 AND ISNULL(FaceMaster, 0) > 0)
					OR (ISNULL(FP, 0) = 0 AND ISNULL(FPMaster, 0) > 0)
					OR (ISNULL(BioData, 0) = 0 AND ISNULL(BioDataMaster, 0) > 0)
					OR (isnull(UserPasswd, 0) = 0  and ISNULL(UserPasswdMaster, 0) > 0)
					OR (isnull(UserIDCard, 0) = 0  and ISNULL(UserIDCardMaster, 0) > 0)
					) AS Temp
			--WHERE RowNumber BETWEEN @StartRow AND @EndRow
			FOR XML PATH('')), 1, 1, '');

		
		-- Llamada al stored procedure
		if (isnull(@PINs, '') != '')
		begin
			exec [Scheduler].[spSchedulerQueryUsersDataZKTECO] 
				@DevSN=@DevSN
				,@PINs=@PINs
		end
	--	SET @StartRow = @EndRow + 1;
	--	SET @EndRow = @StartRow + 9;
	--END

END
GO
