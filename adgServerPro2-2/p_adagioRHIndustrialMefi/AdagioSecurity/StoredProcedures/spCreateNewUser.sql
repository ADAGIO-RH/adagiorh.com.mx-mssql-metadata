USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crear usuarios de base de datos
** Autor			: Aneudy Abreu
** Email			: aabre@adagio.com.mx
** FechaCreacion	: 2022-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2022-06-08			Aneudy Abreu		Se agregó el parámetro @dbOwner
***************************************************************************************************/
CREATE proc [AdagioSecurity].[spCreateNewUser](
	@Login varchar(100),
	@NewUser varchar(100),
	@dbOwner bit = 0
) as

	declare 
		@script nvarchar(max) = FORMATMESSAGE(N'
			CREATE USER %s FOR LOGIN %s
			ALTER USER %s WITH DEFAULT_SCHEMA=[dbo]
		', @NewUser, @Login, @NewUser);

	EXEC sp_executesql @script 

	if (isnull(@dbOwner, 0) = 1)
	begin
		EXECUTE sp_AddRoleMember 'db_owner', @NewUser
	end else
	begin
		EXECUTE sp_AddRoleMember 'support-agent',	@NewUser
		EXECUTE sp_AddRoleMember 'db_ddladmin',		@NewUser
		EXECUTE sp_AddRoleMember 'db_datawriter',	@NewUser
		EXECUTE sp_AddRoleMember 'db_datareader',	@NewUser
	end
GO
