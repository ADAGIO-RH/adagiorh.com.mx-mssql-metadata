USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Seguridad].[spIHistorialLoginUsuario](
	@IDUsuario int
	,@ZonaHoraria varchar(70)
	,@Browser varchar(max)
	,@GeoLocation varchar(max)
	,@FechaHora datetime
	,@LoginCorrecto bit
)
as
begin
	declare @registrosAfectados int;
	declare @IDZonaHoraria int = (select id from Tzdb.Zones with(nolock) where [Name] = @ZonaHoraria)	-- por ejemplo @ZonaHoraria = 'America/Mexico_City'
    DECLARE @NewJSON Varchar(Max),
		@IDHistorialLoginUsuario int;
    begin try
		begin tran
		insert into Seguridad.tblHistorialLoginUsuario(IDUsuario, IDZonaHoraria, Browser, GeoLocation, FechaHora, LoginCorrecto)
		values(@IDUsuario, @IDZonaHoraria, @Browser, @GeoLocation, @FechaHora, @LoginCorrecto)		
		set @IDHistorialLoginUsuario = @@IDENTITY;
		set @registrosAfectados = @@ROWCOUNT;

        	select @NewJSON = (SELECT IDUsuario
                        ,IDZonaHoraria
                        ,Browser
                        ,GeoLocation
                        ,FechaHora
                        ,LoginCorrecto
                        FROM [Seguridad].[tblHistorialLoginUsuario] with(nolock)                   
                    WHERE IDUsuario = @IDUsuario and IDHistorialLoginUsuario = @IDHistorialLoginUsuario FOR JSON PATH)

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblHistorialLoginUsuario]','[Seguridad].[spIHistorialLoginUsuario]','INSERT',@NewJSON,''
		

		if @registrosAfectados = 1
			commit tran
		else
			rollback tran
	end try
	begin catch
		rollback tran
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch

end
GO
