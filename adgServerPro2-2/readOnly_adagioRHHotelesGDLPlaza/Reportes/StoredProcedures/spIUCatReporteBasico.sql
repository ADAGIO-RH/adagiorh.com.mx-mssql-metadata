USE [readOnly_adagioRHHotelesGDLPlaza]
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
	,@IDUsuario int
) as
	declare 
		@msg varchar(max)
	;

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

			insert [Reportes].[tblCatReportesBasicos](IDReporteBasico,IDAplicacion,Nombre,Descripcion,NombreReporte,ConfiguracionFiltros,Grupos,NombreProcedure,Personalizado)
			values(@IDReporteBasico,@IDAplicacion,@Nombre,@Descripcion,@NombreReporte,@ConfiguracionFiltros,@Grupos,@NombreProcedure,@Personalizado)
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
			where IDReporteBasico = @IDReporteBasico
		end;
	end try
	begin catch
		set @msg = ERROR_MESSAGE()

		raiserror(@msg,16,1)
	end catch
GO
