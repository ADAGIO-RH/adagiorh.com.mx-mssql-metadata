USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [zkteco].[spCoreBorrarUserInfo](
	@dtUserInfo [zkteco].[dtUserInfo] readonly,
	@DevSN varchar(50) = null,
	@IDEmpleado int = null,
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
		Exec zkteco.spCoreBuscarEmpleadosMasterByLector @DevSN= @DevSN, @IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario
	END

	

	DELETE zkteco.tblTmpBioData		WHERE PIN IN (SELECT DISTINCT PIN FROM @dtUserInfoLocal) AND DEVSN = @DevSN
	DELETE zkteco.tblTmpFace		WHERE PIN IN (SELECT DISTINCT PIN FROM @dtUserInfoLocal) AND DEVSN = @DevSN
	DELETE zkteco.tblTmpUserPic		WHERE PIN IN (SELECT DISTINCT PIN FROM @dtUserInfoLocal) AND DEVSN = @DevSN
	DELETE zkteco.tblTmpFP			WHERE PIN IN (SELECT DISTINCT PIN FROM @dtUserInfoLocal) AND DEVSN = @DevSN
	DELETE zkteco.tblUserInfo		WHERE PIN IN (SELECT DISTINCT PIN FROM @dtUserInfoLocal) AND DEVSN = @DevSN
	

END
GO
