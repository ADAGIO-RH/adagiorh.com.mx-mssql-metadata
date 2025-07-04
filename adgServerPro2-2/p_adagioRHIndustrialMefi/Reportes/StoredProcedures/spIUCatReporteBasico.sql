USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Reportes].[spIUCatReporteBasico](
	@IDReporteBasico int = 0
	,@IDAplicacion nvarchar(200)
	,@Nombre varchar(100)
	,@Descripcion varchar(255)
	,@NombreReporte	varchar(255)
	,@ConfiguracionFiltros nvarchar(max)
	,@Grupos nvarchar(max)
	,@NombreProcedure varchar(255)
	,@Personalizado	bit
    ,@Privado bit 
	,@IDUsuario int    
) as
	declare 
		@msg varchar(max),
        @hasFiles int,
		@IDUsuarioAdmin int
	;

	select @IDUsuarioAdmin = [App].[fnGetConfiguracionGeneral]('IDUsuarioAdmin', @IDUsuario, 1)

	begin try
		if (@IDReporteBasico = 0)
		begin
			if (ISNULL(@Personalizado,0) = 0) 
			begin
				select @IDReporteBasico = max(IDReporteBasico)+1 from [Reportes].[tblCatReportesBasicos] where isnull(Personalizado,0) = 0	
			end else
			begin
				select @IDReporteBasico = max(IDReporteBasico)+1 from [Reportes].[tblCatReportesBasicos] where isnull(Personalizado,0) = 1	

				if (isnull(@IDReporteBasico,0) < 1000)
				begin
					set @IDReporteBasico = 1000
				end
			end

			insert [Reportes].[tblCatReportesBasicos](IDReporteBasico,IDAplicacion,Nombre,Descripcion,NombreReporte,ConfiguracionFiltros,Grupos,NombreProcedure,Personalizado,Privado)
			values(@IDReporteBasico,@IDAplicacion,@Nombre,@Descripcion,@NombreReporte,@ConfiguracionFiltros,@Grupos,@NombreProcedure,@Personalizado,@Privado)

			exec [Seguridad].[spIUPermisosReportesUsuarios] @IDAplicacion=@IDAplicacion,@IDReporteBasico=@IDReporteBasico,@IDUsuario=@IDUsuario,@Acceso=1,@IDUsuarioLogin=@IDUsuarioAdmin

            select  @IDReporteBasico [IDReporteBasico], @IDAplicacion [IDAplicacion] ,0 [HasFile];
		end else
		begin
			update [Reportes].[tblCatReportesBasicos]
				set 
					IDAplicacion			= @IDAplicacion
					,Nombre					= @Nombre
					,Descripcion			= @Descripcion
					,NombreReporte			= @NombreReporte
					,ConfiguracionFiltros	= @ConfiguracionFiltros
					,Grupos					= @Grupos
					,NombreProcedure		= @NombreProcedure
					,Personalizado			= @Personalizado
                    ,Privado=@Privado
			where IDReporteBasico = @IDReporteBasico

            select @hasFiles= count(*) from App.tblRespaldoReportesTRDP a where a.IDReporteBasico=@IDReporteBasico

            select  @IDReporteBasico [IDReporteBasico], @IDAplicacion [IDAplicacion] ,case when @hasFiles =0 then 0 when @hasFiles >0 then 1 end [HasFile];
		end;
	end try
	begin catch
		set @msg = ERROR_MESSAGE()

		raiserror(@msg,16,1)
	end catch
GO
