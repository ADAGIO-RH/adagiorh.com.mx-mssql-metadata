USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [AdagioSecurity].spCreateSupportAgentDataBaseRole as


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
GO
