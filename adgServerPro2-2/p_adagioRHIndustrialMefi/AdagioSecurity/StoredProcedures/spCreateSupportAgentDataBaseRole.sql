USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [AdagioSecurity].spCreateSupportAgentDataBaseRole as
	declare @ROLE_NAME_SUPPORT_AGENT varchar(50) = 'support-agent'

	if not exists (
		SELECT *
		FROM sys.database_principals
		WHERE type = 'R' -- 'R' indica un rol
		AND name = @ROLE_NAME_SUPPORT_AGENT
	) 
	begin
		CREATE ROLE [support-agent]

		DENY ALTER					ON SCHEMA::[AdagioSecurity] TO [support-agent]
		DENY CONTROL				ON SCHEMA::[AdagioSecurity] TO [support-agent]
		DENY CREATE SEQUENCE		ON SCHEMA::[AdagioSecurity] TO [support-agent]
		DENY DELETE					ON SCHEMA::[AdagioSecurity] TO [support-agent]
		DENY EXECUTE				ON SCHEMA::[AdagioSecurity] TO [support-agent]
		DENY INSERT					ON SCHEMA::[AdagioSecurity] TO [support-agent]
		DENY REFERENCES				ON SCHEMA::[AdagioSecurity] TO [support-agent]
		DENY SELECT					ON SCHEMA::[AdagioSecurity] TO [support-agent]
		DENY TAKE OWNERSHIP			ON SCHEMA::[AdagioSecurity] TO [support-agent]
		DENY UPDATE					ON SCHEMA::[AdagioSecurity] TO [support-agent]
		DENY VIEW CHANGE TRACKING	ON SCHEMA::[AdagioSecurity] TO [support-agent]
		DENY VIEW DEFINITION		ON SCHEMA::[AdagioSecurity] TO [support-agent]
		DENY UPDATE ON [Seguridad].[tblUsuarios] ([Password], [IDPerfil]) TO [support-agent]
	
		GRANT EXECUTE TO [support-agent];
	end else 
	begin
		if not exists(   
			SELECT *
			FROM sys.database_permissions dp
				INNER JOIN sys.database_principals dp_role ON dp.grantee_principal_id = dp_role.principal_id
			WHERE dp.permission_name = 'EXECUTE'
				AND dp_role.name = @ROLE_NAME_SUPPORT_AGENT
				AND dp.class_desc = 'DATABASE'
				AND dp.state = 'G'
		)
		begin
			GRANT EXECUTE TO [support-agent];
		end
	end
GO
